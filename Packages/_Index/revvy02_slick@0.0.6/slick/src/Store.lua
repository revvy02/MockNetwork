local WEAK_MT = {__mode = "v"}

local Cleaner = require(script.Parent.Parent.Cleaner)

local Signal = require(script.Parent.Signal)

local Reducer = require(script.Parent.Reducer)

--[=[
    Store class that holds many values that can be changed by a set of reducers

    @class Store
]=]
local Store = {}
Store.__index = Store

--[=[
    Attempts to add the old state to the history depending on the depth and returns true if successful

    @private
    @param oldState table
]=]
function Store:_tryHistory(oldState)
    if self:getDepth() > 0 then
        self._history = table.clone(self._history)

        table.insert(self._history, 1, oldState)

        self:_trimHistory()
    end
end

--[=[
    Attempts to trim the history of the store depending on depth and current history and returns true if successful

    @private
]=]
function Store:_trimHistory()
    local history = self._history
    local n, depth = #history, self._depth

    if depth < n then
        local newHistory = table.clone(history)

        for i = depth + 1, n do
            newHistory[i] = nil
        end

        self._history = newHistory
    end
end

--[=[
    Attempts to find a changed signal for a key and generate it if generate is true

    @private
    @param key any
    @param generate bool
]=]
function Store:_findChangedSignal(key, generate)
    local changedSignals = self._changedSignals
    local changedSignal = changedSignals[key]

    if not changedSignal and generate then
        changedSignal = Signal.new()
        changedSignals[key] = changedSignal
    end

    return changedSignal
end

--[=[
    Attempts to find a reduced signal for a key and its reducer and generate it if generate is true

    @private
    @param key any
    @param reducer string
    @param generate bool
]=]
function Store:_findReducedSignal(key, reducer, generate)
    local reducedSignals = self._reducedSignals
    local keySignals = reducedSignals[key]

    if not keySignals then
        if not generate then
            return
        end

        keySignals = setmetatable({}, WEAK_MT)
        reducedSignals[key] = keySignals
    end

    local reducedSignal = keySignals[reducer]

    if not reducedSignal and generate then
        reducedSignal = Signal.new()
        keySignals[reducer] = reducedSignal
    end

    return reducedSignal
end

--[=[
    Creates a new Store object

    @param initial? table
    @return Store
]=]
function Store.new(initial)
    local self = setmetatable({}, Store)

    self._depth = 0
    self._history = {}

    self._state = initial or {}

    self._cleaner = Cleaner.new()
    self._reducers = Reducer.Standard

    self._reducedSignals = setmetatable({}, WEAK_MT)
    self._changedSignals = setmetatable({}, WEAK_MT)

    self.changed = self._cleaner:add(Signal.new())
    self.reduced = self._cleaner:add(Signal.new())
    
    return self
end

--[=[
    Returns whether or not the passed argument is a store object

    @param obj any
    @return bool
]=]
function Store.is(obj)
    return type(obj) == "table" and getmetatable(obj) == Store
end

--[=[
    Sets how much history is tracked and removes any excess if the history size exceeds the depth

    @param depth number
]=]
function Store:setDepth(depth)
    if self._depth ~= depth then
        self._depth = depth
        self:_trimHistory()
    end
end

--[=[
    Gets the depth of the store

    @return number
]=]
function Store:getDepth()
    return self._depth
end

--[=[
    Gets the history of the store as a table

    @return table
]=]
function Store:getHistory()
    return self._history
end

--[=[
    Sets the state key to the value without firing any events (should be used to initialize the store)

    @param key any
    @param value any
]=]
function Store:rawset(key, value)
    self._state[key] = value
end

--[=[
    Sets the state of the store without firing any events (should be used to initialize the store)

    @param state table
]=]
function Store:rawsetState(state)
    self._state = state
end

--[=[
    Sets the reducers for the store

    @param reducers table
]=]
function Store:setReducers(reducers)
    self._reducers = reducers
end

--[=[
    Gets the value of the key in the store

    @param key any
]=]
function Store:get(key)
    return self._state[key]
end

--[=[
    Returns the state of the store

    @return table
]=]
function Store:getState()
    return self._state
end

--[=[
    Dispatches args to the reducer for a key

    @param key any
    @param reducer string
    @param ... any
]=]
function Store:dispatch(key, reducer, ...)
    local reduce = self._reducers[reducer]

    assert(reduce, string.format("\"%s\" is not a valid reducer for \"%s\"", reducer, key))

    local oldState = self._state
    local oldValue = oldState[key]
    local newValue = reduce(oldValue, ...)

    if newValue == oldValue then
        return
    end

    local newState = table.clone(oldState)
    newState[key] = newValue
    
    self._state = newState
    self:_tryHistory(oldState)

    self.changed:fire(key, newState, oldState)
    self.reduced:fire(key, reducer, ...)

    -- handle direct key change and reduced signals
    local changedSignal = self:_findChangedSignal(key, false)

    if changedSignal then
        changedSignal:fire(newValue, oldValue)
    end
   
    local reducedSignal = self:_findReducedSignal(key, reducer, false)
       
    if reducedSignal then
        reducedSignal:fire(...)
    end
end

--[=[
    Returns a reduced signal that will be fired if that reducer is used on the key

    @param key any
    @param reducer any
    @return Signal
]=]
function Store:getReducedSignal(key, reducer)
    return self:_findReducedSignal(key, reducer, true)
end

--[=[
    Returns a signal that will be fired if the passed key value is changed
    
    @param key any
    @return Signal
]=]
function Store:getChangedSignal(key)
    return self:_findChangedSignal(key, true)
end

--[=[
    Cleans up the store object and sets destroyed field to true
    @within Store
]=]
function Store:destroy()
    for _, signal in pairs(self._changedSignals) do
        signal:destroy()
    end

    for _, signals in pairs(self._reducedSignals) do
        for _, signal in pairs(signals) do
            signal:destroy()
        end
    end

    self._cleaner:destroy()
    self.destroyed = true
end

return Store