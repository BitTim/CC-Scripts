-- ================================
--  terminal.lua
-- --------------------------------
--  Terminal to access bank
--  accounts and manage funds
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local comlib = require("/lib/comlib")
local dnslib = require("/lib/dnslib")

-- --------------------------------
--  Configurable Properties
-- --------------------------------

local modemSide = "top"
local serverDomain = "bank.test"

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Client"
local version = "v2.0"

-- --------------------------------
--  Internal Properties
-- --------------------------------

local sModem = nil
local serverAddress = nil







-- --------------------------------
--  Main Program
-- --------------------------------

sModem = comlib.open(modemSide)                                 -- Create Secure Modem
if dnslib.init(sModem) == -1 then                               -- Initialize DNSLib
    print("Could not connect to DNS Server")
    return -1
end

serverAddress = dnslib.lookup(serverDomain)                     -- Lookup Address of Server

local card = fs.open("/disk/.auth", "r")
local uuid = card.readLine()
local cardUUID = card.readLine()
card.close()

--Main Loop
while true do
    repeat
        -- Get Input
        term.setTextColor(colors.yellow)
        term.write("Client> ")
        term.setTextColor(colors.white)
        local cmd = read()
        term.setTextColor(colors.lightGray)

        -- Tokeinze input
        local tokens = {}
        for s in string.gmatch(cmd, "([^;]+)") do
            table.insert(tokens, s)
        end

        -- Check if there are at least two arguments
        if tokens[1] == nil or tokens[2] == nil then
            term.setTextColor(colors.red)
            print("Usage: [Header] [Contents] <Timeout>")
            break
        end

        local contents =  textutils.unserialize(tokens[2])
        contents.uuid = uuid
        contents.cardUUID = cardUUID

        print("[" .. tokens[1] .. "]: " ..textutils.serialise(contents))
        local ret = comlib.sendRequest(sModem, serverAddress, tokens[1], contents, tonumber(tokens[3]))

        term.setTextColor(colors.lightGray)
        print(textutils.serialise(ret))
    until true
end