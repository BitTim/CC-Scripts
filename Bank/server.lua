os.loadAPI("api/aeslua")

--Create Secure Modem
local ecnet = require("api/ecnet")
local modem = peripheral.find("modem")
local sModem = ecnet.wrap(modem)

--Set title of shell
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print("Bank Server v1.0")

--Route Output to Monitor
local mon = peripheral.find("monitor")
mon.setTextScale(0.5)
term.redirect(mon)

--Set title of monitor
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print("Bank Server v1.0")
term.setTextColor(colors.lightGray)

--Print Address
log("Address", ecnet.address)

--Function for Logging
local log = function(head, str)
    logStr = "<" .. os.time() .. "> [" .. head .. "]: " .. str
    print(logStr)
end

--Create AuthDB if not existing
if not fs.exists(".authDB") then
    log("Init", "Creating AuthDB")
    local adbFile = fs.open(".authDB", "w")
    adbFile.write("{ }")
    adbFile.close()
end

--Import AuthDB
log("Init", "Importing AuthDB")
local adbFile = fs.open(".authDB", "r")
local adb = textutils.unserialize(adbFile.readAll())
adbFile.close()

--Create BankDB if not existing
if not fs.exists(".bankDB") then
    log("Init", "Creating BankDB")
    local bdbFile = fs.open(".bankDB", "w")
    bdbFile.write("{ }")
    bdbFile.close()
end

--Import AuthDB
log("Init", "Importing BankDB")
local bdbFile = fs.open(".bankDB", "r")
local bdb = textutils.unserialize(bdbFile.readAll())
bdbFile.close()

--Import Encryption Key
log("Init", "Importing encryption key")
local keyFile = fs.open(".key", "r")
local key = textutils.unserialize(keyFile.readAll())
keyFile.close()

-- ================================
-- Authentication Functions
-- ================================

--Function for checking Name
local authName = function(name)
    if adb[name] == nil then return false end
    return true
end

--Function for checking Hash
local authHash = function(name, hash)
    if adb[name].hash ~= hash then return false end
    return true
end

--Function for sending Fail packet
local authFail = function(s, cause)
    --Create reply packet
    local p = {head = "AUTH", state = "FAIL", cause = cause}
    local reply = textutils.serialize(p)
        
    --Send reply packet
    sModem.connect(s, 3)
    sModem.send(s, reply)

    log("Auth", "Denied " .. s .. " with cause: " .. cause)
end

--Function for sending success packet
local authSuccess = function(s)
    --Create reply packet
    local p = {head = "AUTH", state = "SUCCESS"}
    local reply = textutils.serialize(p)
        
    --Send reply packet
    sModem.connect(s, 3)
    sModem.send(s, reply)

    log("Auth", "Granted " .. s)
end

--Function for authentication
local auth = function(s, name, hash, access)
    if not authName(name) then
        log("Auth", "Name not found")
        authFail(s, "NAME")
        return
    end
    
    if not authHash(name, hash) then
        log("Auth", "Hashes don't match")
        authFail(s, "HASH")
        return
    end

    authSuccess(s)
end

-- ================================
-- Bank Functions
-- ================================

--Function for sending current balance of user
local balance = function(s, name)
    --Retreive current balance
    local bal = aeslua.decrypt(key, bdb[name].bal)

    --Create reply packet
    local p = {head = "BAL", balance = bal}
    local reply = textutils.serialize(p)

    --Send reply packet
    sModem.connect(s, 3)
    sModem.send(s.reply)

    log("Balance", "Sent balance of " .. name .. " (" .. bal .. "€) to " .. s)
end

-- ================================
-- Main Loop
-- ================================

while true do
    --Receive Packet
    log("Main", "Receiving packet...")
    local s, msg = sModem.receive()
    local p = textutils.unserialize(msg)

    log("Main", "Received packet with head: " .. p.head)
    
    --Check Packet header
    if p.head == "AUTH" then
        auth(s, p.name, p.hash)
    elseif p.head == "BAL" then
        balance(s, p.name)
    elseif p.head == "DEPOSIT" then

    elseif p.head == "WITHDRAW" then

    end
end


