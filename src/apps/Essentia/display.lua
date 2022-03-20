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
local probeRate = 60








-- --------------------------------
--  Internal Properties
-- --------------------------------

local modules = {}
local sModem
local serverAddress
local pages = uilib.PageHandler:new()
local probeTimer = nil

local mon = peripheral.find("monitor")
local sidePanel = nil








-- --------------------------------
--  Classes
-- --------------------------------

-- Predefinitions

local Module = {}
Module.__index = Module

local SidePanel = {}
SidePanel.__index = SidePanel

-- Class for Modules of aspects

function Module:new(x, y, aspect, title, color)
    local mod = {}
    setmetatable(mod, Module)

    mod.title = title
    mod.color = color
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

    local flowBtn = uilib.Button:new(mod.selAmount, 5, 7, 9, 3, nil, Module.flow, {mod}, false)
    mod.ui:add(flowBtn, "flowBtn")
    
    local lessBtn = uilib.Button:new("<", 2, 7, 3, 3, nil, Module.less, {mod}, false)
    mod.ui:add(lessBtn, "lessBtn")

    local moreBtn = uilib.Button:new(">", 14, 7, 3, 3, nil, Module.more, {mod}, false)
    mod.ui:add(moreBtn, "moreBtn")

    local probeBtn = uilib.Button:new("Probe", 2, 11, 7, 1, nil, Module.probe, {mod}, false)
    mod.ui:add(probeBtn, "probeBtn")

    local resetBtn = uilib.Button:new("Reset", 10, 11, 7, 1, nil, Module.reset, {mod}, false)
    mod.ui:add(resetBtn, "resetBtn")

    mod:update(nil, nil)

    return mod
end

function Module:update(amount, selAmount)
    if amount == nil then amount = self.amount end
    if selAmount == nil then selAmount = self.selAmount end

    self.amount = amount
    self.selAmount = selAmount

    self.ui:get("amountLabel").text = "x" .. amount
    self.ui:get("progbar").val = amount
    self.ui:get("flowBtn").text = selAmount

    if selAmount > self.amount then
        self.ui:get("flowBtn").disabled = true
        self.ui:get("lessBtn").disabled = false
        self.ui:get("moreBtn").disabled = true
    elseif selAmount < 1 then
        self.ui:get("flowBtn").disabled = true
        self.ui:get("lessBtn").disabled = true
        self.ui:get("moreBtn").disabled = false
    else
        self.ui:get("flowBtn").disabled = false
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
    sidePanel:update("Probing", nil, nil, nil)
    sidePanel:update(nil, self.title, self.color, nil)

    local ret = comlib.sendRequest(sModem, serverAddress, "PROBE", {aspect = self.aspect})
    if ret ~= -1 and ret.status == "OK" then self:update(ret.contents.amount, nil) end

    term.clear()
    pages:draw()
    sidePanel.ui:draw()

    sidePanel:update("Ready", "", nil, nil)
end

function Module:flow()
    for i = 5, self.selAmount, 5 do
        sidePanel:update("Flowing", nil, nil, nil)
        sidePanel:update(nil, self.title, self.color, nil)

        local ret = comlib.sendRequest(sModem, serverAddress, "FLOW", {aspect = self.aspect})
        sleep(8.5)

        self:probe()
        probeTimer = os.startTimer(probeRate)
    end

    sidePanel:update("Ready", "", nil, nil)
end

function Module:reset()
    self:update(nil, 0)
end



-- Class for side panel

function SidePanel:new(x, y)
    local sp = {}
    setmetatable(sp, SidePanel)

    sp.state = "Ready"
    sp.aspect = ""
    sp.aspectColor = colors.black
    sp.page = 1

    sp.ui = uilib.Group:new(x, y, nil, "bgPanel")
    sp.ui:add(uilib.Panel:new(" ", 1, 1, 14, 25, nil, uilib.Style:new(colors.white, colors.black)), "bgPanel")

    sp.ui:add(uilib.Label:new(sp.state, 2, 2, nil, uilib.Style:new(colors.white, colors.black)), "statusLabel")
    sp.ui:add(uilib.Label:new(sp.aspect, 2, 3, nil, uilib.Style:new(colors.white, colors.black)), "aspectLabel")
    sp.ui:add(uilib.Button:new("Flow all", 2, 5, 12, 3, nil, SidePanel.flowAll, {sp}, false), "flowAllBtn")
    sp.ui:add(uilib.Button:new("Probe all", 2, 9, 12, 3, nil, SidePanel.probeAll, {sp}, false), "probeAllBtn")
    sp.ui:add(uilib.Button:new("Reset all", 2, 13, 12, 3, nil, SidePanel.resetAll, {sp}, false), "resetAllBtn")

    sp.ui:add(uilib.Button:new("\x1E", 2, 21, 3, 3, nil, SidePanel.prevPage, {sp}, false), "prevBtn")
    sp.ui:add(uilib.Label:new(tostring(sp.page), 7, 22, nil, uilib.Style:new(colors.white, colors.black)), "pageLabel")
    sp.ui:add(uilib.Button:new("\x1F", 11, 21, 3, 3, nil, SidePanel.nextPage, {sp}, false), "nextBtn")

    sp.ui:get("prevBtn").disabled = true
    if #pages.pages <= 1 then sp.ui:get("nextBtn").disabled = true end

    return sp
