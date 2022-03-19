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
local uilib = require("/lib/uilib")

-- --------------------------------
--  Configurable Properties
-- --------------------------------

local modemSide = "top"
local serverDomain = "essentia.dl"








-- --------------------------------
--  Internal Properties
-- --------------------------------

local modules = {}
local sModem
local serverAddress
local pages = uilib.PageHandler:new()








-- --------------------------------
--  Classes
-- --------------------------------

local Module = {}
Module.__index = Module

function Module:new(x, y, aspect, title, color)
    local mod = {}
    setmetatable(mod, Module)

    mod.aspect = aspect
    mod.amount = 0

    mod.selAmount = 0

    mod.ui = uilib.Group:new(x, y)

    local titleLabel = uilib.Label:new(title, 2, 2, nil, uilib.Style:new(color, colors.black))
    mod.ui:add(titleLabel, "titleLabel")

    local amountLabel = uilib.Label:new("x" .. mod.amount, 3, 3, nil, uilib.Style:new(colors.white, colors.black))
    mod.ui:add(amountLabel, "amountLabel")

    local progbar = uilib.ProgressBar:new(0, 250, mod.amount, 2, 5, 15, 1, nil, false, false, uilib.Style:new(color))
    mod.ui:add(progbar, "progbar")

    local runBtn = uilib.Button:new(mod.selAmount, 5, 7, 9, 3, nil, Module.run, {mod}, false)
    mod.ui:add(runBtn, "runBtn")
    
    local lessBtn = uilib.Button:new("<", 2, 7, 3, 3, nil, Module.less, {mod}, false)
    mod.ui:add(lessBtn, "lessBtn")

    local moreBtn = uilib.Button:new(">", 14, 7, 3, 3, nil, Module.more, {mod}, false)
    mod.ui:add(moreBtn, "moreBtn")

    return mod
end

function Module:update(amount, selAmount)
    if amount == nil then amount = self.amount end
    if selAmount == nil then selAmount = self.selAmount end

    self.amount = amount
    self.selAmount = selAmount

    self.ui:get("amountLabel").text = "x" .. amount
    self.ui:get("progbar").val = amount
    self.ui:get("runBtn").text = selAmount

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

    self:update(nil, selAmount)
end

function Module:more()
    local selAmount = self.selAmount + 5
    if selAmount > 250 then selAmount = 250 end

    self:update(nil, selAmount)
end

function Module:probe()
    local ret = comlib.sendRequest(sModem, serverAddress, "PROBE", {aspect = self.aspect})
    if ret ~= -1 and ret.status == "OK" then self:update(ret.contents.amount, nil) end
end

function Module:run()
    for i = 5, self.selAmount, 5 do
        local ret = comlib.sendRequest(sModem, serverAddress, "FLOW", {aspect = self.aspect})
        if i + 5 <= self.selAmount then sleep(10) end
        self:probe()
    end
end








-- --------------------------------
--  Local Functions
-- --------------------------------

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

local function probeAll()
    for i = 1, #modules do
        modules[i]:probe()
    end
end








-- --------------------------------
--  Main Program
-- --------------------------------

-- TODO: Add monitor
-- TODO: Add refresh button to module
-- TODO: Add reset button to module

-- TODO: Add refresh all button
-- TODO: Add flow all button
-- TODO: Add reset all button

sModem = comlib.open(modemSide)                           -- Create Secure Modem
dnslib.init(sModem)                                       -- Initialize DNSLib
serverAddress = dnslib.lookup(serverDomain)               -- Look up server address

term.clear()
term.setCursorPos(1, 1)

table.insert(modules, createModule(1, 1, 1, "sensus", "Sensus", colors.lightBlue))
table.insert(modules, createModule(1, 17, 1, "preamunio", "Preamunio", colors.cyan))
table.insert(modules, createModule(1, 34, 1, "victus", "Victus", colors.red))

probeAll()

while true do
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