local serverID = 11
local privateKey = ".key"
local key = nil
local uuid = ""

local m = 6959

local monitor = peripheral.find("monitor")
local logFile = fs.open(".log", "w")
logFile.close()

rednet.open("top")

term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.yellow)
print("KeycardOS 1.8")

term.redirect(monitor)
term.clear()
monitor.setTextScale(0.5)
term.setBackgroundColor(colors.black)

sleep(1)

--================================--
-- Utility                        --
--================================--

log = function(str)
    logFile.writeLine("["..tostring(os.clock()).."]: "..str)
end

--================================--
-- Network and Encryption         --
--================================--

NET_keyExchange = function()
    local packet = {head = "KEY"}
    rednet.send(serverID, textutils.serialize(packet))
    
    local id, msg = rednet.receive(3)
    if msg == nil then return -1 end
    local packet = textutils.unserialize(msg)
    
    g = packet.g
    n = packet.n
    
    g = tonumber(g)
    n = tonumber(n)
    
    local keyFile = fs.open(privateKey, "r")
    local keyString = keyFile.readAll()
    keyFile.close()
            
    key = math.mod(math.pow(g, tonumber(keyString)), n)
    
    local packet = {head = "KEY_GKEY", gkey = key}    
    rednet.send(serverID, textutils.serialize(packet))
    
    local id, msg = rednet.receive(3)
    if msg == nil then return -1 end 
    local packet = textutils.unserialize(msg)
    
    key = math.mod(math.pow(tonumber(packet.gkey), tonumber(keyString)), n)
end

NET_encryptDecrypt = function(input)
    if key == nil or input == nil then return nil end
    
    local output = ""
    math.randomseed(key)
    
    for i = 1, string.len(input), 1 do
        local byte = string.byte(input, i, i)
        local rnd = math.random(0, 255)
        output = output..string.char(bit.bxor(byte, rnd))
    end
    
    return output
end

NET_hash = function(input)
    local output = 0
    
    for i = 1, #input do
        output = output + i + string.byte(input, i)
    end
    
    output = math.mod(output * (output + 3), m)
    return output
end

--================================--
-- Door Control                   --
--================================--

DOOR_open = function()
    redstone.setOutput("front", true)
    sleep(4)
    redstone.setOutput("front", false)
end

--================================--
-- UI Handling                    --
--================================--

UI_insertCard = function()
    term.clear()
    term.setCursorPos(1, 1)
    term.write("Keycard, please")
    
    local image = paintutils.loadImage(".images/keycardInsert.nfp")
    paintutils.drawImage(image, 1, 1)
    term.setBackgroundColor(colors.black)
end

UI_uuid = function()
    if fs.exists("disk/.uuid") then
        log("Found UUID")
        local uuidFile = fs.open("disk/.uuid", "r")
        uuid = uuidFile.readAll()
        uuidFile.close()
    end
end

UI_connecting = function()
    term.clear()
    term.setCursorPos(1, 1)
    term.write("Connecting...")
    
    log("Connecting to server...")
    
    local image = paintutils.loadImage(".images/connecting.nfp")
    paintutils.drawImage(image, 1, 1)
    term.setBackgroundColor(colors.black)
    
    log("Commencing handshake with server")
    local packet = {head = "OI"}
    rednet.send(serverID, textutils.serialize(packet))
    local id, msg = rednet.receive(3)
    if msg == nil then local packet = {head = "NULL"}
    else local packet = textutils.unserialize(msg) end
    log("Handshake reply: "..packet.head)
    
    log("Exchanging keys with server")
    local result = NET_keyExchange()
    if not packet.head == "HOWZIT" or result == -1 then
        term.clear()
        term.setCursorPos(1, 1)
        if msg == nil then
            term.write("Failed: Timeout")
            log("Failed to connect to server")
        else
            term.write("Failed: Error")
            log("Failed to exchange keys with server")
        end
        
        local image = paintutils.loadImage(".images/connectionFailed.nfp")
        paintutils.drawImage(image, 1, 1)
        term.setBackgroundColor(colors.black)
        
        return -1
    end

    term.clear()
    term.setCursorPos(1, 1)
    term.write("Connected!")
    
    log("Connection established")
    
    local image = paintutils.loadImage(".images/connected.nfp")
    paintutils.drawImage(image, 1, 1)
    term.setBackgroundColor(colors.black)
                            
    return nil
