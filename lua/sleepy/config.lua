
---@class sleepy.Config
---@field global_after? fun(data: string[])

local M = {}

---@type sleepy.Config
M.defaults = { }

---@type sleepy.Config
M.options = M.defaults

--- Merge custom config with default config
---@param opts sleepy.Config -- custom config
---
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
