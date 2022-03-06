local doorConnection = "back"
local mon = peripheral.find("monitor")
local scale = 0.5
local versionString = "v1.0"

local btnTitle = "Open"
local btn = {x = 2, y = 7, w = 13, h = 3}

local title = "Utility Room"
local titleColor = colors.yellow

local btnColor = colors.gray
local btnClickedColor = colors.lime
local btnTextColor = colors.white
local btnClickedTextColor = colors.white

local doorOpenDuration = 4

term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.yellow)
term.write("ButtonOS 1.8")
term.setTextColor(colors.white)

mon.setTextScale(scale)
term.redirect(mon)
term.clear()

function door(state)
    redstone.setOutput(doorConnection, state)
end

function centerText(str, len)
    local centeredStr = ""
    local offset = (len - string.len(str)) / 2
    for i = 1, offset do
        centeredStr = centeredStr .. " "
    end
    
    centeredStr = centeredStr .. str
    return centeredStr
end

function UI_Base()
    term.clear()
    term.setCursorPos(1, 2)
    
    term.setTextColor(colors.lightGray)
    print(centerText("BitSecure", 15))
    print(centerText("Button " .. versionString, 15))
    print("")
    
    term.setTextColor(titleColor)
    print(centerText(title, 15))
    
    term.setTextColor(colors.gray)
    print(string.rep("-", 15))
end

function UI_drawButton(x, y, w, h, text, clicked)
    if clicked then
        term.setTextColor(btnClickedTextColor)
        term.setBackgroundColor(btnClickedColor)
    else
        term.setTextColor(btnTextColor)
        term.setBackgroundColor(btnColor)
    end
    
    for i = 1, h do
        term.setCursorPos(x, y + i - 1)
    
        if i == math.ceil(h / 2) then
            term.write(" " .. text .. string.rep(" ", w - string.len(text) - 1))
        else
            term.write(string.rep(" ", w))    
        end
    end
    
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end

while true do
    UI_Base()
    UI_drawButton(btn.x, btn.y, btn.w, btn.h, btnTitle, false)
    
    local e, side, x, y = os.pullEvent("monitor_touch")
    if x >= btn.x and x < btn.x + btn.w and y >= btn.y and y < btn.y + btn.h then
        UI_drawButton(btn.x, btn.y, btn.w, btn.h, btnTitle, true)
        door(true)
        
        sleep(doorOpenDuration)
        door(false)
    end
    
    sleep(0.1)
end