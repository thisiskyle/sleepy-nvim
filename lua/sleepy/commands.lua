vim.api.nvim_create_user_command(
    'Sleepy',
    function()
        local jobs = require("sleepy.utils").get_visual_selection_as_lua()
        require("sleepy").run_jobs(jobs)
    end,
    { range = true }
)

vim.api.nvim_create_user_command(
    'SleepyClear',
    function()
        require("sleepy.job_handler").clear_jobs()
    end,
    {}
)

vim.api.nvim_create_user_command(
    'SleepyRepeat',
    function()
        local jobs = require("sleepy.history_manager").get_last()
        require("sleepy").run_jobs(jobs)
    end,
    {}
)

vim.api.nvim_create_user_command(
    'SleepyBookmarkSet',
    function()
        local jobs = require("sleepy.utils").get_visual_selection_as_lua()
        require("sleepy.history_manager").set_bookmark(jobs)
    end,
    { range = true }
)

vim.api.nvim_create_user_command(
    'SleepyBookmarkRun',
    function()
        local jobs = require("sleepy.history_manager").get_bookmark()
        require("sleepy").run_jobs(jobs)
    end,
    {}
)

vim.api.nvim_create_user_command(
    'SleepyShowCurlCommands',
    function()
        local jobs = require("sleepy.utils").get_visual_selection_as_lua()
        require("sleepy.job_handler").show_commands(jobs)
    end,
    { range = true }
)

vim.api.nvim_create_user_command(
    'SleepyTemplate',
    function()
        require("sleepy.utils").insert_template()
    end,
    {}
)
