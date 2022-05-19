return function()
    local Server = require(script.Parent.Server)
    local RemoteEventClient = require(script.Parent.RemoteEventClient)

    describe("RemoteEventClient.is", function()
        it("should return true if passed object is a RemoteEventClient", function()
            local server = Server.new()
            local client = server:connect("user")

            server:createRemoteEvent("remoteEvent")

            expect(RemoteEventClient.is(client:getRemoteEvent("remoteEvent"))).to.equal(true)

            server:destroy()
        end)

        it("should return false if passed object is not a RemoteEventClient", function()
            expect(RemoteEventClient.is(false)).to.equal(false)
            expect(RemoteEventClient.is(true)).to.equal(false)
            expect(RemoteEventClient.is(0)).to.equal(false)
            expect(RemoteEventClient.is({})).to.equal(false)
        end)
    end)

    describe("RemoteEventClient:fireServer", function()
        it("should fire the remoteEventServer OnServerEvent signal with the client and passed args", function()
            local server = Server.new()
            local user = server:connect("user")

            server:createRemoteEvent("remoteEvent").OnServerEvent:connect(function(client, value)
                expect(client).to.equal(user)
                expect(value).to.equal(0)
            end)

            user:getRemoteEvent("remoteEvent"):fireServer(0)
            server:destroy()
        end)

        it("should queue passed args on server until an activating connection is made to the remoteEventServer OnServerEvent signal", function()
            local server = Server.new()
            local user = server:connect("user")

            local remoteEvent = server:createRemoteEvent("remoteEvent")
            local done = {}

            user:getRemoteEvent("remoteEvent"):fireServer(2)
            user:getRemoteEvent("remoteEvent"):fireServer(1)

            local count = 0

            remoteEvent.OnServerEvent:connect(function(client, value)
                expect(client).to.equal(user)
                count += value
            end)
            
            expect(count).to.equal(3)

            server:destroy()
        end)
    end)
end