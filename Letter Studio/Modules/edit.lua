local M = {}

M.util = nil
M.cursor = nil
M.pageSize = nil

M.currentWord = ""

function M.init(util, pageSize)
    M.util = util
    M.pageSize = pageSize
end

function M.newPage(pages)
    local page = {}

    pages[#pages + 1] = page
    return pages
end



--TODO: Add Delete, Cut, Copy and Paste
--FIXME: Word wrapping does not work when cursor gets moved to next line

function M.insert(cursorPos, pages, page, x, y, insStr)
    local str = ""
    local inserted = false

    if insStr == nil then return pages end

    if pages[page] and pages[page][y] then
        str = pages[page][y]
        local len = string.len(str)

        if x <= len then
            local sub1 = string.sub(str, 1, x)
            local sub2 = string.sub(str, x + 1)
            str = sub1 .. insStr .. sub2
            inserted = true
        end
    end

    if not inserted then str = str .. insStr end
    cursorPos.x = cursorPos.x + string.len(insStr)

    -- Create new page when entered last possible char on page
    if x > M.pageSize.w - 1 and y > M.pageSize.h - 1 and page > #pages - 1 then
        pages = M.newPage(pages)
    end

    -- Wrap if longer than line
    if string.len(str) > M.pageSize.w then
        local lastSpaceIdx = string.find(str, " [^ ]*$")
        local line = nil
        local wrapped = nil

        if lastSpaceIdx then
            line = string.sub(str, 1, lastSpaceIdx - 1)
            wrapped = string.sub(str, lastSpaceIdx + 1)
        else
            line = string.sub(str, 1, M.pageSize.w)
            wrapped = string.sub(str, M.pageSize.w + 1)
        end

        str = line

        if y + 1 > M.pageSize.h then
            cursorPos.x = 1
            cursorPos.y = 1
            cursorPos.page = page + 1

            if page + 1 > #pages then pages = M.newPage(pages) end
            cursorPos, pages = M.insert(cursorPos, pages, page + 1, 1, 1, wrapped)
        else
            cursorPos.x = 1
            cursorPos.y = cursorPos.y + 1
            cursorPos, pages = M.insert(cursorPos, pages, page, 1, y + 1, wrapped)
        end
    end

    pages[page][y] = str
    return cursorPos, pages
end

return M