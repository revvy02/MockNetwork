local TrueSignal = require(script.Parent.Parent.TrueSignal)

local prepArgs = require(script.Parent.prepArgs)

--[=[
    RemoteEventClient class

    @class RemoteEventClient
]=]
local RemoteEventClient = {}
RemoteEventClient.__index = RemoteEventClient

--[=[
    Constructs a new RemoteEventClient object

    @param name string
    @param server Server
    @param client Client
    @return RemoteEventClient

    @private
]=]
function RemoteEventClient._new(name, server, client)
    local self = setmetatable({}, RemoteEventClient)

    self.name = name

    self._server = server
    self._client = client

    self.OnClientEvent = TrueSignal.new(false, true)

    self._client._remoteEvents[name] = self

    return self
end

--[=[
    Called by RemoteEventServer to fire the client

    @param ... any
    
    @private
]=]
function RemoteEventClient:_fireClient(...)
    self.OnClientEvent:fire(...)
end

--[=[
    Called by RemoteEventServer to clean up
    
    @private
]=]
function RemoteEventClient:_destroy()
    self._client._remoteEvents[self.name] = nil
    self.OnClientEvent:destroy()
end

--[=[
    Fires the corresponding RemoteEventServer instance's OnServerEvent signal with the passed args

    @param ... any
]=]
function RemoteEventClient:fireServer(...)
    self._server:getRemoteEvent(self.name):_fireServer(self._client, prepArgs(...))
end

--[=[
    PascalCase alias for fireServer

    @param ... any

    @method FireServer
    @within RemoteEventClient
]=]
RemoteEventClient.FireServer = RemoteEventClient.fireServer

return RemoteEventClient