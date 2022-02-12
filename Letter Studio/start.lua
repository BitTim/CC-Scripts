local util = require("Modules/util")
local ui = require("Modules/ui")
local edit = require("Modules/edit")
local cursor = require("Modules/cursor")

local w, h = term.getSize()

local pageSize = {w = 25, h = 21}
local pageSpacing = 2
local pagePos = math.floor((w - pageSize.w) / 2)

local pages = {}
local cursorPos = {page = 1, x = 1, y = 1}

local pageOffset = 1
local scrollPos = -(pageOffset + 1)

term.clear()

cursor.init(pageSize)
edit.init(util, pageSize)
ui.init(util, pageSize, pageSpacing, pagePos)

pages = edit.newPage(pages)

while true do
    ui.draw(pageOffset, cursorPos, scrollPos, pages)
    cursor.setVisualCursor(pages, cursorPos, pagePos, scrollPos, pageOffset, pageSpacing)

    local _, y = term.getCursorPos()
    if y < 2 then term.setCursorBlink(false)
    else term.setCursorBlink(true) end

    local eventData = table.pack(os.pullEventRaw())
    local e = eventData[1]

    if e == "char" then
        local c = eventData[2]
        cursorPos, pages = edit.insert(cursorPos, pages, cursorPos.page, cursorPos.x, cursorPos.y, c)
        scrollPos = cursor.jumpToCursor(cursorPos, pagePos, scrollPos, pageOffset, pageSpacing)

    elseif e == "key" then
        local key = eventData[2]

        if key == keys.up then
            cursorPos = cursor.prev(pages, cursorPos, true)

        elseif key == keys.down then
            cursorPos = cursor.next(pages, cursorPos, true)

        elseif key == keys.left then
            cursorPos = cursor.prev(pages, cursorPos, false)

        elseif key == keys.right then
            cursorPos = cursor.next(pages, cursorPos, false)



        elseif key == keys.enter then


        elseif key == keys.delete then


        elseif key == keys.backspace then
            

        end

        scrollPos = cursor.jumpToCursor(cursorPos, pagePos, scrollPos, pageOffset, pageSpacing)

    elseif e == "mouse_click" then


    elseif e == "mouse_scroll" then
        local scrollDir = eventData[2]
        if scrollDir == 0 then scrollDir = -1 end
        scrollPos = scrollPos + scrollDir

        local maxScroll = util.calcMaxOffset(#pages, pageSize, pageSpacing)

        if scrollPos < -(pageOffset + 1) then scrollPos = -(pageOffset + 1) end
        if scrollPos > maxScroll then scrollPos = maxScroll end

    elseif e == "mouse_drag" then


    elseif e == "terminate" then
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.black)
        break
    end
end

term.setTextColor(colors.white)