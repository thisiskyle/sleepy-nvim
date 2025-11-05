
require("sleepy.commands")
local config = require("sleepy.config")

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
    if(jobs == nil) then
        vim.notify("Job list is nil", vim.log.levels.ERROR)
        return
    end

    require("sleepy.history_manager").archive(jobs)
    require("sleepy.job_handler").async(jobs, function(responses)
        require("sleepy.ui").show(responses)
    end)
end


return M
