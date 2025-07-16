---@class sleepy.RequestData
---@field urlencode? string
---@field raw? string
---@field text? string
---@field obj? table

---@class sleepy.HttpRequest table with the data needed to make an http request
---@field type string
---@field url string
---@field headers? string[]
---@field query? string[]
---@field additional_args? string[]
---@field data? sleepy.RequestData[]



---@class sleepy.Curl
local M = {}

local request_types = {
    get = { "-X", "GET", "--get" },
    post = { "-X", "POST" },
}

local function data_urlencode(cmd_table, data)
    if(type(data) == "string") then
        table.insert(cmd_table, "--data-urlencode")
        table.insert(cmd_table, data)
    end
end

local function data_raw(cmd_table, data)
    if(type(data) == "string") then
        table.insert(cmd_table, "--data-raw")
        table.insert(cmd_table, data)
    end
end

local function data_standard(cmd_table, data)
    if(type(data) == "string") then
        table.insert(cmd_table, "--data")
        table.insert(cmd_table, data)

    elseif(type(data) == "table") then
        table.insert(cmd_table, "--data")
        table.insert(cmd_table, vim.json.encode(data))
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
            table.insert(curl_command, "-H")
            table.insert(curl_command, v)
        end
    end

    if(request.data) then
        for _,v in ipairs(request.data) do
            if(v.urlencode) then
                data_urlencode(curl_command, v.urlencode)
            elseif(v.raw) then
                data_raw(curl_command, v.raw)
            elseif(v.text) then
                data_standard(curl_command, v.text)
            elseif(v.obj) then
                data_standard(curl_command, v.obj)
            elseif(type == "get") then
                data_urlencode(curl_command, v[1])
            else
                data_standard(curl_command, v[1])
            end
        end
    end

    table.insert(curl_command, request.url)

    return curl_command
end

return M
