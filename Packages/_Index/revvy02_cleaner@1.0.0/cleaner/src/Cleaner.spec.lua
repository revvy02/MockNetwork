return function()
    local Cleaner = require(script.Parent)

    local function noop()

    end
    
    local empty = {}

    local Object = {}
    Object.__index = Object

    function Object.new(fn)
        return setmetatable({_fn = fn}, Object)
    end

    function Object:set(fn)
        self._fn = fn
    end

    function Object:destroy(...)
        assert(not self.destroyed, "Object is already destroyed")
        self.destroyed = true
        
        if self._fn then
            self._fn(...)
        end
    end

    describe("Cleaner.new", function()
        it("should create and return cleaner object", function()
            local cleaner = Cleaner.new()

            expect(cleaner).to.be.ok()
            expect(cleaner).to.be.a("table")
            expect(getmetatable(cleaner)).to.equal(Cleaner)

            cleaner:destroy()
        end)
    end)
    
    describe("Cleaner:give", function()
        it("should return the task added", function()
            local cleaner = Cleaner.new()
            local object = Object.new()

            expect(cleaner:give(object)).to.equal(object)
            
            cleaner:destroy()
        end)

        it("should fail if task is already added", function()
            local cleaner = Cleaner.new()
            local object = cleaner:give(Object.new())
            
            expect(function()
                cleaner:give(object)
            end).to.throw()

            cleaner:destroy()
        end)

        it("should work without finalizer for connections, instances, functions", function()
            local cleaner = Cleaner.new()

            expect(function()
                local part = cleaner:give(Instance.new("Part"))

                cleaner:give(part.ChildAdded:Connect(noop))
                cleaner:give(noop)
            end).to.never.throw()
            
            cleaner:destroy()
        end)

        it("should work without finalizer for tables if destroy or Destroy is a member", function()
            local cleaner = Cleaner.new()

            expect(function()
                cleaner:give(Object.new())
            end).to.never.throw()

            expect(function()
                cleaner:give({
                    Destroy = noop
                })
            end).to.never.throw()

            cleaner:destroy()
        end)

        it("should throw if no finalizer passed and task is a table with no destroy or Destroy member", function()
            local cleaner = Cleaner.new()

            expect(function()
                cleaner:give(empty)
            end).to.throw()

            cleaner:destroy()
        end)

        it("should work if finalizer is a string and task is an instance or table", function()
            local cleaner = Cleaner.new()
            
            expect(function()
                cleaner:give({
                    cleanup = noop,
                }, "cleanup")
            end)

            cleaner:destroy()
        end)

        it("should work if finalizer args are passed", function()
            local cleaner = Cleaner.new()
   
            expect(function()
                cleaner:give(Object.new(noop), nil, 1, 2, 3)
            end).to.never.throw()

            cleaner:destroy()
        end)

        it("should throw for tables with no destroy or Destroy member and finalizer is not passed", function()
            local cleaner = Cleaner.new()
            
            expect(function()
                cleaner:give(empty)
            end).to.throw()

            return cleaner
        end)
    end)

    describe("Cleaner:has", function()
        it("should return true if task is currently pending", function()
            local cleaner = Cleaner.new()
            local task = cleaner:give(Object.new())

            expect(cleaner:has(task)).to.equal(true)

            cleaner:destroy()
        end)

        it("should return false if task is not currently pending", function()
            local cleaner = Cleaner.new()
            local task = Object.new()

            expect(cleaner:has(task)).to.equal(false)

            cleaner:give(task)
            cleaner:destroy()
        end)
    end)

    describe("Cleaner:set", function()
        it("should return the task added", function()
            local cleaner = Cleaner.new()
            local part = Instance.new("Part")

            expect(cleaner:set("key", part)).to.equal(part)
            
            cleaner:destroy()
        end)

        it("should assign the task to the key", function()
            local cleaner = Cleaner.new()
            local part = cleaner:set("key", Instance.new("Part"))

            expect(cleaner:get("key", part)).to.equal(part)
            
            cleaner:destroy()
        end)

        it("should finalize and overwrite previous tasks set to the key", function()
            local cleaner = Cleaner.new()
            local count = 0

            cleaner:set("key", function()
                count += 1
            end)

            cleaner:set("key", noop)

            expect(count).to.equal(1)

            cleaner:destroy()
        end)
 
    end)

    describe("Cleaner:get", function()
        it("should return whatever task is at the key", function()
            local cleaner = Cleaner.new()
            local part = cleaner:set("key", Instance.new("Part"))

            expect(cleaner:get("key")).to.equal(part)

            cleaner:destroy()
        end)

        it("should return nil if no task is set to the key", function()
            local cleaner = Cleaner.new()
            
            expect(cleaner:get("key")).to.equal(nil)

            cleaner:destroy()
        end)
    end)

    describe("Cleaner:extract", function()
        it("should fail if no task is set to the key", function()
            local cleaner = Cleaner.new()

            expect(function()
                cleaner:extract("key")
            end).to.throw()

            cleaner:destroy()
        end)

        it("should remove the task from the task list without finalizing it", function()
            local cleaner = Cleaner.new()
            local done = false

            local object = cleaner:set("key", Object.new(function()
                done = true
            end))
            
            expect(cleaner:extract("key")).to.equal(object)
            expect(cleaner:get("key")).to.equal(nil)
            expect(done).to.equal(false)

            cleaner:destroy()

            expect(done).to.equal(false)
        end)

        it("should return the task that was extracted", function()
            local cleaner = Cleaner.new()
            local object = Object.new()

            cleaner:set("key", object)
            
            expect(cleaner:extract("key")).to.equal(object)
            
            object:destroy()
            cleaner:destroy()
        end)
    end)

    describe("Cleaner:finalize", function()
        it("should fail if the key isn't set to a task", function()
            local cleaner = Cleaner.new()
            
            expect(function()
                cleaner:finalize("key")
            end).to.throw()
            
            cleaner:destroy()
        end)

        it("should work if initial finalizer args were passed", function()
            local cleaner = Cleaner.new()
            local result

            cleaner:set("key", Object.new(function(value)
                result = value
            end), nil, 1)

            cleaner:finalize("key")

            expect(result).to.equal(1)

            cleaner:destroy()
        end)

        it("should work if new finalizer args are passed", function()
            local cleaner = Cleaner.new()
            local result

            cleaner:set("key", Object.new(function(value)
                result = value
            end), nil, 1)

            cleaner:finalize("key", 2)

            expect(result).to.equal(2)

            cleaner:destroy()
        end)

        it("should finalize the task and remove it from pending tasks", function()
            local cleaner = Cleaner.new()
            local done = false

            cleaner:set("key", function()
                done = true
            end)

            cleaner:finalize("key")

            expect(done).to.equal(true)

            expect(function()
                cleaner:finalize("key")
            end).to.throw()

            return cleaner
        end)
    end)

    describe("Cleaner:work", function()
        it("should finalize all tasks", function()
            local cleaner = Cleaner.new()
            local count = 0

            for _ = 1, 10 do
                cleaner:give(function()
                    count += 1
                end)
            end
            
            expect(count).to.equal(0)
            
            cleaner:destroy()

            expect(count).to.equal(10)

            return cleaner
        end)

        it("should keep finalizing tasks even if a task adds more tasks", function()
            local cleaner = Cleaner.new()
            local count = 0

            local function increment()
                count += 1
            end

            cleaner:give(function()
                for _ = 1, 10 do
                    cleaner:give({
                        destroy = increment,
                    })
                end
            end)

            cleaner:give(function()
                for _ = 1, 5 do
                    cleaner:give({
                        destroy = function()
                            for _ = 1, 5 do
                                cleaner:give({
                                    destroy = increment,
                                })
                            end
                        end
                    })
                end
            end)

            cleaner:work()

            expect(count).to.equal(35)

            return cleaner
        end)

        it("should throw if work is called when already working", function()
            local cleaner = Cleaner.new()
            
            expect(function()
                cleaner:give(function()
                    cleaner:work()
                end)

                cleaner:work()
            end).to.throw()

            -- if I call cleaner:destroy() here, it errors since the error leaves it in a cleaner.working = true state
            -- and cleaner:destroy() calls cleaner:work()
        end)
    end)

    describe("Cleaner:destroy", function()
        it("should finalize all tasks", function()
            local cleaner = Cleaner.new()
            local count = 0

            for _ = 1, 10 do
                cleaner:give(function()
                    count += 1
                end)
            end
            
            expect(count).to.equal(0)
            
            cleaner:destroy()

            expect(count).to.equal(10)
        end)

        it("should set destroyed field to true", function()
            local cleaner = Cleaner.new()

            cleaner:destroy()

            expect(cleaner.destroyed).to.equal(true)
        end)
    end)

end