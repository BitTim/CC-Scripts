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
local dnslib = require("/lib/dnslib")
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

local controllerAddresses = {}
local sModem = nil








-- --------------------------------
--  Request Handlers
-- --------------------------------

local function flow(s, p)
    loglib.log("Flow", "Broadcasting request")
    local responses = comlib.broadcast(controllerAddresses, p.head, p.contents)
    local handled = false

    loglib.log("Flow", "Iterating over responses")
    for i = 1, #responses do
        if responses[i].status == "OK" then
            loglib.log("Flow", "Sending response with status OK")
            comlib.sendResponse(s, p.head, "OK", nil)
            handled = true
        end
    end

    loglib.log("Flow", "Sending response with status FAIL")
    if handled == false then comlib.sendResponse(s, p.head, "FAIL", nil) end
end

local function probe(s, p)
    loglib.log("Probe", "Broadcasting request")
    local responses = comlib.broadcast(controllerAddresses, p.head, p.contents)
    local handled = false

    loglib.log("Probe", "Iterating over responses")
    for i = 1, #responses do
        if responses[i].status == "OK" then
            loglib.log("Probe", "Sending response with status OK")
            comlib.sendResponse(s, p.head, "OK", responses[i].contents)
            handled = true
        end
    end

    loglib.log("Probe", "Sending response with status FAIL")
    if handled == false then comlib.sendResponse(s, p.head, "FAIL", nil) end
end








-- --------------------------------
--  Main Program
-- --------------------------------

sModem = comlib.open(modemSide)                                 -- Create Secure Modem
loglib.init(title, version)                                     -- Initialize LogLib
loglib.log("Address", comlib.getAddress())                      -- Print Address
dnslib.init()                                                   -- Initialize DNSLib
controllerAddresses = dnslob.lookupMultiple(controllerDomains)  -- Look up all controller adresses

if controllerAddresses == -1 then
    error("Could not look up addresses for the controllers")
end

--Main Loop
while true do
    --Receive Packet
    loglib.log("Main", "Receiving packet...")
    local s, msg = sModem.receive()
    local p = textutils.unserialize(msg)

    log("Main", "Received packet with header: " .. p.head)
    
    --Check Packet header
    if p.head == "FLOW" then
        flow(s, p)
    end
end
