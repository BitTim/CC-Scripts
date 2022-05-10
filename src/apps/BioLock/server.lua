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

-- Function for handling normal authentication
local function auth(s, p)
    local checkStr = ""

    -- Check if packet is valid
    if p == nil then
        comlib.sendResponse(sModem, s, "AUTH", "FAIL", {reason = "IPACK"})
        return
    end

    -- Get auth data
    local factors, tuuid, eName, uuuid, pinHash, aCode = table.unpack(p.contents)

    -- Check if given factor types match the needed ones
    local calcFactors = 0
    if eName then calcFactors = calcFactors + 8 end
    if uuuid then calcFactors = calcFactors + 4 end
    if pinHash then calcFactors = calcFactors + 2 end
    if aCode then calcFactors = calcFactors + 1 end

    if factors ~= cTerm.factors then
        comlib.sendResponse(sModem, s, "AUTH", "FAIL", {reason = "IFACT"})
        return
    end

    if calcFactors ~= factors then
        comlib.sendResponse(sModem, s, "AUTH", "FAIL", {reason = "IFACT"})
        return
    end

    checkStr = checkStr .. textutils.serialise(factors)

    -- Get the terminal data of the current request
    local cTerm = nil
    for _, v in pairs(tdb) do
        if v.uuid == tuuid then
            cTerm = v
            break
        end
    end

    -- Check if terminal exists
    if cTerm == nil then
        comlib.sendResponse(sModem, s, "AUTH", "FAIL", {reason = "ITERM"})
        return
    end

    checkStr = checkStr .. textutils.serialise(tuuid)

    -- Variable for holding user data
    local user = nil

    -- Convert given eName, if given, to uuuid
    if eName then
        local newUUUID = nil
        for _, v in pairs(udb) do
            if v.eName == eName then
                newUUUID = v.uuid
                user = v
                break
            end
        end

        if newUUUID == nil or user == nil then
            comlib.sendResponse(sModem, s, "AUTH", "FAIL", {reason = "INAME"})
            return
        end

        if uuuid ~= nil then
            uuuid = newUUUID
        end

        checkStr = checkStr .. textutils.serialise(eName)
    end

    -- Chekci if uUUID is existing
    if uuuid then
        if user then
            if uuuid ~= user.uuid then
                comlib.sendResponse(sModem, s, "AUTH", "FAIL", {reason = "IUUID"})
                return
            end
        else
            for _, v in pairs(udb) do
                if v.uuid == uuuid then
                    user = v
                    break
                end
            end

            if user == nil then
                comlib.sendResponse(sModem, s, "AUTH", "FAIL", {reason = "IUUID"})
                return
            end
        end

        checkStr = checkStr .. textutils.serialise(uuuid)
     end

    -- Check if given uUUID, if given, has access to current terminal
    if uuuid then
        local hasAccess = false
        for _, v in pairs(cTerm.users) do
            if v.uuid == uuuid then
                hasAccess = true
                break
            end
        end

        if hasAccess == false then
            comlib.sendResponse(sModem, s, "AUTH", "FAIL", {reason = "NOACC"})
            return
        end
    end

    -- Check if PIN hashes match, when given
    if pinHash then
        if pinHash ~= user.pinHash then
            comlib.sendResponse(sModem, s, "AUTH", "FAIL", {reason = "IPINH"})
            return
        end

        checkStr = checkStr .. textutils.serialise(pinHash)
    end

    -- Check if 2fa code matches, when given
    if aCode then
        if aCode ~= user.authCode.aCode and aCode ~= user.authCode.pCode then
            comlib.sendResponse(sModem, s, "AUTH", "FAIL", {reason = "I2FAC"})
            return
        end

        checkStr = checkStr .. textutils.serialise(aCode)
    end

    -- Return success packet
    comlib.sendResponse(sModem, s, "AUTH", "OK", {check = checkStr})
end



-- Function for handling "personal temporary authentication number" (ptan) authentications
local function ptanAuth(s, p)
    -- Check if packet is valid
    if p == nil then
        comlib.sendResponse(sModem, s, "PTAN", "FAIL", {reason = "IPACK"})
        return
    end

    -- Get auth data
    local tuuid, ptanHash = table.unpack(p.contents)

    local ptanObj = nil
    for _, t in pairs(tdb) do
        if t.uuid == tuuid then
            for _, p in pairs(v.ptanList) do
                if p.hash == ptanHash then
                    ptanObj = p
                    break
                end
            end

            if ptanObj then break end
        end
    end

    -- Check if PTAN Object exists
    if ptanObj == nil then
        comlib.sendResponse(sModem, s, "PTAN", "FAIL", {reason = "ITANH"})
        return
    end

    -- Check if PTAN has uses and use it
    if ptanObj:use() == false then
        comlib.sendResponse(sModem, s, "PTAN", "FAIL", {reason = "IUSES"})
        return
    end

    -- Return Success
    comlib.sendResponse(sModem, s, "PTAN", "OK", {})
end

local function registerAuthClient(s, p)
    -- Check if packet is valid
    if p == nil then
        comlib.sendResponse(sModem, s, "REGAUTH", "FAIL", {reason = "IPACK"})
        return
    end
	
	-- Get data
	local uuuid, pinHash, address = table.unpack(p.contents)
	
	-- Get users
	local user = nil
	for _, v in pairs(udb) do
		if v.uuid == uuuid then
			user = v
			break
		end
	end
	
	-- Check if user exists
	if user == nil then
		comlib.sendResponse(sModem, s, "REGAUTH", "FAIL", {reason = "IUUID"})
		return
	end
	
	-- Check if hashes match
	if user.pinHash ~= pinHash then
		comlib.sendResponse(sModem, s, "REGAUTH", "FAIL", {reason = "IPINH"})
		return
	end
	
	-- Add address of client to user
	user.authCode:addClient(address)
    comlib.sendResponse(sModem, s, "REGAUTH", "OK", {})
end

-- TODO: Add request for creating a ptan








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
				
				-- Send new code and time to every registered 2fa client
				comlib.broadcast(sModem, v.authCode.clients, "AUTH_CODE_UPDT", {code = v.authCode.aCode, time = v.authCode.time}, 0.5)
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
            if p.head == "AUTH" then
                auth(s, p)
            elseif p.head == "PTAN" then
                ptanAuth(s, p)
            elseif p.head == "REGAUTH" then
                registerAuthClient(s, p)
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
