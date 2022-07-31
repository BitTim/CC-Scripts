-- ================================
--  controller.lua
-- --------------------------------
--  Script to control a create 
--  powered farm
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local uilib = require("/lib/uilib")

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Farm Controller"
local version = "v1.0"

local minSpeed = 1
local maxSpeed = 256

-- --------------------------------
--  Configurable Properties
-- --------------------------------

local farmNames = {"Potato", "Wood"}
local motorIDs = {"electric_motor1", "electric_motor2"}
local storageIDs = {"sophisticatedstorage:barrel_0", "sophisticatedstorage:barrel_1"}
local probeInterval = 5

-- --------------------------------
--  Internal Properties
-- --------------------------------

local screenSize = nil
local intervalTimer = nil

local farms = {}
local styles = {}







-- --------------------------------
--  Events
-- --------------------------------

local function onTimerEvent()
	intervalTimer = os.startTimer(probeInterval)
end







-- --------------------------------
--  Classes
-- --------------------------------

local Farm = {}
Farm.__index = Farm

function Farm:new(x, y, title, motorPeripheral, storagePeripheral)
	local farm = {}
	setmetatable(farm, Farm)

	farm.title = title
	farm.motorPeripheral = motorPeripheral
	farm.storagePeripheral = storagePeripheral

	farm.ui = farm:createUI(x, y, title, storagePeripheral.size())

	farm.storage = 0
	farm.speed = minSpeed
	farm.active = false
end

function Farm:cretaeUI(instance, x, y, title, maxSlots)
	local ui = uilib.Group:new(x, y, nil, "bgPanel")
	ui:add(uilib.Panel:new(" ", 1, 1, 17, 12, nil, styles.bg), "bgPanel")

	ui:add(uilib.Label:new(title, 2, 2, nil, styles.title), "title")
	ui:add(uilib.Label:new("", 2, 3, nil, styles.label), "motorState")
	ui:add(uilib.Button:new("Toggle", 2, 4, 14, 1, nil, Farm.buttonEvent, {instance}, false, styles.button), "toggleButton")

	ui:add(uilib.Label:new("Storage:", 2, 5, nil, styles.label), "storageLabel")
	ui:add(uilib.ProgressBar:new(0, maxSlots, 0, 2, 6, nil, false, false, styles.progress), "storageProgress")

	ui:add(uilib.Label:new("Speed:", 2, 8, nil, styles.label), "speedLabel")
	ui:add(uilib.Button:new("<", 2, 7, 3, 3, nil, Farm.less, {instance}, false), "lessBtn")
	ui:add(uilib.Label:new("", 5, 7, nil, styles.label), "speedValue")
	ui:add(uilib.Button:new(">", 14, 7, 3, 3, nil, Farm.more, {instance}, false), "moreBtn")
end

function Farm:update(storage, speed, active)
	if storage == nil then storage = self.storage end
	if speed == nil then speed = self.speed end
	if active == nil then active = self.active end

	self.storage = storage
	self.speed = speed
	self.active = active

	if active then
		self.motorPeripheral.setSpeed(speed)
	else
		self.motorPeripheral.stop()
	end

	local storagePercent = storage / self.storagePeripheral.size()
	local progressStyle = styles.ok

	if storagePercent > 0.6 then progressStyle = styles.warn
	elseif storagePercent > 0.8 then progressStyle = styles.crit end

	self.ui:get("motorState"):setText(active and "Active" or "Inactive")
	self.ui:get("motorState"):setStyle(active and styles.ok or styles.crit)

	self.ui:get("toggleButton"):setText(active and "Stop" or "Start")

	self.ui:get("storageProgress"):setValue(storage)
	self.ui:get("storageProgress"):setStyle(progressStyle)

	self.ui:get("speedValue"):setText(speed)

	local lessHandled, moreHandled = false, false

	if speed >= maxSpeed then
		moreHandled = true

		self.ui:get("moreBtn").disabled = true
		self.ui:get("lessBtn").disabled = false
	end

	if speed < minSpeed then
		lessHandled = true

		self.ui:get("lessBtn").disabled = true

		if moreHandled == false then
			self.ui:get("moreBtn").disabled = false
		end
	end

    if lessHandled == false then self.ui:get("lessBtn").disabled = false end
    if moreHandled == false then self.ui:get("moreBtn").disabled = false end
end

function Farm:more()
	local speed = self.speed * 2
	if speed > maxSpeed then speed = maxSpeed end

	self:update(nil, speed)
end

function Farm:less()
	local speed = math.ceil(self.speed / 2)
	if speed < minSpeed then speed = minSpeed end

	self:update(nil, speed)
end

function Farm:buttonEvent()
	local active = not self.active
	self:update(nil, nil, active)
end








-- --------------------------------
--  Local functions
-- --------------------------------

local function createStyles()
	local bgStyle = uilib.Style:new(colors.white, colors.black)
	local titleStyle = uilib.Style:new(colors.lightBlue, colors.black)
	local labelStyle = uilib.Style:new(colors.white, colors.black)
	local btnStyle = uilib.Style:new(colors.white, colors.gray, colors.white, colors.lime, colors.gray, colors.lightGray, colors.lightGray, colors.white)

	local okStyle = uilib.Style:new(colors.lime, colors.gray)
	local warnStyle = uilib.Style:new(colors.yellow, colors.gray)
	local critStyle = uilib.Style:new(colors.red, colors.gray)

	styles.bg = bgStyle
	styles.title = titleStyle
	styles.label = labelStyle
	styles.btn = btnStyle

	styles.ok = okStyle
	styles.warn = warnStyle
	styles.crit = critStyle
end

local function initFarms()
	createStyles()

	for i = 1, #motorIDs do
		local motor = peripheral.wrap(motorIDs[i])
		local storage = peripheral.wrap(storageIDs[i])

		local x = (i - 1) * 17 + 1
		local y = 1

		if x > screenSize.x then
			x = 1
			y = y + 12
		end

		if y > screenSize.y then
			break
		end

		local farm = Farm:new(x, y, farmNames[i], motor, storage)
		table.insert(farms, farm)
	end
end

local function drawUI()
	for _, f in ipairs(farms) do
		f:draw()
	end
end







-- --------------------------------
--  Main Program
-- --------------------------------

local mon = peripheral.find("moitor")
term.clear()

if mon ~= nil then
	mon.setTextScale(0.5)
	term.redirect(mon)
	term.clear()
end

screenSize = term.getSize()

initFarms()
drawUI()

while true do
	local eventBundle = table.pack(os.pullEvent())
	local storage = nil

	if eventBundle[1] == "timer" and eventBundle[2] == intervalTimer then
		storage = #f.storagePeripheral.list()
		onTimerEvent()
	end

	for _, f in ipairs(farms) do
		if storage ~= nil and f.storage ~= storage then f:update(storage) end

		f:event(eventBundle)
	end

	drawUI()
	sleep(0.1)
end