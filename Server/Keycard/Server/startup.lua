local instances = {}
local g = 2
local n = 13

local privateKey = ".key"
local keyList = {}

local dbFile = fs.open(".db", "r")
local db = textutils.unserialize(dbFile.readAll())
dbFile.close()

local monitor = peripheral.wrap("top")
rednet.open("back")

term.clear()
term.setCursorPos(1, 1)
term.setTextColor(colors.yellow)
print("ServerOS 1.8")
term.setTextColor(colors.white)

term.redirect(monitor)
monitor.setTextScale(0.5)
term.clear()
term.setCursorPos(1, 1)
term.setBackgroundColor(colors.black)

--================================--
-- Utility                        --
--================================--

log = function(text)
    print("["..tostring(os.clock()).."] "..tostring(text))
end

has = function(tbl, val)
    local f = false
    for i = 1, #tbl do
        if type(tbl[i]) == "table" then
            f = has(tbl[i], val)
            if f then break end
        elseif tbl[i] == val then
            return true
        end
    end
    return f
end

--================================--
-- Network and Encryption         --
--================================--

NET_keyExchangePart1 = function(client)
    local key = ""
    
    log("Socket "..client..": Sending g and n: ("..tostring(g)..", "..tostring(n)..")")
    local packet = {head = "KEY_GN", g = g, n = n}
    log("Socket "..client..": Sent packet with head: KEY_GN")
    rednet.send(client, textutils.serialize(packet))

    local keyFile = fs.open(privateKey, "r")
    local keyString = keyFile.readAll()
    keyFile.close()
    
    key = math.mod(math.pow(g, tonumber(keyString)), n)
    keyList[client] = key
end

NET_keyExchangePart2 = function(client, msg)
    local key = keyList[client]
    local packet = {head = "KEY_GKEY", gkey = key}
    rednet.send(client, textutils.serialize(packet))
    log("Socket "..client..": Sent packet with head: KEY_GKEY")

    local keyFile = fs.open(privateKey, "r")
    local keyString= keyFile.readAll()
    keyFile.close()
        
    key = math.mod(math.pow(tonumber(msg), tonumber(keyString)), n)
    keyList[client] = key
end

NET_encryptDecrypt = function(client, input)
    local output = ""
    if keyList[client] == nil then return -1 end
    math.randomseed(keyList[client])
    
    for i = 1, string.len(input), 1 do
        local byte = string.byte(input, i, i)
        local rnd = math.random(0, 255)
        output = output..string.char(bit.bxor(byte, rnd))
    end
    
    return output
end

--================================--
-- Server                         --
--================================--

instance = function(client, packet)
    while true do
        if packet.head == "OI" then
            local packet = {head = "HOWZIT"}
            rednet.send(client, textutils.serialize(packet))
            log("Socket "..client..": Handshake success")
        end
    
        log("Socket "..client..": Waiting for request")
        id, packet = coroutine.yield()

        log("Socket "..client..": Continuing...")
        if packet.head == "KEY" then
            NET_keyExchangePart1(client)
            log("Socket "..client..": Generated public secret: "..tostring(keyList[client]))
            log("Socket "..client..": Waiting for other public secret")
        elseif packet.head == "KEY_GKEY" then
            log("Socket "..client..": Received public secret: "..tostring(packet.gkey))
            NET_keyExchangePart2(client, packet.gkey)
            log("Socket "..client..": Key exchange success, key: "..tostring(keyList[client]))
        elseif packet.head == "END" then
            log("Socket "..client..": Finished transmission")
            os.reboot()
        elseif packet.head == "DB" then
            log("Socket "..client..": Received login request")
            log("Socket "..client..": Searching in Database for UUID: "..packet.uuid)
            
            local entry = nil
            for i = 1, #db, 1 do
                if db[i].uuid == packet.uuid then
                    log("Socket "..client..": Found UUID")
                    entry = db[i]
                    break
                end
            end
            
            repeat
                if entry == nil then
                    log("Socket "..client..": Could not find UUID, denying request")
                    local packet = {head = "DB_DENIED", error = "UUID not found"}
                    rednet.send(client, NET_encryptDecrypt(client, textutils.serialize(packet)))
                    log("Socket "..client..": Sent packet with head: DB_DENIED")
                    break
                end
            
                log("Socket "..client..": Checking PIN Hash: "..packet.hash)
                log("Socket "..client..": Hashes to check: (DB: "..entry.hash..", CLIENT: "..packet.hash..")")

                local result = (tonumber(entry.hash) == tonumber(packet.hash))
            
                if not result then
                    log("Socket "..client..": PIN Hashes dont match, denying request")
                    local packet = {head = "DB_DENIED", error = "Wrong PIN"}
                    rednet.send(client, NET_encryptDecrypt(client, textutils.serialize(packet)))
                    log("Socket "..client..": Sent packet with head: DB_DENIED")
                    break
                end
                
                log("Socket "..client..": PIN Hash verfied, checking if user has access to area")
                if not has(entry.access, client) then
                    log("Socket "..client..": User has no acces to this area, denying request")
                    local packet = {head = "DB_DENIED", error = "No access ro area"}
                    rednet.send(client, NET_encryptDecrypt(client, textutils.serialize(packet)))
                    log("Socket "..client..": Sent packet with head: DB_DENIED")
                    break
                end
                
                log("Socket "..client..": All parameters verified, granting request")
                local packet = {head = "DB_GRANTED"}
                local msg = textutils.serialize(packet)
                msg = NET_encryptDecrypt(client, msg)
                rednet.send(client, msg)
                log("Socket "..client..": Sent packet with head: DB_GRANTED")
            until true
            
            log("Socket "..client..": Cancelled further verification")    
        end
    end
    
    return
end

--================================--
-- Main Loop                      --
--================================--

log("Initialized")
while true do
    log("Receiving...")
    
    local id, msg = rednet.receive()
    local packet = nil
    if msg == nil then packet = {head = "NULL"}
    else
        log("Received packet: "..msg)
        packet = textutils.unserialize(msg)
    end
    
    if packet == nil then
        log("Packet is encrypted, decrypting...")
        local decrypted = NET_encryptDecrypt(id, msg)
        if decrypted == -1 or decrypted == nil or decrypted == "nil" then
            log("Failed to decrypt packet")
            packet = {head = "NULL"}
        else
            packet = textutils.unserialize(decrypted)
            log("Decrypted packet to: "..textutils.serialize(packet))
            
            if packet == nil then packet = {head = "NULL"} end
        end
    end
    
    log("Received message: "..tostring(packet.head).." from: "..tostring(id))
                    
    if packet.head == "OI" and instances[id] == nil then
        instances[id] = nil
        instances[id] = coroutine.create(instance, id, packet)
        log("Starting socket for: "..tostring(id))
    end
    
    if packet.head == "NULL" then
        log("Received invalid packet")
    else coroutine.resume(instances[id], id, packet) end
end
