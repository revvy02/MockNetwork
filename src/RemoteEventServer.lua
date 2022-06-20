local TrueSignal = require(script.Parent.Parent.TrueSignal)

local prepArgs = require(script.Parent.prepArgs)

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

    self.OnServerEvent = TrueSignal.new(false, true)
    
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
    self.OnServerEvent:fire(client, prepArgs(...))
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

--[=[
    PascalCase alias for fireServer

    @param client Client
    @param ... any

    @method FireClient
    @within RemoteEventServer
]=]
RemoteEventServer.FireClient = RemoteEventServer.fireClient

--[=[
    PascalCase alias for fireAllClients

    @param ... any

    @method FireAllClients
    @within RemoteEventServer
]=]
RemoteEventServer.FireAllClients = RemoteEventServer.fireAllClients

--[=[
    PascalCase alias for destroy

    @method Destroy
    @within RemoteEventServer
]=]
RemoteEventServer.Destroy = RemoteEventServer.destroy

return RemoteEventServer