local Slick = require(script.Parent.Parent.Slick)

--[=[
    RemoteFunctionServer class

    @class RemoteFunctionServer
]=]
local RemoteFunctionServer = {}

RemoteFunctionServer.__index = RemoteFunctionServer

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
    
    local signal = Slick.Signal.new()
    signal.args = table.pack(client, ...)

    table.insert(self._signals, signal)
    
    return signal:wait()
end

--[=[
    Called by Server to clean up
    
    @private
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
    Returns whether the passed argument is a RemoteFunctionServer

    @param obj any
    @return boolean
]=]
function RemoteFunctionServer.is(obj)
    return typeof(obj) == "table" and getmetatable(obj) == RemoteFunctionServer
end

--[=[
    Sends a request to the client and yields until it responds

    @param client Client
    @param ... any
    @return any
]=]
function RemoteFunctionServer:invokeClient(client, ...)
    return client:getRemoteFunction(self.name):_invokeClient(...)
end

RemoteFunctionServer.InvokeServer = RemoteFunctionServer.invokeServer
RemoteFunctionServer.Destroy = RemoteFunctionServer.destroy

return RemoteFunctionServer