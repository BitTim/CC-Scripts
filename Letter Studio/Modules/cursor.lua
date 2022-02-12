local M = {}

M.pageSize = nil

function M.init(pageSize)
    M.pageSize = pageSize
end

function M.getWidth(pages, page, y)
    if pages[page] == nil or pages[page][y] == nil then return 1 end

    local w = string.len(pages[page][y])
    return w
end

function M.setVisualCursor(pages, cursorPos, pagePos, scrollPos, pageOffset, pageSpacing)
    local x, y, p = cursorPos.x, cursorPos.y, cursorPos.page

    repeat
        if x > M.pageSize.w then
            y = y + 1

            if y > #pages[p] + 1 or y > M.pageSize.h then
                p = p + 1

                if p > #pages then
                    y = y - 1
                    p = p - 1
                    break
                end

                y = 1
            end

            x = 1
        end
    until true

    -- TODO: Scroll when cursor off screen

    term.setTextColor(colors.blue)
    term.setCursorPos(x + pagePos - 1, ((p - 1) *(M.pageSize.h + pageSpacing)) + y + pageOffset - scrollPos - 1)
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

        if not yOnly then x = 1
        else
            local newW = M.getWidth(pages, p, y)
            if x > newW + 1 then x = newW + 1 end
        end
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

            y = #pages[p]
        end

        if not yOnly or x > M.getWidth(pages, p, y) + 1 then
            x = M.getWidth(pages, p, y) + 1
        end
    end

    return {x = x, y = y, page = p}
end

return M