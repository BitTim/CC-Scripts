--Create Secure Modem
local ecnet = require("api/ecnet")
local modem = peripheral.find("modem")
local sModem = ecnet.wrap(modem)

--Set title of shell
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print("Keycard Server v2.0")

--Route Output to Monitor
local mon = peripheral.find("monitor")
mon.setTextScale(0.5)
term.redirect(mon)

--Set title of monitor
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print("Keycard Server v2.0")
term.setTextColor(colors.lightGray)

--Function for Logging
local log = function(head, str)
    logStr = "<" .. os.time() .. "> [" .. head .. "]: " .. str
    print(logStr)
end

--Create db if not existing
if not fs.exists(".authDB") then
    log("Init", "Creating AuthDB")
    local dbFile = fs.open(".authDB", "w")
    dbFile.write("{ }")
    dbFile.close()
end

--Import db
log("Init", "Importing AuthDB")
local dbFile = fs.open(".authDB", "r")
local db = textutils.unserialize(dbFile.readAll())
dbFile.close()

--Print Address
log("Address", ecnet.address)

-- ================================
-- Authentication Functions
-- ================================

--Function for checking Name
local authName = function(name)
    if db[name] == nil then return false end
    return true
end

--Function for checking Hash
local authHash = function(name, hash)
    if db[name].hash ~= hash then return false end
    return true
end

--Function for checking Access
local authAccess = function(name, access)
    if db[name].hash < access then return false end
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
    
    if not authAccess(name, access) then
        log("Auth", "No access to client area")
        authFail(s, "ACCESS")
        return
    end

    authSuccess(s)
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
        auth(s, p.name, p.hash, p.access)
    end
end


