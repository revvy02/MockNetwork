return function()
    local MockRemoteEvent = require(script.Parent.MockRemoteEvent)

    describe("MockRemoteEvent.new", function()
        it("should create a new MockRemoteEvent", function()
            local mockRemoteEvent = MockRemoteEvent.new()

            expect(mockRemoteEvent).to.be.ok()
            expect(mockRemoteEvent.is(mockRemoteEvent)).to.equal(true)

            mockRemoteEvent:destroy()
        end)

        it("should create a new MockRemoteEvent with a client id if passed", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")

            expect(mockRemoteEvent:getClient()).to.equal("user")

            mockRemoteEvent:destroy()
        end)
    end)

    describe("MockRemoteEvent.is", function()
        it("should return true if the passed object is a MockRemoteEvent", function()
            local mockRemoteEvent = MockRemoteEvent.new()

            expect(mockRemoteEvent.is(mockRemoteEvent)).to.equal(true)

            mockRemoteEvent:destroy()
        end)

        it("should return false if the passed object is not a MockRemoteEvent", function()
            expect(MockRemoteEvent.is(0)).to.equal(false)
            expect(MockRemoteEvent.is(false)).to.equal(false)
            expect(MockRemoteEvent.is(true)).to.equal(false)
            expect(MockRemoteEvent.is({})).to.equal(false)
        end)
    end)

    describe("MockRemoteEvent:fireServer", function()
        it("should fire OnServerEvent with the client and passed args", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")
            local client, value

            task.spawn(function()
                client, value = mockRemoteEvent.OnServerEvent:wait()
            end)

            mockRemoteEvent:fireServer(true)

            expect(client).to.equal("user")
            expect(value).to.equal(true)

            mockRemoteEvent:destroy()
        end)

        it("should queue passed args on the server until an activating connection is made", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")
            local count = 0

            mockRemoteEvent:fireServer(1)
            mockRemoteEvent:fireServer(2)

            mockRemoteEvent.OnServerEvent:connect(function(_, value)
                count += value
            end)

            expect(count).to.equal(3)

            mockRemoteEvent:destroy()
        end)
    end)

    describe("MockRemoteEvent:fireClient", function()
        it("should fire OnClientEvent with the passed args if initial client arg is the client passed in the constructor", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")
            local value0, value1

            task.spawn(function()
                value0, value1 = mockRemoteEvent.OnClientEvent:wait()
            end)

            mockRemoteEvent:fireClient("user", 0, 1)
            
            expect(value0).to.equal(0)
            expect(value1).to.equal(1)

            mockRemoteEvent:destroy()
        end)

        it("should queue passed args on client until an activating connection is made", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")
            local value0, value1

            mockRemoteEvent:fireClient("user", 0, 1)

            value0, value1 = mockRemoteEvent.OnClientEvent:wait()

            expect(value0).to.equal(0)
            expect(value1).to.equal(1)

            mockRemoteEvent:destroy()
        end)

        it("should throw if the initial client arg is incorrect", function()
            local mockRemoteEvent = MockRemoteEvent.new()
            
            expect(function()
                mockRemoteEvent:fireClient("user", 0, 1)
            end).to.throw()

            mockRemoteEvent:destroy()
        end)
    end)

    describe("MockRemoteEvent:fireAllClients", function()
        it("should fire OnClientEvent with the passed args", function()
            local mockRemoteEvent = MockRemoteEvent.new()
            local value0, value1

            task.spawn(function()
                value0, value1 = mockRemoteEvent.OnClientEvent:wait()
            end)

            mockRemoteEvent:fireAllClients(0, 1)
            
            expect(value0).to.equal(0)
            expect(value1).to.equal(1)

            mockRemoteEvent:destroy()
        end)

        it("should queue passed args on client until an activating connection is made", function()
            local mockRemoteEvent = MockRemoteEvent.new()
            local value0, value1

            mockRemoteEvent:fireAllClients(0, 1)

            value0, value1 = mockRemoteEvent.OnClientEvent:wait()

            expect(value0).to.equal(0)
            expect(value1).to.equal(1)

            mockRemoteEvent:destroy()
        end)
    end)

    describe("MockRemoteEvent:getClient", function()
        it("should return client passed in constructor", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")

            expect(mockRemoteEvent:getClient()).to.equal("user")

            mockRemoteEvent:destroy()
        end)
    end)

    describe("MockRemoteEvent:destroy", function()
        it("should set destroyed field to true", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")

            mockRemoteEvent:destroy()

            expect(mockRemoteEvent.destroyed).to.equal(true)
        end)
    end)
end