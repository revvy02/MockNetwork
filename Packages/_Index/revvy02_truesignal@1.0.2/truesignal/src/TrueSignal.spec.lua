local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Parent.Promise)

local TrueSignal = require(script.Parent)
local Connection = require(script.Parent.Connection)

return function()
    describe("TrueSignal.new", function()
        it("should create a new signal object", function()
            local signal = TrueSignal.new()

            expect(signal).to.be.a("table")
            expect(getmetatable(signal)).to.equal(TrueSignal)

            signal:destroy()
        end)
    end)
    
    describe("TrueSignal:fire", function()
        it("should fire connections with multiple args", function()
            local signal = TrueSignal.new()
            local done = {}

            local connection = signal:connect(function(...)
                table.insert(done, table.pack(...))
            end)

            signal:fire(1, 2, 3)
            signal:fire("Hello ", "friend")

            expect(done[1].n).to.equal(3)
            expect(done[1][1]).to.equal(1)
            expect(done[1][2]).to.equal(2)
            expect(done[1][3]).to.equal(3)

            expect(done[2].n).to.equal(2)
            expect(done[2][1]).to.equal("Hello ")
            expect(done[2][2]).to.equal("friend")

            connection:destroy()
            signal:destroy()
        end)

        it("should fire connected connections immediately if deferred=false", function()
            local signal = TrueSignal.new()
            local done1, done2 = {}, {}

            local connection1 = signal:connect(function(index)
                done1[index] = true
            end)

            signal:fire(1)

            local connection2 = signal:connect(function(index)
                done2[index] = true
            end)

            signal:fire(2)

            expect(done1[1]).to.be.ok()
            expect(done1[2]).to.be.ok()

            expect(done2[1]).to.never.be.ok()
            expect(done2[2]).to.be.ok()

            connection1:destroy()
            connection2:destroy()
            signal:destroy()
        end)

        it("should fire connected connections end-of-frame if deferred=true", function()
            local signal = TrueSignal.new(true)
            local done1, done2 = {}, {}

            local connection1 = signal:connect(function(index)
                done1[index] = true
            end)

            signal:fire(1)

            local connection2 = signal:connect(function(index)
                done2[index] = true
            end)

            signal:fire(2)

            expect(done1[1]).to.never.be.ok()
            expect(done1[2]).to.never.be.ok()
            
            expect(done2[1]).to.never.be.ok()
            expect(done2[2]).to.never.be.ok()

            task.defer(task.spawn, coroutine.running())
            coroutine.yield()
            
            expect(done1[1]).to.be.ok()
            expect(done1[2]).to.be.ok()
            
            expect(done2[1]).to.never.be.ok()
            expect(done2[2]).to.be.ok()

            connection1:destroy()
            connection2:destroy()
            signal:destroy()
        end)
    end)

    describe("TrueSignal:connect", function()
        it("should return a connection that is connected initially", function()
            local signal = TrueSignal.new()
            local connection = signal:connect(function() end)

            expect(connection).to.be.a("table")
            expect(getmetatable(connection)).to.equal(Connection)

            expect(connection.connected).to.equal(true)
            
            signal:destroy()
        end)

        it("should throw connection handler if connection is disconnected from inside handler if deferred=false and queueing=true", function()
            local signal = TrueSignal.new(false, true)

            local passes, fails = 0, 0
            local connection

            signal:fire()
            signal:fire()

            connection = signal:connect(function()
                local success = pcall(function()
                    connection:disconnect()
                end)

                if success then
                    passes += 1
                else
                    fails += 1
                end
            end)

            expect(passes).to.equal(0)
            expect(fails).to.equal(2)

            connection:destroy()
            signal:destroy()
        end)

        it("should fire the connection immediately with queued args if deferred=false and queueing=true", function()
            local signal = TrueSignal.new(false, true)
            local done = {}

            signal:fire(1)
            signal:fire(2)

            signal:connect(function(index)
                done[index] = true
            end)

            expect(done[1]).to.be.ok()
            expect(done[2]).to.be.ok()

            signal:destroy()
        end)

        it("should fire the connection end-of-frame with queued args if deferred=true and queueing=true", function()
            local signal = TrueSignal.new(true, true)
            local done = {}

            signal:fire(1)
            signal:fire(2)

            signal:connect(function(index)
                done[index] = true
            end)

            expect(done[1]).to.never.be.ok()
            expect(done[2]).to.never.be.ok()

            task.defer(task.spawn, coroutine.running())
            coroutine.yield()

            expect(done[1]).to.be.ok()
            expect(done[2]).to.be.ok()

            signal:destroy()
        end)
    end)

    describe("TrueSignal:flush", function()
        it("should remove any queued args and work properly if deferred=false", function()
            local signal = TrueSignal.new(false, true)
            
            signal:fire(1)
            signal:fire(2)

            signal:flush()

            signal:fire(3)

            expect(signal:wait()).to.equal(3)

            signal:destroy()
        end)

        it("should remove any queued args and work properly if deferred=true", function()
            local signal = TrueSignal.new(true, true)
            
            signal:fire(1)
            signal:fire(2)

            signal:flush()

            signal:fire(3)

            expect(signal:wait()).to.equal(3)

            signal:destroy()
        end)
    end)
    
    describe("TrueSignal:wait", function()
        it("should yield until signal is fired and return passed args from the fire call if deferred=false and queueing=false", function()
            local signal = TrueSignal.new()
            local message1, message2

            task.spawn(function()
                message1, message2 = signal:wait()
            end)

            expect(message1).to.never.be.ok()
            expect(message2).to.never.be.ok()

            signal:fire("two", "messages")

            expect(message1).to.equal("two")
            expect(message2).to.equal("messages")

            signal:destroy()
        end)

        it("should yield until end of frame when signal is fired and return passed args from the fire call if deferred=true and queueing=false", function()
            local signal = TrueSignal.new(true)
            local message1, message2

            task.spawn(function()
                message1, message2 = signal:wait()
            end)

            expect(message1).to.never.be.ok()
            expect(message2).to.never.be.ok()

            signal:fire("two", "messages")

            expect(message1).to.never.be.ok()
            expect(message2).to.never.be.ok()

            task.defer(task.spawn, coroutine.running())
            coroutine.yield()

            expect(message1).to.equal("two")
            expect(message2).to.equal("messages")

            signal:destroy()
        end)

        it("it should return args popped from the queue immediately deferred=false and queueing=true", function()
            local signal = TrueSignal.new(false, true)

            signal:fire(1)
            signal:fire(2)

            local popped1 = signal:wait()
            local popped2 = signal:wait()

            expect(popped1).to.equal(1)
            expect(popped2).to.equal(2)

            signal:destroy()
        end)

        it("it should return args popped from the queue at the end of the frame if deferred=true and queueing=true", function()
            local signal = TrueSignal.new(true, true)
            local popped1, popped2

            signal:fire(1)
            signal:fire(2)

            task.spawn(function()
                popped1 = signal:wait()
            end)
            
            task.spawn(function()
                popped2 = signal:wait()
            end)

            expect(popped1).to.never.be.ok()
            expect(popped2).to.never.be.ok()

            task.defer(task.spawn, coroutine.running())
            coroutine.yield()

            expect(popped1).to.equal(1)
            expect(popped2).to.equal(2)

            signal:destroy()
        end)
    end)
    
    describe("TrueSignal:promise", function()
        it("should return a promise that resolves immediately with the args passed in the next fire call if deferred=false and queueing=false", function()
            local signal = TrueSignal.new()
            local promise = signal:promise()

            expect(promise:getStatus()).to.equal(Promise.Status.Started)

            signal:fire("message")

            expect(promise:getStatus()).to.equal(Promise.Status.Resolved)
            expect(promise:expect()).to.equal("message")

            signal:destroy()
        end)

        it("should return a promise that resolves at the end of the frame with the args passed in the next fire call if deferred=true and queueing=false", function()
            local signal = TrueSignal.new(true)
            local promise = signal:promise()

            expect(promise:getStatus()).to.equal(Promise.Status.Started)

            signal:fire("message")

            expect(promise:getStatus()).to.equal(Promise.Status.Started)

            task.defer(task.spawn, coroutine.running())
            coroutine.yield()

            expect(promise:expect()).to.equal("message")

            signal:destroy()
        end)

        it("should return a promise that resolves immediately with args popped from the queue if deferred=false and queueing=true", function()
            local signal = TrueSignal.new(false, true)

            signal:fire(1)
            signal:fire(2)
            
            expect(signal:promise():expect()).to.equal(1)
            expect(signal:promise():expect()).to.equal(2)

            signal:destroy()
        end)

        it("should return a promise that resolves at the end of the frame with args popped from the queue if deferred=true and queueing=true", function()
            local signal = TrueSignal.new(true, true)

            signal:fire(1)
            signal:fire(2)
            
            local promise1 = signal:promise()
            local promise2 = signal:promise()
            
            expect(promise1:getStatus()).to.equal(Promise.Status.Started)
            expect(promise2:getStatus()).to.equal(Promise.Status.Started)

            task.defer(task.spawn, coroutine.running())
            coroutine.yield()

            expect(promise1:getStatus()).to.equal(Promise.Status.Resolved)
            expect(promise2:getStatus()).to.equal(Promise.Status.Resolved)

            expect(promise1:expect()).to.equal(1)
            expect(promise2:expect()).to.equal(2)

            signal:destroy()
        end)
    end)
    


    describe("TrueSignal:destroy", function()
        it("should set destroyed field to true", function()
            local signal = TrueSignal.new()

            signal:destroy()

            expect(signal.destroyed).to.equal(true)
        end)

        it("should disconnect all connected connections", function()
            local signal = TrueSignal.new()

            local connection1 = signal:connect(function() end)
            local connection2 = signal:connect(function() end)

            expect(connection1.connected).to.equal(true)
            expect(connection2.connected).to.equal(true)

            signal:destroy()

            expect(connection1.connected).to.equal(false)
            expect(connection2.connected).to.equal(false)
        end)
    end)
end