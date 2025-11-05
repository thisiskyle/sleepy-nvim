

local M = {}


local history = {}
local bookmark = nil



function M.get_last()
    return history[#history]
end

function M.archive(jobs)
    table.insert(history, jobs)
end

function M.set_bookmark(jobs)
    bookmark = jobs
end

function M.get_bookmark()
    return bookmark
end


return M
