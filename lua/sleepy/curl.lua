---@class sleepy.RequestData
---@field urlencode? string
---@field raw? string
---@field text? string
---@field json_encode? table

---@class sleepy.HttpRequest table with the data needed to make an http request
---@field type string
---@field url string
---@field headers? string[]
---@field additional_args? string[]
---@field data? sleepy.RequestData[]



---@class sleepy.Curl
local M = {}

local request_types = {
    get = { "-X", "GET", "--get" },
    post = { "-X", "POST" },
}

--- build a curl --data-urlencode string for a request
--- and insert it into the provided table
---@param cmd_table table
---@param data string
---
local function urlencode_data(cmd_table, data)
    if(type(data) == "string") then
        table.insert(cmd_table, "--data-urlencode")
        table.insert(cmd_table, data)
    end
    -- todo: we should probably handle a non string
    --       maybe return an error and skip this job
end

--- build a curl --data-raw string for a request
--- and insert it into the provided table
---@param cmd_table table
---@param data string
---
local function raw_data(cmd_table, data)
    if(type(data) == "string") then
        table.insert(cmd_table, "--data-raw")
        table.insert(cmd_table, data)
    end
    -- todo: we should probably handle a non string
    --       maybe return an error and skip this job
end

--- build a curl --data string for a request
--- and insert it into the provided table
---@param cmd_table table
---@param data string
---
local function standard_data(cmd_table, data)
    if(type(data) == "string") then
        table.insert(cmd_table, "--data")
        table.insert(cmd_table, data)
    end
    -- todo: we should probably handle a non string
    --       maybe return an error and skip this job
end

--- encodes the provided data as json and adds it to the request table
--- for now this just assumes you want json
---@param cmd_table table
---@param data table
---
local function json_data(cmd_table, data)
    if(type(data) == "table") then
        table.insert(cmd_table, "--data")
        table.insert(cmd_table, vim.json.encode(data))
        return
    end
    -- todo: we should probably handle a non table
    --       maybe return an error and skip this job
end

--- decide what to do with unlabeled data
---@param cmd_table table
---@param data any
---
local function naked_data(cmd_table, data)
    if(type(data) == "table") then
        json_data(cmd_table, data)
        return
    end

    if(type(data) == "string") then
        standard_data(cmd_table, data)
        return
    end
end



--- Build the curl command string from a sleepy.HttpRequest
---@param request sleepy.HttpRequest
---@return string[]
---
function M.build(request)

    local curl_command = {}
    local type = string.lower(request.type)

    table.insert(curl_command, "curl")
    table.insert(curl_command, "-s")

    if(request.additional_args) then
        for _,v in ipairs(request.additional_args) do
            table.insert(curl_command, v)
        end
    end

    for _,v in ipairs(request_types[type]) do
        table.insert(curl_command, v)
    end

    if(request.headers ~= nil) then
        for _,v in ipairs(request.headers) do
            table.insert(curl_command, "--header")
            table.insert(curl_command, v)
        end
    end

    if(request.data) then
        for _,v in ipairs(request.data) do
            if(v.urlencode) then
                urlencode_data(curl_command, v.urlencode)
            elseif(v.raw) then
                raw_data(curl_command, v.raw)
            elseif(v.json_encode) then
                json_data(curl_command, v.json_encode)
            elseif(type == "get") then
                urlencode_data(curl_command, v[1])
            else
                naked_data(curl_command, v[1])
            end
        end
    end

    table.insert(curl_command, request.url)

    return curl_command
end

return M
