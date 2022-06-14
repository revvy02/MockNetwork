local Signal = require(script.Parent)
local Connection = require(script.Parent.Connection)

return function()
    describe("Connection:disconnect", function()
        it("should set connected field to false", function()
            local signal = Signal.new()
            local connection = signal:connect(function() end)

            expect(connection.connected).to.equal(true)

            connection:disconnect()

            expect(connection.connected).to.equal(false)

            signal:destroy()
        end)
    end)

    describe("Connection:destroy", function()
        it("should disconnect the connection", function()
            local signal = Signal.new()
            local connection = signal:connect(function() end)

            expect(connection.connected).to.equal(true)

            connection:destroy()

            expect(connection.connected).to.equal(false)

            signal:destroy()
        end)

        it("should set the destroyed field to true", function()
            local signal = Signal.new()
            local connection = signal:connect(function() end)

            connection:destroy()

            expect(connection.destroyed).to.equal(true)

            signal:destroy()
        end)
    end)
end