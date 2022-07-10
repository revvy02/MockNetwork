local function isCyclic(tab, checked)
    if checked == nil then
        checked = {}
    end

    checked[tab] = true

    for _, value in tab do
        if typeof(value) == "table" then
            if isCyclic(value, checked) then
                return true
            end
        end
    end

    return false
end

local function deepCopy(tab)
    local new = {}

    for k, v in tab do
        if type(v) == "table" then
            v = deepCopy(v)
        end

        if typeof(k) == "Instance" then
            k = string.format("<Instance> (%s)", k.Name)
        elseif typeof(k) == "table" then
            k = string.format("<Table> (%s)", tostring(k))
        end

        new[k] = v
    end

    return new
end

local function prepArgs(...)
    local new = {}

    for i, arg in {...} do
        if type(arg) == "table" then
            assert(not isCyclic(arg), "tables cannot be cyclic")
            new[i] = deepCopy(arg)
        else
            new[i] = arg
        end
    end

    return table.unpack(new)
end

return prepArgs