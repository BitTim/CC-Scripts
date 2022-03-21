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

local M = {}

-- Class to hold Styles for different UI elements
M.Style = {}
M.Style.__index = M.Style

function M.Style:new(normalFG, normalBG, pressedFG, pressedBG, disabledFG, disabledBG)
    local style = {}
    setmetatable(style, M.Style)

    if normalFG == nil then normalFG = colors.white end
    if normalBG == nil then normalBG = colors.gray end
    if pressedFG == nil then pressedFG = colors.white end
    if pressedBG == nil then pressedBG = colors.lime end
    if disabledFG == nil then disabledFG = colors.gray end
    if disabledBG == nil then disabledBG = colors.lightGray end

    style.normalFG = normalFG
    style.normalBG = normalBG
    style.pressedFG = pressedFG
    style.pressedBG = pressedBG
    style.disabledFG = disabledFG
    style.disabledBG = disabledBG

    return style
end

function M.Style:getColors(pressed, disabled)
    if pressed == nil then pressed = false end
    if disabled == nil then disabled = false end

    if disabled then return self.disabledFG, self.disabledBG end
    if pressed then return self.pressedFG, self.pressedBG end
    return self.normalFG, self.normalBG
end








-- Class that holds properties for a label

M.Label = {}
M.Label.__index = M.Label

function M.Label:new(text, x, y, parent, style)
    local label = {}
    setmetatable(label, M.Label)

    if style == nil then style = M.Style:new() end

    label.text = text
    label.x = x
    label.y = y
    label.parent = parent
    label.style = style

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

    term.write(self.text)

    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
end

-- Function to show the label
function M.Label:show()
    self.visible = true
end

-- Function to hide the label
function M.Label:hide()
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

function M.Button:new(text, x, y, w, h, parent, action, args, toggle, style)
    local btn = {}
    setmetatable(btn, M.Button)

    if toggle == nil then toggle = false end
    if style == nil then style = M.Style:new() end

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
    
    btn.visible = true
    btn.pressed = false
    btn.disabled = false

    return btn
end

-- Function to draw the button
function M.Button:draw()
    if self.visible == false then return end

    local fg, bg = self.style:getColors(self.pressed, self.disabled)
    local x, y = self.x, self.y

    if self.parent then x, y = self.parent:convLocalToGlobal(x, y) end

    -- Iterate over the area of the button
    for j = 1, self.h do
        for i = 1, self.w do
            term.setCursorPos(x + (i - 1), y + (j - 1))
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

            term.setTextColor(colors.white)
            term.setBackgroundColor(colors.black)
        end
    end
end

-- Function to check if a click event occured on the button
function M.Button:clickEvent(ex, ey)
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








-- TODO: Write docs for PageHandler

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
function M.Group:clickEvent(ex, ey)
    local x, y = self.x, self.y
    if self.parent then x, y = self.parent:convGlobalToLocal(x, y) end

    if ex < x and ey < y then return end
    ex, ey = self:convGlobalToLocal(ex, ey)

    for _, v in pairs(self.elements) do
        -- Check if element has clickEvent function
        if getmetatable(v).__index.clickEvent then v:clickEvent(ex, ey) end
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