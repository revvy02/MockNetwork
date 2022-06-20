return function()
    local Server = require(script.Parent.Server)
    local RemoteFunctionClient = require(script.Parent.RemoteFunctionClient)

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

        it("should pass deep copies of data and convert instance keys to strings", function()
            local server = Server.new()
            local user = server:connect("user")

            local remoteFunction = server:createRemoteFunction("remoteFunction")

            local part = Instance.new("Part")

            local data = {
                a = {[part] = 1},
                b = {key = 2},
            }

            task.spawn(function()
                user:getRemoteFunction("remoteFunction"):invokeServer(data, data, part)
            end)

            local data1, data2, passedPart

            remoteFunction.OnServerInvoke = function(_, ...)
                data1, data2, passedPart = ...
            end

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