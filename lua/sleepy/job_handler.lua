---@class sleepy.ResponseData
---@field payload string[]
---@field curl_header string[]

---@class sleepy.Job simplified job data used for creating the actual request job
---@field name string
---@field request sleepy.HttpRequest
---@field command? string[]
---@field after? fun(data?: string[])
---@field test? fun(data?: string[])

---@class sleepy.Response
---@field name? string
---@field data? sleepy.ResponseData
---@field error? string[]
---@field after? fun(data?: string[])
---@field test? fun(data?: string[])
---@field test_results? table

---@class sleepy.TestResult 
---@field name string
---@field result boolean


local utils = require("sleepy.utils")
local ui = require("sleepy.ui")
local curl = require("sleepy.curl")
local running = {}
local complete = {}

--- Get the progress counts and pass it along to the UI
local function show_progress()
    local cfg = require("sleepy.config")

    if(next(running) == nil) then
        ui.show_progress(1, 1)
        return
    end

    local run = 0
    local done = 0

    for _,_ in pairs(running) do
        run = run + 1
    end
    for _,_ in pairs(complete) do
        done = done + 1
    end

    ui.show_progress(run + done, done, cfg.config.animation)
    vim.defer_fn(show_progress, 60)
end


---@class sleepy.Job_Handler
local M = {}

--- Uses vim.fn.system and curl to make a syncronous http request
---@param jobs sleepy.Job[]
---@return sleepy.Response[]
---
function M.sync(jobs)
    local responses = {}

    for _,j in ipairs(jobs) do

        local cmd = j.command or curl.build(j.request)

        if(cmd == "" or cmd == nil) then
            vim.notify("Job command was empty", vim.log.levels.ERROR)
            break
        end

        table.insert(responses, {
            name = j.name or "sleepy",
            data = { vim.fn.system(cmd) },
            after = j.after or nil,
            test = j.test or nil
        })

    end
    return responses
end


--- Uses vim.fn.jobstart and curl to make an asyncronous http request
---@param jobs sleepy.Job[]
---@param on_complete fun(data?: sleepy.Response[]) on_complete callback handler
---
function M.async(jobs, on_complete)

    for _,j in ipairs(jobs) do

        local cmd = j.command or curl.build(j.request)

        if(cmd == "" or cmd == nil) then
            vim.notify("Job command was empty", vim.log.levels.ERROR)
            break
        end

        local job_id = vim.fn.jobstart(
            cmd,
            {
                stdout_buffered = true,
                stderr_buffered = true,

                on_stdout = function(id, data, _)
                    local resp = running[id]

                    local norm = utils.remove_line_endings(data)
                    resp.data = utils.parse_output(norm)

                    if(resp.test) then
                        resp.test_results = resp.test(resp.data.payload)
                    end
                end,

                on_stderr = function (id, data, _)
                    if(next(data) ~= nil and data[1] ~= "") then
                        running[id].error = data
                    end
                end,

                on_exit = function(id, _, _)
                    complete[id] = running[id]
                    running[id] = nil

                    if(next(running) == nil) then
                        on_complete(complete)
                        running = {}
                        complete = {}
                    end
                end,
            }
        )

        -- add the job to the running buffer
        running[job_id] = {
            name = j.name or "sleepy",
            data = nil,
            error = nil,
            after = j.after or nil,
            test = j.test or nil,
            test_results = nil
        }

    end
    show_progress()
end

return M
