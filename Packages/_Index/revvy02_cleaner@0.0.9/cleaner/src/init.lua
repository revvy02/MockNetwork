local NO_FINALIZER_ERROR = "No finalizer found for %s (typeof: %s)"
local DUPLICATE_TASK_ERROR = "Attempted to add duplicate %s (typeof: %s)"
local ALREADY_WORKING_ERROR = "Attempted to call work when already working"
local INVALID_TASK_KEY_ERROR = "Key (%s) is not assigned to any task"

local DEFAULT_FINALIZERS = {
    ["function"] = function(trash)
        trash()
     end,
 
     ["Instance"] = game.Destroy,
 
     ["RBXScriptConnection"] = Instance.new("BindableEvent").Event:Connect(function() end).Disconnect,
}

local function handleTask(task, finalizer, ...)
    if typeof(finalizer) == "string" then
        task[finalizer](task, ...)
    else
        finalizer(task, ...)
    end
end

local ArgMap = newproxy()
local KeyMap = newproxy()
local TaskMap = newproxy()

--[=[
    Task that can be passed to a variety of methods that can be cleaned up

    @type Task function | Instance | RbxScriptConnection | table
    @within Cleaner
]=]

--[=[
    Function or string that will point to a method that will be passed finalizer arguments

    @type Finalizer function | string
    @within Cleaner
]=]

--[=[
    Key that can be used to assign specific tasks

    @type Key string | number | userdata | table
    @within Cleaner
]=]

--[=[
    Cleaner class to make memory management more efficient and avoid leaks

    @class Cleaner
]=]
local Cleaner = {}
Cleaner.__index = Cleaner

--[=[
    Creates a new cleaner object

    @function new
    @within Cleaner
]=]
function Cleaner.new()
    return setmetatable({
        --[=[
            Will be set to true if the cleaner object is currently doing work

            @prop working boolean
            @readonly
            @within Cleaner
        ]=]
        working = false,

        [ArgMap] = {},
        [KeyMap] = {},
        [TaskMap] = {},
    }, Cleaner)
end

--[=[
    Returns whether or not the passed argument is a cleaner

    @param obj any
    @return boolean
]=]
function Cleaner.is(obj)
    return type(obj) == "table" and getmetatable(obj) == Cleaner or false
end

--[=[
    Adds a task to the cleaner

    @param task Task
    @param finalizer? Finalizer -- If nil, it will check for a destroy method in an object if it's a table
    @param ...? any -- Optional arguments passed to the finalizer when called if they aren't overwritten by finalize
    @return Task -- Returns the passed task so you can write less code

    @error "No finalizer found for %s (typeof: %s)"
    @error "Attempted to add duplicate %s (typeof: %s)"
]=]
function Cleaner:add(task, finalizer, ...)
    local taskString, taskTypeof = tostring(task), typeof(task)
    local taskMap = self[TaskMap]

    if not finalizer then
        finalizer = (taskTypeof == "table" and (task.destroy or task.Destroy)) or DEFAULT_FINALIZERS[taskTypeof]
    end

    assert(finalizer, string.format(NO_FINALIZER_ERROR, taskString, taskTypeof))
    assert(not taskMap[task], string.format(DUPLICATE_TASK_ERROR, taskString, taskTypeof))

    if table.pack(...).n > 0 then
        self[ArgMap][task] = {...}
    end

    taskMap[task] = finalizer

    return task
end

--[=[
    Returns whether or not a task has been added to the cleaner

    @param task Task
    @return boolean
]=]
function Cleaner:has(task)
    return self[TaskMap][task] ~= nil
end

--[=[
    Adds a task and assigns a key to the task in the cleaner

    @param key Key
    @param task Task
    @param ...? any -- Optional arguments passed to the finalizer when called if they aren't overwritten by finalize
    @return Task
]=]
function Cleaner:set(key, task, ...)
    if self:get(key) then
        self:finalize(key)
    end

    self[KeyMap][key] = task
    self:add(task, ...)

    return task
end

--[=[
    Gets the task assigned to the key

    @param key Key
    @return Task | nil
]=]
function Cleaner:get(key)
    return self[KeyMap][key]
end

--[=[
    Removes the task at the key from the task list

    @param key Key
    @return Task

    @error "Key (%s) is not assigned to any task"
]=]
function Cleaner:extract(key)
    local keyMap = self[KeyMap]
    local task = keyMap[key]

    assert(task, string.format(INVALID_TASK_KEY_ERROR, tostring(key)))

    keyMap[key] = nil
    self[TaskMap][task] = nil
    self[ArgMap][task] = nil
    
    return task
end

--[=[
    Finalizes the task at the key and passes the args to the finalizer if included.
    This can yield if the finalizer yields.

    @param key Key
    @param ... any -- Optional arguments that can be used to overwrite any that were included in the set call
    @return Task

    @yields
    @error "Key (%s) is not assigned to any task"
]=]
function Cleaner:finalize(key, ...)
    local keyMap = self[KeyMap]
    local task = keyMap[key]
    
    assert(task, string.format(INVALID_TASK_KEY_ERROR, tostring(key)))

    local argMap, taskMap = self[ArgMap], self[TaskMap]

    if table.pack(...).n > 0 then
        handleTask(task, taskMap[task], ...)
    else
        local args = argMap[task]
        handleTask(task, taskMap[task], args and unpack(args))
    end
    
    keyMap[key] = nil
    argMap[key] = nil
    taskMap[task] = nil

    return task
end

--[=[
    Starts working on the task list. This can yield if any finalizers yield.

    @error "Attempted to call work when already working"
    @yields
]=]
function Cleaner:work()
    assert(not self.working, ALREADY_WORKING_ERROR)

    self.working = true

    local empty = false
    local taskMap, argMap = self[TaskMap], self[ArgMap]

    --[[
        To prevent cleaner object from breaking if
        for some reason a task adds another task
    ]]
    while not empty do
        local task, finalizer = next(taskMap)

        if task then
            taskMap[task] = nil

            local args = argMap[task]
            handleTask(task, finalizer, args and unpack(args))
        else
            empty = true
        end
    end

    table.clear(argMap)
    table.clear(self[KeyMap])

    self.working = false
end

--[=[
    Alias for work but sets destroyed field to true

    @yields
]=]
function Cleaner:destroy()
    self:work()
    self.destroyed = true
end

return Cleaner