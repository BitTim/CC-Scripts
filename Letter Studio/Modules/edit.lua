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

    --if pages[page][y] == "" then
        --pages[page][y] = nil
    --end
    
    if x < 2 and y > 1 then
        y = y - 1
        cursorPos, pages = M.insert({x = M.cursor.getWidth(pages, page, y) + 1 , y = y, page = page}, pages, pages[page][y + 1])
        
        -- Shift all lines up
        for i = page, #pages do
            for j = 1, #pages[i] do
                if i ~= page and j > y then
                    if j - 1 < 1 then
                        if i - 1 < 1 then
                            break
                        end

                        pages[i - 1][M.pageSize.h] = pages[i][j]
                    else
                        pages[i][j - 1] = pages[i][j]
                    end
                end
            end
        end
    else
        local str = pages[page][y]
        local h1 = string.sub(str, 1, x - 2)
        local h2 = string.sub(str, x)
        str = h1 .. h2
        pages[page][y] = str
    end

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

    --Split line at x position
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
        local cursorOffset = 0

        if lastSpaceIdx then
            line = string.sub(str, 1, lastSpaceIdx - 1)
            wrapped = string.sub(str, lastSpaceIdx + 1)
        else
            lastSpaceIdx = M.pageSize.w
            line = string.sub(str, 1, lastSpaceIdx)
            wrapped = string.sub(str, lastSpaceIdx + 1)
        end

        if cursorPos.x > lastSpaceIdx then
            moveCursor = true
            cursorOffset = cursorPos.x - lastSpaceIdx
        end

        if string.sub(line, #line) == " " then line = string.sub(line, 1, string.len(line) - 1) end
        str = line

        if y + 1 > M.pageSize.h then
            local newCursorPos = {x = cursorPos.x, y = cursorPos.y, page = cursorPos.page}
            newCursorPos.x = 1
            newCursorPos.y = 1
            newCursorPos.page = page + 1

            if page + 1 > #pages then pages = M.newPage(pages) end
            if pages[newCursorPos.page][newCursorPos.y] and pages[newCursorPos.page][newCursorPos.y] ~= "" and moveCursor == false then
                wrapped = wrapped .. " "
            end

            newCursorPos, pages = M.insert(newCursorPos, pages, wrapped)
            newCursorPos.x = cursorOffset

            if moveCursor then cursorPos = newCursorPos end
        else
            local newCursorPos = {x = cursorPos.x, y = cursorPos.y, page = cursorPos.page}
            newCursorPos.x = 1
            newCursorPos.y = newCursorPos.y + 1

            if pages[newCursorPos.page][newCursorPos.y] and pages[newCursorPos.page][newCursorPos.y] ~= "" and moveCursor == false then
                wrapped = wrapped .. " "
            end

            newCursorPos, pages = M.insert(newCursorPos, pages, wrapped)
            newCursorPos.x = cursorOffset

            if moveCursor then cursorPos = newCursorPos end
        end
    end

    pages[page][y] = str

    for i = 1, string.len(insStr) do
        cursorPos = M.cursor.next(pages, cursorPos, false)
    end

    return cursorPos, pages
end

return M