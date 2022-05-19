local RunService = game:GetService("RunService")
return function()
    local Keeper = require(script.Parent.Keeper)

    describe("Keeper.new", function()
        it("should create a new keeper", function()
            local keeper = Keeper.new()

            expect(keeper).to.be.ok()
            expect(keeper.is(keeper)).to.equal(true)

            keeper:destroy()
        end)
    end)

    describe("Keeper.is", function()
        it("should return whether or not the passed object is a keeper", function()
            local keeper = Keeper.new()

            expect(keeper.is(keeper)).to.equal(true)
            expect(keeper.is(1)).to.equal(false)
            expect(keeper.is({})).to.equal(false)

            keeper:destroy()
        end)
    end)

    describe("Keeper:getCard", function()
        it("should return the card if its key exists and nil if it doesn't", function()
            local keeper = Keeper.new()

            expect(keeper:getCard("key")).to.equal(nil)
            
            keeper:addCard("key")

            expect(keeper:getCard("key")).to.be.ok()

            keeper:destroy()
        end)
    end)

    describe("Keeper:addCard", function()
        it("should throw if a card exists for that key", function()
            local keeper = Keeper.new()

            keeper:addCard("key")

            expect(function()
                keeper:addCard("key")
            end).to.throw()

            keeper:destroy()
        end)

        it("should return the card it creates", function()
            local keeper = Keeper.new()

            local card = keeper:addCard("key")

            expect(card).to.equal(keeper:getCard("key"))
            expect(card).to.be.ok()

            keeper:destroy()
        end)

        it("should fire the added signal with the card it creates", function()
            local keeper = Keeper.new()

            task.spawn(function()
                RunService.RenderStepped:Wait()
                keeper:addCard("key")
            end)

            local key, addedCard = keeper.added:wait()
            
            expect(key).to.equal("key")
            expect(addedCard).to.be.ok()
            expect(addedCard).to.equal(keeper:getCard("key"))

            keeper:destroy()
        end)
    end)

    describe("Keeper:removeCard", function()
        it("should throw if the card does not exist for that key", function()
            local keeper = Keeper.new()

            expect(function()
                keeper:removeCard("key")
            end).to.throw()

            keeper:destroy()
        end)

        it("should return the card it removes", function()
            local keeper = Keeper.new()
            local card = keeper:addCard("key")

            expect(card).to.be.ok()
            expect(keeper:removeCard("key")).to.equal(card)

            keeper:destroy()
        end)

        it("should fire the removed signal with the card it removes", function()
            local keeper = Keeper.new()
            local card = keeper:addCard("key")

            task.spawn(function()
                RunService.RenderStepped:Wait()
                keeper:removeCard("key")
            end)

            local key, removedCard = keeper.removed:wait()
            expect(key).to.equal("key")
            expect(card).to.equal(removedCard)

            keeper:destroy()
        end)
    end)

    describe("Keeper:destroy", function()
        it("should destroy all cards", function()
            local keeper = Keeper.new()

            local keyCard = keeper:addCard("key")
            local lockCard = keeper:addCard("lock")

            keeper:destroy()

            expect(keyCard.destroyed).to.equal(true)
            expect(lockCard.destroyed).to.equal(true)
        end)

        it("should set destroyed field to true", function()
            local keeper = Keeper.new()

            keeper:destroy()

            expect(keeper.destroyed).to.equal(true)
        end)
    end)
end