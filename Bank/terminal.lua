os.loadAPI("api/sha")

--Create Secure Modem
local ecnet = require("api/ecnet")
local modem = peripheral.wrap("back")
local sModem = ecnet.wrap(modem)

local dns = "fe11:af7e:cb8c:4ff5:40ea"
local title = "BitBank"
local titleColor = colors.red
local tallMode = false

local serverDomain = "bitbank.bit"
local serverAddress = ""
local versionString = "v1.1"

local causeStrings = {
    NAME = "Invalid user",
    HASH = "Wrong PIN",
    BALANCE = "Balance too low",
    STOCK = "Not enough in ATM",
    RECIPIANT = "No recipiant"
}

--Init Shell
term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.yellow)
print("Terminal " .. versionString)

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

    term.setTextColor(titleColor)
    print(centerText(title, 15))

    term.setTextColor(colors.lightGray)
    print(centerText("Version " .. versionString, 15))

    term.setTextColor(colors.gray)
    print("---------------")
end

local ejectDisk = function()
    local drive = peripheral.find("drive")
    drive.ejectDisk()
end

--Authenticate
local auth = function(name, pin)
    local hash = sha.sha256(pin)

    local p = {head = "AUTH", name = name, hash = hash}
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
        sleep(2)
        return true
    end
end

--Get Balance
local balance = function(name)
    local p = {head = "BAL", name = name}
    local msg = textutils.serialize(p)

    UI_base()
    term.setCursorPos(1, 8)
    term.setTextColor(colors.red)

    local reply = sendPacketForReply(serverAddress, msg, "BAL")
    if reply == -1 then
        print(centerText("Unknown Error", 15))
        sleep(2)
    else
        term.setTextColor(colors.blue)
        print(centerText(reply.balance .. "$", 15))
        term.setTextColor(colors.white)
        term.setCursorPos(1, 7)
        print(centerText("Balance: ", 15))
        sleep(2)
    end

    term.setTextColor(colors.white)
end

--Transfer
local transfer = function(name, recipiant, amount)
    local p = {head = "TRANSFER", name = name, recipiant = recipiant, amount = amount}
    local msg = textutils.serialize(p)

    UI_base()
    term.setCursorPos(1, 8)
    term.setTextColor(colors.red)

    local reply = sendPacketForReply(serverAddress, msg, "TRANSFER")
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
        print(centerText("Success!", 15))
        sleep(2)
        return true
    end
end

--Change PIN
local changePIN = function(name, pin)
    local hash = sha.sha256(pin)

    local p = {head = "CHGPIN", name = name, hash = hash}
    local msg = textutils.serialize(p)

    UI_base()
    term.setCursorPos(1, 8)
    term.setTextColor(colors.red)

    local reply = sendPacketForReply(serverAddress, msg, "CHGPIN")
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
        print(centerText("Success!", 15))
        sleep(2)
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
    print(centerText("Insert Card", 15))
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
    print(centerText("Invalid card", 15))
end

local UI_drawNumberInput = function(x, y, outputString, title)
    if x == 1 and y == 1 then term.clear() end
    term.setCursorPos(x, y)
    title = title .. "\n"

    write("               ")
    term.setCursorPos(2 + (13 - string.len(title)) / 2, y)

    write(title)
    write("  ")
    term.setBackgroundColor(colors.gray)
    write("  "..outputString.."  ")
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
    
    write("               ")    
end

local UI_numberInput = function(dx, dy, hide, digits, title)
    local output = ""
    local showInput = hide

    while true do
        local outputString = ""
        for i = 1, string.len(output), 1 do outputString = outputString..(not showInput and string.sub(output, i, i) or "*") end
        for i = 1, digits - string.len(output) do outputString = outputString.."_" end
        if digits % 2 == 0 then outputString = string.sub(outputString, 1, digits / 2).." "..string.sub(outputString, digits / 2 + 1, 6) end
        
        UI_drawNumberInput(dx, dy, outputString, title)

        e, side, x, y = os.pullEvent("monitor_touch")
        
        dx = dx - 1
        dy = dy - 3
        
        if     (x >= 3  + dx and x <= 13 + dx) and y == 4 + dy then showInput = not showInput
        elseif (x >= 3  + dx and x <= 5  + dx) and y == 6 + dy then output = output.."1"
        elseif (x >= 7  + dx and x <= 9  + dx) and y == 6 + dy then output = output.."2"
        elseif (x >= 11 + dx and x <= 13 + dx) and y == 6 + dy then output = output.."3"
        elseif (x >= 3  + dx and x <= 5  + dx) and y == 7 + dy then output = output.."4"
        elseif (x >= 7  + dx and x <= 9  + dx) and y == 7 + dy then output = output.."5"
        elseif (x >= 11 + dx and x <= 13 + dx) and y == 7 + dy then output = output.."6"
        elseif (x >= 3  + dx and x <= 5  + dx) and y == 8 + dy then output = output.."7"
        elseif (x >= 7  + dx and x <= 9  + dx) and y == 8 + dy then output = output.."8"
        elseif (x >= 11 + dx and x <= 13 + dx) and y == 8 + dy then output = output.."9"
        elseif (x >= 3  + dx and x <= 5  + dx) and y == 9 + dy then return 1
        elseif (x >= 7  + dx and x <= 9  + dx) and y == 9 + dy then output = output.."0"
        elseif (x >= 11 + dx and x <= 13 + dx) and y == 9 + dy then output = string.sub(output, 1, string.len(output) - 1)
        end
        
        dy = dy + 3
        dx = dx + 1
        
        if string.len(output) == digits then break end
    end

    return output
