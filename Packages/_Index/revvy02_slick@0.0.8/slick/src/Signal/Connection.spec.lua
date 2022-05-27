return function()
    local Signal = require(script.Parent)
    local Connection = require(script.Parent.Connection)

    local function noop()

    end

    describe("Connection.is", function()
        it("should return true if passed object is a Connection", function()
            local signal = Signal.new()
            local connection = signal:connect(noop)

            expect(connection.is(connection)).to.equal(true)
            
            signal:destroy()
        end)

        it("should return false if passed object is not a connection", function()
            local signal = Signal.new()
            local connection = signal:connect(noop)

            expect(connection.is({})).to.equal(false)
            expect(connection.is(noop)).to.equal(false)
            expect(connection.is(true)).to.equal(false)

            signal:destroy()
        end)
    end)

    describe("Connection:disconnect", function()
        it("should set connected field to false", function()
            local signal = Signal.new()
            local connection = signal:connect(noop)

            expect(connection.connected).to.equal(true)

            connection:disconnect()

            expect(connection.connected).to.equal(false)

            signal:destroy()
        end)

        it("should call a onDeactivated callback if it's set and it was the last connection", function()
            local signal = Signal.new()
            local value = 0

            signal:setDeactivatedCallback(function()
                value += 1
            end)

            expect(value).to.equal(0)

            local connection0 = signal:connect(noop)
            expect(value).to.equal(0)

            connection0:disconnect()
            expect(value).to.equal(1)
            
            local connection1 = signal:connect(noop)
            expect(value).to.equal(1)

            signal:connect(noop):disconnect()
            expect(value).to.equal(1)
            
            connection1:disconnect()
            expect(value).to.equal(2)

            signal:destroy()
        end)
    end)

    describe("Connection:destroy", function()
        it("should disconnect the connection", function()
            local signal = Signal.new()
            local connection = signal:connect(noop)

            expect(connection.connected).to.equal(true)

            connection:destroy()

            expect(connection.connected).to.equal(false)

            signal:destroy()
        end)

        it("should set the destroyed field to true", function()
            local signal = Signal.new()
            local connection = signal:connect(noop)

            connection:destroy()

            expect(connection.destroyed).to.equal(true)

            signal:destroy()
        end)

        it("should call a onDeactivated callback if it's set and it was the last connection", function()
            local signal = Signal.new()
            local value = 0

            signal:setDeactivatedCallback(function()
                value += 1
            end)

            expect(value).to.equal(0)

            local connection0 = signal:connect(noop)
            expect(value).to.equal(0)

            connection0:disconnect()
            expect(value).to.equal(1)
            
            local connection1 = signal:connect(noop)
            expect(value).to.equal(1)

            signal:connect(noop):disconnect()
            expect(value).to.equal(1)
            
            connection1:destroy()
            expect(value).to.equal(2)

            signal:destroy()
        end)
    end)
end