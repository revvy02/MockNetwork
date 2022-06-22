local TrueSignal = require(script.Parent.Parent.TrueSignal)

local Client = require(script.Parent.Client)

local RemoteEventClient = require(script.Parent.RemoteEventClient)
local RemoteEventServer = require(script.Parent.RemoteEventServer)

local RemoteFunctionClient = require(script.Parent.RemoteFunctionClient)
local RemoteFunctionServer = require(script.Parent.RemoteFunctionServer)

--[=[
    Server class

    @class Server
]=]
local Server = {}
Server.__index = Server

--[=[
    Constructs a new Server object

    @param clients table
    @return Server
]=]
function Server.new(clients)
    local self = setmetatable({}, Server)

    self._clients = {}
    self._remoteEvents = {}
    self._remoteFunctions = {}

    self.clientConnected = TrueSignal.new()
    self.clientDisconnecting = TrueSignal.new()

    if clients then
        for _, id in pairs(clients) do
            self:connect(id)
        end
    end

    return self
end

--[=[
    Creates a new RemoteEvent on server and clients

    @param name string
    @return RemoteEventServer
]=]
function Server:createRemoteEvent(name)
    for _, client in pairs(self._clients) do
        RemoteEventClient._new(name, self, client)
    end

    return RemoteEventServer._new(name, self)
end

--[=[
    Gets the RemoteEventServer instance

    @param name string
    @return RemoteEventServer

    @error "%s is not a valid RemoteEvent"
]=]
function Server:getRemoteEvent(name)
    assert(self._remoteEvents[name], string.format("%s is not a valid RemoteEvent", name))
    return self._remoteEvents[name]
end

--[=[
    Creates a new RemoteFunction on server and clients

    @param name string
    @return RemoteFunctionServer
]=]
function Server:createRemoteFunction(name)
    for _, client in pairs(self._clients) do
        RemoteFunctionClient._new(name, self, client)
    end

    return RemoteFunctionServer._new(name, self)
end

--[=[
    Gets the RemoteFunctionServer instance

    @param name string
    @return RemoteFunctionServer

    @error "%s is not a valid RemoteFunction"
]=]
function Server:getRemoteFunction(name)
    assert(self._remoteFunctions[name], string.format("%s is not a valid RemoteFunction", name))
    return self._remoteFunctions[name]
end

--[=[
    Connects a new client to the server

    @param id string
    @return Client
]=]
function Server:connect(id)
    return Client._new(id, self)
end

--[=[
    Disconnects client from server

    @param id string
]=]
function Server:disconnect(id)
    self:getClient(id):disconnect()
end

--[=[
    Gets the client object from id

    @param id string
    @return Client
]=]
function Server:getClient(id)
    return self._clients[id]
end

--[=[
    Returns a table with each connected client

    @return table
]=]
function Server:getClients()
    local list = {}

    for _, client in pairs(self._clients) do
        table.insert(list, client)
    end

    return list
end

--[=[
    Returns a table that maps the client id and object with the passed function

    @param fn function
    @return table
]=]
function Server:mapClients(fn)
    local map = {}
    
    if fn then
        for id, client in self._clients do
            local key, value = fn(id, client)
            map[key] = value
        end
    else
        for id, client in self._clients do
            map[id] = client
        end
    end

    return map
end

--[=[
    Prepares server for garbage collection
]=]
function Server:destroy()
    for _, remoteEvent in pairs(self._remoteEvents) do
        remoteEvent:destroy()
    end

    for _, remoteFunction in pairs(self._remoteFunctions) do
        remoteFunction:destroy()
    end

    for _, client in pairs(self._clients) do
        client:disconnect()
    end

    self.clientConnected:destroy()
    self.clientDisconnecting:destroy()

    self.destroyed = true
end

return Server