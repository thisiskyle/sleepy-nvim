---@class Animation
---@field speed number
---@field frames string[]


---@class Animator
---@field animations Animation[]
---@field get_frame fun(animation: Animation): string
---
local M = {}

M.animations = {
    default = {
        speed = 800,
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


---@param animation? Animation
---@return string -- the frame to be displayed
---
function M.get_frame(animation)
    if(not animation) then
        return ""
    end
    return animation.frames[math.floor(vim.uv.hrtime() / (1e6 * animation.speed)) % #animation.frames + 1]
end


return M
