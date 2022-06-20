return function()
    local Server = require(script.Parent.Server)
    local RemoteEventClient = require(script.Parent.RemoteEventClient)

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

        it("should pass deep copies of data and convert instance keys to strings", function()
            local server = Server.new()
            local user = server:connect("user")
            
            local remoteEvent = server:createRemoteEvent("remoteEvent")

            local part = Instance.new("Part")

            local data = {
                a = {[part] = 1},
                b = {key = 2},
            }

            user:getRemoteEvent("remoteEvent"):fireServer(data, data, part)

            local _, data1, data2, passedPart = remoteEvent.OnServerEvent:wait()

            expect(data1).to.never.equal(data)
            expect(data2).to.never.equal(data)

            expect(data1).to.never.equal(data2)

            expect(data1.a[part]).to.never.be.ok()
            expect(data1.a["<Instance> (Part)"]).to.equal(1)

            expect(data2.a[part]).to.never.be.ok()
            expect(data2.a["<Instance> (Part)"]).to.equal(1)

            expect(passedPart).to.equal(part)

            part:Destroy()
            server:destroy()
        end)
    end)
end