end

function SidePanel:update(state, aspect, aspectColor, page)
    if state == nil then state = self.state end
    if aspect == nil then aspect = self.aspect end
    if aspectColor == nil then aspectColor = self.aspectColor end
    if page == nil then page = self.page end

    self.state = state
    self.aspect = aspect
    self.page = page

    local stateColor = colors.orange
    if state == "Ready" then stateColor = colors.green end

    self.ui:get("statusLabel").text = state
    self.ui:get("statusLabel").style.normalFG = stateColor

    self.ui:get("aspectLabel").text = aspect
    self.ui:get("aspectLabel").style.normalFG = aspectColor

    self.ui:get("pageLabel").text = tostring(page)
    self.ui:draw()
end

function SidePanel:nextPage()
    pages:next()

    if pages.active <= 1 then
        self.ui:get("nextBtn").disabled = false
        self.ui:get("prevBtn").disabled = true
    elseif pages.active >= #pages.pages then
        self.ui:get("prevBtn").disabled = false
        self.ui:get("nextBtn").disabled = true
    else
        self.ui:get("prevBtn").disabled = false
        self.ui:get("nextBtn").disabled = false
    end

    self:update(nil, nil, nil, pages.active)
end

function SidePanel:prevPage()
    pages:prev()

    if pages.active <= 1 then
        self.ui:get("nextBtn").disabled = false
        self.ui:get("prevBtn").disabled = true
    elseif pages.active >= #pages.pages then
        self.ui:get("prevBtn").disabled = false
        self.ui:get("nextBtn").disabled = true
    else
        self.ui:get("prevBtn").disabled = false
        self.ui:get("nextBtn").disabled = false
    end

    self:update(nil, nil, nil, pages.active)
end

function SidePanel:flowAll()
    for i = 1, #modules do
        modules[i]:flow()
    end
end

function SidePanel:probeAll()
    for i = 1, #modules do
        modules[i]:probe()
    end
end

function SidePanel:resetAll()
    for i = 1, #modules do
        modules[i]:reset()
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







-- --------------------------------
--  Main Program
-- --------------------------------

if mon then
    mon.setTextScale(0.5)
    term.redirect(mon)
end

sModem = comlib.open(modemSide)                           -- Create Secure Modem
dnslib.init(sModem)                                       -- Initialize DNSLib
serverAddress = dnslib.lookup(serverDomain)               -- Look up server address


table.insert(modules, createModule(1, 1, 1, "sensus", "Sensus", colors.lightBlue))
table.insert(modules, createModule(1, 18, 1, "preamunio", "Preamunio", colors.cyan))
table.insert(modules, createModule(1, 35, 1, "victus", "Victus", colors.red))
table.insert(modules, createModule(1, 52, 1, "a", "A", colors.yellow))
table.insert(modules, createModule(1, 69, 1, "b", "B", colors.orange))

table.insert(modules, createModule(1, 1, 13, "c", "C", colors.blue))
table.insert(modules, createModule(1, 18, 13, "d", "D", colors.pruple))
table.insert(modules, createModule(1, 35, 13, "e", "E", colors.gray))
table.insert(modules, createModule(1, 52, 13, "f", "F", colors.pink))
table.insert(modules, createModule(1, 69, 13, "g", "G", colors.lime))

table.insert(modules, createModule(2, 1, 1, "h", "H", colors.green))
table.insert(modules, createModule(2, 18, 1, "i", "I", colors.brown))
table.insert(modules, createModule(2, 35, 1, "j", "J", colors.yellow))
table.insert(modules, createModule(2, 52, 1, "k", "K", colors.red))
table.insert(modules, createModule(2, 69, 1, "l", "L", colors.purple))

table.insert(modules, createModule(2, 1, 13, "m", "M", colors.lightBlue))
table.insert(modules, createModule(2, 18, 13, "n", "N", colors.green))
table.insert(modules, createModule(2, 35, 13, "o", "O", colors.blue))
table.insert(modules, createModule(2, 52, 13, "p", "P", colors.white))
table.insert(modules, createModule(2, 69, 13, "q", "Q", colors.pink))

-- TODO: Fix clearing when page changed

sidePanel = SidePanel:new(87, 1)

term.clear()
pages:draw()
sidePanel.ui:draw()

sidePanel:probeAll()
probeTimer = os.startTimer(probeRate)

while true do
    local ed = table.pack(os.pullEvent())
    local e = ed[1]

    if e == "monitor_touch" or e == "mouse_click" then
        local x, y = ed[3], ed[4]
        sidePanel.ui:clickEvent(x, y)
        pages:get():clickEvent(x, y)

    elseif e == "timer" then
        if ed[2] == probeTimer then 
            sidePanel:probeAll()
            probeTimer = os.startTimer(probeRate)
        end
    end

    pages:draw()
    sidePanel.ui:draw()

    sleep(0.1)
end