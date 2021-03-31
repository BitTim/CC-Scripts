--Create Secure Modem
local ecnet = require("api/ecnet")
local modem = peripheral.find("modem")
local sModem = ecnet.wrap(modem)

local dns = "c762:b905:a388:cbb6:f317"

--Init Shell
local run = true

term.setTextColor(colors.yellow)
print("Client v1.0")

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
-- Error Handling
-- ================================

local sendPacketForReply = function(msg, head)
    --Connect to DNS
    term.setTextColor(colors.lightGray)
    print("Connecting to DNS...")
    local ret = sModem.connect(dns, 3)

    if not ret then
        term.setTextColor(colors.red)
        print("Failed to connect to DNS")
        return -1
    else
        term.setTextColor(colors.green)
        print("Connected!")
        term.setTextColor(colors.lightGray)
    end

    --Send packet and wait for reply
    print("Sending packet...")
    sModem.send(dns, msg)
    local s, p = sModem.receive(dns, 3)
        
    --Check for timeout
    if s == nil then
        term.setTextColor(colors.red)
        print("Error: Timeout")
        return -1
    end
    
    local reply = textutils.unserialize(p)

    --Check if reply is valid
    if reply == nil then
        return -1
    end

    --Check for invalid packet
    if reply.head ~= head then
        term.setTextColor(colors.red)
        print("Error: Received invalid packet")
        return -1
    end

    return reply
end

-- ================================
-- Functions
-- ================================

--Function to lookup DNS entries
local lookup = function(args)
    --Check if argument exists
    if args[2] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Domain | Usage: lookup [domain]")
        return
    end
    
    --Create packet for lookup
    print("Creating packet...")
    local p = {head = "LOOKUP", domain = args[2]}
    local msg = textutils.serialize(p)
    
    --Send packet and receive reply with error handling
    local ret = sendPacketForReply(msg, "LOOKUP")
    if ret == -1 then return end

    --Check if reply is valid
    if ret == -3 then
        term.setTextColor(colors.red)
        print("Error: Unknown Error")
    end

    --Check if address is nil
    if ret.address == nil then
        term.setTextColor(colors.orange)
        print("Unknown domain")
        return
    end

    --Print address
    term.setTextColour(colors.green)
    print("Address: " .. ret.address)
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
    else
        term.setTextColor(color.red)
        print("Invalid Command")
    end
end

modem.closeAll()
