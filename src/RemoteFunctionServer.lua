local TrueSignal = require(script.Parent.Parent.TrueSignal)

local prepArgs = require(script.Parent.prepArgs)

--[=[
    RemoteFunctionServer class

    @class RemoteFunctionServer
]=]
local RemoteFunctionServer = {}

RemoteFunctionServer.__index = function(self, key)
    return rawget(RemoteFunctionServer, key) or rawget(self, key) or self._internal[key]
end

RemoteFunctionServer.__newindex = function(self, key, fn)
    if key == "OnServerInvoke" then
        self._internal.OnServerInvoke = fn

        for _, signal in pairs(self._signals) do
            signal:fire(fn(table.unpack(signal.args)))
            signal:destroy()
        end
            
        table.clear(self._signals)
    end
end

--[=[
    Constructs a new RemoteFunctionServer object

    @param name string
    @param server Server
    @return RemoteFunctionServer

    @private
]=]
function RemoteFunctionServer._new(name, server)
    local self = {}

    self.name = name
    self.destroyed = false
    
    self._server = server
    
    self._internal = {}
    self._signals = {}

    self._server._remoteFunctions[name] = self

    return setmetatable(self, RemoteFunctionServer)
end

--[=[
    Called by RemoteFunctionClient to invoke the server

    @param client Client
    @param ... any
    @return any
    
    @private
]=]
function RemoteFunctionServer:_invokeServer(client, ...)
    if self._internal.OnServerInvoke then
        return self._internal.OnServerInvoke(client, ...)
    end
    
    local signal = TrueSignal.new()
    signal.args = table.pack(client, prepArgs(...))

    table.insert(self._signals, signal)
    
    return signal:wait()
end

--[=[
    Called by Server to clean up
]=]
function RemoteFunctionServer:destroy()
    self._server._remoteFunctions[self.name] = nil

    for _, client in pairs(self._server._clients) do
        client:getRemoteFunction(self.name):_destroy()
    end

    for _, signal in pairs(self._signals) do
        signal:destroy()
    end

    self.destroyed = true
end

--[=[
    Sends a request to the client and yields until it responds

    @param client Client
    @param ... any
    @return any

    @yields
]=]
function RemoteFunctionServer:invokeClient(client, ...)
    return client:getRemoteFunction(self.name):_invokeClient(prepArgs(...))
end

--[=[
    PascalCase alias for invokeClient

    @param client Client
    @param ... any
    @return any

    @yields

    @method InvokeClient
    @within RemoteFunctionServer
]=]
RemoteFunctionServer.InvokeClient = RemoteFunctionServer.invokeClient

--[=[
    PascalCase alias for destroy

    @method Destroy
    @within RemoteFunctionServer
]=]
RemoteFunctionServer.Destroy = RemoteFunctionServer.destroy

return RemoteFunctionServer