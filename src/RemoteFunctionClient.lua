local TrueSignal = require(script.Parent.Parent.TrueSignal)

local prepArgs = require(script.Parent.prepArgs)

--[=[
    RemoteFunctionClient class

    @class RemoteFunctionClient
]=]
local RemoteFunctionClient = {}

RemoteFunctionClient.__index = function(self, key)
    return rawget(RemoteFunctionClient, key) or rawget(self, key) or self._internal[key]
end


RemoteFunctionClient.__newindex = function(self, key, fn)
    if key == "OnClientInvoke" then
        self._internal.OnClientInvoke = fn

        for _, signal in pairs(self._signals) do
            signal:fire(fn(table.unpack(signal.args)))
            signal:destroy()
        end
        
        table.clear(self._signals)
    end
end

--[=[
    Constructs a new RemoteFunctionClient object

    @param name string
    @param server Server
    @param client Client
    @return RemoteFunctionClient

    @private
]=]
function RemoteFunctionClient._new(name, server, client)
    local self = {}

    self.name = name
    self.destroyed = false
    
    self._server = server
    self._client = client
    
    self._internal = {}
    self._signals = {}

    self._client._remoteFunctions[name] = self

    return setmetatable(self, RemoteFunctionClient)
end

--[=[
    Called by RemoteFunctionServer to invoke the client

    @param ... any
    @return any
    
    @private
]=]
function RemoteFunctionClient:_invokeClient(...)
    if self._internal.OnClientInvoke then
        return self._internal.OnClientInvoke(prepArgs(...))
    end

    local signal = TrueSignal.new()
    signal.args = table.pack(prepArgs(...))

    table.insert(self._signals, signal)

    return signal:wait()
end

--[=[
    Called by RemoteFunctionServer to clean up

    @private
]=]
function RemoteFunctionClient:_destroy()
    self._client._remoteFunctions[self.name] = nil

    for _, signal in pairs(self._signals) do
        signal:destroy()
    end

    self.destroyed = true
end

--[=[
    Sends a request to the server and yields until it receives a response

    @param ... any
    @return any
]=]
function RemoteFunctionClient:invokeServer(...)
    return self._server:getRemoteFunction(self.name):_invokeServer(self._client, ...)
end

--[=[
    PascalCase alias for invokeServer

    @param ... any
    @return any

    @yields

    @method InvokeServer
    @within RemoteFunctionClient
]=]
RemoteFunctionClient.InvokeServer = RemoteFunctionClient.invokeServer

return RemoteFunctionClient