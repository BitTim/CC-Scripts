-- ================================
--  bankutil.lua
-- --------------------------------
--  Console for various
--  functions for managing
--  the bank database
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

os.loadAPI("/lib/ThirdParty/sha")
os.loadAPI("/lib/ThirdParty/aeslua")
local uuidlib = require("/lib/ThirdParty/uuid")
local loglib = require("/lib/loglib")

-- --------------------------------
--  Configurable Properties
-- --------------------------------

local diskSide = "bottom"
local cardBrandName = "Omnicard"
local totalAssets = "100000"        -- Total amount of money in circulation

-- --------------------------------
--  Constants
-- --------------------------------

local title = "Bank Util"
local version = "v2.0"
local dbFilePath = ".db"

-- --------------------------------
--  Internal Properties
-- --------------------------------

local dbFile = nil
local keyFile = nil
local db = nil
local key = nil








-- --------------------------------
--  Local functions
-- --------------------------------

local function updateDB()
    if fs.exists(dbFilePath .. ".bak") then fs.delete(dbFilePath .. ".bak") end     -- Check if Backup exists, if yes delete
    fs.move(dbFilePath, dbFilePath .. ".bak")                                       -- Create Backup
    dbFile = fs.open(dbFilePath, "w")
    dbFile.write(textutils.serialize(db))                                           -- Write current DB to file
    dbFile.close()
end

local function getUUIDfromAccountNum(accountNum)
    local uuid = nil

    for k, v in pairs(db) do
        if v.accountNum == accountNum then
            uuid = k
            break
        end
    end

    return uuid
end

local function getBalance(uuid, asNumber)
    asNumber = asNumber or true

    local bal = aeslua.decrypt(key, db[uuid].balance)
    if asNumber then bal = tonumber(bal) end
    return bal
end

local function setBalance(uuid, balance)
    db[uuid].balance = aeslua.encrypt(key, tostring(balance))
    updateDB()
end




-- Function to List user entries
local list = function(args)
    for k, v in pairs(db) do
        print(k .. ": " .. textutils.serialize(v))
    end
end




-- Function to get balance
local balance = function(args)
    -- Check if argument 1 exists
    if args[2] == nil then
        -- Show error if not
        term.setTextColor(colors.red)
        print("Invalid account number \n Usage: balance [accountNumber]")
        return
    end

	local uuid = getUUIDfromAccountNum(args[2])

    -- Print balance
    print("Balance of " .. db[uuid].name .. ": " .. getBalance(uuid, false))
end




local function history(args)
	-- Check if argument 1 exists
    if args[2] == nil then
        -- Show error if not
        term.setTextColor(colors.red)
        print("Invalid account number \n Usage: history [accountNumber]")
        return
    end

	local uuid = getUUIDfromAccountNum(args[2])

	-- Print history
	print("Transaction history of " .. db[uuid].name .. ": ")
	print(textutils.serialize(db[uuid].transactions))
end




-- Function to register new users
local register = function(args)
    -- Check if argument 1 exists
    if args[2] == nil then
        -- Show error if not
        term.setTextColor(colors.red)
        print("Invalid Name \n Usage: register [name] [pin] [accountNumber]")
        return
    end

    -- Check if argument 2 exists
    if args[3] == nil or string.len(args[3]) ~= 6 then
        -- Show error if not
        term.setTextColor(colors.red)
        print("Invalid PIN. PIN has to contain 6 Digits \n Usage: register [name] [pin] [accountNumber]")
        return
    end

    -- Check if argument 3 exists
    if args[3] == nil or string.len(args[4]) ~= 4 then
        -- Show error if not
        term.setTextColor(colors.red)
        print("Invalid account number. Account number has to contain 4 Digits \n Usage: register [name] [pin] [accountNumber]")
        return
    end

	-- Check if disk is in disk drive
	if not disk.isPresent(diskSide) then
		term.setTextColor(colors.red)
		print("No disk is present. Make sure a disk is present in the disk drive. This disk will become the " .. cardBrandName .. " of the new user")
		return
	end

	-- Create new user object
	local uuid = uuidlib.Generate()
	local cardUUID = uuidlib.Generate()

	local user = {
		name = args[2],
		hash = sha.sha256(args[3]),
		accountNum = args[4],
		balance = aeslua.encrypt(key, "0"),
		cardUUID = cardUUID,
		transactions = {}
	}

    -- Insert user into AuthDB
    db[uuid] = user
    updateDB()
    print("Added new user: " .. args[2] .. " -> " .. textutils.serialize(db[uuid]))

	-- Create bank card
	for _, file in pairs(fs.list("/disk")) do
		fs.delete("/disk/"..file)
	end

	local authFile = fs.open("/disk/.auth", "w")
	authFile.writeLine(uuid)
	authFile.writeLine(cardUUID)
	authFile.close()

	disk.setLabel(diskSide, user.name .. "'s " .. cardBrandName)
