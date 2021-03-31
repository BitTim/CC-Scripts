--Create Secure Modem
local ecnet = require("api/ecnet")
local modem = peripheral.find("modem")
local sModem = ecnet.wrap(modem)

--Set title of shell
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print("DNS Server v1.0")

--Route Output to Monitor
local mon = peripheral.find("monitor")
mon.setTextScale(0.5)
term.redirect(mon)

--Set title of monitor
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print("DNS Server v1.0")
term.setTextColor(colors.lightGray)

--Function for Logging
local log = function(head, str)
    logStr = "<" .. os.time() .. "> [" .. head .. "]: " .. str
    print(logStr)
end

--Check if DNS database exists
if not fs.exists(".dns") then
    --If not, create it
    log("Init", "Creating DNS database")
    local dbFile = fs.open(".dns", "w")
    dbFile.write("{ }")
    dbFile.close()
end

--Import DNS database
log("Init", "Importing DNS database")
local dbFile = fs.open(".dns", "r")
local db = textutils.unserialize(dbFile.readAll())
dbFile.close()

--Main Loop
while true do
    --Receive Packet
    log("Main", "Receiving packet...")
    local s, msg = sModem.receive()
    local p = textutils.unserialize(msg)

    log("Main", "Received packet with head: " .. p.head)
    
    --Check Packet header
    if p.head == "LOOKUP" then
        --Find address of the requested domain
        local address = db[p.domain]
        log("Lookup", "Looked up " .. p.domain .. " -> " .. textutils.serialize(address))
        
        --Create reply packet
        local p = {head = "LOOKUP", address = address}
        local reply = textutils.serialize(p)
        
        --Send reply packet
        sModem.connect(s, 3)
        sModem.send(s, reply)
        log("Lookup", "Sent reply to " .. s)
    elseif p.head == "MODIFY" then
        --Check modify operation
        if p.op == "REGISTER" then
            --Insert entry into db
            db[p.domain] = p.address
            log("Register", "Registered new domain: " .. p.domain .. " -> " .. p.address)
        elseif p.op == "REMOVE" then
            --Remove specified element
            db[p.domain] = nil
            log("Remove", "Removed domain: " .. p.domain)
        end
                
        --Update file
        local dbFile = fs.open(".dns", "w")
        dbFile.write(textutils.serialize(db))
        dbFile.close()
        log("Modify", "Updated database")

        --Create reply packet
        local p = {head = "MODIFY", status = "SUCCESS"}
        local reply = textutils.serialize(p)
        
        --Send reply packet
        sModem.connect(s, 3)
        sModem.send(s, reply)
        log("Modify", "Sent reply status: SUCCESS")
    end
end


