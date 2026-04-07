--!strict
--@author vynx777
--@version 1.0.0
--@description A strictly-typed networking package that facilitates seamless Server and Client communication.

-- Services:
local RunService = game:GetService("RunService")

-- Packages:
local Promise = require(script.Parent.Promise)

-- Utils:
local Utils = script.utils
local Types = require(script.Types)
local GetRemotesFolder = require(Utils.GetRemotesFolder)
local GetNamespaceFolder = require(Utils.GetNamespaceFolder)
local GetEvents = require(Utils.GetEvents)

-- Types:
type NetworkerModule = {
	set: (namespace: string) -> Networker,
}

-- Variables:
local remotesFolder: Folder = GetRemotesFolder()
local _networkers = {}

-- Structure:
--[=[
    @class Networker
    
    A strictly-typed, action-based networking framework for Roblox.
    Handles Client-Server communication safely with built-in timeouts, retries, and strict type checking.
]=]
local Networker = {}
Networker.__index = Networker
export type Networker = typeof(setmetatable({} :: Types.Network, Networker))

-- Constructor:
--[=[
    Initializes a new Network namespace. If one already exists, it returns the cached instance.
    
    @param namespace string -- The unique identifier for this network channel.
    @return Networker -- The networker instance.
]=]
function Networker.set(namespace: string): Networker
	local self = setmetatable({}, Networker)

	self.Namespace = namespace
	self.Folder = nil
	self.Event = nil
	self.Function = nil
	self._dispatch = {}

	if _networkers[namespace] then
		warn(`[Networker] Network with Namespace {namespace} already exists`)
		return _networkers[namespace]
	end

	self:_init()
	_networkers[namespace] = self

	return self
end

-- Initialization:
--[=[
    Initializes the internal structure of the class. Instantiates the namespace folder and required remote objects.
    @private
]=]
function Networker._init(self: Networker)
	local namespaceFolder: Folder = GetNamespaceFolder(self.Namespace, remotesFolder)
	local remoteEvent: RemoteEvent, remoteFunction: RemoteFunction = GetEvents(namespaceFolder)

	self.Folder = namespaceFolder
	self.Event, self.Function = remoteEvent, remoteFunction

	self:_connectEvents(remoteEvent, remoteFunction)
end

--[=[
    Connects internal event listeners to the RemoteEvent and RemoteFunction.
    @private
    @param remoteEvent RemoteEvent
    @param remoteFunction RemoteFunction
]=]
function Networker._connectEvents(self: Networker, remoteEvent: RemoteEvent, remoteFunction: RemoteFunction)
	if RunService:IsServer() then
		local dispatchServer: Types.DispatchServerFn = self._dispatch :: any

		remoteEvent.OnServerEvent:Connect(function(player: Player, actionName: string, data: any?)
			if dispatchServer[actionName] then
				dispatchServer[actionName](player, data)
			end
		end)

		remoteFunction.OnServerInvoke = function(player: Player, actionName: string, data: any?)
			if dispatchServer[actionName] then
				return dispatchServer[actionName](player, data)
			end
			return
		end
	else
		local dispatchClient: Types.DispatchClientFn = self._dispatch :: any

		remoteEvent.OnClientEvent:Connect(function(actionName: string, data: any?)
			if dispatchClient[actionName] then
				dispatchClient[actionName](data)
			end
		end)
	end
end

-- Functionality:
-- Client:
--[=[
    Dispatches a one-way event to the server. Does not yield or wait for a response.

    @client
    @param actionName string -- The action to trigger on the server.
    @param payload Types.NetworkPayload? -- Optional data and configuration options.
]=]
function Networker.send(self: Networker, actionName: string, payload: Types.NetworkPayload?)
	if RunService:IsServer() then
		return
	end

	local p: Types.NetworkPayload = payload or {}
	local data: any = p.data or {}
	local options: Types.NetworkOptions = p.options or {}

	local success, err = pcall(function()
		if typeof(self.Event) == "Instance" and self.Event:IsA("RemoteEvent") then
			self.Event:FireServer(actionName, data)
		end
	end)

	if not success then
		error(`[Networker] Error in '{self.Namespace}:{actionName}' action. ERROR: {err}`)
	end

	if options.debug then
		warn(`[Networker] Sent data successfully to {self.Namespace} as {actionName} action`)
	end
end

