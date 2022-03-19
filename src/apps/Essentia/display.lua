-- ================================
--  display.lua
-- --------------------------------
--  Script for managing and
--  distributing requests to
--  controllers
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local comlib = require("/lib/comlib")
local dnslib = require("/lib/dnslib")
local loglib = require("/lib/loglib")
local uilib = require("/lib/uilib")

-- --------------------------------
--  Configurable Properties
-- --------------------------------



local closedLabelStyle = uilib.Style:new(colors.red, colors.black)
local openLabelStyle = uilib.Style:new(colors.lime, colors.black)



local Module = {}
Module.__index = Module

function Module:new(x, y, aspect, title, color)
    local mod = {}
    setmetatable(mod, Module)

    mod.aspect = aspect
    mod.amount = 0
    mod.status = false

    mod.selAmount = 0

    mod.ui = uilib.Group:new(x, y)

    local titleLabel = uilib.Label:new(title, 2, 2, nil, uilib.Style:new(color, colors.black))
    mod.ui:add(titleLabel, "titleLabel")

    local amountLabel = uilib.Label:new("x" .. mod.amount, 3, 3, nil, uilib.Style:new(colors.white, colors.black))
    mod.ui:add(amountLabel, "amountLabel")

    local progbar = uilib.ProgressBar:new(0, 250, mod.amount, 2, 5, 15, 1, nil, false, false, uilib.Style:new(color))
    mod.ui:add(progbar, "progbar")

    local statusLabel = uilib.Label:new("Closed", 2, 7, nil, closedLabelStyle)
    mod.ui:add(statusLabel, "statusLabel")

    local runBtn = uilib.Button:new(mod.selAmount, 5, 9, 9, 3, nil, Module.run, {mod}, false)
    mod.ui:add(runBtn, "runBtn")
    
    local lessBtn = uilib.Button:new("<", 2, 9, 3, 3, nil, Module.less, {mod}, false)
    mod.ui:add(lessBtn, "lessBtn")

    local moreBtn = uilib.Button:new(">", 14, 9, 3, 3, nil, Module.more, {mod}, false)
    mod.ui:add(moreBtn, "moreBtn")

    return mod
end

function Module:update(amount, status, selAmount)
    if amount == nil then amount = self.amount end
    if status == nil then status = self.status end
    if selAmount == nil then selAmount = self.selAmount end

    self.amount = amount
    self.status = status
    self.selAmount = selAmount

    self.ui:get("amountLabel").text = "x" .. amount
    self.ui:get("progbar").val = amount
    self.ui:get("runBtn").text = selAmount

    local statusText = ""
    local statusStyle = nil

    if status then
        statusText = "Opened"
        statusStyle = openLabelStyle
    else
        statusText = "Closed"
        statusStyle = closedLabelStyle
    end

    self.ui:get("statusLabel").text = statusText
    self.ui:get("statusLabel").style = statusStyle

    if selAmount > self.amount then
        self.ui:get("runBtn").disabled = true
        self.ui:get("lessBtn").disabled = false
        self.ui:get("moreBtn").disabled = true
    elseif selAmount < 1 then
        self.ui:get("runBtn").disabled = true
        self.ui:get("lessBtn").disabled = true
        self.ui:get("moreBtn").disabled = false
    else
        self.ui:get("runBtn").disabled = false
        self.ui:get("lessBtn").disabled = false
        self.ui:get("moreBtn").disabled = false
    end
end

function Module:less()
    local selAmount = self.selAmount - 5
    if selAmount < 0 then selAmount = 0 end

    self:update(nil, nil, selAmount)
end

function Module:more()
    local selAmount = self.selAmount + 5
    if selAmount > 250 then selAmount = 250 end

    self:update(nil, nil, selAmount)
end

function Module:run()
    -- TODO: Insert code to communicate with servers here
end




local pages = uilib.PageHandler:new()



local function createModule(page, x, y, aspect, title, color)
    local mod = Module:new(x, y, aspect, title, color)

    if pages:get(page) == nil then
        local pageGroup = uilib.Group:new(1, 1)
        pageGroup:add(mod.ui, aspect)

        pages:add(pageGroup, page)
    else
        pages:get(page):add(mod.ui, aspect)
    end

    return mod
end



local modules = {
    createModule(1, 1, 1, "instrumentum", "Instrumentum", colors.blue),
    createModule(1, 17, 1, "vitium", "Vitium", colors.purple)
}

term.clear()
term.setCursorPos(1, 1)

modules[1]:update(249, true)
modules[2]:update(3, false)

while true do
    -- TODO: Add probing here

    local ed = table.pack(os.pullEvent())
    local e = ed[1]

    if e == "monitor_touch" or e == "mouse_click" then
        local x, y = ed[3], ed[4]
        pages:get():clickEvent(x, y)
    end

    term.clear()
    pages:draw()
    sleep(0.1)
end