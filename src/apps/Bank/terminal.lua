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

os.loadAPI("/lib/ThirdParty/sha")
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

local failStrings = {
    ACC_NOT_EXIST = "EC01: Account does not exist",
    INV_PARAMS = "EC02: Something went wrong",
    TO_NOT_EXISTS = "EC03: Recipiant does not exist",
    NO_AUTH = "EC04: Something went wrong",
    WRONG_PIN = "EC05: Wrong Pin",
    INV_CARD = "EC06: Invalid card was used",
    AMNT_LEQ_ZERO = "EC07: Amount cannot be below 1$",
    BAL_TOO_LOW = "EC08: Balance too low",
    REPEAT_NOT_MATCH = "EC09: New pin and repeated new pin must match",
    PIN_SHORT = "EC10: Pin needs to have 6 digits",
    NO_RES = "EC11: No response from server",
    DEFAULT = "EC12: Something went wrong"
}

-- --------------------------------
--  Internal Properties
-- --------------------------------

local sModem = nil
local serverAddress = nil
local run = true

local resStatus = ""

local activeScreen = "titleScreen"
local prevScreen = "titleScreen"
local ui = {}
local styles = {}
local redraw = false

local uuid = nil
local cardUUID = nil
local cardLoaded = false

local userData = {}
local balance = 0
local history = {}







-- --------------------------------
--  Local functions (Cannot be defined later)
-- --------------------------------

local function updateResponseUI(status, errorCode)
    local message = ""
    resStatus = status

    if status == "OK" then
        message = "Success!"
        ui["resScreen"]:get("resLabel").style = styles.success
    else
        if errorCode == nil then errorCode = "" end
        message = failStrings[errorCode]

        if message == nil or message == "" then
            message = failStrings["DEFAULT"]
        end

        ui["resScreen"]:get("resLabel").style = styles.error
    end

    ui["resScreen"]:get("resLabel").text = message
end








-- --------------------------------
--  Click events
-- --------------------------------

local function onRedirectBtnClick(targetID)
    if targetID ~= activeScreen then
        ui[activeScreen]:hide()
        ui[targetID]:show()

        prevScreen = activeScreen
        activeScreen = targetID

        redraw = true
    end
end

local function onPinChangeBtnClick()
    local cPin = ui["changePin"]:get("currentPinTextBox").text
    local nPin = ui["changePin"]:get("newPinTextBox").text
    local rnPin = ui["changePin"]:get("repeatNewPinTextBox").text

    -- Check if Pin is long enough
    if #nPin < 6 then
        -- Redirect to resScreen
        updateResponseUI("FAIL", "PIN_SHORT")
        onRedirectBtnClick("resScreen")
        return
    end

    -- Check it new pin and repeated new pin are equal
    if nPin ~= rnPin then
        -- Redirect to resScreen
        updateResponseUI("FAIL", "REPEAT_NOT_MATCH")
        onRedirectBtnClick("resScreen")
        return
    end

    local res = comlib.sendRequest(sModem, serverAddress, "CHGPIN", { uuid = uuid, cardUUID = cardUUID, hash = sha.sha256(cPin), newHash = sha.sha256(nPin) })
    if res == -1 then res = {status = "FAIL", contents = { reason = "NO_RES" }} end

    updateResponseUI(res.status, res.contents.reason)
    onRedirectBtnClick("resScreen")
end

local function onResponseOkClick()
    local targetID = ""

    if resStatus == "FAIL" then
        targetID = prevScreen
    else
        ui[prevScreen]:reset()
        targetID = "homeScreen"
    end

    onRedirectBtnClick(targetID)
end

local function onExitBtnClick()
    run = false
end







-- --------------------------------
--  Classes
-- --------------------------------

-- Predefinitions

local Transaction = {}
Transaction.__index = Transaction

-- Class to hold transaction data

function Transaction:new(x, y, from, to, amount, time)
    -- Todo create object
end








-- --------------------------------
--  Local functions
-- --------------------------------

