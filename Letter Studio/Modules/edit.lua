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

function M.wordWrap(cursorPos, pages)
    local page, x, y = cursorPos.page, cursorPos.x, cursorPos.y
    local iP, iX, iY = page, x, y
    local str = nil

    if pages[page]  == nil or pages[page][y] == nil then
        return cursorPos, pages
    end

    str = pages[page][y]

    local tmp = string.sub(str, 1, M.pageSize.w + 1)
    local lastSpaceIdx = string.find(tmp, " [^ ]*$")

    local line = nil
    local wrapped = nil
    local insertSpace = true
    local moveCursor = false

    if lastSpaceIdx == nil then
        lastSpaceIdx = M.pageSize.w
        line = string.sub(str, 1, lastSpaceIdx)
        insertSpace = false
    else
        line = string.sub(str, 1, lastSpaceIdx - 1)
    end

    if x > lastSpaceIdx then
        x = x - lastSpaceIdx
        moveCursor = true
    end

    pages[page][y] = line
    wrapped = string.sub(str, lastSpaceIdx + 1)

    y = y + 1
    if y > M.pageSize.h then
        page = page + 1
        y = 1

        if page > #pages then
            pages = M.newPage(pages)
        end
    end

    local nextLine = pages[page][y]
    if nextLine == nil then nextLine = "" end

    if nextLine ~= "" and insertSpace then
        wrapped = wrapped .. " "
    end

    nextLine = wrapped .. nextLine

    cursorPos = {x = x, y = y, page = page}
    pages[page][y] = nextLine

    if string.len(nextLine) > M.pageSize.w then cursorPos, pages = M.wordWrap(cursorPos, pages) end

    if not moveCursor then cursorPos = {x = iX, y = iY, page = iP} end
    return cursorPos, pages
end

--TODO: Add Delete, Cut, Copy and Paste

function M.remove(cursorPos, pages)
    local page, x, y = cursorPos.page, cursorPos.x, cursorPos.y
    
    if x > M.pageSize.w then
        x = 1
        y = y + 1

        if y > M.pageSize.h then
            page = page + 1
        end
    end

    if x < 2 then
        repeat
            if y <= 1 and page <= 1 then break end
    
            local prevY = y - 1
            local prevP = page
            
            if prevY < 1 then
                prevP = prevP - 1
                
                if prevP < 1 then break end
            end
    
            local prevWidth = M.cursor.getWidth(pages, prevP, prevY)
            if prevWidth >= M.pageSize.w then
                prevWidth = prevWidth - 1
                pages[prevP][prevY] = string.sub(pages[prevP][prevY], 1, prevWidth)
            end
        
            pages[prevP][prevY] = pages[prevP][prevY] .. pages[page][y]
            
            if string.len(pages[prevP][prevY]) > M.pageSize.w then
                pages[page][y] = ""

                x = prevWidth + 1
                y = prevY
                page = prevP
                
                cursorPos = {x = x, y = y, page = page}
                cursorPos, pages = M.wordWrap(cursorPos, pages)
            else
                x = prevWidth + 1
                y = prevY
                page = prevP
                
                cursorPos = {x = x, y = y, page = page}
                
                for i = page, #pages do
                    for j = 1, #pages[i] do
                        if i ~= page or j > y then
                            if i >= #pages and j >= #pages[i] then
                                pages[i][j] = nil
                                break
                            end
                        
                            if j + 1 > M.pageSize.h then
                                pages[i][j] = pages[i + 1][1]
                            else
                                pages[i][j] = pages[i][j + 1]
                            end
                        end
                    end
                end
            end
        until true
    else
        local str = pages[page][y]
        local h1 = string.sub(str, 1, x - 2)
        local h2 = string.sub(str, x)
        
        str = h1 .. h2
        pages[page][y] = str
        cursorPos = M.cursor.prev(pages, cursorPos, false)
    end
    
    return cursorPos, pages
end

function M.newline(cursorPos, pages)
    local x, y, p = cursorPos.x, cursorPos.y, cursorPos.page

    if y + 1 > M.pageSize.h then
        p = p + 1
        y = 1
    end

    if p > #pages then
        pages = M.newPage(pages)
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
    if str == nil then str = "" end
    pages[p][y] = string.sub(str, 1, x - 1)
    pages[p][y + 1] = string.sub(str, x)
    
    cursorPos = M.cursor.next(pages, cursorPos, false)
    return cursorPos, pages
end

function M.insert(cursorPos, pages, insStr)
    local page, x, y = cursorPos.page, cursorPos.x, cursorPos.y

    local str = ""
    local inserted = false

    if insStr == nil then return cursorPos, pages end

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

    pages[page][y] = str

    -- Wrap if longer than line
    if string.len(str) > M.pageSize.w then
        cursorPos, pages = M.wordWrap(cursorPos, pages)
    end

    for i = 1, string.len(insStr) do
        cursorPos = M.cursor.next(pages, cursorPos, false)
    end

    return cursorPos, pages
end

return M