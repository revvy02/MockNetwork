local TrueSignal = require(script.Parent.Parent.TrueSignal)

local prepArgs = require(script.Parent.prepArgs)

--[=[
    MockRemoteFunction class

    @class MockRemoteFunction
]=]
local MockRemoteFunction = {}

MockRemoteFunction.__index = function(self, key)
    return rawget(MockRemoteFunction, key) or rawget(self, key) or self._internal[key]
end

MockRemoteFunction.__newindex = function(self, key, fn)
    if key == "OnClientInvoke" then
        self._internal.OnClientInvoke = fn
        
        for _, signal in pairs(self._clientSignals) do
            signal:fire(fn(table.unpack(signal.args)))
            signal:destroy()
        end

        table.clear(self._clientSignals)
    elseif key == "OnServerInvoke" then
        self._internal.OnServerInvoke = fn

        for _, signal in pairs(self._serverSignals) do
            signal:fire(fn(self._client, table.unpack(signal.args)))
            signal:destroy()
        end

        table.clear(self._serverSignals)
    end
end

--[=[
    Constructs a new MockRemoteFunction object.

    @param client string
    @return MockRemoteEvent
]=]
function MockRemoteFunction.new(client)
    local self = {}

    --[=[
        Callback property to handle requests on client

        @prop OnClientInvoke function
        @within MockRemoteFunction
    ]=]

    --[=[
        Callback property to handle requests on server

        @prop OnServerInvoke function
        @within MockRemoteFunction
    ]=]
    self.destroyed = false
    self._client = client

    self._internal = {}
    self._clientSignals = {}
    self._serverSignals = {}

    setmetatable(self, MockRemoteFunction)

    return self
end

--[=[
    Sends a request to the server and yields until a response is received

    @param ... any
    @return any

    @yields
]=]
function MockRemoteFunction:invokeServer(...)
    if self._internal.OnServerInvoke then
        return self._internal.OnServerInvoke(self._client, prepArgs(...))
    end

    local signal = TrueSignal.new()
    signal.args = table.pack(prepArgs(...))

    table.insert(self._serverSignals, signal)

    return signal:wait()
end

--[=[
    Sends a request to the client and yields until a response is received

    @param client string
    @param ... any
    @return any

    @yields
]=]
function MockRemoteFunction:invokeClient(client, ...)
    assert(client == self._client, "Invalid client passed")

    if self._internal.OnClientInvoke then
        return self._internal.OnClientInvoke(prepArgs(...))
    end

    local signal = TrueSignal.new()
    signal.args = table.pack(prepArgs(...))

    table.insert(self._clientSignals, signal)

    return signal:wait()
end

--[=[
    Gets the passed client argument in the constructor

    @return any
]=]
function MockRemoteFunction:getClient()
    return self._client
end

--[=[
    Prepares the MockRemoteFunction for garbage collection
]=]
function MockRemoteFunction:destroy()
    for _, signal in pairs(self._clientSignals) do
        signal:destroy()
    end

    for _, signal in pairs(self._serverSignals) do
        signal:destroy()
    end

    self.destroyed = true
end

--[=[
    PascalCase alias for invokeServer

    @param ... any
    @return any

    @yields

    @method InvokeServer
    @within MockRemoteFunction
]=]
MockRemoteFunction.InvokeServer = MockRemoteFunction.invokeServer

--[=[
    PascalCase alias for invokeClient

    @param client string
    @param ... any
    @return any

    @yields

    @method InvokeClient
    @within MockRemoteFunction
]=]
MockRemoteFunction.InvokeClient = MockRemoteFunction.invokeClient

--[=[
    PascalCase alias for destroy

    @method Destroy
    @within MockRemoteFunction
]=]
MockRemoteFunction.Destroy = MockRemoteFunction.destroy

return MockRemoteFunction
