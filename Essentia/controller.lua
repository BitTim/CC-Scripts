--Create Secure Modem
local ecnet = require("api/ecnet")
local modem = peripheral.wrap("top")
local sModem = ecnet.wrap(modem)

--Create Variables
local title = "Essentia Controller"
local version = "v1.0"
local outputSide = "back"

local servedAspects = {}
local nbtPeripheralTags = {}
local nbtPeripherals = {}

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

--Wrap all NBT Peripherals
for i = 1, #nbtPeripheralTags do
    nbtPeripherals[i] = peripheral.wrap(nbtPeripheralTags[i])
end

--Utility functions
local function getLocalID(aspect)
    local localID = 0

    for i = 1, #servedAspects do
        if servedAspects[i] == aspect then localID = i end
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
local function sendPulse(id)
    local rid = 2 ^ (id - 1)
    redstone.setBundledOutput(outputSide, rid)
    sleep(0.1)
    restone.setBundledOutput(outputSide, 0)

    log("SendPulse", "Setting redstone output to: " .. id)
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
        local lid = getLocalID(p.aspect)
        log("Flow", "Converted ID to local ID: " .. p.id .. " -> " .. lid)

        if lid ~= 0 then
            sendPulse(lid)
            sleep(3)
            responseOK(s, p.head)
        else
            responseFAIL(s, p.head)
        end

        log("Open", "Applied change to output var: " .. activeID)
    elseif p.head == "PROBE" then
        local lid = getLocalID(p.aspect)
        log("Probe", "Converted ID to local ID: " .. p.id .. " -> " .. lid)

        if lid ~= 0 then
            if nbtPeripherals[lid].has_nbt() then
                local nbt = nbtPeripherals.read_nbt()
                local nbtAspect, nbtAmount = nbt.Aspect, nbt.Amount
            end
        end
    end
end
