
---@class sleepy.Config
---@field animation string
---@field custom_animations sleepy.Animation[]
---@field global_after fun(data: string[])
---
local default = {
    animation = "default",
    custom_animations = {},
}


local M = {}

---@type sleepy.Config
M.config = default


--- Returns the default config settings
---@return table
---
function M.get_default()
    return default
end


--- Merge custom config with default config
---@param opts sleepy.Config -- custom config
---
function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", default, opts or {})
    local animator = require("sleepy.ui.animator")
    animator.animations = vim.tbl_deep_extend("force", animator.animations, M.config.custom_animations or {})
end

return M
