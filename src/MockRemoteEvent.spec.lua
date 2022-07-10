return function()
    local MockRemoteEvent = require(script.Parent.MockRemoteEvent)

    describe("MockRemoteEvent.new", function()
        it("should create a new MockRemoteEvent", function()
            local mockRemoteEvent = MockRemoteEvent.new()

            expect(mockRemoteEvent).to.be.a("table")
            expect(getmetatable(mockRemoteEvent)).to.equal(MockRemoteEvent)

            mockRemoteEvent:destroy()
        end)

        it("should create a new MockRemoteEvent with a client id if passed", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")

            expect(mockRemoteEvent:getClient()).to.equal("user")

            mockRemoteEvent:destroy()
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

        it("should throw if tables with cyclic values are passed", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")

            local data = {
                a = 1,
            }

            data.b = data

            expect(function()
                mockRemoteEvent:fireServer(data)
            end).to.throw()

            mockRemoteEvent:destroy()
        end)

        it("should pass deep copies of data and convert instance and table keys to strings", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")
            local part = Instance.new("Part")

            local tab = {ok = 1}

            local data = {
                a = {[part] = 1},
                b = {key = 2},
                [tab] = 3,
            }

            mockRemoteEvent:fireServer(data, data, part)

            local _, data1, data2, passedPart = mockRemoteEvent.OnServerEvent:wait()

            expect(data1).to.never.equal(data)
            expect(data2).to.never.equal(data)

            expect(data1).to.never.equal(data2)

            expect(data1.a[part]).to.never.be.ok()
            expect(data1.a["<Instance> (Part)"]).to.equal(1)

            expect(data2.a[part]).to.never.be.ok()
            expect(data2.a["<Instance> (Part)"]).to.equal(1)

            expect(data1[tab]).to.never.be.ok()
            expect(data1["<Table> ("..tostring(tab)..")"]).to.equal(3)

            expect(data2[tab]).to.never.be.ok()
            expect(data2["<Table> ("..tostring(tab)..")"]).to.equal(3)

            expect(passedPart).to.equal(part)

            part:Destroy()
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

        it("should throw if tables with cyclic values are passed", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")

            local data = {
                a = 1,
            }

            data.b = data

            expect(function()
                mockRemoteEvent:fireClient("user", data)
            end).to.throw()

            mockRemoteEvent:destroy()
        end)

        it("should pass deep copies of data and convert instance and table keys to strings", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")
            local part = Instance.new("Part")

            local tab = {ok = 1}

            local data = {
                a = {[part] = 1},
                b = {key = 2},
                [tab] = 3,
            }

            mockRemoteEvent:fireClient("user", data, data, part)

            local data1, data2, passedPart = mockRemoteEvent.OnClientEvent:wait()

            expect(data1).to.never.equal(data)
            expect(data2).to.never.equal(data)

            expect(data1).to.never.equal(data2)
            
            expect(data1.a[part]).to.never.be.ok()
            expect(data1.a["<Instance> (Part)"]).to.equal(1)
            
            expect(data2.a[part]).to.never.be.ok()
            expect(data2.a["<Instance> (Part)"]).to.equal(1)

            expect(data1[tab]).to.never.be.ok()
            expect(data1["<Table> ("..tostring(tab)..")"]).to.equal(3)

            expect(data2[tab]).to.never.be.ok()
            expect(data2["<Table> ("..tostring(tab)..")"]).to.equal(3)

            expect(passedPart).to.equal(part)

            part:Destroy()
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

        it("should throw if tables with cyclic values are passed", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")

            local data = {
                a = 1,
            }

            data.b = data

            expect(function()
                mockRemoteEvent:fireAllClients(data)
            end).to.throw()

            mockRemoteEvent:destroy()
        end)

        it("should pass deep copies of data and convert instance and table keys to strings", function()
            local mockRemoteEvent = MockRemoteEvent.new("user")
            local part = Instance.new("Part")

            local tab = {ok = 1}

            local data = {
                a = {[part] = 1},
                b = {key = 2},
                [tab] = 3,
            }

            mockRemoteEvent:fireAllClients(data, data, part)

            local data1, data2, passedPart = mockRemoteEvent.OnClientEvent:wait()

            expect(data1).to.never.equal(data)
            expect(data2).to.never.equal(data)

            expect(data1).to.never.equal(data2)
            
            expect(data1.a[part]).to.never.be.ok()
            expect(data1.a["<Instance> (Part)"]).to.equal(1)
            
            expect(data2.a[part]).to.never.be.ok()
            expect(data2.a["<Instance> (Part)"]).to.equal(1)

            expect(data1[tab]).to.never.be.ok()
            expect(data1["<Table> ("..tostring(tab)..")"]).to.equal(3)

            expect(data2[tab]).to.never.be.ok()
            expect(data2["<Table> ("..tostring(tab)..")"]).to.equal(3)

            expect(passedPart).to.equal(part)

            part:Destroy()
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