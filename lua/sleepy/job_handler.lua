---@class sleepy.ResponseData
---@field payload string[]
---@field curl_header string[]

---@class sleepy.Job simplified job data used for creating the actual request job
---@field name string
---@field show_cmd? string
---@field type string
---@field url string
---@field headers string[]
---@field data table[]
---@field additional_args? string[]
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
---@field cmd? string[]
---@field show_cmd? boolean

---@class sleepy.TestResult 
---@field name string
---@field result boolean


local utils = require("sleepy.utils")
local ui = require("sleepy.ui")
local curl = require("sleepy.curl")
local active_jobs = {}
local completed_jobs = {}
local inprogress_jobs = {}

--- clear the job lists
---
local function clear_jobs()
    active_jobs = {}
    completed_jobs = {}
    inprogress_jobs = {}
end


--- Get the progress counts and pass it along to the UI
---
local function monitor_progress()
    local run = 0
    local done = 0

    for _,_ in pairs(inprogress_jobs) do
        run = run + 1
    end

    for _,_ in pairs(completed_jobs) do
        done = done + 1
    end

    ui.show_progress(run + done, done)

    if(run == 0) then
        clear_jobs()
        return
    end

    vim.defer_fn(monitor_progress, 60)
end


---@class sleepy.Job_Handler
local M = {}

--- Uses vim.fn.system and curl to make a syncronous http request
--- I am not sure if I will ever actually use this
---@param jobs sleepy.Job[]
---@return sleepy.Response[]
---
function M.sync(jobs)
    local responses = {}

    for _,j in ipairs(jobs) do

        local request = {
            type = j.type,
            url = j.url,
            headers = j.headers,
            data = j.data,
            additional_args = j.additional_args,
        }

        local cmd = j.command or curl.build(request)

        if(cmd == "" or cmd == nil) then
            ui.notify("Job command was empty", vim.log.levels.ERROR)
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

    local config = require("sleepy.config")

    for _,j in ipairs(jobs) do

        local request = {
            type = j.type,
            url = j.url,
            headers = j.headers,
            data = j.data,
            additional_args = j.additional_args,
        }

        local cmd = j.command or curl.build(request)

        if(cmd == "" or cmd == nil) then
            ui.notify("Job command was empty", vim.log.levels.ERROR)
            break
        end

        local job_id = vim.fn.jobstart(
            cmd,
            {
                stdout_buffered = true,
                stderr_buffered = true,

                on_stdout = function(id, data, _)
                    local resp = active_jobs[id]

                    local norm = utils.remove_line_endings(data)
                    resp.data = utils.parse_output(norm)

                    if(resp.test) then
                        resp.test_results = resp.test(resp.data.payload)
                    end
                end,

                on_stderr = function (id, data, _)
                    if(next(data) ~= nil and data[1] ~= "") then
                        active_jobs[id].error = data
                    end
                end,

                on_exit = function(id, _, _)
                    completed_jobs[id] = true
                    inprogress_jobs[id] = nil

                    if(next(inprogress_jobs) == nil) then
                        on_complete(active_jobs)
                    end
                end,
            }
        )

        active_jobs[job_id] = {
            name = j.name or "sleepy",
            show_cmd = j.show_cmd,
            cmd = cmd,
            data = nil,
            error = nil,
            after = j.after or config.options.global_after or nil,
            test = j.test or nil,
            test_results = nil
        }

        inprogress_jobs[job_id] = true

    end
    monitor_progress()
end


M.clear_jobs = clear_jobs


return M
