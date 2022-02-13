local M = {}

M.util = nil
M.cursor = nil
M.pageSize = nil

M.currentWord = ""

function M.init(util, pageSize, cursor)
    M.util = util
    M.pageSize = pageSize
    M.cursor = cursor
end

function M.newPage(pages)
    local page = {}

    pages[#pages + 1] = page
    return pages
end

--TODO: Add Delete, Cut, Copy and Paste

function M.remove(cursorPos, pages)
    local page, x, y = cursorPos.page, cursorPos.x, cursorPos.y

    if pages[page] == nil or pages[page][y] == nil then return cursorPos, pages end

    if pages[page][y] == "" then
        pages[page][y] = nil
        return M.cursor.prev(pages, cursorPos, false), pages
    end

    local str = pages[page][y]
    local h1 = string.sub(str, 1, x - 2)
    local h2 = string.sub(str, x)
    str = h1 .. h2
    pages[page][y] = str

    return M.cursor.prev(pages, cursorPos, false), pages
end

function M.newline(cursorPos, pages)
    local x, y, p = cursorPos.x, cursorPos.y, cursorPos.page

    if y + 1 > M.pageSize.h then
        p = p + 1
        y = 1
    end

    if p > #pages then
        pages = M.newPage()
        pages[p][y + 1] = ""
    end

    -- TODO: Accomodate for x positions

    -- Shift all lines
    for i = #pages, p, -1 do
        for j = #pages[i], 1, -1 do
            if i == p and j < y + 1 then break end

            if j + 1 > M.pageSize.h then
                if i + 1 > #pages then
                    pages = M.newPage(pages)
                end

                pages[i + 1][1] = pages[i][j]
            else
                pages[i][j + 1] = pages[i][j]
            end
        end
    end

    local str = pages[p][y]
    pages[p][y] = string.sub(str, 1, x - 1)
    pages[p][y + 1] = string.sub(str, x)
    
    cursorPos = M.cursor.next(pages, cursorPos, false)
    return cursorPos, pages
end

function M.insert(cursorPos, pages, insStr)
    local page, x, y = cursorPos.page, cursorPos.x, cursorPos.y

    local str = ""
    local inserted = false

    if insStr == nil then return pages end

    if pages[page] and pages[page][y] then
        str = pages[page][y]
        local len = string.len(str)

        if x <= len then
            local sub1 = string.sub(str, 1, x - 1)
            local sub2 = string.sub(str, x)
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
        local tmp = string.sub(str, 1, M.pageSize.w)
        local lastSpaceIdx = string.find(tmp, " [^ ]*$")
        local line = nil
        local wrapped = nil
        local moveCursor = false

        if lastSpaceIdx then
            line = string.sub(str, 1, lastSpaceIdx - 1)
            wrapped = string.sub(str, lastSpaceIdx + 1)
            if cursorPos.x > lastSpaceIdx then moveCursor = true end
        else
            line = string.sub(str, 1, M.pageSize.w)
            wrapped = string.sub(str, M.pageSize.w + 1)
        end

        str = line

        if y + 1 > M.pageSize.h then
            local newCursorPos = {x = cursorPos.x, y = cursorPos.y, page = cursorPos.page}
            newCursorPos.x = 1
            newCursorPos.y = 1
            newCursorPos.page = page + 1

            if page + 1 > #pages then pages = M.newPage(pages) end
            
            newCursorPos, pages = M.insert(newCursorPos, pages, wrapped)
            if moveCursor then cursorPos = newCursorPos end
        else
            local newCursorPos = {x = cursorPos.x, y = cursorPos.y, page = cursorPos.page}
            newCursorPos.x = 1
            newCursorPos.y = newCursorPos.y + 1

            newCursorPos, pages = M.insert(newCursorPos, pages, wrapped)

            if moveCursor then cursorPos = newCursorPos end
        end
    end

    pages[page][y] = str
    return cursorPos, pages
end

return M