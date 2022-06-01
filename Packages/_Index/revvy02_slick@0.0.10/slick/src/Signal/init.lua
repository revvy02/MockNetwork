local Connection = require(script.Connection)
local Promise = require(script.Parent.Parent.Promise) -- packages will be siblings in the datamodel

--[[
    "thread recycling" from Stravant's GoodSignal implementation
]]
local freeRunnerThread = nil

local function acquireRunnerThreadAndCallEventHandler(fn, ...)
	local acquiredRunnerThread = freeRunnerThread
	freeRunnerThread = nil
	fn(...)
	-- The handler finished running, this runner thread is free again.
	freeRunnerThread = acquiredRunnerThread
end

local function runEventHandlerInFreeThread(...)
	acquireRunnerThreadAndCallEventHandler(...)
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

local function eachNode(node, fn, ...)
    while node do
        fn(node, ...)
        node = node._next
    end
end

local function fireDeferred(fn, ...)
    task.defer(fn, ...)
end

local function fireDeferredConnection(node, ...)
    fireDeferred(node._fn, ...)
end

local function fireImmediate(fn, ...)
    if not freeRunnerThread then
        freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
    end

    task.spawn(freeRunnerThread, fn, ...)
end

local function fireImmediateConnection(node, ...)
    fireImmediate(node._fn, ...)
end




--[=[
    Luau signal implementation

    @class Signal
]=]
local Signal = {}
Signal.__index = Signal

--[=[
    Calls the deactivated callback if the conditions for it are right

    @private
    @return bool
]=]
function Signal:_tryDeactivatedCall()
    local onDeactivated = self._onDeactivated

    if onDeactivated and self._head == nil then
        onDeactivated()

        return true
    end

    return false
end

--[=[
    Calls the activated callback if the conditions for it are right

    @private
    @return bool
]=]
function Signal:_tryActivatedCall()
    local onActivated = self._onActivated

    if onActivated and self._head and not self._head._next then
        onActivated()

        return true
    end

    return false
end


--[=[
    Constructs a new signal object.

    @return Signal
]=]
function Signal.new()
    local self = setmetatable({
        --[=[
            Tells whether the signal is in deferred mode or not

            @prop deferred boolean
            @readonly
            @within Signal
        ]=]
        deferred = false,

        --[=[
            Tells whether the signal is currently queueing fired arguments or not

            @prop queueing boolean
            @readonly
            @within Signal
        ]=]
        queueing = false,

        --[=[
            Tells whether or not the signal is currently firing arguments or not
            (this should only be true if the environment it is being read from is within a handler call)
        ]=]
        firing = false,

        _head = nil,
        _onActivated = nil,
        _onDeactivated = nil,
    }, Signal)

    return self
end

--[=[
    Enables argumenting queuing from fire calls when there are no connections and sets queueing to true
]=]
function Signal:enableQueueing()
    if not self.queueing then
        self._queue = {}
        self.queueing = true
    end
end

--[=[
    Disables argumenting queuing from fire calls when there are no connections and sets queueing to false
]=]
function Signal:disableQueueing()
    if self.queueing then
        self._queue = nil
        self.queueing = false
    end
end

--[=[
    Enables deferred signaling and sets deferred to true
]=]
function Signal:enableDeferred()
    if not self.deferred then
        self.deferred = true
    end
end

--[=[
    Disables deferred signaling and sets deferred to false
]=]
function Signal:disableDeferred()
    if self.deferred then
        self.deferred = false
    end
end

--[=[
    Sets the callback that is called when a connection is made from when there are no connections (an activated state enters).

    @param fn function
]=]
function Signal:setActivatedCallback(fn)
    self._onActivated = fn
end

--[=[
    Sets the callback that is called when the last active connection is disconnected (a deactivated state enters).

    @param fn function
]=]
function Signal:setDeactivatedCallback(fn)
    self._onDeactivated = fn
end

--[=[
    Fires the signal with the optional passed arguments. This method makes optimizations by recycling threads in cases where connections don't yield if deferred is false.

    @param ... any
]=]
function Signal:fire(...)
    local head = self._head

    if head == nil then
        if self.queueing then
            table.insert(self._queue, table.pack(...))
        end
    else
        self.firing = true

        eachNode(head, self.deferred and fireDeferredConnection or fireImmediateConnection, ...)

        local newHead, newTail

        eachNode(head, function(node)
            if node.connected then
                if not newHead then
                    newHead = node
                    newTail = node
                else
                    newTail._next = node
                    newTail = node
                end
            end
        end)
        
        self._head = newHead
        self.firing = false

        self:_tryDeactivatedCall()
    end
end

--[=[
    Empties any queued arguments that may have been added when fire was called with no connections.
]=]
function Signal:flush()
    if self.queueing then
        table.clear(self._queue)
    end
end

--[=[
    Yields the current thread until the signal is fired and returns what was fired

    @yields
    @return any
]=]
function Signal:wait()
    return select(2, self:promise():await())
end

--[=[
    Returns a promise that resolves the next time the signal is fired

    @return Promise
]=]
function Signal:promise()
    return Promise.new(function(resolve, reject, onCancel)
        if self.queueing and self._queue[1] then
            resolve(table.unpack(table.remove(self._queue, 1)))
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
    Connects a handler function to the signal so that it can be called when it's fired.

    @param fn function
    @return Connection
]=]
function Signal:connect(fn)
    local connection = Connection.new(self, fn)
    local head = self._head

    connection._next = head
    self._head = connection

    if not head then
        self:_tryActivatedCall()
        
        while self.queueing and self._queue[1] and self._head do
            fireImmediate(fn, table.unpack(table.remove(self._queue, 1)))
        end
    end

    return connection
end

--[=[
    Disconnects all connections
]=]
function Signal:disconnectAll()
    local onDeactivated = self._onDeactivated
    local head = self._head

    eachNode(head, function(node)
        node.connected = false
    end)

    if head and onDeactivated then
        onDeactivated()
    end

    self._head = nil
end

--[=[
    Alias for disconnectAll but sets destroyed field to true
]=]
function Signal:destroy()
    self:flush()
    self:disconnectAll()
    self.destroyed = true
end

--[[
    Include PascalCase RbxScriptSignal interface
]]
Signal.Destroy = Signal.destroy
Signal.Wait = Signal.wait
Signal.Connect = Signal.connect
Signal.DisconnectAll = Signal.disconnectAll

return Signal