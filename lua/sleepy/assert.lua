local M = {}

--- Assumes a json string is provided as an array of strings. 
--- This is because of the way the data is brought back in chunks
--- Checks it for a key value pair.
---@param data string[]
---@param path string[]
---@param value string
---@return boolean
---
function M.json_path_equals(data, path, value)
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

--- Assumes data is a json string represented as an array of string. 
--- Checks that the provided path exists
---@param data string[]
---@param path string[]
---@return boolean
---
function M.json_path_exists(data, path)
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
---@param pattern string
---@return boolean
---
function M.data_contains(data, pattern)
    if(not data) then
        return false
    end
    for _,line in ipairs(data) do
        if(string.find(line, pattern)) then
            return true
        end
    end
    return false
end

return M
