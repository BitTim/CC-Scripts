-- Script for controlling Essentia Valves and reading stored amount of essentia in jars

-- Import libraries
local comlib = require("/lib/comlib")

--Create Variables
local title = "Essentia Controller"
local version = "v1.0"

-- Configurable Properties
local servedAspects = {}
local nbtPeripheralTags = {}
local outputSide = "back"
local modemSide = "top"

-- Internal Properties
local nbtPeripherals = {}
local sModem = nil

--Create Secure Modem
sModem = comlib.open(modemSide)

--Set title of shell
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print(title.." "..version)
term.setTextColor(colors.lightGray)

-- Logging with title and time
local function log(head, str)
    local logStr = "<" .. os.time() .. "> [" .. head .. "]: " .. str
    print(logStr)
end

--Print Address
log("Address", comlib.getAddress())

--Wrap all NBT Peripherals
for i = 1, #nbtPeripheralTags do
    nbtPeripherals[i] = peripheral.wrap(nbtPeripheralTags[i])
end

-- Convert aspect name to local ID
local function getLocalID(aspect)
    local localID = 0

    for i = 1, #servedAspects do
        if servedAspects[i] == aspect then localID = i end
    end

    return localID
end

-- Sends a redstone pulse to a bundled cable on the output side on the specified channel
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
            comlib.sendResponse(s, p.head, "OK", nil)
        else
            comlib.sendResponse(s, p.head, "FAIL", nil)
        end

        log("Flow", "Applied change to output var: " .. activeID)

    elseif p.head == "PROBE" then
        local lid = getLocalID(p.aspect)
        log("Probe", "Converted ID to local ID: " .. p.id .. " -> " .. lid)

        if lid ~= 0 then
            if nbtPeripherals[lid].has_nbt() then
                local nbt = nbtPeripherals.read_nbt()
                local nbtAspect, nbtAmount = nbt.Aspect, nbt.Amount
		
				comlib.sendResponse(s, p.head, "OK", {aspect = nbtAspect, amount = nbtAmount})
            else
				comlib.sendResponse(s, p.head, "FAIL", nil)
			end
        else
			comlib.sendResponse(s, p.head, "FAIL", nil)
		end
    end
end