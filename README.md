# 📡 Networker

[![Wally](https://img.shields.io/badge/Wally-1.0.7-blue)](https://wally.run/)
[![Luau](https://img.shields.io/badge/Luau-Strict-orange)](https://luau-lang.org/)
[![Docs](https://img.shields.io/badge/Docs-Moonwave-purple)](https://vynx777.github.io/networker/)
[![License](https://img.shields.io/badge/License-MIT-green)](https://github.com/vynx777/networker/blob/main/LICENSE)

**Networker** is a strictly typed (Strict Luau), action-based networking framework for the Roblox platform. It provides secure Client-Server communication with built-in support for Promises, timeouts, and automatic retry attempts.

> 📖 **[Read the official Documentation & API Reference here!](https://vynx777.github.io/networker/)**

---

## ✨ Key Features

* **🔒 Strict Typing:** Full Luau Linter support – eliminate errors caused by action name typos.
* **⏳ Timeout & Retry:** Intelligent request retry system and time limits (configurable for each individual request).
* **📦 Promise Support:** Native integration with `evaera/promise` (non-blocking asynchronous logic).
* **🛠 Action-Based:** Logic organized into "actions" within readable Namespaces.
* **📖 Moonwave Ready:** Professional documentation automatically generated from inline code comments.

---

## ⚙️ Installation

Add Networker to your `wally.toml` file:

```toml
[dependencies]
Networker = "vynx777/networker@1.0.7"
```

Then, install the package:
```bash
wally install
```

---

## 🚀 Quick Start

### 🖥️ Server Side

```lua
local Networker = require(game.ReplicatedStorage.Packages.Networker)
local PlayerNet = Networker.set("PlayerData")

-- Listening for actions (One-Way)
PlayerNet:on("UpdateBio", function(player, data)
    print(player.Name .. " changed bio to: " .. data.text)
end)

-- Handling requests (Request-Response)
PlayerNet:on("GetStats", function(player)
    return { Level = 10, Gold = 500 }
end)
```

### 🕹️ Client Side

```lua
local Networker = require(game.ReplicatedStorage.Packages.Networker)
local PlayerNet = Networker.set("PlayerData")

-- 1. Simple dispatch
PlayerNet:send("UpdateBio", { data = { text = "Hello!" } })

-- 2. Request using Promises
PlayerNet:request("GetStats", { options = { usePromise = true } })
    :andThen(function(stats)
        print("Level: " .. stats.Level)
    end)
    :catch(warn)

-- 3. Synchronous request (Yielding)
local stats = PlayerNet:request("GetStats", { options = { timeout = 5 } })
```

---

## 📚 API Documentation

Networker features comprehensive documentation generated using Moonwave. 

**👉 [Visit the Networker Documentation](https://vynx777.github.io/networker/)** for the full API reference, advanced guides, and exact type definitions.

*(For contributors: If you are making changes to the source code and want to preview the documentation locally, run `moonwave dev` in the root directory).*

---

## 📜 License

This project is distributed under the **MIT** license. See the `LICENSE` file for details.
