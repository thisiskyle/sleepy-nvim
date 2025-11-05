
require("sleepy.commands")
local config = require("sleepy.config")
local curl = require("sleepy.curl")

---@class sleepy
local M = {}


--- Setup the application with the provided options
---
function M.setup(opts)
    config.setup(opts)
end


--- Entry point function for running jobs from a provided list
---@param jobs? sleepy.Job[]
---
function M.run_jobs(jobs)
    require("sleepy.history_manager").archive(jobs)
    if(jobs == nil) then
        vim.notify("Job list is nil", vim.log.levels.ERROR)
        return
    end
    require("sleepy.job_handler").async(jobs, function(responses)
        require("sleepy.ui").show(responses)
    end)
end


--- Entry point function for starting a job based on visual selection
---
function M.run_highlighted_jobs()
    local jobs = require("sleepy.utils").get_visual_selection_as_lua()
    M.run_jobs(jobs)
end


function M.show_commands()
    local jobs = require("sleepy.utils").get_visual_selection_as_lua()
    if(jobs == nil) then
        vim.notify("Job list is nil", vim.log.levels.ERROR)
        return
    end

    local lines = {}

    for _,j in ipairs(jobs) do

        local request = {
            type = j.type,
            url = j.url,
            headers = j.headers,
            data = j.data,
            additional_args = j.additional_args,
        }

        if(j.command) then
            table.insert(lines, j.command)
        else
            local cmd = curl.build(request)
            local cmdStr = require("sleepy.utils").get_curl_string(cmd)
            table.insert(lines, cmdStr)
        end
    end

    require("sleepy.ui").show_commands(lines)
end


function M.repeat_last()
    local jobs = require("sleepy.history_manager").get_last()
    M.run_jobs(jobs)
end




return M
