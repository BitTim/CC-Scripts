local serverID = 11
local privateKey = ".key"
local key = nil

local monitor = peripheral.wrap("left")
rednet.open("top")

term.redirect(monitor)
monitor.setTextScale(0.5)
term.setBackgroundColor(colors.black)

--================================--
-- UI Drawing                     --
--================================--

UI_insertCard = function()
    term.clear()
    term.setCursorPos(1, 1)
    term.write("Keycard, please")
    
    local image = paintutils.loadImage(".images/keycardInsert.nfp")
    paintutils.drawImage(image, 1, 1)
    term.setBackgroundColor(colors.black)
    
    local e, side = os.pullEvent("disk")
end

UI_connecting = function()
    term.clear()
    term.setCursorPos(1, 1)
    term.write("Connecting...")
    
    local image = paintutils.loadImage(".images/connecting.nfp")
    paintutils.drawImage(image, 1, 1)
    term.setBackgroundColor(colors.black)
    
    rednet.send(serverID, "OI")
    local id, msg = rednet.receive(10)
    
    if msg == nil or NET_keyExchange == -1 then
        term.clear()
        term.setCursorPos(1, 1)
        term.write("Failed: Timeout")
        
        local image = paintutils.loadImage(".images/connectionFailed.nfp")
        paintutils.drawImage(image, 1, 1)
        term.setBackgroundColor(colors.black)
        
        return -1
    end
    
    return nil
end

UI_pinCode = function()
    
end

--================================--
-- Network and Encryption         --
--================================--

NET_keyExchange = function()
    rednet.send(serverID, "KEY")
    local id, g = rednet.receive(10)
    local id, n = rednet.receive(10)
    
    local keyFile = fs.open(privateKey, "r")
    key = math.mod(math.pow(g, tonumber(keyFile.readAll())), n)
    
    rednet.send(serverID, key)
    local id, msg = rednet.receive(10)
    
    key = math.mod(math.pow(g, tonumber(msg)), n)
end

NET_encryptDecrypt = function(input)
    local output = ""
    math.randomseed(key)
    
    for i = 1, string.len(input), 1 do
        local byte = string.byte(input, i, i)
        local rnd = math.random(0, 255)
        output..tostring(bit.bxor(byte, rnd)            
    end
    
    return output
end

NET_hash = function()

end

--================================--
-- Main Loop                      --
--================================--

while true do
    repeat
        UI_insertCard()
    
        if UI_connecting() == -1 then
            sleep(3)
            break
        end            
    until true
    
    disk.eject("drive_0")
end
