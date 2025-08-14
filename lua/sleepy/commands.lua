vim.api.nvim_create_user_command(
    'Sleepy',
    function()
        require("sleepy").use_selection()
    end,
    {
        range = true
    }
)
