local M = {}

--- Assumes a json string is provided as an array of strings. 
--- This is because of the way the data is brought back in chunks
--- Checks it for a key value pair.
---@param data string[]
---@param path string[]
---@param value string
---@return boolean
---
function M.json_path_value(data, path, value)
    if(not data) then
        return false
    end

    local data_str = ""
    for _,v in ipairs(data) do
        data_str = data_str .. v
    end

    local json_tbl = vim.json.decode(data_str)
    local current = json_tbl
    for _,k in pairs(path) do
        if(type(current) == "table") then
            current = current[k]
        end
    end

    if(current == value) then
        return true
    end
    return false
end

--- Assumes a json string is provided. Checks it for a key.
---@param data string[]
---@param path string[]
---@return boolean
---
function M.json_has_key(data, path)
    if(not data) then
        return false
    end

    local data_str = ""
    for _,v in ipairs(data) do
        data_str = data_str .. v
    end

    local json_tbl = vim.json.decode(data_str)
    local current = json_tbl
    for _,k in pairs(path) do
        if(type(current) == "table") then
            current = current[k]
        end
    end
    if(current) then
        return true
    end
    return false
end


--- Assumes string[] is provided, checks it for a specific sub string
---@param data string[]
---@param str string
---@return boolean
---
function M.data_contains(data, str)
    if(not data) then
        return false
    end
    for _,line in ipairs(data) do
        if(string.find(line, str)) then
            return true
        end
    end
    return false
end

return M