end

UI_drawPINField = function(pinString)
    term.clear()
    term.setCursorPos(1, 1)
    
    write(" Please enter  \n")
    write("   PIN Code    \n")
    write(" +-----------+ \n")
    
    write(" |")
    term.setBackgroundColor(colors.gray)
    write("  "..pinString.."  ")
    term.setBackgroundColor(colors.black)
    write("| \n")
    
    write(" +-----------+ \n")
    write(" | 1 | 2 | 3 | \n")
    write(" | 4 | 5 | 6 | \n")
    write(" | 7 | 8 | 9 | \n")
    
    write(" |")
    term.setBackgroundColor(colors.red)
    write(" X ")
    term.setBackgroundColor(colors.black)
    write("| 0 |")
    term.setBackgroundColor(colors.yellow)
    write(" C ")
    term.setBackgroundColor(colors.black)
    write("| \n")
    
    write(" +-----------+")    
end

UI_pleaseWait = function()
    term.clear()
    term.setCursorPos(1, 1)
    write("Please wait...")
    
    local image = paintutils.loadImage(".images/pleaseWait.nfp")
    paintutils.drawImage(image, 1, 1)
    term.setBackgroundColor(colors.black)
end

UI_accessGranted = function()
    term.clear()
    term.setCursorPos(1, 1)
    write("Access Granted")
    
    local image = paintutils.loadImage(".images/accessGranted.nfp")
    paintutils.drawImage(image, 1, 1)
    term.setBackgroundColor(colors.black)
end

UI_accessDenied = function(str)
    term.clear()
    term.setCursorPos(1, 1)
    write("Access Denied: \n")
    write(str)
    
    local image = paintutils.loadImage(".images/accessDenied.nfp")
    paintutils.drawImage(image, 1, 1)
    term.setBackgroundColor(colors.black)
end


UI_pinCode = function()
    local pin = ""
    local showPin = false

    log("Getting PIN")
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
    
    
    UI_pleaseWait()
    
    local packet = {head = "DB", uuid = uuid, hash = NET_hash(pin)}
    rednet.send(serverID, NET_encryptDecrypt(textutils.serialize(packet)))
    log("Sent login request")

    local drive = peripheral.find("drive")
    drive.ejectDisk()
    log("Ejected disk")

    local id, msg = rednet.receive(3)
    if msg == nil then
        UI_accessDenied("Timeout")
        log("Request denied: Timeout")
        return
    end
        
    local packet = textutils.unserialize(NET_encryptDecrypt(msg))
    if packet == nil then
        UI_accessDenied("Error")
        log("Request denied: Failed to receive response")
        return
    end
    
    if packet.head == "DB_DENIED" then
        UI_accessDenied(packet.error)
        log("Request denied: "..packet.error)
    elseif packet.head == "DB_GRANTED" then
        UI_accessGranted()
        DOOR_open()
        log("Request granted")
    end
end 

UI_cancelled = function()
    term.clear()
    term.setCursorPos(1, 1)
    term.write("Cancelled")
    
    local image = paintutils.loadImage(".images/accessDenied.nfp")
    paintutils.drawImage(image, 1, 1)
    term.setBackgroundColor(colors.black)
end

--================================--
-- Main Loop                      --
--================================--

while true do
    logFile = fs.open(".log", "a")

    UI_insertCard()
    local btnPressed = false

    while not fs.exists("disk") do
        if redstone.getInput("back") == true then
            if btnPressed == false then
                DOOR_open()
                btnPressed = true
            end
        elseif redstone.getInput("back") == false then
            btnPressed = false
        end
        
        sleep(0.1)
    end
    
    UI_uuid()

    repeat
    
        if UI_connecting() == -1 then break end
        
        local pinResult = UI_pinCode()
        if pinResult == 1 then
            log("Cancelled request")
            UI_cancelled()
        end
    until true
    
    local packet = {head = "END"}
    rednet.send(serverID, NET_encryptDecrypt(textutils.serialize(packet)))
    log("Sent END request")
    
    uuid = ""
    key = nil
    
    log("Reset UUID and key")
    logFile.close()
    sleep(2)
    
    os.reboot()
end
