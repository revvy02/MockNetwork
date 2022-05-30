local Slick = require(script.Parent.Parent.Slick)

--[=[
    MockRemoteEvent class

    @class MockRemoteEvent
]=]
local MockRemoteEvent = {}
MockRemoteEvent.__index = MockRemoteEvent

--[=[
    Constructs a new MockRemoteEvent object.

    @param client any
    @return MockRemoteEvent
]=]
function MockRemoteEvent.new(client)
    local self = setmetatable({}, MockRemoteEvent)

    self._client = client

    --[=[
        Signal property to listen to received data on client

        @prop OnClientEvent Signal
        @within MockRemoteEvent
        @readonly
    ]=]
    self.OnClientEvent = Slick.Signal.new()
    self.OnClientEvent:enableQueueing()
    
    --[=[
        Signal property to listen to received data on server

        @prop OnServerEvent Signal
        @within MockRemoteEvent
        @readonly
    ]=]
    self.OnServerEvent = Slick.Signal.new()
    self.OnServerEvent:enableQueueing()

    return self
end

--[=[
    Fires OnServerEvent with the client and passed arguments

    @param ... any
]=]
function MockRemoteEvent:fireServer(...)
    self.OnServerEvent:fire(self._client, ...)
end

--[=[
    Fires OnClientEvent with the passed arguments

    @param client any
    @param ... any
]=]
function MockRemoteEvent:fireClient(client, ...)
    assert(client == self._client, "Invalid client passed")

    self.OnClientEvent:fire(...)
end

--[=[
    Fires OnClientEvent with the passed arguments

    @param ... any
]=]
function MockRemoteEvent:fireAllClients(...)
    self.OnClientEvent:fire(...)
end

--[=[
    Returns the client passed in the constructor

    @return any
]=]
function MockRemoteEvent:getClient()
    return self._client
end

--[=[
    Prepares the MockRemoteEvent instance for garbage collection
]=]
function MockRemoteEvent:destroy()
    self.OnClientEvent:destroy()
    self.OnServerEvent:destroy()

    self.destroyed = true
end

MockRemoteEvent.FireServer = MockRemoteEvent.fireServer
MockRemoteEvent.FireClient = MockRemoteEvent.fireClient
MockRemoteEvent.Destroy = MockRemoteEvent.destroy

return MockRemoteEvent