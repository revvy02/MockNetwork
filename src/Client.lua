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

    @param id string
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

        @prop id string
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
    @return RemoteEventClient

    @error "%s is not a valid RemoteEvent"
]=]
function Client:getRemoteEvent(name)
    assert(self._remoteEvents[name], string.format("%s is not a valid RemoteEvent", name))
    return self._remoteEvents[name]
end

--[=[
    Gets the RemoteFunctionClient if it exists, returns nil otherwise

    @param name string
    @return RemoteFunctionClient

    @error "%s is not a valid RemoteFunction"
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
    Returns a table that maps the remoteEvent name and object with the passed function

    @param fn function
    @return table
]=]
function Client:mapRemoteEvents(fn)
    local map = {}
    
    if fn then
        for name, client in self._remoteEvents do
            local key, value = fn(name, client)
            map[key] = value
        end
    else
        for name, client in self._remoteEvents do
            map[name] = client
        end
    end

    return map
end

--[=[
    Returns a table that maps the remoteFunction name and object with the passed function

    @param fn function
    @return table
]=]
function Client:mapRemoteFunctions(fn)
    local map = {}
    
    if fn then
        for name, client in self._remoteFunctions do
            local key, value = fn(name, client)
            map[key] = value
        end
    else
        for name, client in self._remoteFunctions do
            map[name] = client
        end
    end

    return map
end

--[=[
    Alias for disconnect but sets destroyed field to true
]=]
function Client:destroy()
    self:disconnect()
    self.destroyed = true
end

return Client