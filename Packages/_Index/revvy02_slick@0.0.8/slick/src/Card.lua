local WEAK_MT = {__mode = "v"}

local Signal = require(script.Parent.Signal)
local Reducer = require(script.Parent.Reducer)
local None = require(script.Parent.None)

local ChangedKey = newproxy()

--[=[
    Card class that holds a single value and lets changes be observed

    @class Card
]=]
local Card = {}
Card.__index = Card

--[=[
    Attempts to add the old value to the history depending on the depth and returns true if successful

    @private
    @param oldValue any
]=]
function Card:_tryHistory(oldValue)
    if self:getDepth() > 0 then
        self._history = table.clone(self._history)

        table.insert(self._history, 1, oldValue == nil and None or oldValue)

        self:_trimHistory()
    end
end

--[=[
    Attempts to trim the history of the card depending on the current depth and returns true if successful

    @private
]=]
function Card:_trimHistory()
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
    Finds the weak reference to the signal and generates it if specified

    @private
    @param key any
    @param generate bool
]=]
function Card:_findSignal(key, generate)
    local signals = self._signals
    local signal = signals[key]

    if not signal and generate then
        signal = Signal.new()
        signals[key] = signal
    end

    return signal
end

--[=[
    Creates a new Card object

    @param initial any
    @return Card
]=]
function Card.new(initial)
    local self = setmetatable({}, Card)

    self._value = initial

    self._depth = 0
    self._history = {}

    self._signals = setmetatable({}, WEAK_MT)
    
    self._reducers = Reducer.Standard

    return self
end

--[=[
    Checks whether or not the passed arg is a card

    @param obj any
    @return bool
]=]
function Card.is(obj)
    return type(obj) == "table" and getmetatable(obj) == Card
end

--[=[
    Sets how much history is tracked and removes any excess if the history size exceeds the depth

    @param depth number
]=]
function Card:setDepth(depth)
    if self._depth ~= depth then
        self._depth = depth
        self:_trimHistory()
    end
end

--[=[
    Gets the depth of the card
]=]
function Card:getDepth()
    return self._depth
end

--[=[
    Gets the history of the card depending on the card's depth
]=]
function Card:getHistory()
    return self._history
end

--[=[
    Gets the signal that will be fired for a reducer if it's dispatched

    @param reducer string
    @return Signal
]=]
function Card:getReducedSignal(reducer)
    return self:_findSignal(reducer, true)
end

--[=[
    Gets the signal that will be fired if the value changes

    @return Signal
]=]
function Card:getChangedSignal()
    return self:_findSignal(ChangedKey, true)
end

--[=[
    Sets the reducers for the key (should typically only be set once when the Key is instantiated)

    @param reducers table
]=]
function Card:setReducers(reducers)
    self._reducers = reducers
end

--[=[
    Sets the value without triggering any signals or history updates

    @param value any
]=]
function Card:rawset(value)
    self._value = value
end

--[=[
    Gets the current value

    @return any
]=]
function Card:getValue()
    return self._value
end

--[=[
    Dispatches the current reducer to update the value while firing the changed and appropriate reduced signal

    @param reducer string
    @param ... any
]=]
function Card:dispatch(reducer, ...)
    local reduce = self._reducers[reducer]

    assert(reduce, string.format("\"%s\" is not a valid reducer", reducer))
    
    local oldValue = self._value
    local newValue = reduce(oldValue, ...)

    self:_tryHistory(oldValue)
    self:rawset(newValue)

    local changedSignal = self:_findSignal(ChangedKey, false)

    if changedSignal then
        changedSignal:fire(newValue, oldValue)
    end

    local reducedSignal = self:_findSignal(reducer, false)

    if reducedSignal then
		reducedSignal:fire(...)
    end
end

--[=[
    Prepares card for garbage collection
]=]
function Card:destroy()
    for _, signal in pairs(self._signals) do
        signal:destroy()
    end

    self.destroyed = true
end

return Card