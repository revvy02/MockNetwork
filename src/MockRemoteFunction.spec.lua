return function()
    local MockRemoteFunction = require(script.Parent.MockRemoteFunction)

    describe("MockRemoteFunction.new", function()
        it("should create a new MockRemoteFunction", function()
            local mockRemoteFunction = MockRemoteFunction.new()

            expect(mockRemoteFunction).to.be.a("table")
            expect(getmetatable(mockRemoteFunction)).to.equal(MockRemoteFunction)

            mockRemoteFunction:destroy()
        end)

        it("should create a new MockRemoteFunction with a client id if passed", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")

            expect(mockRemoteFunction:getClient()).to.equal("user")

            mockRemoteFunction:destroy()

        end)

        it("should have a readable OnClientInvoke property", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")

            expect(mockRemoteFunction.OnClientInvoke).to.equal(nil)

            local function onClientInvoke()
                
            end

            mockRemoteFunction.OnClientInvoke = onClientInvoke
            expect(mockRemoteFunction.OnClientInvoke).to.equal(onClientInvoke)

            mockRemoteFunction:destroy()
        end)

        it("should have a readable OnServerInvoke property", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")

            expect(mockRemoteFunction.OnServerInvoke).to.equal(nil)

            local function onServerInvoke()
                
            end

            mockRemoteFunction.OnServerInvoke = onServerInvoke
            expect(mockRemoteFunction.OnServerInvoke).to.equal(onServerInvoke)

            mockRemoteFunction:destroy()
        end)
    end)

    describe("MockRemoteFunction:invokeServer", function()
        it("should return a response from the request if a handler exists", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")

            mockRemoteFunction.OnServerInvoke = function(_, value)
                return value * 2
            end

            expect(mockRemoteFunction:invokeServer(1)).to.equal(2)

            mockRemoteFunction:destroy()
        end)

        it("should queue the request if a handler doesn't exist and respond once it does", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")
            local count = 0

            --[[
                ran into a bug where
                doing count += mockRemoteFunction:invokeServer(...) would make tests fail,
                this is because it's adding the result of the invoke to the value of count before it finishes
                (fixed now)
            ]]

            task.spawn(function()
                local new = mockRemoteFunction:invokeServer(1)
                count += new
            end)

            task.spawn(function()
                local new = mockRemoteFunction:invokeServer(2)
                count += new
            end)

            mockRemoteFunction.OnServerInvoke = function(_, value)
                return value * 2
            end

            expect(count).to.equal(6)

            mockRemoteFunction:destroy()
        end)

        it("should pass deep copies of data and convert instance keys to strings", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")
            local part = Instance.new("Part")

            local data = {
                a = {[part] = 1},
                b = {key = 2},
            }

            task.spawn(function()
                mockRemoteFunction:invokeServer( data, data, part)
            end)

            local data1, data2, passedPart

            mockRemoteFunction.OnServerInvoke = function(_, ...)
                data1, data2, passedPart = ...
            end

            expect(data1).to.never.equal(data)
            expect(data2).to.never.equal(data)

            expect(data1).to.never.equal(data2)

            expect(data1.a[part]).to.never.be.ok()
            expect(data1.a["<Instance> (Part)"]).to.equal(1)

            expect(data2.a[part]).to.never.be.ok()
            expect(data2.a["<Instance> (Part)"]).to.equal(1)

            expect(passedPart).to.equal(part)

            part:Destroy()
            mockRemoteFunction:destroy()
        end)

    end)

    describe("MockRemoteFunction:invokeClient", function()
        it("should return a response from the request if a handler exists", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")
            
            mockRemoteFunction.OnClientInvoke = function(value)
                return value * 2
            end

            expect(mockRemoteFunction:invokeClient("user", 1)).to.equal(2)

            mockRemoteFunction:destroy()
        end)

        it("should queue the request if a handler doesn't exist and respond once it does", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")
            local count = 0

            task.spawn(function()
                local new = mockRemoteFunction:invokeClient("user", 1)
                count += new
            end)

            task.spawn(function()
                local new = mockRemoteFunction:invokeClient("user", 2)
                count += new
            end)

            mockRemoteFunction.OnClientInvoke = function(value)
                return value * 2
            end

            expect(count).to.equal(6)

            mockRemoteFunction:destroy()
        end)

        it("should throw if the initial client arg is incorrect", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")

            expect(function()
                mockRemoteFunction:invokeClient("player", 1)
            end).to.throw()

            mockRemoteFunction:destroy()
        end)

        it("should pass deep copies of data and convert instance keys to strings", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")
            local part = Instance.new("Part")

            local data = {
                a = {[part] = 1},
                b = {key = 2},
            }

            task.spawn(function()
                mockRemoteFunction:invokeClient("user", data, data, part)
            end)

            local data1, data2, passedPart

            mockRemoteFunction.OnClientInvoke = function(...)
                data1, data2, passedPart = ...
            end

            expect(data1).to.never.equal(data)
            expect(data2).to.never.equal(data)

            expect(data1).to.never.equal(data2)

            expect(data1.a[part]).to.never.be.ok()
            expect(data1.a["<Instance> (Part)"]).to.equal(1)

            expect(data2.a[part]).to.never.be.ok()
            expect(data2.a["<Instance> (Part)"]).to.equal(1)

            expect(passedPart).to.equal(part)

            part:Destroy()
            mockRemoteFunction:destroy()
        end)
    end)

    describe("MockRemoteFunction:getClient", function()
        it("should return client passed in constructor", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")

            expect(mockRemoteFunction:getClient()).to.equal("user")

            mockRemoteFunction:destroy()
        end)
    end)

    describe("MockRemoteFunction:destroy", function()
        it("should set destroyed field to true", function()
            local mockRemoteFunction = MockRemoteFunction.new("user")

            mockRemoteFunction:destroy()

            expect(mockRemoteFunction.destroyed).to.equal(true)
        end)
    end)
end