end

local UI_cancelled = function()
    UI_base()

    term.setCursorPos(1, 8)
    term.setTextColor(colors.red)

    term.write(centerText("Cancelled", 15))
    sleep(2)
end

local UI_drawActions = function(x, y, name)
    term.clear()
    term.setCursorPos(x, y)
    
    term.setTextColor(titleColor)
    term.write(centerText(name, 15))
    term.setTextColor(colors.white)
    
    term.setCursorPos(x + 1, y + 2)
    
    term.setBackgroundColor(colors.gray)
    term.write(centerText(" Balance    ", 15))
    term.setBackgroundColor(colors.black)
    
    term.setCursorPos(x + 1, y + 4)
    
    term.setBackgroundColor(colors.gray)
    term.write(centerText(" Transfer   ", 15))
    term.setBackgroundColor(colors.black)
    
    term.setCursorPos(x + 1, y + 6)
    
    term.setBackgroundColor(colors.gray)
    term.write(centerText(" Change PIN ", 15))
    term.setBackgroundColor(colors.black)
    
    term.setCursorPos(x + 1, y + 8)
    
    term.setBackgroundColor(colors.red)
    term.write(centerText(" Quit       ", 15))
    term.setBackgroundColor(colors.black)
end

local UI_actions = function(dx, dy, name)
    while true do
        UI_drawActions(dx, dy, name)
        e, side, x, y = os.pullEvent("monitor_touch")
        
        if x >= 2 + dx and x <= 14 + dx then
            if y == 2 + dy then return "balance" end
            if y == 4 + dy then return "transfer" end
            if y == 6 + dy then return "changePIN" end
            if y == 8 + dy then return "quit" end
        end
    end
end

local UI_transfer = function(name)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    term.write(centerText("Transfer" ,15))
    term.setTextColor(colors.white)

    local recipiant = UI_numberInput(1, 3, false, 6, "Recipiant")
    if recipiant == 1 then
        UI_cancelled()
        return -1
    end

    local amount = UI_numberInput(1, 3, false, 6, "Amount")
    if amount == 1 then
        UI_cancelled()
        return -1
    end

    transfer(name, recipiant, amount)
end

local UI_changePIN = function(name)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    term.write(centerText("Change PIN" ,15))
    term.setTextColor(colors.white)

    local newPIN = UI_numberInput(1, 3, true, 6, "New PIN")
    if newPIN == 1 then
        UI_cancelled()
        return -1
    end

    changePIN(name, newPIN)
end

local UI_quit = function()
    UI_base()

    term.setCursorPos(1, 8)
    term.setTextColor(colors.blue)

    term.write(centerText("Goodbye!", 15))
    sleep(2)
end

-- ================================
-- Main Loop
-- ================================

--Main Loop
while true do
    local run = lookupServer()
    local yOff = 2

    if tallMode then
        yOff = 11
    end

    while run do
        UI_insertCard()

        --Wait, if no disk is inserted
        while not fs.exists("disk") do
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
            
            --Authenticate user
            
            term.clear()
            term.setCursorPos(1, 1)
            term.setTextColor(colors.red)
            term.write(centerText("Enter PIN" ,15))
            term.setTextColor(colors.white)

            local pin = UI_numberInput(1, 3, true, 6, "PIN")

            if pin == 1 then
                ejectDisk()
                break
            end

            if auth(name, pin) == false then
                ejectDisk()
                break
            end
            
            --Ask for actions
            local quit = false
            while not quit do
                local action = UI_actions(1, 1, name)
                
                if action == "balance" then
                    balance(name)
                elseif action == "transfer" then
                    UI_transfer(name)
                elseif action == "changePIN" then
                    UI_changePIN(name)
                elseif action == "quit" then
                    break
                end
            end
            
            --Return Card
            ejectDisk()
            UI_quit()
        until true

        sleep(0.1)
    end
    
term.setTextColor(colors.red)
term.write("Could not connect to server, retrying")
term.setTextColor(colors.white)

sleep(2)
end

modem.closeAll()
