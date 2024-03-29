local util = require("Modules/util")
local ui = require("Modules/ui")
local edit = require("Modules/edit")
local cursor = require("Modules/cursor")
local file = require("Modules/file")
local fsdiag = require("Modules/ThirdParty/fileDialog")

local w, h = term.getSize()

local pageSize = {w = 25, h = 21}
local pageSpacing = 2
local pagePos = math.ceil((w - pageSize.w) / 2)

local layers = {{color = colors.black, title = "Black", pages = {}}}
local cursorPos = {layer = 1, page = 1, x = 1, y = 1}

local pageOffset = 1
local scrollPos = -(pageOffset + 1)

local control = false

local expandedID = 0
local clickedID = 0

local running = true

local function exit()
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)

    running = false
end

local function getLayers()
    return layers
end

local function setLayers(newLayers)
    layers = newLayers
end

local function getCursorPos()
    return cursorPos
end

local function setCursorPos(newCursorPos)
    cursorPos = newCursorPos
end

term.clear()

cursor.init(pageSize)
edit.init(util, pageSize, cursor)
ui.init(util, pageSize, pageSpacing, pagePos)
file.init(fsdiag, setLayers, getLayers, setCursorPos, getCursorPos)

ui.addMenu("File")

ui.addEntry("New", 1, file.new)
ui.addEntry("Save", 1, file.save)
ui.addEntry("Save As", 1, file.saveAs)
ui.addEntry("Open", 1, file.open)
ui.addEntry("Exit", 1, exit)

ui.addMenu("Layers")

ui.addEntry("Add", 2, nil)
ui.addEntry("Edit", 2, nil)
ui.addEntry("Clear", 2, nil)
ui.addEntry("Remove", 2, nil)

ui.addEntry(layers[1].title, 2, nil, layers[1].color)
layers[1].pages = edit.newPage(layers[1])

while running do
    ui.draw(pageOffset, cursorPos, scrollPos, layers, expandedID, clickedID)
    cursor.setVisualCursor(layers[cursorPos.layer].pages, cursorPos, pagePos, scrollPos, pageOffset, pageSpacing)

    local _, y = term.getCursorPos()
    if y < 2 or expandedID ~= 0 then term.setCursorBlink(false)
    else term.setCursorBlink(true) end

    local eventData = table.pack(os.pullEventRaw())
    local e = eventData[1]

    if e == "char" then
        if not control then
            local c = eventData[2]
            cursorPos, layers[cursorPos.layer].pages = edit.insert(cursorPos, layers[cursorPos.layer].pages, c)
            scrollPos = cursor.jumpToCursor(cursorPos, pagePos, scrollPos, pageOffset, pageSpacing)
        end

    elseif e == "key" then
        local key = eventData[2]

        if key == keys.leftCtrl then
            control = true

        elseif key == keys.up and not control then
            cursorPos = cursor.prev(layers[cursorPos.layer].pages, cursorPos, true)

        elseif key == keys.down and not control then
            cursorPos = cursor.next(layers[cursorPos.layer].pages, cursorPos, true)

        elseif key == keys.left and not control then
            cursorPos = cursor.prev(layers[cursorPos.layer].pages, cursorPos, false)

        elseif key == keys.right and not control then
            cursorPos = cursor.next(layers[cursorPos.layer].pages, cursorPos, false)

        elseif key == keys.home then
            cursorPos = cursor.jumpBegin(cursorPos, control)

        elseif key == keys["end"] then
            cursorPos = cursor.jumpEnd(layers[cursorPos.layer].pages, cursorPos, control)
            


        elseif key == keys.enter and not control then
            cursorPos, layers[cursorPos.layer].pages = edit.newline(cursorPos, layers[cursorPos.layer].pages)

        elseif key == keys.backspace and not control then
            cursorPos, layers[cursorPos.layer].pages = edit.remove(cursorPos, layers[cursorPos.layer].pages)

        elseif key == keys.delete and not control then

        end

        scrollPos = cursor.jumpToCursor(cursorPos, pagePos, scrollPos, pageOffset, pageSpacing)

    elseif e == "key_up" then
        local key = eventData[2]

        if key == keys.leftCtrl then
            control = false
        end

    elseif e == "paste" then
        local str = eventData[2]
        cursorPos, layers[cursorPos.layer].pages = edit.insert(cursorPos, layers[cursorPos.layer].pages, str)
        scrollPos = cursor.jumpToCursor(cursorPos, pagePos, scrollPos, pageOffset, pageSpacing)

    elseif e == "mouse_click" then
        local btn, x, y = eventData[2], eventData[3], eventData[4]
        if btn == 1 then
            local unhandled = true
            
            if y <= 1 or expandedID ~= 0 then
                unhandled = false
                
                if expandedID > 0 then
                    if x >= ui.menuBar[expandedID].x and x <= ui.menuBar[expandedID].x + ui.menuBar[expandedID].w then
                        if y > #ui.menuBar[expandedID].entries + 1 then
                            expandedID = 0
                            clickedID = 0
                            unhandled = true
                        elseif y > 1 then
                            clickedID = y - 1
                            if ui.menuBar[expandedID].entries[clickedID].action then ui.menuBar[expandedID].entries[clickedID].action() end

                            expandedID = 0
                            clickedID = 0
                        end
                    elseif y > 1 then
                        expandedID = 0
                        clickedID = 0
                        unhandled = true
                    end
                end
                
                if y <= 1 then
                    for i = 1, #ui.menuBar do
                        if x >= ui.menuBar[i].x and x <= ui.menuBar[i].x + ui.menuBar[i].w then
                            expandedID = i
                            break
                        end
                    end
                end
            end

            if unhandled then
                if expandedID > 0 then
                    expandedID = 0
                    clickedID = 0
                end
                
                cursorPos = cursor.setPos(layers[cursorPos.layer].pages, cursor.fromScreenSpace(x, y, pagePos, scrollPos, pageOffset, pageSpacing))
            end
        end

    elseif e == "mouse_scroll" then
        local scrollDir = eventData[2]
        if scrollDir == 0 then scrollDir = -1 end
        scrollPos = scrollPos + scrollDir

        local nPages = 1
        for l = 1, #layers do
            if #layers[l].pages > nPages then
                nPages = #layers[l].pages
            end
        end

        local maxScroll = util.calcMaxOffset(nPages, pageSize, pageSpacing)

        if scrollPos < -(pageOffset + 1) then scrollPos = -(pageOffset + 1) end
        if scrollPos > maxScroll then scrollPos = maxScroll end

    elseif e == "mouse_drag" then


    elseif e == "terminate" then
        exit()
    end
end

term.setTextColor(colors.white)