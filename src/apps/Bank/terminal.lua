-- ================================
--  terminal.lua
-- --------------------------------
--  Terminal to access bank
--  accounts and manage funds
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
local serverDomain = "bank.test"
local cardBrandName = "Omnicard"

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Client"
local version = "v2.0"
local screenSize = { w = 51, h = 19 }

-- --------------------------------
--  Internal Properties
-- --------------------------------

local sModem = nil
local serverAddress = nil
local run = true

local activeScreen = "titleScreen"
local ui = {}
local styles = {}

local uuid = nil
local cardUUID = nil
local cardLoaded = false







-- --------------------------------
--  Click events
-- --------------------------------

local function onRedirectBtnClick(targetID)
    ui[activeScreen]:hide()
    ui[targetID]:show()

    activeScreen = targetID
end

local function onExitBtnClick()
    run = false
end







-- --------------------------------
--  Local functions
-- --------------------------------

local function createStyles()
    local bgStyle = uilib.Style:new(colors.black, colors.white)
    local btnStyle = uilib.Style:new(colors.white, colors.red, colors.white, colors.gray, colors.lightGray, colors.gray, colors.lightGray, colors.white)

    styles.bg = bgStyle
    styles.btn = btnStyle
end

local function createUI()
    createStyles()

    -- Title screen
    local titleScreen = uilib.Group:new(1, 1, nil, "bg", {})
    titleScreen:add(
        uilib.Panel:new(" ", 1, 1, screenSize.w, screenSize.h, titleScreen, styles.bg),
        "bg")

    titleScreen:add(
        uilib.Label:new("[TMP] Please insert your " .. cardBrandName, 2, 2, titleScreen, styles.bg)
    )

    ui["titleScreen"] = titleScreen




    -- Home Screen
    local homeScreen = uilib.Group:new(1, 1, nil, "bg", {})
    homeScreen:add(
        uilib.Panel:new(" ", 1, 1, screenSize.w, screenSize.h, homeScreen, styles.bg),
        "bg")

    homeScreen:add(
        -- Logo needs to be 49x7 in size
        uilib.Image:new("/assets/logo.nfp", 2, 2, homeScreen),
        "logoImage")

    homeScreen:add(
        uilib.Button:new("Account Info", 4, 10, 18, 3, homeScreen, onRedirectBtnClick, {"accountInfo"}, false, styles.btn, "\x7f", 1),
        "accountInfoBtn")
    homeScreen:add(
        uilib.Button:new("Send Funds", 4, 15, 18, 3, homeScreen, onRedirectBtnClick, {"sendFunds"}, false, styles.btn, "\x7f", 1),
        "sendFundsBtn")
    homeScreen:add(
        uilib.Button:new("Change PIN", 31, 10, 18, 3, homeScreen, onRedirectBtnClick, {"changePIN"}, false, styles.btn, "\x7f", 1),
        "changePINBtn")
    homeScreen:add(
        uilib.Button:new("Exit", 31, 15, 18, 3, homeScreen, onExitBtnClick, {}, false, styles.btn, "\x7f", 1),
        "exitBtn")

    ui["homeScreen"] = homeScreen




    -- Account Info
    local accountInfo = uilib.Group:new(1, 1, nil, "bg", {})
    accountInfo:add(
        uilib.Panel:new(" ", 1, 1, screenSize.w, screenSize.h, accountInfo, styles.bg),
        "bg")

    accountInfo:add(
        uilib.Button:new("Back", 2, 2, 6, 3, accountInfo, onRedirectBtnClick, {"homeScreen"}, false, styles.btn, "\x7f", 1),
        "backBtn")

    ui["accountInfo"] = accountInfo




    -- Send Funds
    local sendFunds = uilib.Group:new(1, 1, nil, "bg", {})
    sendFunds:add(
        uilib.Panel:new(" ", 1, 1, screenSize.w, screenSize.h, sendFunds, styles.bg),
        "bg")

    sendFunds:add(
        uilib.Button:new("Back", 2, 2, 6, 3, sendFunds, onRedirectBtnClick, {"homeScreen"}, false, styles.btn, "\x7f", 1),
        "backBtn")

    ui["sendFunds"] = sendFunds




    -- Change PIN
    local changePIN = uilib.Group:new(1, 1, nil, "bg", {})
    changePIN:add(
        uilib.Panel:new(" ", 1, 1, screenSize.w, screenSize.h, changePIN, styles.bg),
        "bg")

        changePIN:add(
        uilib.Button:new("Back", 2, 2, 6, 3, changePIN, onRedirectBtnClick, {"homeScreen"}, false, styles.btn, "\x7f", 1),
        "backBtn")

    ui["changePIN"] = changePIN
end

local function drawUI()
    ui[activeScreen]:draw()
end

local function onClick(x, y)
    ui[activeScreen]:clickEvent(x, y)
end








-- --------------------------------
--  Main Program
-- --------------------------------

sModem = comlib.open(modemSide)                                 -- Create Secure Modem
if dnslib.init(sModem) == -1 then                               -- Initialize DNSLib
    print("Could not connect to DNS Server")
    return -1
end

serverAddress = dnslib.lookup(serverDomain)                     -- Lookup Address of Server

createUI()
drawUI()

--Main Loop
while run do
    -- Check if disk is present, wait for disk to be inserted
    while not fs.exists("disk") do
        if activeScreen ~= "titleScreen" then
            activeScreen = "titleScreen"
            cardLoaded = false
            drawUI()
        end

        sleep(0.1)
    end

    -- Load from card if not loaded before
    if not cardLoaded then
        local card = fs.open("/disk/.auth", "r")
        uuid = card.readLine()
        cardUUID = card.readLine()
        card.close()

        cardLoaded = true
        onRedirectBtnClick("homeScreen")
        drawUI()
    end

    -- Check for events
    local eventData = table.pack(os.pullEventRaw())
    local e = eventData[1]

    -- Handle events
    if e == "mouse_click" then
        local x, y = eventData[3], eventData[4]
        onClick(x, y)
    end

    -- Draw UI
    drawUI()
end

-- Cleanup after exit
term.clear()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.setCursorPos(1, 1)

uuid = nil
cardUUID = nil