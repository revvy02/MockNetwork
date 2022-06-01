local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Parent.Promise)

local Signal = require(script.Parent.Signal)
local Connection = require(script.Parent.Signal.Connection)

return function()
    describe("Signal.new", function()
        it("should create a new signal object", function()
            local signal = Signal.new()

            expect(signal).to.be.a("table")
            expect(getmetatable(signal)).to.equal(Signal)

            signal:destroy()
        end)

        it("should have deferred property be false initially", function()
            local signal = Signal.new()

            expect(signal.deferred).to.equal(false)

            signal:destroy()
        end)

        it("should have queueing property be false initially", function()
            local signal = Signal.new()

            expect(signal.queueing).to.equal(false)

            signal:destroy()
        end)
    end)

    describe("Signal:enableQueueing", function()
        it("should set queueing property to true", function()
            local signal = Signal.new()
            
            signal:enableQueueing()
            expect(signal.queueing).to.equal(true)

            signal:destroy()
        end)
    end)

    describe("Signal:disableQueueing", function()
        it("should set queueing property to false", function()
            local signal = Signal.new()
            
            signal:enableQueueing()
            expect(signal.queueing).to.equal(true)

            signal:disableQueueing()
            expect(signal.queueing).to.equal(false)

            signal:destroy()
        end)
    end)

    describe("Signal:enableDeferred", function()
        it("should set deferred property to true", function()
            local signal = Signal.new()
            
            signal:enableDeferred()
            expect(signal.deferred).to.equal(true)

            signal:destroy()
        end)
    end)

    describe("Signal:disableDeferred", function()
        it("should set deferred property to false", function()
            local signal = Signal.new()
            
            signal:enableDeferred()
            expect(signal.deferred).to.equal(true)

            signal:disableDeferred()
            expect(signal.deferred).to.equal(false)

            signal:destroy()
        end)
    end)
    
    describe("Signal:fire", function()
        it("should fire connections with future passed args", function()
            local signal = Signal.new()
            local done = {}

            signal:connect(function(value)
                done[value] = true
            end)

            signal:fire(1)
            signal:fire(2)
            signal:fire(3)

            expect(done[1]).to.equal(true)
            expect(done[2]).to.equal(true)
            expect(done[3]).to.equal(true)

            signal:destroy()
        end)

        it("should queue passed args and fire the first connection made with all of them if queueing enabled", function()
            local signal = Signal.new()
            signal:enableQueueing()

            local count = 0

            signal:fire(1)
            signal:fire(2)
            signal:fire(10)

            signal:connect(function(value)
                count += value
            end)

            expect(count).to.equal(13)

            signal:destroy()
        end)

        it("should not fire the first connection with queued args if the args are flushed first if queueing enabled", function()
            local signal = Signal.new()
            signal:enableQueueing()

            local done = false

            signal:fire(true)
            signal:flush()

            signal:connect(function(value)
                done = value
            end)

            expect(done).to.equal(false)

            signal:fire(true)
            expect(done).to.equal(true)

            signal:destroy()
        end)

        it("should not queue passed args and fire the first connection with them if queueing disabled", function()
            local signal = Signal.new()
            local done = false

            signal:fire(true)

            signal:connect(function(value)
                done = value
            end)

            expect(done).to.equal(false)

            signal:destroy()
        end)

        it("should fire connected connections with the passed args", function()
            local signal = Signal.new()
            local count = 0

            signal:connect(function(inc)
                count += inc
            end)

            signal:connect(function(inc)
                count += inc * 2
            end)

            signal:fire(1)
            expect(count).to.equal(3)
            
            signal:destroy()
        end)

        it("should fire disconnected connections that were disconnected during :fire if not deferred", function()
            local signal = Signal.new()
            local done0, done1 = false, false

            local connection = signal:connect(function(bool)
                done0 = bool
            end)

            signal:connect(function(bool)
                done1 = bool
                connection:disconnect()

                -- This test and those similar to it work based on assumptions in the order of how handlers are called
                -- The order that handlers are called isn't behavior to rely on but I think it's important to have
                -- well defined behavior.
            end)

            signal:fire(true)

            expect(done0).to.equal(true)
            expect(done1).to.equal(true)

            signal:destroy()
        end)

        it("should not fire disconnected connections that were disconnected outside :fire if not deferred", function()
            local signal = Signal.new()
            local done0, done1 = false, false

            local connection = signal:connect(function(bool)
                done0 = bool
            end)

            signal:connect(function(bool)
                done1 = bool
            end)

            connection:disconnect()
            signal:fire(true)

            expect(done0).to.equal(false)
            expect(done1).to.equal(true)
            
            signal:destroy()
        end)

        it("should fire connections connected at the time of fire call with the passed args at the end of the frame if deferred", function()
            local signal = Signal.new()
            signal:enableDeferred()

            local done0, done1, done2 = false, false, false

            signal:connect(function(bool)
                done0 = bool
            end)

            signal:connect(function(bool)
                done1 = bool
            end)

            signal:fire(true)

            signal:connect(function(bool)
                done2 = bool
            end)

            -- Should be false since the fire call is deferred until the end of the frame

            expect(done0).to.equal(false)
            expect(done1).to.equal(false)
            expect(done2).to.equal(false)

            RunService.RenderStepped:Wait()

            expect(done0).to.equal(true)
            expect(done1).to.equal(true)
            expect(done2).to.equal(false)

            signal:destroy()
        end)

        it("should fire disconnected connections at the end of the frame that were disconnected from between the fire call to the end of the frame if deferred", function()
            local signal = Signal.new()
            signal:enableDeferred()

            local done0, done1 = false, false

            signal:connect(function(bool)
                done0 = bool
            end)

            signal:connect(function(bool)
                done1 = bool
            end)

            signal:fire(true)

            expect(done0).to.equal(false)
            expect(done1).to.equal(false)

            signal:disconnectAll()
            RunService.RenderStepped:Wait()

            expect(done0).to.equal(true)
            expect(done1).to.equal(true)

            signal:destroy()
        end)

        it("should not fire disconnected connections at the end of the frame that were disconnected outside the deferred fire call to the end of the frame if deferred", function()
            local signal = Signal.new()
            signal:enableDeferred()

            local done = false

            signal:connect(function(bool)
                done = bool
            end)
            
            signal:disconnectAll()
            signal:fire(true)

            expect(done).to.equal(false)

            RunService.RenderStepped:Wait()

            expect(done).to.equal(false)

            signal:destroy()
        end)

        it("should not fire connected connections that were connected after the fire call if deferred", function()
            local signal = Signal.new()
            signal:enableDeferred()

            local done = false

            signal:fire(true)

            signal:connect(function(bool)
                done = bool
            end)

            RunService.RenderStepped:Wait()
            expect(done).to.equal(false)

            signal:fire(true)

            RunService.RenderStepped:Wait()
            expect(done).to.equal(true)

            signal:destroy()
        end)
    end)
    
    describe("Signal:wait", function()
        it("should yield until signal is fired and return passed args from fire call", function()
            local signal = Signal.new()
            local result = false

            task.spawn(function()
                result = signal:wait()
            end)

            expect(result).to.equal(false)
            signal:fire(true)
            expect(result).to.equal(true)

            signal:destroy()
        end)

        it("if args are queued, it should return with args popped from the queue if args are queued", function()
            local signal = Signal.new()
            signal:enableQueueing()

            signal:fire(0)
            signal:fire(1)
            signal:fire(2)

            local popped0 = signal:wait()
            local popped1 = signal:wait()
            local popped2 = signal:wait()

            expect(popped0).to.equal(0)
            expect(popped1).to.equal(1)
            expect(popped2).to.equal(2)

            signal:destroy()
        end)
    end)
    
    describe("Signal:promise", function()
        it("should return a promise", function()
            local signal = Signal.new()
            local promise = signal:promise()

            expect(Promise.is(promise)).to.equal(true)

            signal:destroy()
        end)

        it("should return a promise that resolves with the args passed in the next fire call", function()
            local signal = Signal.new()
            local result = false

            signal:promise():andThen(function(value)
                result = value
            end)

            expect(result).to.equal(false)
            signal:fire(true)
            expect(result).to.equal(true)

            signal:destroy()
        end)

        it("should return a promise that resolves with args popped from the queue if args are queued", function()
            local signal = Signal.new()
            signal:enableQueueing()

            local result = 2

            signal:fire(0)
            signal:fire(1)
            
            expect(select(2, signal:promise():await())).to.equal(0)
            expect(select(2, signal:promise():await())).to.equal(1)

            signal:promise():andThen(function(value)
                result = value
            end)

            signal:fire(2)
            expect(result).to.equal(2)

            signal:destroy()
        end)
    end)
    
    describe("Signal:connect", function()
        it("should return a connection object that uses the passed handler", function()
            local signal = Signal.new()
            local connection = signal:connect(function() end)
            
            expect(connection).to.be.a("table")
            expect(getmetatable(connection)).to.equal(Connection)

            signal:destroy()
        end)

        it("should return a connection that is connected initially", function()
            local signal = Signal.new()
            local connection = signal:connect(function() end)

            expect(connection.connected).to.equal(true)

            signal:destroy()
        end)

        it("should call an onActivated callback if it's set and it's the only connection", function()
            local signal = Signal.new()
            local value = 0

            signal:setActivatedCallback(function()
                value += 1
            end)

            expect(value).to.equal(0)
            
            signal:connect(function() end):disconnect()
            expect(value).to.equal(1)
            
            signal:connect(function() end)
            expect(value).to.equal(2)

            signal:connect(function() end)
            expect(value).to.equal(2)

            signal:destroy()
        end)

        it("should throw within connection handler if connection is disconnected from inside handler if args are queued", function()
            local signal = Signal.new()
            signal:enableQueueing()

            local count = 0
            local connection

            signal:fire(1)
            signal:fire(2)
            signal:fire(10)

            connection = signal:connect(function()
                expect(function()
                    connection:disconnect()
                end).to.throw()
            end)

            signal:destroy()
        end)

        it("should not throw if connection is disconnected from inside handler if args not queued", function()
            local signal = Signal.new()
            local connection

            expect(function()
                connection = signal:connect(function()
                    connection:disconnect()
                end)
            end).to.never.throw()

            signal:destroy()
        end)

        it("should fire the connection with all queued args in FIFO order if args are queued", function()
            local signal = Signal.new()
            signal:enableQueueing()

            local output = {}

            signal:fire(1)
            signal:fire(2)
            signal:fire(10)

            signal:connect(function(value)
                table.insert(output, value)
            end)

            expect(output[1]).to.equal(1)
            expect(output[2]).to.equal(2)
            expect(output[3]).to.equal(10)

            signal:destroy()
        end)
    end)
    
    describe("Signal:disconnectAll", function()
        it("should disconnect all connected connections", function()
            local signal = Signal.new()
            local connection0 = signal:connect(function() end)
            local connection1 = signal:connect(function() end)

            expect(connection0.connected).to.equal(true)
            expect(connection1.connected).to.equal(true)

            signal:disconnectAll()

            expect(connection0.connected).to.equal(false)
            expect(connection1.connected).to.equal(false)

            signal:destroy()
        end)

        it("should call a onDeactivated callback if it's set", function()
            local signal = Signal.new()
            local value = 0

            signal:setDeactivatedCallback(function()
                value += 1
            end)

            signal:connect(function() end)
            expect(value).to.equal(0)

            signal:disconnectAll()
            expect(value).to.equal(1)

            signal:destroy()
        end)
    end)

    describe("Signal:destroy", function()
        it("should set destroyed field to true", function()
            local signal = Signal.new()

            signal:destroy()

            expect(signal.destroyed).to.equal(true)
        end)

        it("should disconnect all connected connections", function()
            local signal = Signal.new()
            local connection0 = signal:connect(function() end)
            local connection1 = signal:connect(function() end)

            expect(connection0.connected).to.equal(true)
            expect(connection1.connected).to.equal(true)

            signal:destroy()

            expect(connection0.connected).to.equal(false)
            expect(connection1.connected).to.equal(false)
        end)

        it("should call a onDeactivated callback if it's set", function()
            local signal = Signal.new()
            local value = 0

            signal:setDeactivatedCallback(function()
                value += 1
            end)

            signal:connect(function() end)
            expect(value).to.equal(0)

            signal:destroy()
            expect(value).to.equal(1)
        end)
    end)
end