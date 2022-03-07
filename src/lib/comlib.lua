-- Library for communication between two computers
local M = {}

local ecnet = require(".\\ThirdParty\\ecnet.lua")

-- Open secure modem
function M.open(side)
    local modem = peripheral.wrap("top")
    local sModem = ecnet.wrap(modem)
    return sModem
end

-- Get current address
function M.getAddress()
    return ecnet.address
end

-- Send a response to a request
function M.sendResponse(rec, head, status, contents)
    -- Create response packet
	local p = {head = head, status = status, contents = contents}
    local reply = textutils.serialize(p)

    -- Send reply packet
    sModem.connect(rec, 3)
    sModem.send(rec, reply)
end

return M