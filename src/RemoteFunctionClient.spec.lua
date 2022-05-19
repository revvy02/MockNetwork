return function()
    local Server = require(script.Parent.Server)
    local RemoteFunctionClient = require(script.Parent.RemoteFunctionClient)

    describe("RemoteFunctionClient.is", function()
        it("should return true if passed object is a RemoteFunctionClient", function()
            local server = Server.new()
            local client = server:connect("user")

            server:createRemoteFunction("remoteFunction")

            expect(RemoteFunctionClient.is(client:getRemoteFunction("remoteFunction"))).to.equal(true)

            server:destroy()
        end)

        it("should return false if passed object is not a RemoteFunctionClient", function()
            expect(RemoteFunctionClient.is(false)).to.equal(false)
            expect(RemoteFunctionClient.is(true)).to.equal(false)
            expect(RemoteFunctionClient.is(0)).to.equal(false)
            expect(RemoteFunctionClient.is({})).to.equal(false)
        end)
    end)

    describe("RemoteFunctionClient:invokeServer", function()
       it("should return a response from the server if a handler exists", function()
            local server = Server.new()

            server:createRemoteFunction("remoteFunction").OnServerInvoke = function(client, value)
                return value * 2
            end

            expect(server:connect("user"):getRemoteFunction("remoteFunction"):invokeServer(1)).to.equal(2)
            
            server:destroy()
        end)

        it("should queue requests on server if not handler exists and respond once it does", function()
            local server = Server.new()
            local user = server:connect("user")

            local remoteFunction = server:createRemoteFunction("remoteFunction")
            local count = 0

            task.spawn(function()
                local new = user:getRemoteFunction("remoteFunction"):invokeServer(1)
                count += new
            end)
            
            task.spawn(function()
                local new = user:getRemoteFunction("remoteFunction"):invokeServer(2)
                count += new
            end)

            remoteFunction.OnServerInvoke = function(client, value)
                return value * 2
            end

            expect(count).to.equal(6)

            server:destroy()
        end)
    end)
end