---@class sleepy.Animation
---@field delta_time_ms number
---@field frames string[]

---@class sleepy.Animator
---@field animations sleepy.Animation[]
---@field get_frame fun(animation: sleepy.Animation): string
---
local M = {}

M.animations = {
    ---@type sleepy.Animation
    default = {
        delta_time_ms = 600,
        frames = {
            "( -_-)    |",
            "( -_-).   |",
            "( -_-).z  |",
            "( -_-).zZ |",
            "( -_-).z  |",
            "( -_-).   |",
        }
    },
}


---@param animation? sleepy.Animation
---@return string -- the frame to be displayed
---
function M.get_frame(animation)
    if(not animation) then
        return ""
    end
    local frame_index = math.floor((vim.uv.hrtime() / 1e6) / animation.delta_time_ms) % #animation.frames + 1
    return animation.frames[frame_index]
end


return M
