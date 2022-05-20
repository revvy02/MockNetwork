return function()
    local MockRemoteFunction = require(script.Parent.MockRemoteFunction)

    describe("MockRemoteFunction.new", function()
        it("should create a new MockRemoteFunction", function()
            local mockRemoteFunction = MockRemoteFunction.new()

            expect(mockRemoteFunction).to.be.ok()
            expect(mockRemoteFunction.is(mockRemoteFunction)).to.equal(true)

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

    describe("MockRemoteFunction.is", function()
        it("should return true if the passed object is a MockRemoteFunction", function()
            local mockRemoteFunction = MockRemoteFunction.new()

            expect(mockRemoteFunction.is(mockRemoteFunction)).to.equal(true)

            mockRemoteFunction:destroy()
        end)

        it("should return false if the passed object is not a MockRemoteFunction", function()
            expect(MockRemoteFunction.is(0)).to.equal(false)
            expect(MockRemoteFunction.is(false)).to.equal(false)
            expect(MockRemoteFunction.is(true)).to.equal(false)
            expect(MockRemoteFunction.is({})).to.equal(false)
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