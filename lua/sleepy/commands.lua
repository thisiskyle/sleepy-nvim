vim.api.nvim_create_user_command(
    'Sleepy',
    function()
        require("sleepy").run_highlighted_jobs()
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
    'SleepyShowCurlCommands',
    function()
        require("sleepy").show_commands()
    end,
    { range = true }
)

vim.api.nvim_create_user_command(
    'SleepyTemplate',
    function()
        require("sleepy.utils").insert_template()
    end,
    { }
)
