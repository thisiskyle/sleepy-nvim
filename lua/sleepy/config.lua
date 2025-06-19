
---@class sleepy.Config
---@field animation? string
---@field custom_animations? sleepy.Animation[]
---@field global_after? fun(data: string[])

local M = {}

---@type sleepy.Config
M.defaults = {
    animation = "default",
    custom_animations = {},
}


---@type sleepy.Config
M.options = M.defaults



--- Merge custom config with default config
---@param opts sleepy.Config -- custom config
---
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
    local animator = require("sleepy.ui.animator")
    animator.animations = vim.tbl_deep_extend("force", animator.animations, M.options.custom_animations or {})
end

return M
