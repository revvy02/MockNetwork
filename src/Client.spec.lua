return function()
    local Server = require(script.Parent.Server)
    local Client = require(script.Parent.Client)

    local RemoteEventClient = require(script.Parent.RemoteEventClient)
    local RemoteFunctionClient = require(script.Parent.RemoteFunctionClient)

    describe("Client.is", function()
        it("should return true if passed object is a Client", function()
            local server = Server.new()
            local client = server:connect("user")

            expect(Client.is(client)).to.equal(true)
        end)

        it("should return false if passed object is not a Client", function()
            expect(Client.is(true)).to.equal(false)
            expect(Client.is(false)).to.equal(false)
            expect(Client.is(0)).to.equal(false)
            expect(Client.is({})).to.equal(false)
        end)
    end)

    describe("Client:getRemoteEvent", function()
        it("should return the client sided RemoteEvent if it exists", function()
            local server = Server.new()
            local client = server:connect("user")

            server:createRemoteEvent("remoteEvent")

            expect(client:getRemoteEvent("remoteEvent")).to.be.ok()
            expect(RemoteEventClient.is(client:getRemoteEvent("remoteEvent"))).to.equal(true)

            server:destroy()
        end)

        it("should return nil if it doesn't exist", function()
            local server = Server.new()
            local client = server:connect("user")

            expect(client:getRemoteEvent("remoteEvent")).to.equal(nil)

            server:destroy()
        end)
    end)

    describe("Client:getRemoteFunction", function()
        it("should return the client sided RemoteFunction if it exists", function()
            local server = Server.new()
            local client = server:connect("user")

            server:createRemoteFunction("remoteFunction")
            
            expect(client:getRemoteFunction("remoteFunction")).to.be.ok()
            expect(RemoteFunctionClient.is(client:getRemoteFunction("remoteFunction"))).to.equal(true)

            server:destroy()
        end)

        it("should return nil if it doesn't exist", function()
            local server = Server.new()
            local client = server:connect("user")

            expect(client:getRemoteFunction("remoteFunction")).to.equal(nil)

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