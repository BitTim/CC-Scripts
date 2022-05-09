-- ================================
--  comlib.lua
-- --------------------------------
--  Library for communication
--  between two computers
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local ecnet = require("/lib/ThirdParty/ecnet")








-- --------------------------------
--  Functions
-- --------------------------------

local M = {}

-- Open secure modem
function M.open(side)
    local modem = peripheral.wrap(side)
    local sModem = ecnet.wrap(modem)
    return sModem
end

-- Get current address
function M.getAddress()
    return ecnet.address
end

-- Send a request and wait for response
function M.sendRequest(sModem, address, header, contents, timeout)
    -- Set defult values for not specified variables
    if timeout == nil then timeout = 10 end
    if sModem == nil then return -1 end

    -- Connect to Server
    local ret = sModem.connect(address, 3)
    if not ret then return -1 end

    -- Create request packet
    local packet = {head = header, status = "REQUEST", contents = contents}
    local request = textutils.serialize(packet)

    -- Send packet and wait for response
    sModem.send(address, request)
    local sender, msg = sModem.receive(address, timeout)

    -- Check for timeout
    if sender == nil then
        return -1
    end

    local response = textutils.unserialize(msg)

    -- Check if reply is valid
    if response == nil then
        return -1
    end

    -- Check for invalid packet
    if response.head ~= header then
        return -1
    end

    return response
end

-- Send a response to a request
function M.sendResponse(sModem, address, header, status, contents)
    if sModem == nil then return end

    -- Create response packet
	local p = {head = header, status = status, contents = contents}
    local reply = textutils.serialize(p)

    -- Send reply packet
    sModem.connect(address, 3)
    sModem.send(address, reply)
end

-- Broadcast a request to multiple receivers
function M.broadcast(sModem, addresses, header, contents, timeout)
    -- Set defult values for not specified variables
    if timeout == nil then timeout = 30 end
    if sModem == nil then return end

    local responses = {}

    -- Iterate over all addresses
    for i = 1, #addresses do
        local response = M.sendRequest(sModem, addresses[i], header, contents, timeout)
        if response == -1 then response = {head = header, status = "FAIL", contents = {}} end
        responses[i] = response
    end

    return responses
end

return M