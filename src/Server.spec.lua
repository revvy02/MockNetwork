return function()
    local Server = require(script.Parent.Server)
    local Client = require(script.Parent.Client)

    local RemoteEventServer = require(script.Parent.RemoteEventServer)
    local RemoteEventClient = require(script.Parent.RemoteEventClient)
    local RemoteFunctionServer = require(script.Parent.RemoteFunctionServer)
    local RemoteFunctionClient = require(script.Parent.RemoteFunctionClient)

    describe("Server.new", function()
        it("should return a new Server object", function()
            local server = Server.new()

            expect(server).to.be.a("table")
            expect(getmetatable(server)).to.equal(Server)

            server:destroy()
        end)

        it("should create clients from passed ids if any are passed", function()
            local server = Server.new({"user0", "user1"})

            expect(server:getClient("user0")).to.be.ok()
            expect(server:getClient("user1")).to.be.ok()

            server:destroy()
        end)
    end)

    describe("Server:createRemoteEvent", function()
        it("should create a RemoteEvent object on server and each client", function()
            local server = Server.new()

            local user1 = server:connect("user1")
            local user2 = server:connect("user2")

            server:createRemoteEvent("remoteEvent")

            expect(server:getRemoteEvent("remoteEvent")).to.be.a("table")
            expect(getmetatable(server:getRemoteEvent("remoteEvent"))).to.equal(RemoteEventServer)
            
            expect(user1:getRemoteEvent("remoteEvent")).to.be.a("table")
            expect(getmetatable(user1:getRemoteEvent("remoteEvent"))).to.equal(RemoteEventClient)

            expect(user2:getRemoteEvent("remoteEvent")).to.be.a("table")
            expect(getmetatable(user2:getRemoteEvent("remoteEvent"))).to.equal(RemoteEventClient)

            server:destroy()
        end)
    end)

    describe("Server:getRemoteEvent", function()
        it("should get the RemoteEvent object from the server", function()
            local server = Server.new()

            local remote = server:createRemoteEvent("remoteEvent")

            expect(server:getRemoteEvent("remoteEvent")).to.equal(remote)

            server:destroy()
        end)

        it("should throw if a RemoteEvent with the passed name doesn't exist", function()
            local server = Server.new()

            expect(function()
                server:getRemoteEvent("remoteEvent")
            end).to.throw()

            server:destroy()
        end)
    end)

    describe("Server:createRemoteFunction", function()
        it("should create a RemoteFunction object on server and each client", function()
            local server = Server.new()

            local user1 = server:connect("user1")
            local user2 = server:connect("user2")

            server:createRemoteFunction("remoteFunction")

            expect(server:getRemoteFunction("remoteFunction")).to.be.a("table")
            expect(getmetatable(server:getRemoteFunction("remoteFunction"))).to.equal(RemoteFunctionServer)
            
            expect(user1:getRemoteFunction("remoteFunction")).to.be.a("table")
            expect(getmetatable(user1:getRemoteFunction("remoteFunction"))).to.equal(RemoteFunctionClient)

            expect(user2:getRemoteFunction("remoteFunction")).to.be.a("table")
            expect(getmetatable(user2:getRemoteFunction("remoteFunction"))).to.equal(RemoteFunctionClient)

            server:destroy()
        end)
    end)

    describe("Server:getRemoteFunction", function()
        it("should get the RemoteFunction object from the server", function()
            local server = Server.new()

            local remote = server:createRemoteFunction("remoteFunction")

            expect(server:getRemoteFunction("remoteFunction")).to.equal(remote)

            server:destroy()
        end)

        it("should throw if a RemoteFunction with the passed name doesn't exist", function()
            local server = Server.new()

            expect(function()
                server:getRemoteFunction("remoteFunction")
            end).to.throw()

            server:destroy()
        end)
    end)
    
    describe("Server:connect", function()
        it("should return a client object with the id", function()
            local server = Server.new()
            
            local client = server:connect("user")

            expect(client).to.be.a("table")
            expect(getmetatable(client)).to.equal(Client)
            expect(client.id).to.equal("user")

            server:destroy()
        end)

        it("should return a client that has all the remote objects with it", function()
            local server = Server.new()

            server:createRemoteEvent("remoteEvent")
            server:createRemoteFunction("remoteFunction")

            local client = server:connect("user")

            expect(client:getRemoteEvent("remoteEvent")).to.be.a("table")
            expect(getmetatable(client:getRemoteEvent("remoteEvent"))).to.equal(RemoteEventClient)

            expect(client:getRemoteFunction("remoteFunction")).to.be.a("table")
            expect(getmetatable(client:getRemoteFunction("remoteFunction"))).to.equal(RemoteFunctionClient)

            server:destroy()
        end)

        it("should fire the clientConnected event with the client object", function()
            local server = Server.new()
            local client

            server.clientConnected:connect(function(connectedClient)
                client = connectedClient
            end)

            server:connect("user")

            expect(client).to.be.ok()
            expect(client.id).to.equal("user")

            server:destroy()
        end)

        it("should throw if a connected client exists with the id", function()
            local server = Server.new()

            server:connect("user")

            expect(function()
                server:connect("user")
            end).to.throw()

            server:destroy()
        end)
    end)

    describe("Server:disconnect", function()
        it("should disconnect the client with the id and set client's connected field to false", function()
            local server = Server.new()

            local client = server:connect("user")

            expect(function()
                server:disconnect("user")
            end).to.never.throw()

            expect(client.connected).to.equal(false)
            expect(server:getClient("user")).to.equal(nil)

            server:destroy()
        end)

        it("should fire the clientDisconnecting event with the client object", function()
            local server = Server.new()

            local client = server:connect("user")

            server.clientDisconnecting:connect(function(disconnectingClient)
                expect(client).to.equal(disconnectingClient)
            end)

            server:disconnect("user")

            server:destroy()
        end)

        it("should throw if no connected client exists with the id", function()
            local server = Server.new()

            expect(function()
                server:disconnect("user")
            end).to.throw()

            server:destroy()
        end)
    end)

    describe("Server:getClient", function()
        it("should return the client with the id", function()
            local server = Server.new()

            server:connect("user")
            expect(server:getClient("user")).to.be.ok()
            expect(server:getClient("user").id).to.equal("user")

            server:destroy()
        end)

        it("should return nil if the client with the passed id doesn't exist", function()
            local server = Server.new()

            expect(server:getClient("user")).to.equal(nil)

            server:destroy()
        end)
    end)

    describe("Server:getClients", function()
        it("should return a list of currently connected clients", function()
            local server = Server.new({"user1", "user2", "user3"})
            local clients = server:getClients()
            
            local user1, user2, user3 = server:getClient("user1"), server:getClient("user2"), server:getClient("user3")

            expect(table.find(clients, user1)).to.be.ok()
            expect(table.find(clients, user2)).to.be.ok()
            expect(table.find(clients, user3)).to.be.ok()

            server:destroy()
        end)
    end)

    describe("Server:mapClients", function()
        it("should return a dictionary that maps the client id to the object if no function is passed", function()
            local server = Server.new({"user1", "user2", "user3"})
            local clients = server:mapClients()
            
            expect(clients.user1).to.equal(server:getClient("user1"))
            expect(clients.user2).to.equal(server:getClient("user2"))
            expect(clients.user3).to.equal(server:getClient("user3"))

            server:destroy()
        end)
        
        it("should return a dictionary that is properly mapped if a function is passed", function()
            local server = Server.new({"user1", "user2", "user3"})

            local clients = server:mapClients(function(id, client)
                return string.upper(id), typeof(client)
            end)
            
            expect(clients.user1).to.never.be.ok()
            expect(clients.user2).to.never.be.ok()
            expect(clients.user3).to.never.be.ok()

            expect(clients.USER1).to.equal("table")
            expect(clients.USER2).to.equal("table")
            expect(clients.USER3).to.equal("table")

            server:destroy()
        end)
    end)

    describe("Server:getClients", function()
        it("should return a list of currently connected clients", function()
            local server = Server.new({"user1", "user2", "user3"})
            local clients = server:getClients()
            
            local user1, user2, user3 = server:getClient("user1"), server:getClient("user2"), server:getClient("user3")

            expect(table.find(clients, user1)).to.be.ok()
            expect(table.find(clients, user2)).to.be.ok()
            expect(table.find(clients, user3)).to.be.ok()

            server:destroy()
        end)
    end)

    describe("Server:destroy", function()
        it("should disconnect all clients and fire clientDisconnecting for all of them", function()
            local server = Server.new()
            local done = {}

            local user1 = server:connect("user1")
            local user2 = server:connect("user2")
            local user3 = server:connect("user3")

            local conn = server.clientDisconnecting:connect(function(client)
                done[client] = true
            end)

            server:destroy()

            expect(user1.connected).to.equal(false)
            expect(user2.connected).to.equal(false)
            expect(user3.connected).to.equal(false)

            expect(done[user1]).to.equal(true)
            expect(done[user2]).to.equal(true)
            expect(done[user3]).to.equal(true)
        end)

        it("should set destroyed field to true", function()
            local server = Server.new()

            server:destroy()

            expect(server.destroyed).to.equal(true)
        end)
    end)
end