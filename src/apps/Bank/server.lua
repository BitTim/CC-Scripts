-- ================================
--  server.lua
-- --------------------------------
--  Server for use with the
--  Bank project
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

os.loadAPI("lib/ThirdParty/aeslua")
local comlib = require("/lib/comlib")
local loglib = require("/lib/loglib")

-- --------------------------------
--  Configurable Properties
-- --------------------------------

local modemSide = "top"
local totalAssets = 200             -- Total amount of money in circulation
local authThreshold = 100           -- If amount of payment is above this threshold, auth is required

local taxPercentageNormal = 5
local taxPercentageDouble = 15
local taxPercentageMax = 40

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Bank Server"
local version = "v2.0"
local dbFilePath = ".db"

-- --------------------------------
--  Internal Properties
-- --------------------------------

local sModem = nil
local dbFile = nil
local keyFile = nil
local db = nil
local key = nil








-- --------------------------------
--  Local functions
-- --------------------------------

local function updateDB()
    if fs.exists(dbFilePath .. ".bak") then fs.delete(dbFilePath .. ".bak") end     -- Check if Backup exists, if yes delete
    fs.move(dbFilePath, dbFilePath .. ".bak")                                       -- Create Backup
    dbFile = fs.open(dbFilePath, "w")
    dbFile.write(textutils.serialize(db))                                           -- Write current DB to file
    dbFile.close()
    loglib.log("updateDB", "Updated DB file")
end

local function getUUIDfromAccountNum(accountNum)
    local uuid = nil

    for k, v in pairs(db) do
        if v.accountNum == accountNum then
            uuid = k
            break
        end
    end

    return uuid
end

local function getNumAccounts()
    local numAccounts = 0

    for _, _ in pairs(db) do
        numAccounts = numAccounts + 1
    end

    return numAccounts
end

local function getRandomAccountUUID()
    local numAccounts = getNumAccounts()
    local iterations = math.random(numAccounts)
    local retUUID = ""

    local i = 1
    for uuid, _ in pairs(db) do
        retUUID = uuid
        i = i + 1
        if i > iterations then break end
    end

    return retUUID
end

local function getBalance(uuid, asNumber)
    asNumber = asNumber or true

    local bal = aeslua.decrypt(key, db[uuid].balance)
    if asNumber then bal = tonumber(bal) end
    return bal
end

local function setBalance(uuid, balance)
    db[uuid].balance = aeslua.encrypt(key, tostring(balance))
    updateDB()
end

local function addTransactionEntry(fromUUID, toUUID, amount, desc, time, date)
    table.insert(db[fromUUID].transactions, { from = fromUUID, to = toUUID, amount = amount, desc = desc, time = time, date = date })
    table.insert(db[toUUID].transactions, { from = fromUUID, to = toUUID, amount = amount, desc = desc, time = time, date = date })
    updateDB()
end

local function getTaxPercentage(uuid)
    local bal = getBalance(uuid)
    local normalPerAcc = totalAssets / getNumAccounts()

    if bal <= normalPerAcc then
        return (taxPercentageNormal / normalPerAcc) * bal
    elseif bal > normalPerAcc and bal <= normalPerAcc * 2 then
        local dy = taxPercentageDouble - taxPercentageNormal
        return (dy / normalPerAcc) * (bal - normalPerAcc) + taxPercentageNormal
    else
        local dx = totalAssets - (2 * normalPerAcc)
        local dy = taxPercentageMax - taxPercentageDouble
        return (dy / dx) * (x - (2 * normalPerAcc)) + taxPercentageDouble
    end
end

local function getAmountfromPercentage(uuid, percentage)
    local bal = getBalance(uuid)
    return math.floor(bal * (percentage / 100) * 100) / 100
end








-- --------------------------------
--  Request Handlers
-- --------------------------------

-- Get user data
local function userData(s, p)
    local uuid = p.contents.uuid

    local data = {}
    data.name = db[uuid].name
    data.accountNum = db[uuid].accountNum

    comlib.sendResponse(sModem, s, "USER", "OK", data)
    loglib.log("USER", "Responded with " .. data.name .. " and " .. data.accountNum .. " to " .. s)
end

-- Get name of user based on account number
local function name(s, p)
    local accountNum = p.contents.accountNum
    local uuid = getUUIDfromAccountNum(accountNum)
    local accountName = "N/A"

    if uuid ~= nil then
        accountName = db[uuid].name
    end

    comlib.sendResponse(sModem, s, "NAME", "OK", { name = accountName })
    loglib.log("NAME", "Responded with " .. accountName .. " to " .. s)
end

