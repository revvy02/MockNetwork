return function()
    local Server = require(script.Parent.Server)
    local RemoteFunctionServer = require(script.Parent.RemoteFunctionServer)

    describe("RemoteFunctionServer.is", function()
        it("should return true if passed object is a RemoteFunctionServer", function()
            local server = Server.new()

            local remoteFunction = server:createRemoteFunction("remoteFunction")

            expect(RemoteFunctionServer.is(remoteFunction)).to.equal(true)

            server:destroy()
        end)

        it("should return false if passed object is not a RemoteFunctionServer", function()
            expect(RemoteFunctionServer.is(false)).to.equal(false)
            expect(RemoteFunctionServer.is(true)).to.equal(false)
            expect(RemoteFunctionServer.is(0)).to.equal(false)
            expect(RemoteFunctionServer.is({})).to.equal(false)
        end)
    end)

    describe("RemoteFunctionServer:invokeClient", function()
       it("should return a response from the client if a handler exists", function()
            local server = Server.new()
            local user = server:connect("user")

            local remoteFunction = server:createRemoteFunction("remoteFunction")

            user:getRemoteFunction("remoteFunction").OnClientInvoke = function(value)
                return value * 2
            end

            expect(remoteFunction:invokeClient(user, 1)).to.equal(2)

            server:destroy()
        end)

        it("should queue requests on client if not handler exists and respond once it does", function()
            local server = Server.new()
            local user = server:connect("user")

            local remoteFunction = server:createRemoteFunction("remoteFunction")
            local count = 0

            task.spawn(function()
                local new = remoteFunction:invokeClient(user, 1)
                count += new
            end)
            
            task.spawn(function()
                local new = remoteFunction:invokeClient(user, 2)
                count += new
            end)

            user:getRemoteFunction("remoteFunction").OnClientInvoke = function(value)
                return value * 2
            end

            expect(count).to.equal(6)

            server:destroy()
        end)
    end)

    describe("RemoteFunctionServer:destroy", function()
        it("should remove associated client sided remote function for each client", function()
            local server = Server.new()
            local user0 = server:connect("user0")
            local user1 = server:connect("user1")

            local remoteFunction = server:createRemoteFunction("remoteFunction")

            expect(user0:getRemoteFunction("remoteFunction")).to.be.ok()
            expect(user1:getRemoteFunction("remoteFunction")).to.be.ok()

            remoteFunction:destroy()

            expect(user0:getRemoteFunction("remoteFunction")).to.equal(nil)
            expect(user1:getRemoteFunction("remoteFunction")).to.equal(nil)

            server:destroy()
        end)

        it("should set destroyed field to true", function()
            local server = Server.new()
            local remoteFunction = server:createRemoteFunction("remoteFunction")

            remoteFunction:destroy()

            expect(remoteFunction.destroyed).to.equal(true)
            
            server:destroy()
        end)
    end)
end