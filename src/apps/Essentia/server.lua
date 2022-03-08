-- ================================
--  server.lua
-- --------------------------------
--  Script for managing and
--  distributing requests to
--  controllers
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local comlib = require("/lib/comlib")
local loglib = require("/lib/loglib")

-- --------------------------------
--  Configurable Properties
-- --------------------------------

local controllerDomains = {}
local modemSide = "top"

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Essentia Server"
local version = "v1.0"

-- --------------------------------
--  Internal Properties
-- --------------------------------

local sModem = nil








-- --------------------------------
--  Main Program
-- --------------------------------

sModem = comlib.open(modemSide) -- Create Secure Modem
loglib.init(title, version) -- Initialize LogLib
loglib.log("Address", comlib.getAddress()) -- Print Address























--Utility functions
local sendPacketForReply = function(address, msg, head, timeout)
    --Connect to Server
    local ret = sModem.connect(address, 3)
    if not ret then return -1 end

    --Send packet and wait for reply
    sModem.send(address, msg)
    local s, p = sModem.receive(address, timeout)
        
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

local function broadcast(receivers, msg, head, timeout)
    local statuses = {}

    for i = 1, #receivers do
        log("Broadcast", "Sending to: " .. receivers[i])
        local address = lookup(receivers[i])

        local reply = sendPacketForReply(address, msg, head, timeout)
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
            local statuses = broadcast(controllerDomains, msg, "FLOW", 10)
            
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
