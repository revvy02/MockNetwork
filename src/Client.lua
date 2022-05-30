local RemoteEventClient = require(script.Parent.RemoteEventClient)
local RemoteFunctionClient = require(script.Parent.RemoteFunctionClient)

--[=[
    Client class

    @class Client
]=]
local Client = {}
Client.__index = Client

--[=[
    Constructs a new Client object

    @param id string | number
    @param server Server
    @return Client

    @private
]=]
function Client._new(id, server)
    assert(not server:getClient(id), string.format("%s is already a client", tostring(id)))

    local self = setmetatable({}, Client)

    self._server = server
    
    --[=[
        Stores the id of the client passed in the constructor

        @prop id string | number
        @within Client
        @readonly
    ]=]
    self.id = id

    --[=[
        Tells whether the client object is connected or not
        
        @prop connected bool
        @within Client
        @readonly
    ]=]
    self.connected = true

    self._remoteEvents = {}
    self._remoteFunctions = {}

    self._server._clients[id] = self

    for name in pairs(self._server._remoteEvents) do
        RemoteEventClient._new(name, self._server, self)
    end

    for name in pairs(self._server._remoteFunctions) do
        RemoteFunctionClient._new(name, self._server, self)
    end

    self._server.clientConnected:fire(self)

    return self
end

--[=[
    Gets the RemoteEventClient if it exists, returns nil otherwise

    @param name string
    @return RemoteEventClient | nil
]=]
function Client:getRemoteEvent(name)
    assert(self._remoteEvents[name], string.format("%s is not a valid RemoteEvent", name))
    return self._remoteEvents[name]
end

--[=[
    Gets the RemoteFunctionClient if it exists, returns nil otherwise

    @param name string
    @return RemoteFunctionClient | nil
]=]
function Client:getRemoteFunction(name)
    assert(self._remoteFunctions[name], string.format("%s is not a valid RemoteFunction", name))
    return self._remoteFunctions[name]
end

--[=[
    Disconnects the client from the server
]=]
function Client:disconnect()
    self.connected = false

    self._server.clientDisconnecting:fire(self)

    for _, event in pairs(self._remoteEvents) do
        event:destroy()
    end

    for _, func in pairs(self._remoteFunctions) do
        func:destroy()
    end

    self._server._clients[self.id] = nil
end

--[=[
    Alias for disconnect but sets destroyed field to true
]=]
function Client:destroy()
    self:disconnect()
    self.destroyed = true
end

return Client