-- ================================
--  uilib.lua
-- --------------------------------
--  A library for various UI
--  actions like drawing elements
--  and checking for events.
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

local bigtext = require("/lib/ThirdParty/bigtext")
local numChars = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "." }

local M = {}

-- Class to hold Styles for different UI elements
M.Style = {}
M.Style.__index = M.Style

function M.Style:new(normalFG, normalBG, pressedFG, pressedBG, disabledFG, disabledBG, shadowFG, shadowBG)
    local style = {}
    setmetatable(style, M.Style)

    if normalFG == nil then normalFG = colors.white end
    if normalBG == nil then normalBG = colors.gray end
    if pressedFG == nil then pressedFG = colors.white end
    if pressedBG == nil then pressedBG = colors.lime end
    if disabledFG == nil then disabledFG = colors.gray end
    if disabledBG == nil then disabledBG = colors.lightGray end
    if shadowFG == nil then shadowFG = colors.lightGray end
    if shadowBG == nil then shadowBG = colors.black end

    style.normalFG = normalFG
    style.normalBG = normalBG
    style.pressedFG = pressedFG
    style.pressedBG = pressedBG
    style.disabledFG = disabledFG
    style.disabledBG = disabledBG
    style.shadowFG = shadowFG
    style.shadowBG = shadowBG

    return style
end

function M.Style:getColors(pressed, disabled)
    if pressed == nil then pressed = false end
    if disabled == nil then disabled = false end

    if disabled then return self.disabledFG, self.disabledBG end
    if pressed then return self.pressedFG, self.pressedBG end
    return self.normalFG, self.normalBG
end

function M.Style:getShadowColors()
    return self.shadowFG, self.shadowBG
end








-- Class that holds properties for a label

M.Label = {}
M.Label.__index = M.Label

function M.Label:new(text, x, y, parent, style, big)
    local label = {}
    setmetatable(label, M.Label)

    if style == nil then style = M.Style:new() end
    if big == nil then big = false end

    label.text = text
    label.x = x
    label.y = y
    label.parent = parent
    label.style = style
    label.big = big

    label.visible = true

    return label
end

-- Draws the Label
function M.Label:draw()
    if self.visible == false then return end

    local fg, bg = self.style:getColors(false, false)
    local x, y = self.x, self.y

    if self.parent then x, y = self.parent:convLocalToGlobal(x, y) end

    term.setTextColor(fg)
    term.setBackgroundColor(bg)
    term.setCursorPos(x, y)

    if not self.big then
        term.write(self.text)
    else
        bigtext.bigWrite(self.text)
    end

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
end

-- Function to change text in the label
function M.Label:changeText(text)
    self.text = text
    self:draw()
end

-- Function to show the label
function M.Label:show()
    self.visible = true
end

-- Function to hide the label
function M.Label:hide()
    self.visible = false
end








-- Class that holds properties for an image

M.Image = {}
M.Image.__index = M.Image

function M.Image:new(imgPath, x, y, parent)
    local image = {}
    setmetatable(image, M.Image)

    image.imgData = paintutils.loadImage(imgPath)
    image.x = x
    image.y = y
    image.parent = parent

    image.visible = true

    return image
end

-- Draws the Image
function M.Image:draw()
    if self.visible == false then return end

    local x, y = self.x, self.y
    if self.parent then x, y = self.parent:convLocalToGlobal(x, y) end

    paintutils.drawImage(self.imgData, x, y)
end

-- Function to show the image
function M.Image:show()
    self.visible = true
end

-- Function to hide the Image
function M.Image:hide()
    self.visible = false
end








-- Class that holds properties for a panel

M.Panel = {}
M.Panel.__index = M.Panel

function M.Panel:new(fill, x, y, w, h, parent, style)
    local panel = {}
    setmetatable(panel, M.Panel)

    if style == nil then style = M.Style:new() end

    panel.fill = fill
    panel.x = x
    panel.y = y
    panel.w = w
    panel.h = h
    panel.parent = parent
    panel.style = style

    panel.visible = true

    return panel
end

