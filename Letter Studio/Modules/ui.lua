local menuBarColor = colors.gray
local menuBarTextColor = colors.white
local menuBarClickedColor = colors.blue
local menuBarClickedTextColor = colors.white

local menuSpacing = 3

local backgroundColor = colors.lightBlue
local foregroundColor = colors.white
local shadowColor = colors.gray

local M = {}

M.util = nil

M.pageSize = nil
M.pageSpacing = 0
M.pagePos = nil

M.menuBar = {}

function M.init(util, pageSize, pageSpacing, pagePos)
    M.util = util
    M.pageSize = pageSize
    M.pageSpacing = pageSpacing
    M.pagePos = pagePos
end

function M.addMenu(title)
    local x = 1
    if M.menuBar[#M.menuBar] then x = M.menuBar[#M.menuBar].x + M.menuBar[#M.menuBar].w end

	M.menuBar[#M.menuBar + 1] = {title = title, x = x, w = string.len(title) + menuSpacing, entries = {}}
	return #M.menuBar
end

function M.addEntry(title, menuID, action, color)
    if color == nil then color = menuBarTextColor end

	M.menuBar[menuID].entries[#M.menuBar[menuID].entries + 1] = {title = title, color = color, action = action}

    for j = 1, #M.menuBar[menuID].entries do
        if string.len(M.menuBar[menuID].entries[j].title) + menuSpacing > M.menuBar[menuID].w then
            M.menuBar[menuID].w = string.len(M.menuBar[menuID].entries[j].title) + menuSpacing
        end
    end

	return #M.menuBar[menuID].entries
end

function M.removeEntry(entryID, menuID)
	M.menuBar[menuID].entries[entryID] = nil
end

function M.drawMenuBar(expandedID, clickedID)
    local w, _ = term.getSize()
    term.setCursorPos(1, 1)

	for i = 1, #M.menuBar do
        if i == expandedID then
            for j = 1, #M.menuBar[i].entries do
                term.setCursorPos(M.menuBar[i].x, j + 1)

                if j == clickedID then
                    term.setBackgroundColor(menuBarClickedColor)
                    term.setTextColor(menuBarClickedTextColor)
                else
                    term.setBackgroundColor(menuBarColor)

                    local col = M.menuBar[i].entries[j].color
                    if col == nil then col = menuBarTextColor end

                    term.setTextColor(col)
                end

                term.write(M.util.padText(M.menuBar[i].entries[j].title, M.menuBar[i].w))
            end

            term.setBackgroundColor(menuBarClickedColor)
            term.setTextColor(menuBarClickedTextColor)
        else
            term.setBackgroundColor(menuBarColor)
            term.setTextColor(menuBarTextColor)
        end

        term.setCursorPos(M.menuBar[i].x, 1)
        term.write(M.util.padText(M.menuBar[i].title, M.menuBar[i].w) .. string.rep(" ", menuSpacing))
	end

    term.setBackgroundColor(menuBarColor)
    term.setTextColor(menuBarTextColor)

    term.setCursorPos(M.menuBar[#M.menuBar].x + M.menuBar[#M.menuBar].w, 1)
    term.write(M.util.padText("", w))

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

function M.drawPages(pageOffset, scrollPos, layers, layer)
    local _, h = term.getSize()

    for l = 1, #layers do
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
                term.setTextColor(layers[l].color)
                term.setBackgroundColor(colors.white)

                if layers[l].pages[pos.page] == nil or layers[l].pages[pos.page][pos.y] == nil then
                    term.write(M.util.padText("", M.pageSize.w))
                else
                    term.write(M.util.padText(layers[l].pages[pos.page][pos.y], M.pageSize.w))
                end

                if pos.y > 1 then
                    term.setTextColor(shadowColor)
                    term.setBackgroundColor(backgroundColor)

                    term.write("\127")
                end

                term.setBackgroundColor(colors.black)
            end
        end
    end

    print("")
    print(textutils.serialise(layers[layer]))
    term.setTextColor(layers[layer].color)
end

function M.draw(pageOffset, cursorPos, scrollPos, layers, expandedID, clickedID)
    M.drawBackground(pageOffset)
    M.drawCursorPos(cursorPos)
    M.drawPages(pageOffset, scrollPos, layers, cursorPos.layer)
    M.drawMenuBar(expandedID, clickedID)
end

return M