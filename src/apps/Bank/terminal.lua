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
local authThreshold = 100

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Client"
local version = "v2.0"
local screenSize = { w = 51, h = 19 }

local successString = "Operation successful!"

local failStrings = {
	ACC_NOT_EXIST = "EC01: Account does not exist",
	INV_PARAMS = "EC02: Something went wrong",
	TO_NOT_EXISTS = "EC03: Recipiant not existing",
	NO_AUTH = "EC04: Something went wrong",
	WRONG_PIN = "EC05: Wrong Pin",
	INV_CARD = "EC06: Invalid card was used",
	AMNT_LEQ_ZERO = "EC07: Amount cannot be 0$",
	BAL_TOO_LOW = "EC08: Balance too low",
	REPEAT_NOT_MATCH = "EC09: New pins dont match",
	PIN_SHORT = "EC10: Pin requires 6 digits",
	NO_RES = "EC11: Server not responding",
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
local refetchUserData = false

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
		message = successString
		ui["resScreen"]:get("content"):get("resLabel").style = styles.success
	else
		if errorCode == nil then errorCode = "" end
		message = failStrings[errorCode]

		if message == nil or message == "" then
			message = failStrings["DEFAULT"]
		end

		ui["resScreen"]:get("content"):get("resLabel").style = styles.error
	end

	ui["resScreen"]:get("content"):get("resLabel").text = message
end

local function updateConfirmSendFundsUI()
	local description = ui["sendFunds"]:get("descriptionTextBox").text
	local recipiant = ui["sendFunds"]:get("recipiantTextBox").text
	local amount = ui["sendFunds"]:get("amountTextBox").text
	local amountDecimals = ui["sendFunds"]:get("amountDecimalsTextBox").text

	if amount == "" then amount = "0" end
	if amountDecimals == "" then amountDecimals = "0" end

	amountDecimals = string.format("%.02f", tonumber(amountDecimals) / 100)
	amountDecimals = string.sub(amountDecimals, 3)

	local descH, descW, descPad = ui["sendFunds"]:get("descriptionTextBox").h, ui["sendFunds"]:get("descriptionTextBox").w, ui["sendFunds"]:get("descriptionTextBox").padding

	local descLines = {}
	for i = 1, descH - descPad * 2 do
        local line = string.sub(description, (i - 1) * (descW - descPad * 2) + 1, i * (descW - descPad * 2))
        if line == "" then
			descLines[i] = ""
		else
			descLines[i] = line
		end
    end

	local recipiantName = ""
	local res = comlib.sendRequest(sModem, serverAddress, "NAME", { accountNum = recipiant })

	if res == -1 then
		recipiantName = "N/A"
	else
		recipiantName = res.contents.name
	end

	ui["confirmSendFunds"]:get("descriptionLine1Label").text = descLines[1]
	ui["confirmSendFunds"]:get("descriptionLine2Label").text = descLines[2]
	ui["confirmSendFunds"]:get("descriptionLine3Label").text = descLines[3]

	ui["confirmSendFunds"]:get("recipiantLabel").text = recipiant
	ui["confirmSendFunds"]:get("recipiantNameLabel").text = "(" .. recipiantName .. ")"
	ui["confirmSendFunds"]:get("amountLabel").text = amount
	ui["confirmSendFunds"]:get("amountDecimalsLabel").text = amountDecimals
end








-- --------------------------------
--  Click events
-- --------------------------------

local function onRedirectBtnClick(targetID)
	if targetID ~= activeScreen then
		ui[activeScreen]:hide()
		ui[targetID]:show()

		if activeScreen ~= "confirmSendFunds" and activeScreen ~= "authScreen" then
			prevScreen = activeScreen
		end

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

local function onSendFundsConfirmClicked()
	updateConfirmSendFundsUI()
	onRedirectBtnClick("confirmSendFunds")
end

local function onConfirmSendFundsConfirmClicked()
	local amount = ui["sendFunds"]:get("amountTextBox").text
	local amountDecimals = ui["sendFunds"]:get("amountDecimalsTextBox").text

	if amount == "" then amount = "0" end
	if amountDecimals == "" then amountDecimals = "0" end

	local totalAmount = tonumber(amount) + (tonumber(amountDecimals) / 100)
	amount = string.format("%.02f", totalAmount)

	if tonumber(amount) >= authThreshold then
		onRedirectBtnClick("authScreen")
		return
	end

	local description = ui["sendFunds"]:get("descriptionTextBox").text
	local recipiant = ui["sendFunds"]:get("recipiantTextBox").text

	-- TODO: Add timestamp to transactions

	local bundle = { uuid = uuid, cardUUID = cardUUID, desc = description, to = recipiant, amount = amount }
	local res = comlib.sendRequest(sModem, serverAddress, "PAY", bundle)
	if res == -1 then res = {status = "FAIL", contents = { reason = "NO_RES" }} end

	updateResponseUI(res.status, res.contents.reason)
	onRedirectBtnClick("resScreen")

	refetchUserData = true
end

local function onAuthConfirmClicked()
	local pin = ui["authScreen"]:get("content"):get("pinTextBox").text
	local hash = sha.sha256(pin)

	ui["authScreen"]:reset()

	if prevScreen == "sendFunds" then
		-- Send PAY packet from here intead from the other handler
		local amount = ui["sendFunds"]:get("amountTextBox").text
		local description = ui["sendFunds"]:get("descriptionTextBox").text
		local recipiant = ui["sendFunds"]:get("recipiantTextBox").text

		local bundle = { uuid = uuid, cardUUID = cardUUID, desc = description, to = recipiant, amount = amount, hash = hash }
		local res = comlib.sendRequest(sModem, serverAddress, "PAY", bundle)
		if res == -1 then res = {status = "FAIL", contents = { reason = "NO_RES" }} end

		updateResponseUI(res.status, res.contents.reason)
		onRedirectBtnClick("resScreen")

		refetchUserData = true
		return
	elseif prevScreen == "titleScreen" then
		-- TODO
		-- Send Auth request to server
		-- Redirect to homeScreen
	end
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
	local inputStyle = uilib.Style:new(colors.blue, colors.white)

	styles.bg = bgStyle
	styles.shadedBG = bgShadedStyle
	styles.btn = btnStyle
	styles.tb = tbStyle
	styles.success = successStyle
	styles.error = errorStyle
	styles.input = inputStyle
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




	-- Auth screen
	local authScreen = uilib.Group:new(1, 1, nil, "bg", {})
	authScreen:add(
		uilib.Panel:new("\x7f", 1, 1, screenSize.w, screenSize.h, authScreen, styles.shadedBG),
		"bg")

	local authScreenContent = uilib.Group:new(3, 3, nil, "bg", {})

	authScreenContent:add(
		uilib.Panel:new(" ", 1, 1, screenSize.w - 4, screenSize.h - 4, onAuthConfirmClicked, styles.bg),
		"bg")

	authScreenContent:add(
		-- Logo needs to be 49x7 in size
		uilib.Image:new("/assets/logo.nfp", 0, 2, authScreenContent),
		"logoImage")

	authScreenContent:add(
		uilib.Label:new("Pin:", 5, 12, authScreenContent, styles.bg, false),
		"pinTitleLabel")

	authScreenContent:add(
		uilib.TextBox:new(10, 11, 9, 3, 1, authScreenContent, 6, true, true, nil, styles.tb),
		"pinTextBox")

	authScreenContent:add(
		uilib.Button:new("Confirm", 35, 11, 9, 3, authScreenContent, onAuthConfirmClicked, {}, false, styles.btn, "\x7f", 1),
		"confirmBtn")

	authScreen:add(authScreenContent, "content")
	ui["authScreen"] = authScreen




	-- Response Screen
	local resScreen = uilib.Group:new(1, 1, nil, "bg", {})
	resScreen:add(
		uilib.Panel:new("\x7f", 1, 1, screenSize.w, screenSize.h, resScreen, styles.shadedBG),
		"bg")

	local resScreenContent = uilib.Group:new(3, 3, nil, "bg", {})

	resScreenContent:add(
		uilib.Panel:new(" ", 1, 1, screenSize.w - 4, screenSize.h - 4, onAuthConfirmClicked, styles.bg),
		"bg")

	resScreenContent:add(
	-- Logo needs to be 49x7 in size
		uilib.Image:new("/assets/logo.nfp", 0, 2, resScreen),
		"logoImage")

	resScreenContent:add(
		uilib.Label:new("", 5, 12, resScreen, styles.error, false),
		"resLabel")

	resScreenContent:add(
		uilib.Button:new("Continue", 34, 11, 10, 3, resScreen, onResponseOkClick, {}, false, styles.btn, "\x7f", 1),
		"continueBtn")

	resScreen:add(resScreenContent, "content")
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
		uilib.Button:new("Transactions", 4, 10, 18, 3, homeScreen, onRedirectBtnClick, {"transactions"}, false, styles.btn, "\x7f", 1),
		"transactionsBtn")
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




	-- Transactions
	local transactions = uilib.Group:new(1, 1, nil, "bg", {})
	transactions:add(
		uilib.Panel:new(" ", 1, 1, screenSize.w, screenSize.h, transactions, styles.bg),
		"bg")

	transactions:add(
		uilib.Button:new("Back", 2, 2, 6, 3, transactions, onRedirectBtnClick, {"homeScreen"}, false, styles.btn, "\x7f", 1),
		"backBtn")

	transactions:add(
		uilib.Label:new("Balance: ", 12, 2, transactions, styles.bg),
		"balTitleLabel")
	transactions:add(
		uilib.Label:new("", 12, 3, transactions, styles.bg, true),
		"balLabel")

	transactions:add(
		uilib.Label:new("Name: ", 2, 7, transactions, styles.bg),
		"nameTitleLabel")
	transactions:add(
		uilib.Label:new("", 8, 7, transactions, styles.bg),
		"nameLabel")

	transactions:add(
		uilib.Label:new("Account Number: ", 26, 7, transactions, styles.bg),
		"accountNumTitleLabel")
	transactions:add(
		uilib.Label:new("", 42, 7, transactions, styles.bg),
		"accountNumLabel")

	ui["transactions"] = transactions




	-- Send Funds
	local sendFunds = uilib.Group:new(1, 1, nil, "bg", {})
	sendFunds:add(
		uilib.Panel:new(" ", 1, 1, screenSize.w, screenSize.h, sendFunds, styles.bg),
		"bg")

	sendFunds:add(
		uilib.Button:new("Back", 2, 2, 6, 3, sendFunds, onRedirectBtnClick, {"homeScreen"}, false, styles.btn, "\x7f", 1),
		"backBtn")

	sendFunds:add(
		uilib.Label:new("Balance: ", 12, 2, sendFunds, styles.bg),
		"balTitleLabel")
	sendFunds:add(
		uilib.Label:new("", 12, 3, sendFunds, styles.bg, true),
		"balLabel")

	sendFunds:add(
		uilib.Label:new("Name: ", 2, 7, sendFunds, styles.bg),
		"nameTitleLabel")
	sendFunds:add(
		uilib.Label:new("", 8, 7, sendFunds, styles.bg),
		"nameLabel")

	sendFunds:add(
		uilib.Label:new("Account Number: ", 26, 7, sendFunds, styles.bg),
		"accountNumTitleLabel")
	sendFunds:add(
		uilib.Label:new("", 42, 7, sendFunds, styles.bg),
		"accountNumLabel")

	sendFunds:add(
		uilib.Label:new("Description:", 2, 11, sendFunds, styles.bg, false),
		"descriptionTitleLable")
	sendFunds:add(
		uilib.TextBox:new(15, 11, 36, 3, 0, sendFunds, 100, false, false, nil, styles.tb),
		"descriptionTextBox")

	sendFunds:add(
		uilib.Label:new("Recipiant:", 2, 15, sendFunds, styles.bg, false),
		"recipiantTitleLabel")
	sendFunds:add(
		uilib.TextBox:new(15, 15, 5, 1, 0, sendFunds, 4, true, false, nil, styles.tb),
		"recipiantTextBox")

	sendFunds:add(
		uilib.Label:new("Amount:", 2, 17, sendFunds, styles.bg, false),
		"amountTitleLabel")
	sendFunds:add(
		uilib.TextBox:new(15, 17, 7, 1, 0, sendFunds, 6, true, false, nil, styles.tb),
		"amountTextBox")
	sendFunds:add(
		uilib.Label:new(".", 22, 17, sendFunds, styles.bg, false),
		"amountDecimalPointLabel")
	sendFunds:add(
		uilib.TextBox:new(23, 17, 3, 1, 0, sendFunds, 2, true, false, nil, styles.tb),
		"amountDecimalsTextBox")
	sendFunds:add(
		uilib.Label:new("$", 27, 17, sendFunds, styles.bg, false),
		"amountCurrencyLabel")

	sendFunds:add(
		uilib.Button:new("Confirm", 41, 15, 9, 3, sendFunds, onSendFundsConfirmClicked, {}, false, styles.btn, "\x7f", 1),
		"confirmBtn")

	ui["sendFunds"] = sendFunds




	-- Confirm send funds
	local confirmSendFunds = uilib.Group:new(1, 1, nil, "bg", {})
	confirmSendFunds:add(
		uilib.Panel:new(" ", 1, 1, screenSize.w, screenSize.h, confirmSendFunds, styles.bg),
		"bg")

	confirmSendFunds:add(
		uilib.Button:new("Back", 2, 2, 6, 3, confirmSendFunds, onRedirectBtnClick, {"sendFunds"}, dalse, styles.btn, "\x7f", 1),
		"backBtn")

	confirmSendFunds:add(
		uilib.Label:new("Balance: ", 12, 2, confirmSendFunds, styles.bg),
		"balTitleLabel")
	confirmSendFunds:add(
		uilib.Label:new("", 12, 3, confirmSendFunds, styles.bg, true),
		"balLabel")

	confirmSendFunds:add(
		uilib.Label:new("Name: ", 2, 7, confirmSendFunds, styles.bg),
		"nameTitleLabel")
	confirmSendFunds:add(
		uilib.Label:new("", 8, 7, confirmSendFunds, styles.bg),
		"nameLabel")

	confirmSendFunds:add(
		uilib.Label:new("Account Number: ", 26, 7, confirmSendFunds, styles.bg),
		"accountNumTitleLabel")
	confirmSendFunds:add(
		uilib.Label:new("", 42, 7, confirmSendFunds, styles.bg),
		"accountNumLabel")

	confirmSendFunds:add(
		uilib.Label:new("Description:", 2, 11, confirmSendFunds, styles.bg, false),
		"descriptionTitleLable")
	confirmSendFunds:add(
		uilib.Label:new("", 15, 11, confirmSendFunds, styles.input, false),
		"descriptionLine1Label")
	confirmSendFunds:add(
		uilib.Label:new("", 15, 12, confirmSendFunds, styles.input, false),
		"descriptionLine2Label")
	confirmSendFunds:add(
		uilib.Label:new("", 15, 13, confirmSendFunds, styles.input, false),
		"descriptionLine3Label")

	confirmSendFunds:add(
		uilib.Label:new("Recipiant:", 2, 15, confirmSendFunds, styles.bg, false),
		"recipiantTitleLabel")
	confirmSendFunds:add(
		uilib.Label:new("", 15, 15, confirmSendFunds, styles.input, false),
		"recipiantLabel")
	confirmSendFunds:add(
		uilib.Label:new("", 20, 15, confirmSendFunds, styles.input, false),
		"recipiantNameLabel")

	confirmSendFunds:add(
		uilib.Label:new("Amount:", 2, 17, confirmSendFunds, styles.bg, false),
		"amountTitleLabel")
	confirmSendFunds:add(
		uilib.Label:new("", 15, 17, confirmSendFunds, styles.input, false),
		"amountLabel")
	confirmSendFunds:add(
		uilib.Label:new(".", 22, 17, confirmSendFunds, styles.bg, false),
		"amountDecimalPointLabel")
	confirmSendFunds:add(
		uilib.Label:new("", 23, 17, confirmSendFunds, styles.input, false),
		"amountDecimalsLabel")
	confirmSendFunds:add(
		uilib.Label:new("$", 27, 17, confirmSendFunds, styles.bg, false),
		"amountCurrencyLabel")

	confirmSendFunds:add(
		uilib.Button:new("Confirm", 41, 15, 9, 3, confirmSendFunds, onConfirmSendFundsConfirmClicked, {}, false, styles.btn, "\x7f", 1),
		"confirmBtn")

	ui["confirmSendFunds"] = confirmSendFunds




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
	ui["transactions"]:get("nameLabel").text = userData.name
	ui["transactions"]:get("accountNumLabel").text = userData.accountNum
	ui["transactions"]:get("balLabel").text = string.format("%.02f", balance) .. "$"

	ui["sendFunds"]:get("nameLabel").text = userData.name
	ui["sendFunds"]:get("accountNumLabel").text = userData.accountNum
	ui["sendFunds"]:get("balLabel").text = string.format("%.02f", balance) .. "$"

	ui["confirmSendFunds"]:get("nameLabel").text = userData.name
	ui["confirmSendFunds"]:get("accountNumLabel").text = userData.accountNum
	ui["confirmSendFunds"]:get("balLabel").text = string.format("%.02f", balance) .. "$"
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

	if refetchUserData then
		updateData()
		refetchUserData = false
	end

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

for _, v in pairs(ui) do
	v:reset()
end