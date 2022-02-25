--Create Secure Modem
local ecnet = require("api/ecnet")
local modem = peripheral.find("modem")
local sModem = ecnet.wrap(modem)

local dns = "02ed:16d0:a091:c3c5:84d6"

--Create Variables
local title = "Essentia Server"
local version = "v1.0"
local controllerDomains = {}

--Set title of shell
term.setTextColor(colors.yellow)
term.clear()
term.setCursorPos(1, 1)
print(title.." "..version)

--Route Output to Monitor
local mon = peripheral.find("monitor")
mon.setTextScale(0.5)
term.redirect(mon)

--Set title of monitor
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

--Connect to DNS
log("INIT", "Connecting to DNS...")
local connected = sModem.connect(dns, 3)

--Show status message
if not connected then
    log("INIT", "Failed to connect to DNS")
else
    log("INIT", "Connected!")
end

--Utility functions
local sendPacketForReply = function(address, msg, head)
    --Connect to Server
    local ret = sModem.connect(address, 3)
    if not ret then return -1 end

    --Send packet and wait for reply
    sModem.send(address, msg)
    local s, p = sModem.receive(address, 3)
        
    --Check for timeout
    if s == nil then
        return -1
    end
    
    local reply = textutils.unserialize(p)

    --Check if reply is valid
    if reply == nil then
        return -1
    end

    --Check for invalid packet
    if reply.head ~= head then
        return -1
    end

    return reply
end

local lookup = function(domain)
    --Look up server
    local p = {head = "LOOKUP", domain = domain}
    local msg = textutils.serialize(p)

    local reply = sendPacketForReply(dns, msg, "LOOKUP")
    if reply == -1 then return false end

    return reply.address
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

local function broadcast(receivers, msg, head)
    local statuses = {}

    for i = 1, #receivers do
        log("Broadcast", "Sending to: " .. receivers[i])
        local address = lookup(receivers[i])

        local reply = sendPacketForReply(address, msg, head)
        if reply == -1 then reply = {status = "FAIL"} end
        statuses[#statuses + 1] = reply.status

        if reply.status == "OK" then break end
    end

    return statuses
end



--Main Loop
while true do
    --Receive Packet
    log("Main", "Receiving packet...")
    local s, msg = sModem.receive()
    local p = textutils.unserialize(msg)

    log("Main", "Received packet with head: " .. p.head)
    
    local failed = false
    --Check Packet header
    if p.head == "FLOW" then
        log("Flow", "Flowing id " .. p.id .. " x" .. p.amount)
        local newP = {head = "FLOW", id = p.id}
        local msg = textutils.serialize(newP)

        for i = 1, p.amount do
            local statuses = broadcast(controllerDomains, msg, "FLOW")
            
            local ok = false
            for st = 1, #statuses do
                if statuses[st] == "OK" then
                    ok = true
                    break
                end
            end

            if ok == false then
                responseFAIL(s, p.head)
                failed = true
                break
            end
        end

        if failed == false then
            responseOK(s, p.head)
        end
    end
end
