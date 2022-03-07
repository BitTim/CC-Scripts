local modem = peripheral.wrap("left")

local blacklist = {"minecraft:cobblestone", "chisel:basalt2", "minecraft:bedrock", "minecraft:chest", "minecraft:air", "minecraft:stone", "minecraft:dirt", "minecraft:gravel", "minecraft:clay", "dragonicevolution:draconium_ore"}

local branchLen = 0
local numBranches = 0

local cBranch = 0
local cBranchLen = 0

local state = "idle"
local pos = vector.new(0, 0, 0)
success, block = turtle.inspect()
local blockFront = block["name"]

x, y, z = gps.locate(2)
if x then pos = vector.new(x, y, z) end

local statusRoutine = coroutine.create(function()
    while true do
        local package = {state, blockFront, cBranch, cBranchLen, turtle.getFuelLevel()}
        modem.transmit(1, 1, package)
        coroutine.yield()
    end
end)

term.clear()
term.setCursorPos(1, 1)
print("Branch Mine\n")
print("The turtle needs a few chests in its first slot, to build a chest to dump all of the mined goods\n")

state = "input"
write("Branch length: ")
branchLen = tonumber(read())
write("Number of branches: ")
numBranches = tonumber(read())

coroutine.resume(statusRoutine)

inArray = function(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false    
end

inspect = function()
    success, block = turtle.inspectUp()
    if success then
        blockFront = block["name"]
        if not inArray(blacklist, blockFront) then
            state = "found"
            coroutine.resume(statusRoutine)
            turtle.digUp()
            turtle.up()

            state = "search"
            coroutine.resume(statusRoutine)
            inspect()
            turtle.down()
        end
    end

    success, block = turtle.inspectDown()
    if success then
        blockFront = block["name"]
        if not inArray(blacklist, blockFront) then
            state = "found"
            coroutine.resume(statusRoutine)
            turtle.digDown()
            turtle.down()

            state = "search"
            coroutine.resume(statusRoutine)
            inspect()
            turtle.up()
        end
    end

    for i = 0, 3, 1 do
        turtle.turnRight()
        success, block = turtle.inspect()
        if success then
            blockFront = block["name"]
            if not inArray(blacklist, blockFront) then
                state = "found"
                coroutine.resume(statusRoutine)
                turtle.dig()
                turtle.forward()

                state = "search"
                coroutine.resume(statusRoutine)
                inspect()
                turtle.back()
            end
        end
    end
end

for i = 0, numBranches - 1, 1 do
    cBranch = i

    state = "starting"
    coroutine.resume(statusRoutine)

    turtle.turnRight()
    turtle.turnRight()

    while turtle.detect() do
        turtle.dig()
        sleep(0.1)
    end  

    turtle.forward()

    while turtle.detectUp() do
            turtle.digUp()
            sleep(0.1)
        end

    turtle.back()

    turtle.select(1)
    turtle.place()

    turtle.turnRight()
    turtle.turnRight()

    for j = 0, branchLen, 1 do
        cBranchLen = j

        state = "clearing path"
        coroutine.resume(statusRoutine)
        while turtle.detect() do
            turtle.dig()
            sleep(0.1)
        end     

        state = "move"
        coroutine.resume(statusRoutine)
        turtle.forward()

        state = "clearing top"
        coroutine.resume(statusRoutine)
        while turtle.detectUp() do
            turtle.digUp()
            sleep(0.1)
        end
    
        state = "search"
        coroutine.resume(statusRoutine)
        inspect()
        turtle.up()
        inspect()
        turtle.down()
    end

    state = "returning"
    coroutine.resume(statusRoutine)
    turtle.turnRight()
    turtle.turnRight()

    for j = 0, branchLen, 1 do
        turtle.forward()
    end

    for j = 2, 16, 1 do
        turtle.select(j)
        turtle.drop(turtle.getItemCount(j))
    end

    turtle.turnRight()

    state = "Making new branch"
    coroutine.resume(statusRoutine)
    for j = 0, 2, 1 do
        while turtle.detect() do
            turtle.dig()
            sleep(0.1)
        end  
        
        turtle.forward()

        while turtle.detectUp() do
            turtle.digUp()
            sleep(0.1)
        end
    end

    turtle.turnLeft()

    while turtle.detect() do
        turtle.dig()
        sleep(0.1)
    end  

    turtle.forward()

    while turtle.detectUp() do
            turtle.digUp()
            sleep(0.1)
        end

    turtle.back()

    turtle.select(1)
    turtle.place()

    turtle.turnRight()
    turtle.turnRight()
end