--[=[
    Yields the current thread to request data from the server. Automatically handles timeouts, retries, and optional Promise wrapping.

    @client
    @yields
    @param actionName string -- The action to request from the server.
    @param payload Types.NetworkPayload? -- Optional data, retries, timeout, and Promise configuration.
    @return Promise | any? -- Returns a Promise if `usePromise` is true, otherwise returns the raw data.
]=]
function Networker.request(self: Networker, actionName: string, payload: Types.NetworkPayload?): any?
	if RunService:IsServer() then
		return
	end

	if typeof(self.Function) ~= "Instance" then
		return
	end

	local p: Types.NetworkPayload = payload or {}
	local data: any = p.data
	local options: Types.NetworkOptions = p.options or {}

	local retry: number = options.retry or 0
	local timeout: number = options.timeout or 10
	local debug: boolean = options.debug or false
	local usePromise: boolean = options.usePromise or false

	local function executeRequest()
		local attempts: number = 0
		local successRequest: boolean = false
		local result: any = nil

		while attempts <= retry do
			attempts += 1

			local invokeThread = task.spawn(function()
				local success, output = pcall(function()
					return self.Function:InvokeServer(actionName, data)
				end)
				successRequest = success
				result = output
			end)

			local elapsed: number = 0
			while coroutine.status(invokeThread) ~= "dead" and elapsed < timeout do
				task.wait(0.1)
				elapsed += 0.1

				if debug == true and math.round(elapsed * 10) % 10 == 0 then
					warn(`[Networker] '{actionName}' timeout in {math.round(timeout - elapsed)}s`)
				end
			end

			if coroutine.status(invokeThread) ~= "dead" then
				task.cancel(invokeThread)
				successRequest = false
				result = `Timeout reached after {attempts} attempts`
			end

			if successRequest then
				break
			end

			if attempts <= retry then
				warn(`[Networker] '{actionName}' failed. Retrying... ({attempts}/{retry})`)
				task.wait(1)
			end
		end

		return successRequest, result
	end

	if usePromise then
		return Promise.new(function(resolve, reject)
			task.spawn(function()
				local success, output = executeRequest()

				if success then
					if debug then
						warn(`[Networker] Sent request successfully to {self.Namespace} as {actionName}`)
					end
					resolve(output)
				else
					reject(output)
				end
			end)
		end)
	end

	local success, result = executeRequest()

	if not success then
		error(`[Networker] Error in action '{self.Namespace}:{actionName}' ERROR: {result}`)
	end

	if options.debug then
		warn(`[Networker] Sent request successfully to {self.Namespace} as {actionName}`)
	end

	return result
end

--[=[
    Registers a callback to listen for incoming one-way events from the server.

    @client
    @param actionName string -- The action to listen for.
    @param fn (data: any?) -> any? -- The callback function to execute when the event is received.
]=]
function Networker.listen(self: Networker, actionName: string, fn: (data: any?) -> any?)
	if RunService:IsServer() then
		return
	end

	self._dispatch[actionName] = function(data: any?): any?
		local result = fn(data)
		if result ~= nil then
			return result
		end
		return nil
	end
end

-- Server:
--[=[
    Pushes data to a specific recipient, a list of recipients, or broadcasts to "all" clients. Does not yield.

    @server
    @param actionName string -- The action to trigger on the client(s).
    @param recipient Types.Recipient -- The target Player, array of Players, or "all".
    @param payload Types.NetworkPayload? -- Optional data and configuration options.
]=]
function Networker.push(self: Networker, actionName: string, recipient: Types.Recipient, payload: Types.NetworkPayload?)
	if not RunService:IsServer() then
		return
	end

	if not self.Event then
		return
	end

	local p: Types.NetworkPayload = payload or {}
	local data: any = p.data or {}
	local options: Types.NetworkOptions = p.options or {}

	local success, err = pcall(function()
		if typeof(recipient) == "string" and recipient == "all" then
			self.Event:FireAllClients(actionName, data)
		elseif typeof(recipient) == "table" then
			for _, player in recipient do
				if typeof(player) == "Instance" and player:IsA("Player") then
					self.Event:FireClient(player, actionName, data)
				end
			end
		elseif typeof(recipient) == "Instance" and recipient:IsA("Player") then
			self.Event:FireClient(recipient, actionName, data)
		end
	end)

	if not success then
		error(`[Networker] Error in '{self.Namespace}:{actionName}' action. ERROR: {err}`)
	end

	if options.debug then
		warn(`[Networker] Sent data successfully to {self.Namespace} as {actionName} action`)
	end
end

--[=[
    Registers a callback to handle incoming requests or events from a client.

    @server
    @param actionName string -- The action to handle.
    @param fn (player: Player, data: any?) -> any? -- The callback function to execute. Returns data back to the client if invoked via request.
]=]
function Networker.on(self: Networker, actionName: string, fn: (player: Player, data: any?) -> any?)
	if not RunService:IsServer() then
		return
	end

	self._dispatch[actionName] = function(player: Player, data: any): any?
		local result = fn(player, data)
		if result ~= nil then
			return result
		end
		return nil
	end
end

return Networker :: NetworkerModule
