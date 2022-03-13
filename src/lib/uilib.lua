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

function M.Label:new(text, x, y, style)
    local label = {}
    setmetatable(label, M.Label)

    if style == nil then style = M.Style:new() end

    label.text = text
    label.x = x
    label.y = y
    label.style = style

    label.visible = true

    return label
end

-- Draws the Label
function M.Label:draw()
    if self.visible == false then return end

    local fg, bg = self.style:getColors(false, false)

    term.setTextColor(fg)
    term.setBackgroundColor(bg)
    term.setCursorPos(self.x, self.y)

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






-- Class to hold properties of a button
M.Button = {}
M.Button.__index = M.Button

function M.Button:new(text, x, y, w, h, action, args, toggle, style)
    local btn = {}
    setmetatable(btn, M.Button)

    if toggle == nil then toggle = false end
    if style == nil then style = M.Style:new() end

    btn.text = text
    btn.x = x
    btn.y = y
    btn.w = w
    btn.h = h
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

    -- Iterate over the area of the button
    for j = 1, self.h do
        for i = 1, self.w do
            term.setCursorPos(self.x + (i - 1), self.y + (j - 1))
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
    if self.visible == flase or self.disabled == true then return end

    -- Check if clicked coordinate is within button
    if ex >= self.x and ex <= self.x + self.w  and ey >= self.y and ey <= self.y + self.h then
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

function M.ProgressBar:new(minVal, maxVal, val, x, y, w, h, vertical, inverted, style)
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
    
    -- Get colors
    local fg, bg = self.style:getColors(false, false)

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
            term.setCursorPos(self.x + cx, self.y + cy)

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








-- Class for handling pages of UI elements

M.Page = {}
M.Page.__index = M.Page

function M.Page:new()
    local page = {}
    setmetatable(page, M.Page)

    

    return page
end

return M