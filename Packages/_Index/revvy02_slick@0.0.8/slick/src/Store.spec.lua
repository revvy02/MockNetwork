local RunService = game:GetService("RunService")

return function()
    local Store = require(script.Parent.Store)

    describe("Store.new", function()
        it("should create a new store object", function()
            local store = Store.new()

            expect(store).to.be.ok()
            expect(store.is(store)).to.equal(true)

            store:destroy()
        end)

        it("should set the initial state if passed", function()
            local initial = {a = 1, b = 2, c = 3}
            local store = Store.new(initial)

            expect(store:getState()).to.equal(initial)

            store:destroy()
        end)

        it("should have an empty table as the state if no initial is passed", function()
            local store = Store.new()

            expect(next(store:getState())).to.equal(nil)

            store:destroy()
        end)
    end)

    describe("Store.is", function()
        it("should return true if the passed object is a store object", function()
            local store = Store.new()

            expect(store.is(store)).to.equal(true)

            store:destroy()
        end)

        it("should return false if the passed object is not a store object", function()
            local store = Store.new()

            expect(store.is(0)).to.equal(false)
            expect(store.is(true)).to.equal(false)
            expect(store.is({})).to.equal(false)

            store:destroy()
        end)
    end)




    describe("Store:setDepth", function()
        it("should set the depth of the store", function()
            local store = Store.new({a = 1, b = 2, c = 3})
            
            store:setDepth(3)
            expect(store:getDepth()).to.equal(3)

            store:destroy()
        end)
        
        it("should trim any excess history off depending on depth", function()
            local store = Store.new({a = 1, b = 2, c = 3})

            store:setDepth(3)

            store:dispatch("a", "setValue", 2)
            store:dispatch("a", "setValue", 3)
            store:dispatch("a", "setValue", 4)

            expect(store:getHistory()[3].a).to.equal(1)

            store:dispatch("a", "setValue", 5)

            expect(#store:getHistory()).to.equal(3)
            expect(store:getHistory()[3].a).to.equal(2)

            store:setDepth(1)
            expect(#store:getHistory()).to.equal(1)
            expect(store:getHistory()[1].a).to.equal(4)

            store:destroy()
        end)
    end)

    describe("Store:getDepth", function()
        it("should return the depth of the store", function()
            local store = Store.new()

            store:setDepth(10)

            expect(store:getDepth()).to.equal(10)

            store:destroy()
        end)
    end)
    
    describe("Store:getHistory", function()
        it("should return the history depending on the depth of the store", function()
            local store = Store.new()

            store:setDepth(2)

            store:dispatch("a", "setValue", 1)
            store:dispatch("a", "setValue", 2)
            store:dispatch("a", "setValue", 3)
            store:dispatch("a", "setValue", 4)

            expect(#store:getHistory()).to.equal(2)
            expect(store:getHistory()[1].a).to.equal(3)
            expect(store:getHistory()[2].a).to.equal(2)

            store:destroy()
        end)
    end)





    describe("Store:getReducedSignal", function()
        it("should get the reduced signal for the passed key and reducer", function()
            local store = Store.new()

            local signal = store:getReducedSignal("a", "setValue")

            expect(signal).to.be.ok()
            expect(signal.is(signal)).to.equal(true)

            store:destroy()
        end)
    end)


    describe("Store:getChangedSignal", function()
        it("should return a changed signal for the passed key", function()
            local store = Store.new()

            local signal = store:getChangedSignal("a")

            expect(signal).to.be.ok()
            expect(signal.is(signal)).to.equal(true)

            store:destroy()
        end)
    end)

    describe("Store:dispatch", function()
        it("should change the value correctly", function()
            local store = Store.new()

            store:dispatch("a", "setValue", 1)
            expect(store:getValue("a")).to.equal(1)

            store:destroy()
        end)

        it("should throw if reducer doesn't exist", function()
            local store = Store.new()

            expect(function()
                store:dispatch("a", "set", 1) -- reducer is setValue, not set, so this should error
            end).to.throw()

            store:destroy()
        end)

        it("should fire the public changed signal", function()
            local store = Store.new({a = 1})
            local key, new, old

            store.changed:connect(function(...)
                key, new, old = ...
            end)

            store:dispatch("a", "setValue", 2)

            expect(store:getValue("a")).to.equal(2)
            expect(key).to.equal("a")
            expect(new.a).to.equal(2)
            expect(old.a).to.equal(1)

            store:destroy()
        end)

        it("should fire the public reduced signal", function()
            local store = Store.new({a = 1})
            local key, reducer, value

            store.reduced:connect(function(...)
                key, reducer, value = ...
            end)

            store:dispatch("a", "setValue", 2)

            expect(store:getValue("a")).to.equal(2)
            expect(key).to.equal("a")
            expect(reducer).to.equal("setValue")
            expect(value).to.equal(2)

            store:destroy()
        end)

        it("should fire the appropriate key changed signal", function()
            local store = Store.new({a = 1})
            local new, old

            store:getChangedSignal("a"):connect(function(...)
                new, old = ...
            end)

            store:dispatch("a", "setValue", 2)
            expect(new).to.equal(2)
            expect(old).to.equal(1)

            store:destroy()
        end)

        it("should fire the appropriate key reduced signal", function()
            local store = Store.new({a = {}})
            local index, value

            store:getReducedSignal("a", "setIndex"):connect(function(...)
                index, value = ...
            end)

            store:dispatch("a", "setIndex", "a", 1)
            expect(index).to.equal("a")
            expect(value).to.equal(1)
            expect(store:getValue("a").a).to.equal(1)

            store:destroy()
        end)

    end)

    describe("Store:rawset", function()
        it("should set the key value without firing signals", function()
            local store = Store.new()
            local done = false

            store:getChangedSignal("a"):connect(function()
                done = true
            end) 

            store:getReducedSignal("a", "setValue"):connect(function()
                done = true
            end)

            store.changed:connect(function()
                done = true
            end)

            store:rawset("a", 1)

            expect(store:getValue("a")).to.equal(1)
            expect(done).to.equal(false)

            store:destroy()
        end)
    end)
    


    describe("Store:destroy", function()
        it("should disconnect any connections", function()
            local store = Store.new()

            local connection0 = store:getChangedSignal("a"):connect(function() end)
            local connection1 = store:getReducedSignal("a", "setValue"):connect(function() end)

            store:destroy()

            expect(connection0.connected).to.equal(false)
            expect(connection1.connected).to.equal(false)
        end)

        it("should set destroyed field to true", function()
            local store = Store.new()
            store:destroy()

            expect(store.destroyed).to.equal(true)
        end)
    end)
end