vim.api.nvim_create_user_command(
    'Sleepy',
    function()
        require("sleepy").use_selection()
    end,
    {
        range = true
    }
)

vim.api.nvim_create_user_command(
    'SleepyAnimate',
    function()
        require("sleepy.ui").test_animations(500)
    end,
    {}
)
