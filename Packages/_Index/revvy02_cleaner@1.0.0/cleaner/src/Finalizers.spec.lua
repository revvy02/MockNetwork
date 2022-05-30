return function()
    local Cleaner = require(script.Parent)

    describe("Finalizers", function()
        it("should handle functions", function()
            local cleaner = Cleaner.new()
            local upvalue = 0

            cleaner:give(function()
                upvalue += 1
            end)    
            
            cleaner:work()
            expect(upvalue).to.equal(1)

            cleaner:work()
            expect(upvalue).to.equal(1)
            
            cleaner:destroy()
        end)

        it("should handle instances", function()
            local cleaner = Cleaner.new()
            local part = cleaner:give(Instance.new("Part", workspace))

            cleaner:work()
            expect(part.Parent).to.equal(nil)

            cleaner:destroy()
        end)
        
        it("should handle RBXScriptConnections", function()
            local cleaner = Cleaner.new()

            local part = Instance.new("Part", workspace)
            local name

            local connection = cleaner:give(part:GetPropertyChangedSignal("Name"):Connect(function()
                name = part.Name
            end))

            part.Name = "TestName"
            expect(name).to.equal("TestName")

            cleaner:work()
            expect(connection.Connected).to.equal(false)
            
            cleaner:destroy()
        end)

        it("should handle threads", function()
            local cleaner = Cleaner.new()

            local thread = cleaner:give(coroutine.create(function()

            end))
            
			expect(coroutine.status(thread)).to.equal("suspended")

			cleaner:work()

			expect(coroutine.status(thread)).to.equal("dead")

            cleaner:destroy()
        end)
    end)
end