local function createStyles()
    local bgStyle = uilib.Style:new(colors.black, colors.white)
    local bgShadedStyle = uilib.Style:new(colors.lightGray, colors.white)
    local btnStyle = uilib.Style:new(colors.white, colors.red, colors.white, colors.gray, colors.lightGray, colors.gray, colors.lightGray, colors.white)
    local tbStyle = uilib.Style:new(colors.black, colors.lightGray, colors.white, colors.red, colors.gray, colors.lightGray)
    local successStyle = uilib.Style:new(colors.green, colors.white)
    local errorStyle = uilib.Style:new(colors.red, colors.white)

    styles.bg = bgStyle
    styles.shadedBG = bgShadedStyle
    styles.btn = btnStyle
    styles.tb = tbStyle
    styles.success = successStyle
    styles.error = errorStyle
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




    -- Response Screen
    local resScreen = uilib.Group:new(1, 1, nil, "bg", {})
    resScreen:add(
        uilib.Panel:new(" ", 1, 1, screenSize.w, screenSize.h, resScreen, styles.shadedBG),
        "bg")

    resScreen:add(
    -- Logo needs to be 49x7 in size
        uilib.Image:new("/assets/logo.nfp", 2, 2, resScreen),
        "logoImage")

    resScreen:add(
        uilib.Label:new("", 2, 11, resScreen, styles.error, false),
        "resLabel")

    resScreen:add(
        uilib.Button:new("Confirm", 41, 15, 9, 3, resScreen, onResponseOkClick, {}, false, styles.btn, "\x7f", 1),
        "confirmBtn")

    ui["resScreen"] = resScreen




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
        uilib.Button:new("Change Pin", 31, 10, 18, 3, homeScreen, onRedirectBtnClick, {"changePin"}, false, styles.btn, "\x7f", 1),
        "changePinBtn")
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

    accountInfo:add(
        uilib.Label:new("Balance: ", 12, 2, accountInfo, styles.bg),
        "balTitleLabel")
    accountInfo:add(
        uilib.Label:new("", 12, 3, accountInfo, styles.bg, true),
        "balLabel")

    accountInfo:add(
        uilib.Label:new("Name: ", 2, 7, accountInfo, styles.bg),
        "nameTitleLabel")
    accountInfo:add(
        uilib.Label:new("", 8, 7, accountInfo, styles.bg),
        "nameLabel")

    accountInfo:add(
        uilib.Label:new("Account Number: ", 26, 7, accountInfo, styles.bg),
        "accountNumTitleLabel")
    accountInfo:add(
        uilib.Label:new("", 42, 7, accountInfo, styles.bg),
        "accountNumLabel")

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




    -- Change Pin
    local changePin = uilib.Group:new(1, 1, nil, "bg", {})
    changePin:add(
        uilib.Panel:new(" ", 1, 1, screenSize.w, screenSize.h, changePin, styles.bg),
        "bg")

    changePin:add(
        uilib.Button:new("Back", 2, 2, 6, 3, changePin, onRedirectBtnClick, {"homeScreen"}, false, styles.btn, "\x7f", 1),
        "backBtn")

    changePin:add(
        uilib.Label:new("Change Pin", 12, 3, changePin, styles.bg, true),
        "changePinTitleLabel")

    changePin:add(
        uilib.Label:new("Current Pin:", 2, 9, changePin, styles.bg, false),
        "currentPinTitleLabel")
    changePin:add(
        uilib.TextBox:new(18, 8, 9, 3, 1, changePin, 6, true, true, nil, styles.tb),
        "currentPinTextBox")

    changePin:add(
        uilib.Label:new("New Pin:", 2, 13, changePin, styles.bg, false),
        "newPinTitleLabel")
    changePin:add(
        uilib.TextBox:new(18, 12, 9, 3, 1, changePin, 6, true, true, nil, styles.tb),
        "newPinTextBox")

    changePin:add(
        uilib.Label:new("Repeat new Pin:", 2, 17, chanhePin, styles.bg, false),
        "repeatNewPinTitleLabel")
    changePin:add(
        uilib.TextBox:new(18, 16, 9, 3, 1, changePin, 6, true, true, nil, styles.tb),
        "repeatNewPinTextBox")

    changePin:add(
        uilib.Button:new("Confirm", 41, 15, 9, 3, changePin, onPinChangeBtnClick, {}, false, styles.btn, "\x7f", 1),
        "confirmBtn")

    ui["changePin"] = changePin
end

local function updateAccountUI()
    ui["accountInfo"]:get("nameLabel").text = userData.name
    ui["accountInfo"]:get("accountNumLabel").text = userData.accountNum
    ui["accountInfo"]:get("balLabel").text = tostring(balance) .. "$"
end

local function drawUI()
    ui[activeScreen]:draw()
end

local function events(e)
    ui[activeScreen]:event(e)
end

local function updateData()
    userData = comlib.sendRequest(sModem, serverAddress, "USER", { uuid = uuid }).contents
    balance = comlib.sendRequest(sModem, serverAddress, "BAL", { uuid = uuid }).contents.balance
    history = comlib.sendRequest(sModem, serverAddress, "HIST", { uuid = uuid }).contents.history

    updateAccountUI()
end

local function checkDisk()
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

        updateData()

        cardLoaded = true
        onRedirectBtnClick("homeScreen")
        drawUI()
    end
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
    redraw = false
    checkDisk()

    -- Handle events
    local e = table.pack(os.pullEventRaw())
    events(e)

    -- Draw UI
    if redraw then drawUI() end
end

-- Cleanup after exit
term.clear()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.setCursorPos(1, 1)

userData = nil
balance = nil
history = nil
uuid = nil
cardUUID = nil