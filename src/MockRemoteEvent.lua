local TrueSignal = require(script.Parent.Parent.TrueSignal)

local prepArgs = require(script.Parent.prepArgs)

--[=[
    MockRemoteEvent class

    @class MockRemoteEvent
]=]
local MockRemoteEvent = {}
MockRemoteEvent.__index = MockRemoteEvent

--[=[
    Constructs a new MockRemoteEvent object.

    @param client string
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
    self.OnClientEvent = TrueSignal.new(false, true)
    
    --[=[
        Signal property to listen to received data on server

        @prop OnServerEvent Signal
        @within MockRemoteEvent
        @readonly
    ]=]
    self.OnServerEvent = TrueSignal.new(false, true)

    return self
end

--[=[
    Fires OnServerEvent with the client and passed arguments

    @param ... any
]=]
function MockRemoteEvent:fireServer(...)
    self.OnServerEvent:fire(self._client, prepArgs(...))
end

--[=[
    Fires OnClientEvent with the passed arguments

    @param client string
    @param ... any
]=]
function MockRemoteEvent:fireClient(client, ...)
    assert(client == self._client, "Invalid client passed")

    self.OnClientEvent:fire(prepArgs(...))
end

--[=[
    Fires OnClientEvent with the passed arguments

    @param ... any
]=]
function MockRemoteEvent:fireAllClients(...)
    self.OnClientEvent:fire(prepArgs(...))
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

--[=[
    PascalCase alias for fireServer

    @param ... any

    @method FireServer
    @within MockRemoteEvent
]=]
MockRemoteEvent.FireServer = MockRemoteEvent.fireServer

--[=[
    PascalCase alias for fireClient

    @param client string
    @param ... any

    @method FireClient
    @within MockRemoteEvent
]=]
MockRemoteEvent.FireClient = MockRemoteEvent.fireClient

--[=[
    PascalCase alias for fireAllClients

    @param ... any

    @method FireAllClients
    @within MockRemoteEvent
]=]
MockRemoteEvent.FireAllClients = MockRemoteEvent.fireAllClients

--[=[
    PascalCase alias for destroy

    @method Destroy
    @within MockRemoteEvent
]=]
MockRemoteEvent.Destroy = MockRemoteEvent.destroy

return MockRemoteEvent