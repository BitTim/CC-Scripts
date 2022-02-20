local titleBarColor = colors.gray
local titleBarTextColor = colors.white
local backgroundColor = colors.lightBlue
local foregroundColor = colors.white
local shadowColor = colors.gray

local textColor = colors.black

local M = {}

M.util = nil

M.pageSize = nil
M.pageSpacing = 0
M.pagePos = nil

function M.init(util, pageSize, pageSpacing, pagePos)
    M.util = util
    M.pageSize = pageSize
    M.pageSpacing = pageSpacing
    M.pagePos = pagePos
end



function M.drawTitleBar()
    local w, _ = term.getSize()
    term.setCursorPos(1, 1)

    term.setBackgroundColor(titleBarColor)
    term.setTextColor(titleBarTextColor)
    term.write(M.util.padText("New   Load   Save", w))
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

function M.drawBackground(pageOffset)
    local w, h = term.getSize()

    term.setBackgroundColor(backgroundColor)

    for y = pageOffset + 1, h do
        term.setCursorPos(1, y)
        term.write(string.rep(" ", w))
    end

    term.setBackgroundColor(colors.black)
end

function M.drawCursorPos(cursorPos)
    local w, h = term.getSize()

    term.setTextColor(foregroundColor)
    term.setBackgroundColor(backgroundColor)

    term.setCursorPos(1, h - 2)
    term.write("X:    " .. cursorPos.x)
    term.setCursorPos(1, h - 1)
    term.write("Y:    " .. cursorPos.y)
    term.setCursorPos(1, h)
    term.write("Page: " .. cursorPos.page)

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
end

function M.drawPages(pageOffset, cursorPos, scrollPos, pages)
    local _, h = term.getSize()

    for y = pageOffset + 1, h do
        local pos = M.util.offsetToPos(scrollPos + (y - 1), M.pageSize, M.pageSpacing)
        term.setCursorPos(M.pagePos, y)

        if pos.y > M.pageSize.h then
            if pos.y == M.pageSize.h + 1 then
                term.setTextColor(shadowColor)
                term.setBackgroundColor(backgroundColor)

                term.write(" " .. string.rep("\127", M.pageSize.w))

                term.setBackgroundColor(colors.black)
                term.setTextColor(colors.white)
            end
        else
            term.setTextColor(colors.black)
            term.setBackgroundColor(colors.white)

            if pages[pos.page] == nil or pages[pos.page][pos.y] == nil then
                term.write(M.util.padText("", M.pageSize.w))
            else
                term.write(M.util.padText(pages[pos.page][pos.y], M.pageSize.w))
            end

            if pos.y > 1 then
                term.setTextColor(shadowColor)
                term.setBackgroundColor(backgroundColor)

                term.write("\127")
            end

            term.setBackgroundColor(colors.black)
        end
    end

    term.setTextColor(textColor)
end

function M.draw(pageOffset, cursorPos, scrollPos, pages)
    M.drawTitleBar()
    M.drawBackground(pageOffset)
    M.drawCursorPos(cursorPos)
    M.drawPages(pageOffset, cursorPos, scrollPos, pages)
end

return M