-- Draws the Panel
function M.Panel:draw()
    if self.visible == false then return end

    local fg, bg = self.style:getColors(false, false)
    local x, y = self.x, self.y

    if self.parent then x, y = self.parent:convLocalToGlobal(x, y) end

    -- Iterate over the area of the panel
    for j = 1, self.h do
        for i = 1, self.w do
            term.setCursorPos(x + (i - 1), y + (j - 1))
            term.setTextColor(fg)
            term.setBackgroundColor(bg)

            term.write(self.fill)

            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.black)
        end
    end
end

-- Function to show the panel
function M.Panel:show()
    self.visible = true
end

-- Function to hide the panel
function M.Panel:hide()
    self.visible = false
end






-- Class to hold properties of a button
M.Button = {}
M.Button.__index = M.Button

function M.Button:new(text, x, y, w, h, parent, action, args, toggle, style, shadowChar, shadowSize)
    local btn = {}
    setmetatable(btn, M.Button)

    toggle = toggle or false
    style = style or M.Style:new()
    shadowChar = shadowChar or " "
    shadowSize = shadowSize or 0

    btn.text = text
    btn.x = x
    btn.y = y
    btn.w = w
    btn.h = h
    btn.parent = parent
    btn.style = style

    btn.action = action
    btn.args = args
    btn.toggle = toggle

    btn.shadowChar = shadowChar
    btn.shadowSize = shadowSize

    btn.visible = true
    btn.pressed = false
    btn.disabled = false

    return btn
end

-- Function to draw the button
function M.Button:draw()
    if self.visible == false then return end

    local fg, bg = self.style:getColors(self.pressed, self.disabled)
    local sfg, sbg = self.style:getShadowColors()
    local x, y = self.x, self.y

    if self.parent then x, y = self.parent:convLocalToGlobal(x, y) end

    -- Iterate over the area of the button + shadow
    for j = 1, self.h + self.shadowSize do
        for i = 1, self.w + self.shadowSize do
            term.setCursorPos(x + (i - 1), y + (j - 1))

            if j <= self.h and i <= self.w then
                -- Draw Button
                term.setTextColor(fg)
                term.setBackgroundColor(bg)

                -- If vertically in the center, draw text
                if j == math.ceil(self.h / 2) then
                    -- Draw Padding
                    if i == 1 or i == self.w or (i - 1) > string.len(self.text) then
                        term.write(" ")
                    else
                        term.write(string.sub(self.text, i - 1, i - 1))
                    end
                else
                    term.write(" ")
                end
            elseif j > 1 and i > 1 then
                -- Draw Shadow
                term.setTextColor(sfg)
                term.setBackgroundColor(sbg)

                term.write(self.shadowChar)
            end

            -- Reset colors
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.black)
        end
    end
end

-- Function to check if a click event occured on the button
function M.Button:event(eventBundle)
    -- Handler for click events
    if eventBundle[1] == "mouse_click" or eventBundle[1] == "monitor_touch" then
        local ex, ey = eventBundle[3], eventBundle[4]
        -- Check if button is visible and not disabled
        if self.visible == false or self.disabled == true then return end

        -- Check if clicked coordinate is within button
        if ex >= self.x and ex < self.x + self.w  and ey >= self.y and ey < self.y + self.h then
            -- Check if button needs to be toggled off
            if self.toggle == true and self.pressed == true then
                self.pressed = false
                return
            end

            self.pressed = true
            self:draw()

            local ret = nil
            if self.action and self.args then
                ret = {self.action(table.unpack(self.args))}
            end

            -- Reset button if not in toggle mode
            if self.toggle == false then
                sleep(0.1)
                self.pressed = false

                self:draw()
            end

            if ret then return ret end
        end
    end
end

-- Function to disable the button
function M.Button:disable(status)
    if status == nil then status = not self.disabled end
    self.disabled = status
end

-- Function to show the button
function M.Button:show()
    self.visible = true
    self.disabled = false
end

-- Function to hide the button
function M.Button:hide()
    self.visible = false
    self.disabled = true
end








-- Class to hold properties of a text box
M.TextBox = {}
M.TextBox.__index = M.TextBox

