local Connection = require(script.Connection)
local Promise = require(script.Parent.Promise) -- packages will be siblings in the datamodel

local function eachNode(node, fn, ...)
    while node do
        fn(node, ...)
        node = node._next
    end
end

local function fireDeferredConnection(node, ...)
    task.defer(node._fn, ...)
end

local function fireImmediateConnection(node, ...)
    task.spawn(node._fn, ...)
end

--[=[
    Luau TrueSignal implementation

    @class TrueSignal
]=]
local TrueSignal = {}
TrueSignal.__index = TrueSignal

--[=[
    Constructs a new TrueSignal object.

    @param deferred bool
    @param queueing bool

    @return TrueSignal
]=]
function TrueSignal.new(deferred, queueing)
    local self = setmetatable({}, TrueSignal)

    if deferred then
        self._deferred = true
    end

    if queueing then
        self._queue = {}
    end

    return self
end

--[=[
    Fires any connections with the passed args

    @param ... any
]=]
function TrueSignal:fire(...)
    local head = self._head

    if head == nil then
        if self._queue then
            table.insert(self._queue, table.pack(...))
        end
    else
        eachNode(head, self._deferred and fireDeferredConnection or fireImmediateConnection, ...)
    end
end

--[=[
    Connects a handler function to the signal so that it can be called when it's fired.

    @param fn function
    @return Connection
]=]
function TrueSignal:connect(fn)
    local connection = Connection._new(self, fn)
    local head = self._head

    connection._next = head

    self._head = connection
    
    if not head and self._queue then
        if self._deferred then
            while self._queue[1] and self._head do
                task.defer(fn, table.unpack(table.remove(self._queue, 1)))
            end
        else
            while self._queue[1] and self._head do
                task.spawn(fn, table.unpack(table.remove(self._queue, 1)))
            end
        end
    end

    return connection
end

--[=[
    Empties any queued arguments that may have been added when fire was called with no connections.
]=]
function TrueSignal:flush()
    if self._queue then
        table.clear(self._queue)
    end
end

--[=[
    Yields the current thread until the TrueSignal is fired and returns what was fired

    @yields
    @return any
]=]
function TrueSignal:wait()
    return self:promise():expect()
end

--[=[
    Returns a promise that resolves the next time the TrueSignal is fired

    @return Promise
]=]
function TrueSignal:promise()
    return Promise.new(function(resolve, _, onCancel)
        if self._queue and self._queue[1] then
            local args = table.remove(self._queue, 1)

            if self._deferred then
                task.defer(resolve, table.unpack(args))
            else
                resolve(table.unpack(args))
            end
            
            return
        end

        local connection

        onCancel(function()
            connection:disconnect()
        end)

        connection = self:connect(function(...)
            connection:disconnect()
            resolve(...)
        end)
    end)
end

--[=[
    Flushes the TrueSignal and disconnects all connections
]=]
function TrueSignal:destroy()
    self:flush()

    local head = self._head

    eachNode(head, function(node)
        node.connected = false
    end)

    self._head = nil
    self.destroyed = true
end

--[[
    Include PascalCase RbxScriptTrueSignal interface
]]
TrueSignal.Destroy = TrueSignal.destroy
TrueSignal.Wait = TrueSignal.wait
TrueSignal.Connect = TrueSignal.connect

return TrueSignal