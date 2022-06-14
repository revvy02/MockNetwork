--[=[
    Connection class for use with Signal

    @class Connection
]=]
local Connection = {}
Connection.__index = Connection

--[=[
    Constructs a new connection object

    @param signal Signal
    @param fn function
    @return Connection

    @private
]=]
function Connection._new(signal, fn)

    return setmetatable({
        _fn = fn,
        _signal = signal,

        --[=[
            Tells whether the connection is currently connected or not. If false, the connection is dead and cannot be revived

            @prop connected
            @within Connection
            @readonly
        ]=]
        connected = true,
    }, Connection)
end

--[=[
    Disconnects the connection from the parent signal and sets connected to false
]=]
function Connection:disconnect()
    if not self.connected then
        return
    end

    self.connected = false

    local signal = self._signal
    local node = signal._head

    if node == self then
        signal._head = self._next
    else
        while node and node._next ~= self do
            node = node._next
        end

        if node then
            node._next = self._next
        end
    end
end

--[=[
    Alias for disconnect but sets destroyed field to true
]=]
function Connection:destroy()
    self:disconnect()
    self.destroyed = true
end

--[[
    Include RbxScriptSignal interface so that Signal objects
    can work in place of RbxScriptSignals
]]
Connection.Disconnect = Connection.disconnect
Connection.Destroy = Connection.destroy

return Connection