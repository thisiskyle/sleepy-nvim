local M = {}


--- Formats the test results into a string[] for buffer insertion
---@param results table
---@return string[]
---
local function format_test_results(results)
    local content = {}
    for _,v in pairs(results) do
        table.insert(content, "Test: " .. v.name .. " [" .. tostring(v.result) .. "]")
    end
    table.insert(content, "")
    return content
end



--- starts at given id and finds and increments until it finds 
--- an available base + id for a buffer
---@param base string
---@param id number
---
local function find_buf_name(base, id)
    local name = base .. id

    if(vim.fn.bufexists(name) == 0) then
        return name
    else
        if(vim.fn.bufloaded(name) == 0) then
            return name
        end
    end

    return find_buf_name(base, id + 1)
end



--- Writes data to a buffer
---@param bufn number
---@param data string[]
---
local function write(bufn, data)
    if(not data) then
        return
    end
    vim.api.nvim_buf_set_lines(bufn, 0, -1, false, data)
end



--- Insert at top of buffer
---@param bufn number
---@param data string[]
---
local function insert_at_top(bufn, data)
    vim.api.nvim_buf_set_lines(bufn, 0, 0, false, data)
end



--- Creates a buffer
---@param name string
---
local function create(name)
    local n = name:gsub(" ", "_")
    vim.cmd(":new")
    vim.cmd(":file " .. find_buf_name(n .. "_", 1))
    vim.cmd(":set fileformat=unix")
    vim.opt_local.buftype = "nofile"
    vim.opt_local.filetype = "text"
    vim.opt_local.swapfile = false
    return vim.api.nvim_get_current_buf()
end



--- Displays each Response in a new buffer
--- and runs the after() function if there is one
---@param responses Response[]
---
function M.show(responses)
    for _,r in pairs(responses) do

        if(r.error) then
            local bufn = create(r.name .. "_error")
            write(bufn, r.error)

        else
            local bufn = create(r.name)
            write(bufn, r.data.payload)
            if(r.after) then
                r.after(r.data)
            end

            if(r.data.curl_header) then
                insert_at_top(bufn, r.data.curl_header)
            end

            if(r.test_results) then
                insert_at_top(bufn, format_test_results(r.test_results))
            end
            vim.cmd(":norm gg")
        end

    end
end


--- Diplays a notification of the current job progress
---@param target number
---@param completed number
---@param anim? string
---
function M.show_progress(target, completed, anim)
    local animator = require("sleepy.ui.animator")
    local spinner = ""
    local message = "Done!"

    if(not (completed == target)) then
        local animation = animator.animations[anim] or nil
        spinner = animator.get_frame(animation)
        message = "Completed Requests: " .. completed .. "/" .. target
    end

    vim.notify(message, "info", {
        id = "sleepy_progress",
        title = "Sleepy Progress",
        opts = function(notif)
            notif.icon = spinner
        end
    })

end



--- Creates a dummy notification that displays all the animations
--- this probably only works because I am using snacks notifier
function M.test_animations(count)
    if(count <= 0) then
        return
    end

    local animator = require("sleepy.ui.animator")
    local message = ""

    for k,v in pairs(animator.animations) do
        message = message .. k .. ": " .. animator.get_frame(v) .. "\n"
    end

    vim.notify(message, "info", {
        id = "sleepy_animate",
        title = "Sleepy Animations",
    })

    count = count - 1

    vim.defer_fn(function() M.test_animations(count) end, 50)
end

return M
