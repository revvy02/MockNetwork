local Slick = require(script.Parent.Parent.Slick)

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

    self.OnClientEvent = Slick.Signal.new()
    self.OnClientEvent:enableQueueing()

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
    Returns whether the passed argument is a RemoteEventClient

    @param obj any
    @return boolean
]=]
function RemoteEventClient.is(obj)
    return typeof(obj) == "table" and getmetatable(obj) == RemoteEventClient
end

--[=[
    Fires the corresponding RemoteEventServer instance's OnServerEvent signal with the passed args

    @param ... any
]=]
function RemoteEventClient:fireServer(...)
    self._server:getRemoteEvent(self.name):_fireServer(self._client, ...)
end

RemoteEventClient.FireServer = RemoteEventClient.fireServer
RemoteEventClient.Destroy = RemoteEventClient.destroy

return RemoteEventClient