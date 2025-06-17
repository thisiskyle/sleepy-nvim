
---@class Config
---@field animation string
---@field custom_animations table


---@type Config
local default = {
    animation = "sleepy",
    custom_animations = {},
}


local M = {}

M.config = default

--- Returns the default config settings
---@return table
---
function M.get_default()
    return default
end


--- Merge custom config with default config
---@param opts Config -- custom config
---
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", default, opts or {})

    local animator = require("sleepy.ui.animator")
    animator.animations = vim.tbl_deep_extend("force", animator.animations, M.config.custom_animations or {})
end

return M