function M.TextBox:new(x, y, w, h, padding, parent, maxChars, numOnly, obfuscated, obfuscateChar, style)
    padding = padding or 1
    numOnly = numOnly or false
    obfuscated = obfuscated or false
    obfuscateChar = obfuscateChar or "\x07"
    style = style or M.Style:new()

    local maxPossibleChars = (w - padding * 2) * (h - padding * 2) - 1
    if maxChars == nil or maxChars > maxPossibleChars then maxChars = maxPossibleChars end

    local tb = {}
    setmetatable(tb, M.TextBox)

    tb.x = x
    tb.y = y
    tb.w = w
    tb.h = h
    tb.padding = padding
    tb.parent = parent
    tb.maxChars = maxChars
    tb.numOnly = numOnly
    tb.obfuscated = obfuscated
    tb.obfuscateChar = obfuscateChar
    tb.style = style

    tb.text = ""
    tb.visible = true
    tb.disabled = false
    tb.focused = false

    tb.cursorPos = 0

    return tb
end

-- Function to draw the textbox
function M.TextBox:draw()
    if self.visible == false then return end

    local fg, bg = self.style:getColors(false, self.disabled)
    local cfg, cbg = self.style:getColors(true, false)
    local x, y = self.x, self.y
    local w, h = self.w, self.h

    if self.parent then x, y = self.parent:convLocalToGlobal(x, y) end

    -- Draw background
    paintutils.drawFilledBox(x, y, x + w - 1, y + h - 1, bg)

    -- Add text
    term.setTextColor(fg)

    for i = 1, h - self.padding * 2 do
        term.setCursorPos(x + self.padding, y + self.padding + (i - 1))

        local line = string.sub(self.text, (i - 1) * (w - self.padding * 2) + 1, i * (w - self.padding * 2))
        if line == "" then break end

        if self.obfuscated == true then
            term.write(string.rep(self.obfuscateChar, string.len(line)))
        else
            term.write(line)
        end
    end

    -- Add cursor
    if self.focused then
        term.setTextColor(cfg)
        term.setBackgroundColor(cbg)

        local cursorChar = string.sub(self.text, self.cursorPos + 1, self.cursorPos + 1)
        if cursorChar == "" then cursorChar = " " end
        if self.obfuscated and cursorChar ~= " " then cursorChar = self.obfuscateChar end

        local cx, cy = self.cursorPos % (w - self.padding * 2) + self.padding, math.floor(self.cursorPos / (w - self.padding * 2)) + self.padding
        term.setCursorPos(x + cx, y + cy)
        term.write(cursorChar)
    end

    -- Reset colors
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
end

-- Function to hanlde events
function M.TextBox:event(eventBundle)
    -- Handler for key event
    if eventBundle[1] == "key" then
        local key = eventBundle[2]
        local changed = false

        -- Check if textbox is focused, visible and not disabled
        if self.focused == false or self.visible == false or self.disabled == true then return end

        -- Arrow key navigation
        if key == keys.left and self.cursorPos > 0 then
            self.cursorPos = self.cursorPos - 1
            changed = true
        end

        if key == keys.right and self.cursorPos < #self.text then
            self.cursorPos = self.cursorPos + 1
            changed = true
        end

        -- Text deletion
        if key == keys.backspace and self.cursorPos > 0 then
            self.cursorPos = self.cursorPos - 1

            local h1 = string.sub(self.text, 1, self.cursorPos)
            local h2 = string.sub(self.text, self.cursorPos + 2)
            self.text = h1 .. h2

            changed = true
        end

        if key == keys.delete and self.cursorPos < #self.text then
            local h1 = string.sub(self.text, 1, self.cursorPos)
            local h2 = string.sub(self.text, self.cursorPos + 2)
            self.text = h1 .. h2
            changed = true
        end

        -- Redraw
        if changed then self:draw() end
    end




    -- Handler or char event
    if eventBundle[1] == "char" then
        local char = eventBundle[2]

        -- Check if textbox is focused, visible and not disabled
        if self.focused == false or self.visible == false or self.disabled == true then return end
        if #self.text >= self.maxChars then return end

        -- Filter chars when numOnly is enabled
        if self.numOnly then
            local charIsNum = false

            for _, v in pairs(numChars) do
                if v == char then charIsNum = true end
            end

            if charIsNum == false then return end
        end

        -- Insert char
        local h1 = string.sub(self.text, 1, self.cursorPos)
        local h2 = string.sub(self.text, self.cursorPos + 1)
        self.text = h1 .. char .. h2

        self.cursorPos = self.cursorPos + 1

        -- Redraw
        self:draw()
    end




    -- Handler for mouse click event
    if eventBundle[1] == "mouse_click" then
        local ex, ey = eventBundle[3], eventBundle[4]

        -- Check if textbox is visible and not disabled
        if self.visible == false or self.disabled == true then return end

        -- Check if clicked coordinate is within textbox
        if ex >= self.x and ex < self.x + self.w  and ey >= self.y and ey < self.y + self.h then
            self:focus()
        else
            self:unfocus()
        end
    end
