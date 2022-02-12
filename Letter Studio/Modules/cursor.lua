local M = {}

function M.getWidth(pages, page, y)
    if pages[page] == nil or pages[page][y] == nil then return 1 end

    local w = string.len(pages[page][y])
    return w
end

function M.setVisualCursor(pages, cursorPos, pagePos, scrollPos, pageOffset, pageSize)
    local x, y, p = cursorPos.x, cursorPos.y, cursorPos.page
    
    if x > pageSize.w then
        local newPos = M.next(pages, {x = x, y = y, page = p}, false)
        x, y, p = newPos.x, newPos.y, newPos.page
    
        print("New Pos: x " .. x .. ", y " .. y .. ", p " .. p)
    end
    
    print("Used Pos: x " .. x .. ", y " .. y .. ", p " .. p)
    sleep(2)
    term.setCursorPos(x + pagePos - 1, ((p - 1) * pageSize.h) + y + pageOffset - scrollPos - 1)
end

function M.next(pages, cursorPos, yOnly)
    if yOnly == nil then yOnly = false end
    local x, y, p = cursorPos.x, cursorPos.y, cursorPos.page

    if not yOnly then x = x + 1 end

    if x > M.getWidth(pages, p, y) + 1 or yOnly then
        y = y + 1

        if y > #pages[p] then
            p = p + 1

            if p > #pages then
                return cursorPos
            end

            y = 1
        end

        x = 1
    end

    return {x = x, y = y, page = p}
end

function M.prev(pages, cursorPos, yOnly)
    if yOnly == nil then yOnly = false end
    local x, y, p = cursorPos.x, cursorPos.y, cursorPos.page

    if not yOnly then x = x - 1 end

    if x < 1 or yOnly then
        y = y - 1

        if y < 1 then
            p = p - 1

            if p < 1 then
                return cursorPos
            end

            y = #pages[page]
        end

        x = M.getWidth(pages, p, y) + 1
    end

    return {x = x, y = y, page = p}
end

return M