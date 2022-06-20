local function deepCopy(tab)
    local new = {}

    for k, v in tab do
        if type(v) == "table" then
            v = deepCopy(v)
        end

        if typeof(k) == "Instance" then
            k = string.format("<Instance> (%s)", k.Name)
        end

        new[k] = v
    end

    return new
end

local function prepArgs(...)
    local new = {}

    for i, arg in {...} do
        if type(arg) == "table" then
            new[i] = deepCopy(arg)
        else
            new[i] = arg
        end
    end

    return table.unpack(new)
end

return prepArgs