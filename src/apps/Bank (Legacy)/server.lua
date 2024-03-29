os.loadAPI("api/aeslua")

--Create Secure Modem
local ecnet = require("api/ecnet")
local modem = peripheral.find("modem")
local sModem = ecnet.wrap(modem)

--Set title of shell
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print("Bank Server v1.1")

--Route Output to Monitor
local mon = peripheral.find("monitor")
mon.setTextScale(0.5)
term.redirect(mon)

--Set title of monitor
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print("Bank Server v1.1")
term.setTextColor(colors.lightGray)

--Function for Logging
local log = function(head, str)
    logStr = "<" .. os.time() .. "> [" .. head .. "]: " .. str
    print(logStr)
end

--Create BankDB if not existing
if not fs.exists(".bankDB") then
    log("Init", "Creating BankDB")
    local bdbFile = fs.open(".bankDB", "w")
    bdbFile.write("{ }")
    bdbFile.close()
end

--Import BankDB
log("Init", "Importing BankDB")
local bdbFile = fs.open(".bankDB", "r")
local bdb = textutils.unserialize(bdbFile.readAll())
bdbFile.close()

--Import Encryption Key
log("Init", "Importing encryption key")
local keyFile = fs.open(".key", "r")
local key = keyFile.readAll()
keyFile.close()

--Print Address
log("Address", ecnet.address)

-- ================================
-- Authentication Functions
-- ================================

--Function for checking Name
local authName = function(name)
    if bdb[name] == nil then return false end
    return true
end

--Function for checking Hash
local authHash = function(name, hash)
    log("Auth", bdb[name].hash)
    log("Auth", hash)
    if bdb[name].hash ~= hash then return false end
    return true
end

--Function for sending Fail packet
local responseFail = function(s, head, cause)
    --Create reply packet
    local p = {head = head, state = "FAIL", cause = cause}
    local reply = textutils.serialize(p)
        
    --Send reply packet
    sModem.connect(s, 3)
    sModem.send(s, reply)

    log("Response", "Failed " .. head .. " " .. s .. " with cause: " .. cause)
end

--Function for sending success packet
local responseSuccess = function(s, head)
    --Create reply packet
    local p = {head = head, state = "SUCCESS"}
    local reply = textutils.serialize(p)
        
    --Send reply packet
    sModem.connect(s, 3)
    sModem.send(s, reply)

    log("Response", "Success " .. head .. " " .. s)
end

--Function for authentication
local auth = function(s, name, hash)
    if not authName(name) then
        log("Auth", "Name not found")
        responseFail(s, "AUTH", "NAME")
        return
    end
    
    if not authHash(name, hash) then
        log("Auth", "Hashes don't match")
        responseFail(s, "AUTH", "HASH")
        return
    end

    responseSuccess(s, "AUTH")
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
    sModem.send(s, reply)

    log("Balance", "Sent balance of " .. name .. " (" .. bal .. "$) to " .. s)
end

local transfer = function(s, name, recipiant, amount)
    log("Transfer", "Transferring " .. amount .. "$ from " .. name .. " to " .. recipiant)
    amount = tonumber(amount)

    --Check if user has anough money
    local bal = tonumber(aeslua.decrypt(key, bdb[name].bal))
    
    if amount > bal then
        log("Transfer", "Balance too low: " .. name)

        --Create reply packet
        local p = {head = "TRANSFER", state = "FAIL", cause = "BALANCE"}
        local reply = textutils.serialize(p)
        
        --Send reply packet
        sModem.connect(s, 3)
        sModem.send(s, reply)
        return
    end

    --Find Recipiant name
    local target = ""
    log("Transfer", "Looking up recipiant")

    for key, value in pairs(bdb) do
        if value.id == recipiant then
            target = key
            break
        end
    end

    --Recipiant not found
    if target == "" then
        log("Transfer", "Recipiant " .. recipiant .. " not found")

        --Create reply packet
        local p = {head = "TRANSFER", state = "FAIL", cause = "RECIPIANT"}
        local reply = textutils.serialize(p)
        
        --Send reply packet
        sModem.connect(s, 3)
        sModem.send(s, reply)
        return
    end

    log("Transfer", "Recipiant is: " .. target)

    --Add amount to targets balance
    local targetBal = tostring(tonumber(aeslua.decrypt(key, bdb[target].bal)) + amount)
    bdb[target].bal = aeslua.encrypt(key, targetBal)
    log("Transfer", "Added " .. amount .. "$ to recipiants balance")

    --Remove amount from sender
    bal = bal - amount
    bdb[name].bal = aeslua.encrypt(key, tostring(bal))
    log("Transfer", "Removed " .. amount .. "$ from senders balance")

    --Create reply packet
    local p = {head = "TRANSFER", state = "SUCCESS"}
    local reply = textutils.serialize(p)

    --Send reply packet
    sModem.connect(s, 3)
    sModem.send(s, reply)

    --Log transfer in db
    table.insert(bdb[name].transfers, {from = name, to = target, amount = amount})
    table.insert(bdb[target].transfers, {from = name, to = target, amount = amount})
    log("Transfer", "Written transfer log")

    --Save db file
    if fs.exists(".bankDB.bak") then fs.delete(".bankDB.bak") end
    fs.move(".bankDB", ".bankDB.bak")
    local bdbFile = fs.open(".bankDB", "w")
    bdbFile.write(textutils.serialize(bdb))
    bdbFile.close()
    log("Transfer", "Saved Database")
end

--Function for changing PIN of user
local changePIN = function(s, name, hash)
    if not authName(name) then
        log("Auth", "Name not found")
        responseFail(s, "CHGPIN", "NAME")
        return
    end

    bdb[name].hash = hash
    if fs.exists(".bankDB.bak") then fs.delete(".bankDB.bak") end
    fs.move(".bankDB", ".bankDB.bak")
    local bdbFile = fs.open(".bankDB", "w")
    bdbFile.write(textutils.serialize(bdb))
    bdbFile.close()
    responseSuccess(s, "CHGPIN")
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
    elseif p.head == "TRANSFER" then
        transfer(s, p.name, p.recipiant, p.amount)
    elseif p.head == "CHGPIN" then
        changePIN(s, p.name, p.hash)
    elseif p.head == "PRINT" then
        --TODO: Return Transfer History
    end
end