end

-- Function to disable the text box
function M.TextBox:disable(status)
    if status == nil then status = not self.disabled end
    self.disabled = status
end

-- Function to show the text box
function M.TextBox:show()
    self.visible = true
    self.disabled = false
end

-- Function to hide the text box
function M.TextBox:hide()
    self.visible = false
    self.disabled = true
end

-- Function to focus text box
function M.TextBox:focus()
    local focused = self.focused
    self.focused = true

    -- Redraw
    if self.focused ~= focused then self:draw() end
end

-- Function to unfocus text box
function M.TextBox:unfocus()
    local focused = self.focused
    self.focused = false

    -- Redraw
    if self.focused ~= focused then self:draw() end
end








-- Class to hold properties of a progress bar
M.ProgressBar = {}
M.ProgressBar.__index = M.ProgressBar

function M.ProgressBar:new(minVal, maxVal, val, x, y, w, h, parent, vertical, inverted, style)
    if vertical == nil then vertical = false end
    if inverted == nil then inverted = false end
    if style == nil then style = M.Style:new() end

    local progbar = {}
    setmetatable(progbar, M.ProgressBar)

    progbar.minVal = minVal
    progbar.maxVal = maxVal
    progbar.val = val
    progbar.x = x
    progbar.y = y
    progbar.w = w
    progbar.h = h
    progbar.parent = parent
    progbar.vertical = vertical
    progbar.inverted = inverted
    progbar.style = style

    progbar.visible = true

    return progbar
end

-- Function to draw the progress bar
function M.ProgressBar:draw()
    if self.visible == false then return end

    local scaledSize = self.w
    if self.vertical then scaledSize = self.h end

    -- Calculate number of filled pixels
    local numFilled = (self.val - self.minVal) / (self.maxVal - self.minVal) * scaledSize
    local numSolidFilled = math.floor(numFilled)
    local numPartlyFilled = 1
    if numFilled == math.floor(numFilled) then numPartlyFilled = 0 end

    -- Get colors and position
    local fg, bg = self.style:getColors(false, false)
    local x, y = self.x, self.y

    if self.parent then x, y = self.parent:convLocalToGlobal(x, y) end

    -- Iterate over all pixels
    for j = 1, self.h do
        for i = 1, self.w do
            -- Invert if needed
            local cx = i - 1
            local cy = j - 1

            if self.inverted then
                cx = (self.w - 1) - cx
                cy = (self.h - 1) - cy
            end

            -- Set cursor pos to current pixel
            term.setCursorPos(x + cx, y + cy)

            local pos = i
            if self.vertical then pos = ((self.h + 1) - j) end

            -- Check how the current pixel should be drawn
            if pos <= numSolidFilled then
                term.setBackgroundColor(fg) -- This is not a typo.
                term.write(" ")
            elseif pos == numSolidFilled + 1 and numPartlyFilled == 1 then
                term.setTextColor(fg)
                term.setBackgroundColor(bg)
                term.write("\x7f")
            else
                term.setBackgroundColor(bg)
                term.write(" ")
            end

            -- Reset colors
            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.black)
        end
    end
