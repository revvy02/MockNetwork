# MockNetwork
<div align="center">
	<h1>MockNetwork</h1>
	<p>Roblox testing library that replicates networking behavior</p>
	<a href="https://revvy02.github.io/MockNetwork/"><strong>View docs</strong></a>
</div>
<!--moonwave-hide-before-this-line-->

## Usage
MockNetwork is designed for writing tests for things that have side effects across a network.
Examples include things like a networking library, or a player DataStore replication library.

## Install using Package Manager
[MockNetwork can be installed as a package from Wally](https://wally.run/package/revvy02/mocknetwork)

## Roblox Remote Behavior
MockNetwork serves to replicate specific behavior of Roblox's RemoteEvent and RemoteFunction instances such as the following:

*Queueing*\
Firing a remote will queue the request on the receiving side until a handler is set or a connection is made

*Mutates Instance Keys in Tables*\
Passing a table that has an instances as keys will result in the keys being converted to strings

## Examples
*Using the Server class*\
Can be used if you want to test behavior for multiple different clients

```lua
local server = MockNetwork.Server.new({"user1", "user2"})
local user1, user2 = server:getClient("user1"), server:getClient("user2")
local serverRemoteEvent = server:createRemoteEvent("replicateData")

local user1RemoteEvent = user1:getRemoteEvent("replicateData")
local user2RemoteEvent = user2:getRemoteEvent("replicateData")

serverRemoteEvent:FireClient(user1, "Hello user1!")
serverRemoteEvent:FireClient(user2, "Hello user2!")

-- also demonstrates queueing behavior of remotes

expect(user1RemoteEvent.OnClientEvent:Wait()).to.equal("Hello user1!")
expect(user1RemoteEvent.OnClientEvent:Wait()).to.equal("Hello user2!")
```

*Using MockRemoteEvent*\
Can be used if you want to just test behavior for a single client

```lua
local mockRemoteEvent = MockNetwork.MockRemoteEvent.new("user")

mockRemoteEvent:FireClient("user", "Hello user!")

expect(mockRemoteEvent.OnClientEvent:Wait()).to.equal("Hello user!")
```

*Using MockRemoteFunction*\
Can be used if you want to just test behavior for a single client

```lua
local mockRemoteFunction = MockNetwork.MockRemoteFunction.new("user")
local response

task.spawn(function()
	mockRemoteFunction:InvokeClient("user", 1)
end)

mockRemoteFunction.OnClientInvoke = function(num)
	return num * 2
end

expect(response).to.equal(2)
```