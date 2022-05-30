local Cleaner = require(script.Parent.Parent.Cleaner)
local Promise = require(script.Parent.Parent.Promise)

local Card = require(script.Parent.Card)
local Signal = require(script.Parent.Signal)

--[=[
    Keeper class that tracks and holds card instances

    @class Keeper
]=]
local Keeper = {}
Keeper.__index = Keeper

--[=[
    Creates a new Keeper object

    @return Keeper
]=]
function Keeper.new()
    local self = setmetatable({}, Keeper)

    self._cleaner = Cleaner.new()

    self.created = self._cleaner:give(Signal.new())
    self.removed = self._cleaner:give(Signal.new())
    self.changed = self._cleaner:give(Signal.new())

    return self
end

--[=[
    Gets the card from the key

    @param key any
    @return Card | nil
]=]
function Keeper:getCard(key)
    return self._cleaner:get(key)
end

--[=[
    Creates the card and fires keyAdded or throws if it exists

    @param key any
    @param value any
    @return Card
]=]
function Keeper:createCard(key, value, reducers)
    assert(not self._cleaner:get(key), string.format("%s already exists as a card", tostring(key)))

    local card = self._cleaner:set(key, Card.new(value, reducers))
    card.key = key

    self.created:fire(key, card)

    self._cleaner:set(card, card:getChangedSignal():connect(function(newValue, oldValue)
        self.changed:fire(card, newValue, oldValue)
    end))

    return card
end

--[=[
    Removes the key and fires keyRemoved or throws if it doesn't exist

    @param key any
    @return Card
]=]
function Keeper:removeCard(key)
    assert(self._cleaner:get(key), string.format("%s does not exist as a card", tostring(key)))

    local card = self._cleaner:finalize(key)

    self._cleaner:finalize(card)

    self.removed:fire(key, card)

    return card
end

--[=[
    Prepares keeper for garbage collection
]=]
function Keeper:destroy()
    self._cleaner:destroy()
    self.destroyed = true
end

return Keeper