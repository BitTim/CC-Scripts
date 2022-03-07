os.loadAPI("api/sha")

--Create Secure Modem
local ecnet = require("api/ecnet")
local modem = peripheral.find("modem")
local sModem = ecnet.wrap(modem)

local dns = "fe11:af7e:cb8c:4ff5:40ea"
local doorConnection = "back"
local btnConnection = "back"
local title = "Keycard"
local titleColor = colors.white
local access = "all"

local serverDomain = "server.key"
local serverAddress = ""
local versionString = "v2.2"

local causeStrings = {
    NAME = "Invalid user",
    HASH = "Wrong PIN",
    ACCESS = "No Access"
}

--Init Shell
term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.yellow)
print("Keycard Reader " .. versionString)

local mon = peripheral.find("monitor")
mon.setTextScale(0.5)
term.redirect(mon)
term.clear()

-- ================================
-- Error Handling
-- ================================

local sendPacketForReply = function(address, msg, head)
    --Connect to Server
    local ret = sModem.connect(address, 3)
    if not ret then return -1 end

    --Send packet and wait for reply
    sModem.send(address, msg)
    local s, p = sModem.receive(address, 3)
        
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

-- ================================
-- Functions
-- ================================

--Connect to DNS
local lookupServer = function()
    --Look up server
    local p = {head = "LOOKUP", domain = serverDomain}
    local msg = textutils.serialize(p)

    local reply = sendPacketForReply(dns, msg, "LOOKUP")
    if reply == -1 then return false end

    serverAddress = reply.address
    return true
end

--Centers Text
local centerText = function(str, len)
    local centeredStr = ""
    local offset = (len - string.len(str)) / 2
    for i = 1, offset, 1 do
        centeredStr = centeredStr .. " "
    end

    centeredStr  = centeredStr .. str
    return centeredStr
end

--Base UI
local UI_base = function()
    term.clear()
    term.setCursorPos(1, 3)

    term.setTextColor(colors.lightGray)
    print(centerText("BitSecure", 15))
    print(centerText("Keycard " .. versionString, 15))
    print("")

    term.setTextColor(titleColor)
    print(centerText(title, 15))

    term.setTextColor(colors.gray)
    print("---------------")
end

--Control door
local door = function(state)
    redstone.setOutput(doorConnection, state)
end

local ejectDisk = function()
    local drive = peripheral.find("drive")
    drive.ejectDisk()
end

--Authenticate
local auth = function(name, pin, access)
    local hash = sha.sha256(pin)

    local p = {head = "AUTH", name = name, hash = hash, access = access}
    local msg = textutils.serialize(p)

    UI_base()
    term.setCursorPos(1, 8)
    term.setTextColor(colors.red)

    local reply = sendPacketForReply(serverAddress, msg, "AUTH")
    if reply == -1 then
        print(centerText("Unknown Error", 15))
        sleep(2)
        return
    end

    if reply.state == "FAIL" then
        print(centerText(causeStrings[reply.cause], 15))
        sleep(2)
        return false
    elseif reply.state == "SUCCESS" then
        term.setTextColor(colors.green)
        print(centerText("Welcome!", 15))
        return true
    end
end

-- ================================
-- UI
-- ================================

local UI_insertCard = function()
    UI_base()
    term.setCursorPos(1, 8)
    term.setTextColor(colors.white)
    print("  Insert Card  ")
end

local UI_checkDisk = function()
    if fs.exists("disk/.auth") then
        local authFile = fs.open("disk/.auth", "r")
        local name = authFile.readAll()
        authFile.close()

        return name
    end

    return nil
end

local UI_invalidDisk = function()
    UI_base()
    term.setCursorPos(1, 8)
    term.setTextColor(colors.red)
    print(centerText("Invalid Keycard", 15))
end

local UI_drawPINField = function(pinString)
    term.clear()
    term.setCursorPos(1, 1)
    
    write(" Please enter  \n")
    write("   PIN Code    \n")
    write("               \n")
    
    write("  ")
    term.setBackgroundColor(colors.gray)
    write("  "..pinString.."  ")
    term.setBackgroundColor(colors.black)
    write("  \n")
    
    write("               \n")
    write("   1   2   3   \n")
    write("   4   5   6   \n")
    write("   7   8   9   \n")
    
    write("  ")
    term.setBackgroundColor(colors.red)
    write(" X ")
    term.setBackgroundColor(colors.black)
    write("  0  ")
    term.setBackgroundColor(colors.yellow)
    write(" C ")
    term.setBackgroundColor(colors.black)
    write("  \n") 
end

local UI_pinCode = function(name)
    local pin = ""
    local showPin = false

    while true do
        local pinString = ""
        for i = 1, string.len(pin), 1 do pinString = pinString..(showPin and string.sub(pin, i, i) or "*") end
        for i = 1, 6 - string.len(pin) do pinString = pinString.."_" end
        pinString = string.sub(pinString, 1, 3).." "..string.sub(pinString, 4, 6)
        
        UI_drawPINField(pinString)

        e, side, x, y = os.pullEvent("monitor_touch")
        
        if     (x >= 3  and x <= 13) and y == 4 then showPin = not showPin
        elseif (x >= 3  and x <= 5 ) and y == 6 then pin = pin.."1"
        elseif (x >= 7  and x <= 9 ) and y == 6 then pin = pin.."2"
        elseif (x >= 11 and x <= 13) and y == 6 then pin = pin.."3"
        elseif (x >= 3  and x <= 5 ) and y == 7 then pin = pin.."4"
        elseif (x >= 7  and x <= 9 ) and y == 7 then pin = pin.."5"
        elseif (x >= 11 and x <= 13) and y == 7 then pin = pin.."6"
        elseif (x >= 3  and x <= 5 ) and y == 8 then pin = pin.."7"
        elseif (x >= 7  and x <= 9 ) and y == 8 then pin = pin.."8"
        elseif (x >= 11 and x <= 13) and y == 8 then pin = pin.."9"
        elseif (x >= 3  and x <= 5 ) and y == 9 then return 1
        elseif (x >= 7  and x <= 9 ) and y == 9 then pin = pin.."0"
        elseif (x >= 11 and x <= 13) and y == 9 then pin = string.sub(pin, 1, string.len(pin) - 1)
        end
        
        if string.len(pin) == 6 then break end
    end

    local authResult = auth(name, pin, access)
    ejectDisk()

    if authResult then
        door(true)
        sleep(4)
        door(false)
    end
end

-- ================================
-- Main Loop
-- ================================

--Main Loop
while true do
    local run = lookupServer()

    while run do
        UI_insertCard()

        --Listen for redstone, if no disk is inserted
        while not fs.exists("disk") do
            if redstone.getInput(btnConnection) == true then
                door(true) 
                sleep(4)
            end

            if redstone.getInput(btnConnection) == false then door(false) end
            sleep(0.1)
        end

        repeat
            local name = UI_checkDisk()
            if name == nil then
                UI_invalidDisk()
                ejectDisk()

                sleep(2)
                break
            end
        
            local pinResult = UI_pinCode(name)
            if pinResult == 1 then
                ejectDisk()
            end
        until true

        sleep(0.1)
    end
    
    term.setTextColor(colors.red)
    term.write("Could not connect to server, retrying")
    term.setTextColor(colors.white)
    
    sleep(2)
end

modem.closeAll()
