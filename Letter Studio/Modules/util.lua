local M = {}

function M.centerText(text, w, padded)
    if padded == nil then padded = false end

    local offset = math.floor(w - string.len(text) / 2)
    local ret = string.rep(" ", offset) .. text

    if padded then ret = ret .. string.rep(" ", w - string.len(ret)) end
end

function M.padText(text, w)
    local ret = text .. string.rep(" ", w - #text)
    return ret
end



function M.offsetToPos(scrollPos, pageSize, pageSpacing)
    local page = math.floor(scrollPos / (pageSize.h + pageSpacing)) + 1
    local y = scrollPos - ((pageSize.h + pageSpacing) * (page - 1)) + 1

    local pos = {page = page, x = 1, y = y}
    return pos
end

function M.calcMaxOffset(numPages, pageSize, pageSpacing)
    return ((pageSize.h + pageSpacing) * (numPages - 1)) + pageSpacing + 2
end

return M