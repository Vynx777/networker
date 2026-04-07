--!strict

-- Types:
--[=[
    @interface Network
    @within Networker
    .Namespace string -- The unique identifier for this network channel.
    .Folder Folder? -- The folder containing the RemoteEvent and RemoteFunction.
    .Event RemoteEvent? -- The RemoteEvent used for one-way communication.
    .Function RemoteFunction? -- The RemoteFunction used for two-way (request/response) communication.
    ._dispatch DispatchClientFn | DispatchServerFn -- Internal dictionary for routing incoming actions.
]=]
export type Network = {
	Namespace: string,
	Folder: Folder?,
	Event: RemoteEvent?,
	Function: RemoteFunction?,
	_dispatch: DispatchClientFn | DispatchServerFn,
}

--[=[
    @type DispatchServerFn { [string]: (player: Player, data: any?) -> any? }
    @within Networker
    A dictionary mapping action names to server-side callback functions.
]=]
export type DispatchServerFn = { [string]: (player: Player, data: any?) -> any? }

--[=[
    @type DispatchClientFn { [string]: (data: any?) -> any? }
    @within Networker
    A dictionary mapping action names to client-side callback functions.
]=]
export type DispatchClientFn = { [string]: (data: any?) -> any? }

--[=[
    @type Recipient Player | { Player } | "all"
    @within Networker
    Defines the target(s) for a server-to-client push. Can be a single Player, an array of Players, or the string "all" to broadcast to everyone.
]=]
export type Recipient = Player | { Player } | "all"

--[=[
    @interface NetworkPayload
    @within Networker
    .data any? -- The actual data to send across the network.
    .options NetworkOptions? -- Optional configuration for how the request should be handled.
]=]
export type NetworkPayload = {
	data: any?,
	options: NetworkOptions?,
}

--[=[
    @interface NetworkOptions
    @within Networker
    .debug boolean? -- If true, prints warning and success messages to the output for debugging.
    .timeout number? -- The maximum time (in seconds) to wait for a response before cancelling.
    .retry number? -- The number of times to retry a failed request.
    .usePromise boolean? -- If true, the request will immediately return a Promise instead of yielding the thread.
]=]
export type NetworkOptions = {
	debug: boolean?,
	timeout: number?,
	retry: number?,
	usePromise: boolean?,
}

return {}
