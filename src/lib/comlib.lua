--- Library for communication between two computers
--- @class comlib
local M = {}

local ecnet = require(".\\ThirdParty\\ecnet.lua")

--- Open secure modem
--- @param side string Side of the modem for the connection
--- @return table Secure modem object
--- @see ecnet
function M.open(side)
    local modem = peripheral.wrap("top")
    local sModem = ecnet.wrap(modem)
    return sModem
end

return M