end

-- Function to show the button
function M.ProgressBar:show()
    self.visible = true
end

-- Function to hide the button
function M.ProgressBar:hide()
    self.visible = false
end








-- Class for handling groups of UI elements

M.Group = {}
M.Group.__index = M.Group

function M.Group:new(x, y, parent, background, elements)
	local group = {}
	setmetatable(group, M.Group)

	if elements == nil then elements = {} end

	group.x = x
	group.y = y
    group.parent = parent
    group.background = background
	group.elements = elements

	group.visible = true

	return group
end

-- Function to convert from local to global coordinate space
function M.Group:convLocalToGlobal(x, y)
    x = x + self.x - 1
    y = y + self.y - 1

    return x, y
end

-- Function to convert from global to local coordinate space
function M.Group:convGlobalToLocal(x, y)
    x = x - self.x + 1
    y = y - self.y + 1

    return x, y
end

-- Function to draw the entire Group
function M.Group:draw()
	if self.visible == false then return end
    if self.background then self.elements[self.background]:draw() end

	for k, v in pairs(self.elements) do
        repeat
            if k == self.background then break end
		    v:draw()
        until true
	end
end

-- Function to pass the click event to all elemens
function M.Group:event(eventBundle)
    -- Manipulate coordinates for click events
    if eventBundle[1] == "mouse_click" or eventBundle[1] == "monitor_touch" then
        local x, y = self.x, self.y
        local ex, ey = eventBundle[3], eventBundle[4]
        if self.parent then x, y = self.parent:convGlobalToLocal(x, y) end

        if ex < x and ey < y then return end
        ex, ey = self:convGlobalToLocal(ex, ey)
        eventBundle[3], eventBundle[4] = ex, ey

        for _, v in pairs(self.elements) do
            -- Check if element has event function
            if getmetatable(v).__index.event then v:event(eventBundle) end
        end
    end

    -- Call event function on every child
    for _, v in pairs(self.elements) do
        -- Check if element has event function
        if getmetatable(v).__index.event then v:event(eventBundle) end
    end
end

-- Functon to add an element to the group
function M.Group:add(element, id)
	if id == nil or id == "" then return end
	if element == nil then return end

    element.parent = self
	self.elements[id] = element
end

-- Function to remove an element from the group
function M.Group:remove(id)
	if id == nil or id == "" then return end
	self.elements[id] = nil
end

-- Function to get a specific element from the group
function M.Group:get(id)
	if id == nil or id == "" then return -1 end
	return self.elements[id]
end

-- Function to make group visible
function M.Group:show()
	self.visible = true
end

-- Function to make group invisible
function M.Group:hide()
	self.visible = false
end








-- Class for handling pages of UI elements

M.PageHandler = {}
M.PageHandler.__index = M.PageHandler

function M.PageHandler:new(pages, active)
    local pageHandler = {}
    setmetatable(pageHandler, M.PageHandler)

	if pages == nil then
		pages = {}
		active = 1
	end
	if active == nil then active = 1 end

    pageHandler.pages = pages
	pageHandler.active = active

    return pageHandler
end

-- Function to draw the current page
function M.PageHandler:draw()
	local page = self:get()
	page:draw()
end

-- Function to add a page
function M.PageHandler:add(page, index)
	if index == nil then index = #self.pages + 1 end
	self.pages[index] = page
end

-- Function to remove a page
function M.PageHandler:remove(index)
	if index == nil then return end
	self.pages[index] = nil
end

-- Function to get a specific page
function M.PageHandler:get(index)
	if index == nil then index = self.active end
	return self.pages[index]
end

-- Function to move to next page
function M.PageHandler:next()
	if self.active + 1 > #self.pages then return end

    self:get():hide()
	self.active = self.active + 1

    self:get():show()
	self:draw()
end

-- Function to move to previous page
function M.PageHandler:prev()
	if self.active - 1 < 1 then return end

    self:get():hide()
	self.active = self.active - 1

    self:get():show()
	self:draw()
end

return M