
local history = {}

local M = {}

function M.get_last()
    return history[#history]
end

function M.archive(jobs)
    table.insert(history, jobs)
end

return M
