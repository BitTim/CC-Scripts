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
local totalAssets = "100000"        -- Total amount of money in circulation
local authThreshold = 100           -- If amount of payment is above this threshold, auth is required

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

local function addTransactionEntry(fromUUID, toUUID, amount, desc)
    table.insert(db[fromUUID].transactions, { from = fromUUID, to = toUUID, amount = amount, desc = desc })
    table.insert(db[toUUID].transactions, { from = fromUUID, to = toUUID, amount = amount, desc = desc })
    updateDB()
end








-- --------------------------------
--  Request Handlers
-- --------------------------------

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
    local uuid, to, amount, desc, cardUUID, hash = p.contents.uuid, p.contents.to, p.contents.amount, p.contents.desc, p.contents.cardUUID, p.contents.hash
    local toUUID = getUUIDfromAccountNum(to);
    amount = tonumber(amount)

    -- Check all fail states
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

    if amount > authThreshold and hash == nil then
        loglib.log("PAY", "Failed, amount above threshold and no auth")
        comlib.sendResponse(sModem, s, "PAY", "FAIL", { reason = "NO_AUTH" })
        return
    end

    if amount > authThreshold and hash ~= db[uuid].hash then
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

    addTransactionEntry(uuid, toUUID, amount, desc)
    loglib.log("PAY", "Added transaction entry")

    -- Send response
    comlib.sendResponse(sModem, s, "PAY", "OK", {})
end









-- --------------------------------
--  Main Program
-- --------------------------------

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
    if p.head == "BAL" then
        balance(s, p)
    elseif p.head == "HIST" then
        history(s, p)
    elseif p.head == "PAY" then
        payment(s, p)
    end
end
