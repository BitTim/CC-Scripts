os.loadAPI("api/sha")

--Init Shell
term.setTextColor(colors.yellow)
print("Auth Util v1.0")

--Create db if not existing
if not fs.exists(".authDB") then
    local dbFile = fs.open(".authDB", "w")
    dbFile.write("{ }")
    dbFile.close()
end

--Import db
local dbFile = fs.open(".authDB", "r")
local db = textutils.unserialize(dbFile.readAll())
dbFile.close()

-- ================================
-- Functions
-- ================================

--Function to List user entries
local list = function(args)
    for k, v in pairs(db) do
        print(k .. ": " .. textutils.serialize(v))
    end
end

--Function to register new users
local register = function(args)
    --Check if argument 1 exists
    if args[2] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Name \n Usage: register [name] [pin] [accessLevel]")
        return
    end

    --Check if argument 1 exists
    if args[3] == nil or string.len(args[3]) ~= 6 then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid PIN. PIN has to contain 6 Digits \n Usage: register [name] [pin] [accessLevel]")
        return
    end

    --Check if argument 1 exists
    if args[4] == nil or tonumber(args[4]) == 0 then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Access level. Access level has to be more than 0 \n Usage: register [name] [pin] [accessLevel]")
        return
    end

    --Insert user into AuthDB
    db[args[2]] = {hash = sha.sha256(args[3]), access = tonumber(args[4])}
    print("Adding new user: " .. args[2] .. " -> " .. textutils.serialize(db[args[2]]))

    --Save AuthDB file
    local dbFile = fs.open(".authDB", "w")
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
    local dbFile = fs.open(".authDB", "w")
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
    elseif tokens[1] == "register" then
        register(tokens)
    elseif tokens[1] == "remove" then
        remove(tokens)
    elseif tokens[1] == "help" then
        print("help     - Shows this page")
        print("clear    - Clear screen")
        print("exit     - Exits the tool")
        print("list     - Lists all users")
        print("register - Register user")
        print("remove   - Removes user")
    else
        term.setTextColor(colors.red)
        print("Invalid Command")
    end
end