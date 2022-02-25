--Create Secure Modem
local ecnet = require("api/ecnet")
local modem = peripheral.find("modem")
local sModem = ecnet.wrap(modem)

--Create Variables
local title = "Essentia Controller"
local version = "v1.0"
local servedIDs = {}
local outputSide = "back"

--Internal variables
local activeID = 0

--Set title of shell
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print(title.." "..version)
term.setTextColor(colors.lightGray)

--Function for Logging
local log = function(head, str)
    local logStr = "<" .. os.time() .. "> [" .. head .. "]: " .. str
    print(logStr)
end

--Print Address
log("Address", ecnet.address)

--Utility functions
local function getLocalID(id)
    local localID = 0

    for i = 1, #servedIDs do
        if servedIDs[i] == id then localID = i end
    end

    return localID
end

local responseOK = function(s, head)
    --Create reply packet
    local p = {head = head, status = "OK"}
    local reply = textutils.serialize(p)
        
    --Send reply packet
    sModem.connect(s, 3)
    sModem.send(s, reply)

    log("Response", "\"OK\" sent to: " .. s)
end

local responseFAIL = function(s, head)
    --Create reply packet
    local p = {head = head, status = "FAIL"}
    local reply = textutils.serialize(p)
        
    --Send reply packet
    sModem.connect(s, 3)
    sModem.send(s, reply)

    log("Response", "\"FAIL\" sent to: " .. s)
end


--Update function
local function update()
    redstone.setBundledOutput(outputSide, activeID)
    log("Update", "Set redstone output to var: " .. activeID)
end

--Main Loop
while true do
    --Receive Packet
    log("Main", "Receiving packet...")
    local s, msg = sModem.receive()
    local p = textutils.unserialize(msg)

    log("Main", "Received packet with head: " .. p.head)
    
    --Check Packet header
    if p.head == "FLOW" then
        local lid = getLocalID(p.id)
        log("Open", "Converted ID to local ID: " .. p.id .. " -> " .. lid)

        if lid ~= 0 then
            activeID = 2 ^ (lid - 1)
            update()
            sleep(0.1)

            activeID = 0
            update()
            sleep(5) --TODO: Tweak Cooldowns

            responseOK(s, p.head)
        else
            responseFAIL(s, p.head)
        end

        log("Open", "Applied change to output var: " .. activeID)
    end
end
