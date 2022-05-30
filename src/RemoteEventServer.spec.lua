return function()
    local Server = require(script.Parent.Server)
    local RemoteEventServer = require(script.Parent.RemoteEventServer)

    describe("RemoteEventServer:fireClient", function()
        it("should fire the specified client remote event with the passed args", function()
            local server = Server.new()
            local user0 = server:connect("user0")
            local user1 = server:connect("user1")

            local remoteEvent = server:createRemoteEvent("remoteEvent")

            user0:getRemoteEvent("remoteEvent").OnClientEvent:connect(function(value0, value1)
                expect(value0).to.equal(0)
                expect(value1).to.equal(1)
            end)

            user1:getRemoteEvent("remoteEvent").OnClientEvent:connect(function(value2, value3)
                expect(value2).to.equal(2)
                expect(value3).to.equal(3)
            end)

            remoteEvent:fireClient(user0, 0, 1)
            remoteEvent:fireClient(user1, 2, 3)

            server:destroy()
        end)

        it("should queue passed args on client until an activating connection is made to the specified remoteEventClient OnClientEvent signal", function()
            local server = Server.new()
            local user0 = server:connect("user0")
            local user1 = server:connect("user1")

            local remoteEvent = server:createRemoteEvent("remoteEvent")

            remoteEvent:fireClient(user0, 0, 1)
            remoteEvent:fireClient(user1, 2, 3)

            user0:getRemoteEvent("remoteEvent").OnClientEvent:connect(function(value0, value1)
                expect(value0).to.equal(0)
                expect(value1).to.equal(1)
            end)

            user1:getRemoteEvent("remoteEvent").OnClientEvent:connect(function(value2, value3)
                expect(value2).to.equal(2)
                expect(value3).to.equal(3)
            end)

            server:destroy()
        end)
    end)

    describe("RemoteEventServer:fireAllClients", function()
        it("should fire the specified client remote event for all clients with the passed args", function()
            local server = Server.new()
            local user0 = server:connect("user0")
            local user1 = server:connect("user1")

            local remoteEvent = server:createRemoteEvent("remoteEvent")

            user0:getRemoteEvent("remoteEvent").OnClientEvent:connect(function(value0, value1)
                expect(value0).to.equal(0)
                expect(value1).to.equal(1)
            end)

            user1:getRemoteEvent("remoteEvent").OnClientEvent:connect(function(value2, value3)
                expect(value2).to.equal(0)
                expect(value3).to.equal(1)
            end)

            remoteEvent:fireAllClients(0, 1)

            server:destroy()
        end)

        it("should queue passed args on clients until an activating connection is made to the client's remoteEventClient OnClientEvent signal", function()
            local server = Server.new()
            local user0 = server:connect("user0")
            local user1 = server:connect("user1")

            local remoteEvent = server:createRemoteEvent("remoteEvent")

            remoteEvent:fireAllClients(0, 1)

            user0:getRemoteEvent("remoteEvent").OnClientEvent:connect(function(value0, value1)
                expect(value0).to.equal(0)
                expect(value1).to.equal(1)
            end)

            user1:getRemoteEvent("remoteEvent").OnClientEvent:connect(function(value2, value3)
                expect(value2).to.equal(0)
                expect(value3).to.equal(1)
            end)

            server:destroy()
        end)
    end)

    describe("RemoteEventServer:destroy", function()
        it("should remove associated client sided remote events for each client", function()
            local server = Server.new()
            local user0 = server:connect("user0")
            local user1 = server:connect("user1")

            local remoteEvent = server:createRemoteEvent("remoteEvent")

            expect(user0:getRemoteEvent("remoteEvent")).to.be.ok()
            expect(user1:getRemoteEvent("remoteEvent")).to.be.ok()

            remoteEvent:destroy()

            expect(function()
                user0:getRemoteEvent("remoteEvent")
            end).to.throw()
            
            expect(function()
                user1:getRemoteEvent("remoteEvent")
            end).to.throw()

            server:destroy()
        end)

        it("should set destroyed field to true", function()
            local server = Server.new()
            local remoteEvent = server:createRemoteEvent("remoteEvent")

            remoteEvent:destroy()

            expect(remoteEvent.destroyed).to.equal(true)
            
            server:destroy()
        end)
    end)
end