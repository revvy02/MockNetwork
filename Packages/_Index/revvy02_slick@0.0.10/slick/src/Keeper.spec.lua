local RunService = game:GetService("RunService")

local Keeper = require(script.Parent.Keeper)

return function()
    describe("Keeper.new", function()
        it("should create a new keeper", function()
            local keeper = Keeper.new()

            expect(keeper).to.be.a("table")
            expect(getmetatable(keeper)).to.equal(Keeper)

            keeper:destroy()
        end)
    end)

    describe("Keeper:getCard", function()
        it("should return the card if its key exists and nil if it doesn't", function()
            local keeper = Keeper.new()

            expect(keeper:getCard("key")).to.equal(nil)
            
            keeper:createCard("key")

            expect(keeper:getCard("key")).to.be.ok()

            keeper:destroy()
        end)
    end)

    describe("Keeper:createCard", function()
        it("should throw if a card exists for that key", function()
            local keeper = Keeper.new()

            keeper:createCard("key")

            expect(function()
                keeper:createCard("key")
            end).to.throw()

            keeper:destroy()
        end)

        it("should return the card it creates", function()
            local keeper = Keeper.new()

            local card = keeper:createCard("key")

            expect(card).to.equal(keeper:getCard("key"))
            expect(card).to.be.ok()

            keeper:destroy()
        end)

        it("should fire the created signal with the card it creates", function()
            local keeper = Keeper.new()

            task.spawn(function()
                RunService.RenderStepped:Wait()
                keeper:createCard("key")
            end)

            local key, addedCard = keeper.created:wait()
            
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
            local card = keeper:createCard("key")

            expect(card).to.be.ok()
            expect(keeper:removeCard("key")).to.equal(card)

            keeper:destroy()
        end)

        it("should fire the removed signal with the card it removes", function()
            local keeper = Keeper.new()
            local card = keeper:createCard("key")

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

            local keyCard = keeper:createCard("key")
            local lockCard = keeper:createCard("lock")

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