-- Get balance of user
local function balance(s, p)
    local uuid = p.contents.uuid

    if db[uuid] == nil then
        loglib.log("BAL", "Fail, account not existing")
        comlib.sendResponse(sModem, s, "BAL", "FAIL", { reason = "ACC_NOT_EXIST" })
        return
    end

    local bal = getBalance(uuid, false)

    comlib.sendResponse(sModem, s, "BAL", "OK", { balance = bal })
    loglib.log("BAL", "Responded with " .. bal .. "$ to " .. s)
end

-- Get history of all transactions for user
local function history(s, p)
    local uuid = p.contents.uuid

    if db[uuid] == nil then
        loglib.log("HIST", "Fail, account not existing")
        comlib.sendResponse(sModem, s, "HIST", "FAIL", { reason = "ACC_NOT_EXIST" })
        return
    end

    local hist = db[uuid].transactions

    comlib.sendResponse(sModem, s, "HIST", "OK", { history = hist })
    loglib.log("HIST", "Responded with history of " .. db[uuid].name .. " to " .. s)
end

-- Move money from one account to another
local function payment(s, p)
    local uuid, to, amount, desc, cardUUID, hash, time, date = p.contents.uuid, p.contents.to, p.contents.amount, p.contents.desc, p.contents.cardUUID, p.contents.hash, p.contents.time, p.contents.date
    local toUUID = getUUIDfromAccountNum(to);

    amount = tonumber(amount)
    desc = desc or ""

    -- Check all fail states
    if uuid == nil or to == nil or amount == nil or cardUUID == nil then
        loglib.log("PAY", "Fail, invalid parameters")
        comlib.sendResponse(sModem, s, "PAY", "FAIL", { reason = "INV_PARAMS" })
        return
    end

    if db[uuid] == nil then
        loglib.log("PAY", "Fail, account not existing")
        comlib.sendResponse(sModem, s, "PAY", "FAIL", { reason = "ACC_NOT_EXIST" })
        return
    end

    if toUUID == nil then
        loglib.log("PAY", "Failed, recipiant does not exits")
        comlib.sendResponse(sModem, s, "PAY", "FAIL", { reason = "TO_NOT_EXISTS" })
        return
    end

    if amount >= authThreshold and hash == nil then
        loglib.log("PAY", "Failed, amount above threshold and no auth")
        comlib.sendResponse(sModem, s, "PAY", "FAIL", { reason = "NO_AUTH" })
        return
    end

    if amount >= authThreshold and hash ~= db[uuid].hash then
        loglib.log("PAY", "Failed, wrong PIN")
        comlib.sendResponse(sModem, s, "PAY", "FAIL", { reason = "WRONG_PIN" })
        return
    end

    if cardUUID == nil or cardUUID ~= db[uuid].cardUUID then
        loglib.log("PAY", "Failed, invalid card was used")
        comlib.sendResponse(sModem, s, "PAY", "FAIL", { reason = "INV_CARD" })
        return
    end

    if amount <= 0 then
        loglib.log("PAY", "Failed, amount 0 or less")
        comlib.sendResponse(sModem, s, "PAY", "FAIL", { reason = "AMNT_LEQ_ZERO" })
        return
    end

    if getBalance(uuid) < amount then
        loglib.log("PAY", "Failed, balance too low")
        comlib.sendResponse(sModem, s, "PAY", "FAIL", { reason = "BAL_TOO_LOW" })
        return
    end

    -- Transfer funds
    setBalance(uuid, getBalance(uuid) - amount)
    setBalance(toUUID, getBalance(uuid) + amount)
    loglib.log("PAY", "Transferred " .. tostring(amount) .. "$ from " .. db[uuid].name .. " to " .. db[toUUID].name .. " with description: " .. desc)

    addTransactionEntry(uuid, toUUID, amount, desc, time, date)
    loglib.log("PAY", "Added transaction entry")

    -- Send response
    comlib.sendResponse(sModem, s, "PAY", "OK", {})
end

