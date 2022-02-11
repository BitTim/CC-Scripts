local M = {}

function M.getWidth(pages, page, y)
    if pages[page] == nil or pages[page][y] == nil then return 1 end

    local w = string.len(pages[page][y])
    return w
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