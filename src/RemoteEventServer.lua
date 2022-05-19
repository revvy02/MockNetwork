local Slick = require(script.Parent.Parent.Slick)

--[=[
    RemoteEventServer class

    @class RemoteEventServer
]=]
local RemoteEventServer = {}
RemoteEventServer.__index = RemoteEventServer

--[=[
    Constructs a new RemoteEventServer object

    @param name string
    @param server Server
    @return RemoteEventServer

    @private
]=]
function RemoteEventServer._new(name, server)
    local self = setmetatable({}, RemoteEventServer)

    self.name = name
    self._server = server

    self.OnServerEvent = Slick.Signal.new()
    self.OnServerEvent:enableQueueing()
    
    self._server._remoteEvents[name] = self

    return self
end

--[=[
    Called by RemoteEventClient to fire the server

    @param client Client
    @param ... any
    
    @private
]=]
function RemoteEventServer:_fireServer(client, ...)
    self.OnServerEvent:fire(client, ...)
end

--[=[
    Prepares RemoteEventServer for garbage  collection
]=]
function RemoteEventServer:destroy()
    self._server._remoteEvents[self.name] = nil
    
    for _, client in pairs(self._server._clients) do
        client:getRemoteEvent(self.name):_destroy()
    end
    
    self.OnServerEvent:destroy()
    self.destroyed = true
end

--[=[
    Returns whether the passed argument is a RemoteEventServer

    @param obj any
    @return boolean
]=]
function RemoteEventServer.is(obj)
    return typeof(obj) == "table" and getmetatable(obj) == RemoteEventServer
end

--[=[
    Fires the corresponding RemoteEventClient instance's OnClientEvent signal with the passed arguments

    @param client Client
    @param ... any
]=]
function RemoteEventServer:fireClient(client, ...)
    client:getRemoteEvent(self.name):_fireClient(...)
end

--[=[
    Fires the corresponding RemoteEventClient instance's OnClientEvent signal with the passed arguments for each client

    @param ... any
]=]
function RemoteEventServer:fireAllClients(...)
    for _, client in pairs(self._server._clients) do
        self:fireClient(client, ...)
    end
end

RemoteEventServer.FireClient = RemoteEventServer.fireClient
RemoteEventServer.FireAllClients = RemoteEventServer.fireAllClients
RemoteEventServer.Destroy = RemoteEventServer.destroy

return RemoteEventServer