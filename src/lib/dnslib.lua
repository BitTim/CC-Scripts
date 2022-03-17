-- ================================
--  dnslib.lua
-- --------------------------------
--  Library for various DNS
--  operations
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local comlib = require("/lib/comlib")








-- --------------------------------
--  Functions
-- --------------------------------

local M = {}

M.dnsAddress = ""

-- Initialize DNSLib
function M.init()
    -- Open DNS address file
    local dnsAddressFile = fs.open("/.dnsAddress", "r")
    if dnsAddressFile == nil then return -1 end

    -- Read DNS address from file
    local dnsAddress = dnsAddressFile.readLine()
    dnsAddressFile.close()

    -- Check if read address is not empty
    if dnsAddress == nil or dnsAddress == nil then
        return -1
    end

    -- Set DNS address
    M.dnsAddress = dnsAddress
    return true
end

-- Lookup domain
function M.lookup(domain)
    local response = comlib.sendRequest(M.dnsAddress, "LOOKUP", {domain = domain})
    if response == -1 then return -1 end

    -- TODO: Implement check for not found domain

    return response.contents[address]
end

-- Lookup multiple domains
function M.lookupMultiple(domains)
    local addresses = {}

    -- Iterate over all domains
    for i = 1, #domains do
        local address = M.lookup(domains[i])
        if address == -1 then return -1 end
        addresses[i] = address
    end

    return addresses
end

return M