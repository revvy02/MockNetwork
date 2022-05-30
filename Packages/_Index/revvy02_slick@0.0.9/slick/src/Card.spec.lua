local RunService = game:GetService("RunService")

local Card = require(script.Parent.Card)
local Signal = require(script.Parent.Signal)

return function()
    describe("Card.new", function()
        it("should create a new card object", function()
            local card = Card.new()

            expect(card).to.be.a("table")
            expect(getmetatable(card)).to.equal(Card)

            card:destroy()
        end)

        it("should set the initial value if it's passed", function()
            local card = Card.new(0)
            
            expect(card:getValue()).to.equal(0)

            card:destroy()
        end)

        it("should use the reducers if passed instead of standard reducers", function()
            local card = Card.new(1, {
                increment = function(old, amount)
                    return old + amount
                end,
            })

            expect(function()
                card:dispatch("setValue", 1)
            end).to.throw()

            expect(function()
                card:dispatch("increment", 1)
            end).to.never.throw()
            
            expect(card:getValue()).to.equal(2)

            card:destroy()
        end)

        it("should use standard reducers if not passed", function()
            local card = Card.new(2)

            expect(function()
                card:dispatch("setValue", 1)
            end).to.never.throw()

            expect(card:getValue()).to.equal(1)

            card:destroy()
        end)
    end)

    describe("Card:setDepth", function()
        it("should set the depth of the card and trim any excess history off if necessary", function()
            local card = Card.new()
            
            card:rawset(0)
            card:setDepth(3)

            expect(card:getDepth()).to.equal(3)

            card:dispatch("setValue", 1)
            card:dispatch("setValue", 2)
            card:dispatch("setValue", 3)

            expect(card:getHistory()[3]).to.equal(0)
            expect(card:getHistory()[4]).to.equal(nil)

            card:dispatch("setValue", 4)

            expect(card:getHistory()[3]).to.equal(1)
            expect(card:getHistory()[4]).to.equal(nil)

            card:setDepth(1)
            expect(card:getHistory()[1]).to.equal(3)
            expect(card:getHistory()[2]).to.equal(nil)

            card:destroy()
        end)
    end)

    describe("Card:getDepth", function()
        it("should return the depth of the card", function()
            local card = Card.new()

            card:setDepth(10)

            expect(card:getDepth()).to.equal(10)

            card:destroy()
        end)
    end)
    
    describe("Card:getHistory", function()
        it("should return the history depending on the depth of the card", function()
            local card = Card.new()

            card:setDepth(2)

            card:dispatch("setValue", 1)
            card:dispatch("setValue", 2)
            card:dispatch("setValue", 3)
            card:dispatch("setValue", 4)

            expect(#card:getHistory()).to.equal(2)

            card:destroy()
        end)
    end)





    describe("Card:getReducedSignal", function()
        it("should get the reduced signal for the passed reducer type", function()
            local card = Card.new()

            local signal = card:getReducedSignal("setValue")

            expect(signal).to.be.a("table")
            expect(getmetatable(signal)).to.equal(Signal)

            card:destroy()
        end)
    end)

    describe("Card:getChangedSignal", function()
        it("should get the changed signal for the card", function()
            local card = Card.new()

            local signal = card:getChangedSignal()

            expect(signal).to.be.a("table")
            expect(getmetatable(signal)).to.equal(Signal)
            
            card:destroy()
        end)
    end)

    describe("Card:dispatch", function()
        it("should change the value correctly if reducers are set", function()
            local card = Card.new()

            card:dispatch("setValue", 1)
            expect(card:getValue()).to.equal(1)

            card:destroy()
        end)

        it("should throw if reducer doesn't exist", function()
            local card = Card.new()

            expect(function()
                card:dispatch("set", 1) -- reducer is setValue instead of set
            end).to.throw()

            card:destroy()
        end)

        it("should fire the changed signal with the new and old value", function()
            local card = Card.new()
            local new, old

            card:getChangedSignal():connect(function(...)
                new, old = ...
            end)

            card:rawset(2)
            card:dispatch("setValue", 3)

            expect(card:getValue()).to.equal(3)
            expect(new).to.equal(3)
            expect(old).to.equal(2)

            card:destroy()
        end)

        it("should fire the appropriate reduced signal", function()
            local card = Card.new({})
            local index, value

            card:getReducedSignal("setIndex"):connect(function(...)
                index, value = ...
            end)

            card:dispatch("setIndex", "a", 1)

            expect(index).to.equal("a")
            expect(value).to.equal(1)
            expect(card:getValue().a).to.equal(1)

            card:destroy()
        end)

    end)

    describe("Card:rawset", function()
        it("should set the value without firing any signals", function()
            local card = Card.new()
            local done = false

            card:getChangedSignal():connect(function()
                done = true
            end)

            card:rawset(2)
            expect(card:getValue()).to.equal(2)
            expect(done).to.equal(false)

            card:destroy()
        end)
    end)
    


    describe("Card:destroy", function()
        it("should disconnect any connections", function()
            local card = Card.new()
            local connection0 = card:getChangedSignal():connect(function() end)
            local connection1 = card:getReducedSignal("setValue"):connect(function() end)

            card:destroy()

            expect(connection0.connected).to.equal(false)
            expect(connection1.connected).to.equal(false)
        end)

        it("should set destroyed field to true", function()
            local card = Card.new()
            card:destroy()

            expect(card.destroyed).to.equal(true)
        end)
    end)

end