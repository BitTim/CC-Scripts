-- ================================
--  server.lua
-- --------------------------------
--  Serverv for multi factor
--  authentication
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local comlib = require("/lib/comlib")
local loglib = require("/lib/loglib")
local authlib = require("/lib/authlib")

-- --------------------------------
--  Configurable Properties
-- --------------------------------

local modemSide = "top"

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Auth Server"
local version = "v1.0"

-- --------------------------------
--  Internal Properties
-- --------------------------------

local sModem = nil
local udb = {}
local tdb = {}








-- --------------------------------
--  Local Functions
-- --------------------------------

local function initDBs()
    -- Load DB Files
    local userDBFile = fs.open("/.userDB", "r")
    local tmpUserDB = textutils.unserialize(userDBFile.readAll())
    userDBFile.close()

    local termDBFile = fs.open("/.termDB", "r")
    local tmpTermDB = textutils.unserialize(termDBFile.readAll())
    termDBFile.close()

    -- Create objects
    for _, v in pairs(tmpUserDB) do
        local user = authlib.User:new(v.uuid, v.eName, v.pinHash)
        table.insert(udb, user)
    end

    for _, v in pairs(tmpTermDB) do
        local term = authlib.Terminal:new(v.uuid, v.name, v.users)
        table.insert(tdb, term)
    end
end








-- --------------------------------
--  Request Handlers
-- --------------------------------

local function req(s, p)
    comlib.sendResponse(sModem, s, "TEST", "OK", nil)
end








-- --------------------------------
--  Parallel Handlers
-- --------------------------------

local function timerHandler()
    while true do
        local _, timer = os.pullEvent("timer")

        for _, v in pairs(udb) do
            if v.authCode.timer == timer then
                loglib.log(v.eName, v.authCode.aCode .. ", " .. v.authCode.time .. "s")
                v.authCode:update()
                break
            end
        end
    end
end

local function receiveHandler()
    while true do
        repeat
            --Receive Packet
            local s, msg = sModem.receive(nil, 0)
            if s == nil or msg == nil then break end

            local p = textutils.unserialize(msg)

            loglib.log("Main", "Received packet with header: " .. p.head)

            --Check Packet header
            if p.head == "TEST" then
                req(s, p)
            end
        until true
    end
end








-- --------------------------------
--  Main Program
-- --------------------------------

sModem = comlib.open(modemSide)                                 -- Create Secure Modem
loglib.init(title, version, 0.5)                                -- Initialize LogLib
loglib.log("Address", comlib.getAddress())                      -- Print Address

initDBs()

--Main Loop
while true do
    parallel.waitForAny(timerHandler, receiveHandler)
end
