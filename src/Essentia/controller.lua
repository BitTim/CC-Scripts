--- Script for controlling Essentia Valves and reading stored amount of essentia in jars
--- @class Essentia.Controller
local M = {}

--Create Secure Modem


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

--- Logging with title and time
--- @param head string Title of log message
--- @param str string Log message
function M.log(head, str)
    local logStr = "<" .. os.time() .. "> [" .. head .. "]: " .. str
    print(logStr)
end

--Print Address
log("Address", ecnet.address)

--Wrap all NBT Peripherals
for i = 1, #nbtPeripheralTags do
    nbtPeripherals[i] = peripheral.wrap(nbtPeripheralTags[i])
end

--- Convert aspect name to local ID
--- @param aspect string Aspect name to convert
--- @return int Local ID of the aspct or 0 when aspect is not served
function M.getLocalID(aspect)
    local localID = 0

    for i = 1, #servedAspects do
        if servedAspects[i] == aspect then localID = i end
    end

    return localID
end

--- Send a response to a request
--- @param s string Adress of requesting client
--- @param head string Header of the response packet
--- @param status string Status of the response packet
--- @param contents table Table with packet contents
function M.sendResponse(s, head, status, contents)
    -- Create response packet
	local p = {head = head, status = status, contents = contents}
    local reply = textutils.serialize(p)
        
    -- Send reply packet
    sModem.connect(s, 3)
    sModem.send(s, reply)

    log("Response", "\"OK\" sent to: " .. s)
end

--- Sends a redstone pulse to a bundled cable on the output side on the specified channel
--- @param id int Local ID which corresponds to the color channel of the bundled cable
function M.sendPulse(id)
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
            sendResponse(s, p.head, "OK", nil)
        else
            sendResponse(s, p.head, "FAIL", nil)
        end

        log("Flow", "Applied change to output var: " .. activeID)
    elseif p.head == "PROBE" then
        local lid = getLocalID(p.aspect)
        log("Probe", "Converted ID to local ID: " .. p.id .. " -> " .. lid)

        if lid ~= 0 then
            if nbtPeripherals[lid].has_nbt() then
                local nbt = nbtPeripherals.read_nbt()
                local nbtAspect, nbtAmount = nbt.Aspect, nbt.Amount
		
				sendResponse(s, p.head, "OK", {aspect = nbtAspect, amount = nbtAmount})
            else
				sendResponse(s, p.head, "FAIL", nil)
			end
        else
			sendResponse(s, p.head, "FAIL", nil)	
		end
    end
end

return M
