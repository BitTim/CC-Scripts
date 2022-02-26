--Create Secure Modem
local ecnet = require("api/ecnet")
local modem = peripheral.find("modem")
local sModem = ecnet.wrap(modem)

local dns = "02ed:16d0:a091:c3c5:84d6"
local server = "essentia.ds"

--Init Shell
local run = true

term.setTextColor(colors.yellow)
print("Essentia Client v1.0")

--Connect to DNS
term.setTextColor(colors.lightGray)
print("Connecting to DNS...")
run = sModem.connect(dns, 3)

--Show status message
if not run then
    term.setTextColor(colors.red)
    print("Failed to connect to DNS")
    term.setTextColor(colors.white)
else
    term.setTextColor(colors.green)
    print("Connected!")
    term.setTextColor(colors.lightGray)
end

-- ================================
-- Functions
-- ================================

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

--Function to lookup DNS entries
local lookup = function(domain)
    --Look up server
    local p = {head = "LOOKUP", domain = domain}
    local msg = textutils.serialize(p)

    local reply = sendPacketForReply(dns, msg, "LOOKUP")
    if reply == -1 then return false end

    return reply.address
end

-- ================================
-- Main Loop
-- ================================

while run do
    --Get Input
    term.setTextColor(colors.yellow)
    term.write("Client> ")
    term.setTextColor(colors.white)
    local cmd = read()
    term.setTextColor(colors.lightGray)
    
    --Tokeinze input
    local tokens = {}
    for s in string.gmatch(cmd, "([^ ]+)") do
        table.insert(tokens, s)
    end

    --Check Commands
    if tokens[1] == "exit" then
        --Close Program
        break

    elseif tokens[1] == "flow" then
        if tokens[2] and tokens[3] then
            local p = {head = "FLOW", id = tonumber(tokens[2]), amount = tonumber(tokens[3])}
            local msg = textutils.serialize(p)

            local serverAddr = lookup(server)
            if serverAddr ~= false then
                local rep = sendPacketForReply(serverAddr, msg, "FLOW", 10)
                if rep == -1 then
                    term.setTextColor(colors.red)
                    print("Failed")
                    term.setTextColor(colors.lightGray)
                elseif rep.status == "OK" then
                    term.setTextColor(colors.green)
                    print("Success!")
                    term.setTextColor(colors.lightGray)
                else
                    term.setTextColor(colors.red)
                    print("Failed")
                    term.setTextColor(colors.lightGray)
                end
            end
        end

    else
        term.setTextColor(color.red)
        print("Invalid Command")
    end
end

modem.closeAll()