end




-- Function to remove users
local remove = function(args)
    -- Check if argument 1 exists
    if args[2] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid account number | Usage: remove [accountNumber]")
        return
    end

    --Check if user exists
    if db[args[2]] == nil then
        term.setTextColor(colors.orange)
        print("Account " .. args[2] .. " does not exist")
        return
    end

    --Remove user from AuthDB
    db[getUUIDfromAccountNum(args[2])] = nil
    print("Removed account: " .. args[2])

    updateDB()
end




local function changePIN(args)
	-- Check if argument 1 exists
    if args[2] == nil then
        -- Show error if not
        term.setTextColor(colors.red)
        print("Invalid account number \n Usage: changePIN [accountNumber] [pin]")
        return
    end

	-- Check if argument 2 exists
    if args[3] == nil or string.len(args[3]) ~= 6 then
        -- Show error if not
        term.setTextColor(colors.red)
        print("Invalid PIN. PIN has to contain 6 Digits \n Usage: changePIN [accountNumber] [pin]")
        return
    end

	-- Change PIN for user
	local uuid = getUUIDfromAccountNum(agrs[2])
	db[uuid].hash = sha.sha256(args[3])
	updateDB()

	print("Changed PIN for account: " .. args[2])
end




local add = function(args)
    --Check if argument 1 exists
    if args[2] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid account number \n Usage: add [accountNumber] [amount]")
        return
    end

    --Check if argument 2 exists
    if args[3] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Amount \n Usage: add [accountNumber] [amount]")
        return
    end

	local uuid = getUUIDfromAccountNum(args[2])

    local bal = getBalance(uuid)
    bal = bal + tonumber(args[3])
    if bal < 0 then bal = 0 end

    setBalance(uuid, bal)
    updateDB()
end




local take = function(args)
    --Check if argument 1 exists
    if args[2] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid account number \n Usage: take [accountNumber] [amount]")
        return
    end

    --Check if argument 2 exists
    if args[3] == nil then
        --Show error if not
        term.setTextColor(colors.red)
        print("Invalid Amount \n Usage: take [account number] [amount]")
        return
    end

	local uuid = getUUIDfromAccountNum(agrs[2])

    local bal = getBalance(uuid)
    bal = bal - tonumber(args[3])
    if bal < 0 then bal = 0 end

    setBalance(uuid, bal)
	updateDB()
end








-- --------------------------------
--  Main Program
-- --------------------------------

loglib.init(title, version, 0.5, true)						-- Initialize LogLib

-- Initialize Database
if not fs.exists(dbFilePath) then
    loglib.log("Init", "Creating DB")
    dbFile = fs.open(dbFilePath, "w")
    dbFile.write("{}")
    dbFile.close()
end

-- Import Database
dbFile = fs.open(dbFilePath, "r")
db = textutils.unserialize(dbFile.readAll())
dbFile.close()

--Import Encryption Key
keyFile = fs.open(".key", "r")
key = keyFile.readAll()
keyFile.close()




-- Main Loop
while true do
    -- Get Input
    term.setTextColor(colors.yellow)
    term.write("Bank> ")
    term.setTextColor(colors.white)
    local cmd = read()
    term.setTextColor(colors.lightGray)

    -- Tokeinze input
    local tokens = {}
    for s in string.gmatch(cmd, "([^ ]+)") do
        table.insert(tokens, s)
    end

	-- Check Commands
    if tokens[1] == "exit" then
        -- Close Program
        break
    elseif tokens[1] == "clear" then
        shell.run("clear")
    elseif tokens[1] == "list" then
        list(tokens)
    elseif tokens[1] == "balance" then
        balance(tokens)
	elseif tokens[1] == "history" then
		history(tokens)
    elseif tokens[1] == "register" then
        register(tokens)
    elseif tokens[1] == "remove" then
        remove(tokens)
	elseif tokens[1] == "changePIN" then
		changePIN(tokens)
    elseif tokens[1] == "add" then
        add(tokens)
    elseif tokens[1] == "take" then
        take(tokens)
    elseif tokens[1] == "help" then
        print("help      - Shows this page")
        print("clear     - Clear screen")
        print("exit      - Exits the tool")
        print("list      - Lists all users")
        print("balance   - Shows user balance")
		print("history   - Shows transaction history of user")
        print("register  - Register user")
        print("remove    - Removes user")
		print("changePIN - Changes PIN of user")
        print("add       - Adds money to user")
        print("take      - Takes money from user")
    else
        term.setTextColor(colors.red)
        print("Invalid Command")
    end
end