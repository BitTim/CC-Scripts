local util = require("Modules/util")

local titleBarColor = colors.gray
local backgroundColor = colors.lightBlue
local shadowColor = colors.gray

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
    term.write(util.padText("", w))
    term.setBackgroundColor(colors.black)
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

function M.drawPages(pageOffset, cursorPos, scrollPos, pages)
    local _, h = term.getSize()

    for y = pageOffset + 1, h do
        local pos = util.offsetToPos(scrollPos + (y - 1), M.pageSize, M.pageSpacing)
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
                term.write(util.padText("", M.pageSize.w))
            else
                term.write(util.padText(pages[pos.page][pos.y], M.pageSize.w))
            end

            if pos.y > 1 then
                term.setTextColor(shadowColor)
                term.setBackgroundColor(backgroundColor)

                term.write("\127")
            end

            term.setBackgroundColor(colors.black)
        end
    end

    term.setTextColor(colors.black)
end

function M.draw(pageOffset, cursorPos, scrollPos, pages)
    M.drawTitleBar()
    M.drawBackground(pageOffset)
    M.drawPages(pageOffset, cursorPos, scrollPos, pages)
end

return M