local function tax(s, p)
    local totalTaxAmount = 0
    local changes = {}

    -- Get amounts and percentages
    loglib.log("TAX", "Iterating over all accounts to get percentages and amounts")
    for uuid, _ in pairs(db) do
        local percentage = getTaxPercentage(uuid)
        local amount = getAmountfromPercentage(uuid, percentage)
        totalTaxAmount = totalTaxAmount + amount

        changes[uuid] = {}
        changes[uuid].amount = -amount
        changes[uuid].perc = percentage
        changes[uuid].taken = amount
        changes[uuid].leftover = 0
    end

    -- Calc even share
    loglib.log("TAX", "Total tax pool: " .. totalTaxAmount .. "$")
    local amountPerAcc = math.floor(totalTaxAmount / getNumAccounts() * 100) / 100
    loglib.log("TAX", "Current share is: " .. amountPerAcc .. "$")

    -- Add the leftover amount to random account
    local leftover = math.floor((totalTaxAmount - (amountPerAcc * getNumAccounts())) * 100 + 0.5) / 100
    local luckyOne = getRandomAccountUUID()
    changes[luckyOne].leftover = changes[luckyOne].leftover + leftover
    loglib.log("TAX", "Added leftover amount of " .. leftover .. "$ to " .. db[luckyOne].accountNum)

    -- Apply changes
    loglib.log("TAX", "Iterating over every account and applying changes")
    for uuid, _ in pairs(db) do
        local amount, percentage, taken, leftover = changes[uuid].amount, changes[uuid].perc, changes[uuid].taken, changes[uuid].leftover

        amount = amount + amountPerAcc

        local bal = getBalance(uuid)
        setBalance(uuid, bal + amount)

        -- Crate entry for transaction
        local transactionObj = {}
        transactionObj.from = "TAX"
        transactionObj.to = uuid
        transactionObj.amount = math.abs(amount)
        transactionObj.desc = "[Taxes] Percentage: " .. percentage .. "%, Taken: " .. taken .. "$, Given: " .. amountPerAcc + leftover .. "$"

        if amount < 0 then
            local tmp = transactionObj.from
            transactionObj.from = transactionObj.to
            transactionObj.to = tmp
        end

        -- Insert transaction into history
        table.insert(db[uuid].transactions, transactionObj)
    end

    loglib.log("TAX", "Finished")
    comlib.sendResponse(sModem, s, "TAX", "OK", {})
end

local function changePin(s, p)
    local uuid, cardUUID, hash, newHash = p.contents.uuid, p.contents.cardUUID, p.contents.hash, p.contents.newHash

    -- Check if parameters are valid
    if uuid == nil or cardUUID == nil or hash == nil or newHash == nil then
        loglib.log("CHGPIN", "Failed, invalid parameters")
        comlib.sendResponse(sModem, s, "CHGPIN", "FAIL", { reason = "INV_PARAMS" })
    end

    -- Check if card is valid
    if db[uuid].cardUUID ~= cardUUID then
        loglib.log("CHGPIN", "Failed, invalid card was used")
        comlib.sendResponse(sModem, s, "CHGPIN", "FAIL", { reason = "INV_CARD" })
    end

    -- Check if hashes match
    if db[uuid].hash ~= hash then
        loglib.log("CHGPIN", "Failed, old pins dont match")
        comlib.sendResponse(sModem, s, "CHGPIN", "FAIL", { reason = "WRONG_PIN" })
        return
    end

    loglib.log("CHGPIN", "Changing Pin")
    db[uuid].hash = newHash
    updateDB()

    loglib.log("CHGPIN", "Finished")
    comlib.sendResponse(sModem, s, "CHGPIN", "OK", {})
end









-- --------------------------------
--  Main Program
-- --------------------------------

math.randomseed(os.time())

sModem = comlib.open(modemSide)                                 -- Create Secure Modem
loglib.init(title, version, 0.5)                                -- Initialize LogLib
loglib.log("Address", comlib.getAddress())                      -- Print Address

-- Initialize Database
loglib.log("Init", "Checking if DB exists...")
if not fs.exists(dbFilePath) then
    loglib.log("Init", "Creating DB")
    dbFile = fs.open(dbFilePath, "w")
    dbFile.write("{}")
    dbFile.close()
end

-- Import Database
loglib.log("Init", "Importing DB")
dbFile = fs.open(dbFilePath, "r")
db = textutils.unserialize(dbFile.readAll())
dbFile.close()

--Import Encryption Key
loglib.log("Init", "Importing encryption key")
keyFile = fs.open(".key", "r")
key = keyFile.readAll()
keyFile.close()




-- Main Loop
while true do
    -- Receive Packet
    loglib.log("Main", "Receiving packet...")
    local s, msg = sModem.receive()
    local p = textutils.unserialize(msg)

    loglib.log("Main", "Received packet with header: " .. p.head)

    -- Check Packet header
    if p.head == "USER" then
        userData(s, p)
    elseif p.head == "NAME" then
        name(s, p)
    elseif p.head == "BAL" then
        balance(s, p)
    elseif p.head == "HIST" then
        history(s, p)
    elseif p.head == "PAY" then
        payment(s, p)
    elseif p.head == "TAX" then
        tax(s, p)
    elseif p.head == "CHGPIN" then
        changePin(s, p)
    end
end
