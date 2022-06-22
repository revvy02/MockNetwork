return function()
    local Server = require(script.Parent.Server)
    local Client = require(script.Parent.Client)

    local RemoteEventClient = require(script.Parent.RemoteEventClient)
    local RemoteFunctionClient = require(script.Parent.RemoteFunctionClient)

    describe("Client:getRemoteEvent", function()
        it("should return the client sided RemoteEvent if it exists", function()
            local server = Server.new()
            local client = server:connect("user")

            server:createRemoteEvent("remoteEvent")

            expect(client:getRemoteEvent("remoteEvent")).to.be.a("table")
            expect(getmetatable(client:getRemoteEvent("remoteEvent"))).to.equal(RemoteEventClient)

            server:destroy()
        end)

        it("should throw if it doesn't exist", function()
            local server = Server.new()
            local client = server:connect("user")

            expect(function()
                client:getRemoteEvent("remoteEvent")
            end).to.throw()

            server:destroy()
        end)
    end)

    describe("Client:getRemoteFunction", function()
        it("should return the client sided RemoteFunction if it exists", function()
            local server = Server.new()
            local client = server:connect("user")

            server:createRemoteFunction("remoteFunction")
            
            expect(client:getRemoteFunction("remoteFunction")).to.be.a("table")
            expect(getmetatable(client:getRemoteFunction("remoteFunction"))).to.equal(RemoteFunctionClient)

            server:destroy()
        end)

        it("should throw if it doesn't exist", function()
            local server = Server.new()
            local client = server:connect("user")

            expect(function()
                client:getRemoteFunction("remoteFunction")
            end).to.throw()

            server:destroy()
        end)
    end)

    describe("Client:disconnect", function()
        it("should set connected field set to false", function()
            local server = Server.new()
            local client = server:connect("user")

            client:disconnect()

            expect(client.connected).to.equal(false)

            server:destroy()
        end)

        it("should not exist on server anymore", function()
            local server = Server.new()
            local client = server:connect("user")

            expect(server:getClient("user")).to.be.ok()

            client:disconnect()
            
            expect(server:getClient("user")).to.equal(nil)

            server:destroy()
        end)
    end)

    describe("Client:mapRemoteEvents", function()
        it("should return a dictionary that maps the remoteEvent name to the object if no function is passed", function()
            local server = Server.new()
            local client = server:connect("user")

            server:createRemoteEvent("remoteEvent1")
            server:createRemoteEvent("remoteEvent2")

            local map = client:mapRemoteEvents()

            expect(map.remoteEvent1).to.be.ok()
            expect(map.remoteEvent2).to.be.ok()

            expect(map.remoteEvent1).to.equal(client:getRemoteEvent("remoteEvent1"))
            expect(map.remoteEvent2).to.equal(client:getRemoteEvent("remoteEvent2"))

            server:destroy()
        end)

        it("should return a dictionary that is properly mapped if a function is passed", function()
            local server = Server.new()
            local client = server:connect("user")

            server:createRemoteEvent("remoteEvent1")
            server:createRemoteEvent("remoteEvent2")

            local map = client:mapRemoteEvents(function(name, remoteEvent)
                return string.upper(name), typeof(remoteEvent)
            end)

            expect(map.remoteEvent1).to.never.be.ok()
            expect(map.remoteEvent2).to.never.be.ok()

            expect(map.REMOTEEVENT1).to.equal("table")
            expect(map.REMOTEEVENT2).to.equal("table")

            server:destroy()
        end)
    end)

    describe("Client:mapRemoteFunctions", function()
        it("should return a dictionary that maps the remoteFunction name to the object if no function is passed", function()
            local server = Server.new()
            local client = server:connect("user")

            server:createRemoteFunction("remoteFunction1")
            server:createRemoteFunction("remoteFunction2")

            local map = client:mapRemoteFunctions()

            expect(map.remoteFunction1).to.be.ok()
            expect(map.remoteFunction2).to.be.ok()

            expect(map.remoteFunction1).to.equal(client:getRemoteFunction("remoteFunction1"))
            expect(map.remoteFunction2).to.equal(client:getRemoteFunction("remoteFunction2"))

            server:destroy()
        end)

        it("should return a dictionary that is properly mapped if a function is passed", function()
            local server = Server.new()
            local client = server:connect("user")

            server:createRemoteFunction("remoteFunction1")
            server:createRemoteFunction("remoteFunction2")

            local map = client:mapRemoteFunctions(function(name, remoteFunction)
                return string.upper(name), typeof(remoteFunction)
            end)

            expect(map.remoteFunction1).to.never.be.ok()
            expect(map.remoteFunction2).to.never.be.ok()

            expect(map.REMOTEFUNCTION1).to.equal("table")
            expect(map.REMOTEFUNCTION2).to.equal("table")

            server:destroy()
        end)
    end)


    describe("Client:destroy", function()
        it("should disconect the client", function()
            local server = Server.new()
            local client = server:connect("user")

            client:destroy()

            expect(client.connected).to.equal(false)

            server:destroy()
        end)

        it("should set destroyed field to true", function()
            local server = Server.new()
            local client = server:connect("user")

            client:destroy()

            expect(client.destroyed).to.equal(true)

            server:destroy()
        end)
    end)
end