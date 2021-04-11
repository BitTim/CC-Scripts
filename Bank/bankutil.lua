os.loadAPI("api/sha")
os.loadAPI("api/aeslua")

--Init Shell
term.setTextColor(colors.yellow)
print("Bank Util v1.0")

--Create BankDB if not existing
if not fs.exists(".bankDB") then
    log("Init", "Creating BankDB")
    local bdbFile = fs.open(".bankDB", "w")
    dbFile.write("{ }")
    dbFile.close()
end

--Import BankDB
log("Init", "Importing BankDB")
local dbFile = fs.open(".bankDB", "r")
local db = textutils.unserialize(bdbFile.readAll())
dbFile.close()

--Import Encryption Key
log("Init", "Importing encryption key")
local keyFile = fs.open(".key", "r")
local key = textutils.unserialize(keyFile.readAll())
keyFile.close()

-- ================================
-- Functions
-- ================================

--Function to List user entries
local list = function(args)
    for k, v in pairs(db) do
        print(k .. ": " .. textutils.serialize(v))
    end
end

--Function to get balance
local balance = function(args)
    --Check if argument 1 exists
    if args[2] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Name \n Usage: balance [name]")
        return
    end

    --Print balance
    print("Balance of " .. args[2] .. ": " .. textutils.serialize(aeslua.decrypt(key, db[args[2]].bal)))
end

--Function to register new users
local register = function(args)
    --Check if argument 1 exists
    if args[2] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Name \n Usage: register [name] [pin] [id]")
        return
    end

    --Check if argument 2 exists
    if args[3] == nil or string.len(args[3]) ~= 6 then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid PIN. PIN has to contain 6 Digits \n Usage: register [name] [pin] [id]")
        return
    end

    --Check if argument 3 exists
    if args[3] == nil or string.len(args[4]) ~= 6 then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid ID. ID has to contain 6 Digits \n Usage: register [name] [pin] [id]")
        return
    end

    --Insert user into AuthDB
    db[args[2]] = {hash = sha.sha256(args[3]), id = args[4], bal = 0, transfers = {}}
    print("Adding new user: " .. args[2] .. " -> " .. textutils.serialize(db[args[2]]))

    --Save AuthDB file
    local dbFile = fs.open(".bankDB", "w")
    dbFile.write(textutils.serialize(db))
    dbFile.close()
end

--Function to remove users
local remove = function(args)
    --Check if argument 1 exists
    if args[2] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Name | Usage: remove [name]")
        return
    end

    --Check if user exists
    if db[args[2]] == nil then
        term.setTextColor(colors.orange)
        print("User " .. args[2] .. " does not exist")
        return
    end

    --Remove user from AuthDB
    db[args[2]] = nil
    print("Removed user: " .. args[2])

    --Save AuthDB file
    local dbFile = fs.open(".bankDB", "w")
    dbFile.write(textutils.serialize(db))
    dbFile.close()
end

local add = function(args)
    --Check if argument 1 exists
    if args[2] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Name \n Usage: add [name] [amount]")
        return
    end

    --Check if argument 2 exists
    if args[3] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Amount \n Usage: add [name] [amount]")
        return
    end

    local bal = tonumber(aeslua.decrypt(key, db[args[2]].bal))
    bal += amount
    if bal < 0 then bal = 0 end

    db[args[2]].bal = tostring(aeslua.encrypt(key, bal))

    --Save AuthDB file
    local dbFile = fs.open(".bankDB", "w")
    dbFile.write(textutils.serialize(db))
    dbFile.close()
end

local take = function(args)
    --Check if argument 1 exists
    if args[2] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Name \n Usage: take [name] [amount]")
        return
    end

    --Check if argument 2 exists
    if args[3] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Amount \n Usage: take [name] [amount]")
        return
    end

    local bal = tonumber(aeslua.decrypt(key, db[args[2]].bal))
    bal -= amount
    if bal < 0 then bal = 0 end

    db[args[2]].bal = tostring(aeslua.encrypt(key, bal))

    --Save AuthDB file
    local dbFile = fs.open(".bankDB", "w")
    dbFile.write(textutils.serialize(db))
    dbFile.close()
end

-- ================================
-- Main Loop
-- ================================

while true do
    --Get Input
    term.setTextColor(colors.yellow)
    term.write("Auth> ")
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
    elseif tokens[1] == "clear" then
        shell.run("clear")
    elseif tokens[1] == "list" then
        list(tokens)
    elseif tokens[1] == "list" then
        balance(tokens)
    elseif tokens[1] == "register" then
        register(tokens)
    elseif tokens[1] == "remove" then
        remove(tokens)
    elseif tokens[1] == "add" then
        add(tokens)
    elseif tokens[1] == "take" then
        take(tokens)
    elseif tokens[1] == "help" then
        print("help     - Shows this page")
        print("clear    - Clear screen")
        print("exit     - Exits the tool")
        print("list     - Lists all users")
        print("balance  - Shows user balance")
        print("register - Register user")
        print("remove   - Removes user")
        print("add      - Adds money to user")
        print("take     - Takes money from user")
    else
        term.setTextColor(colors.red)
        print("Invalid Command")
    end
end