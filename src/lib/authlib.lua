-- ================================
--  authlib.lua
-- --------------------------------
--  Library for authentication
--  objects and function
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

-- --------------------------------
--  Dependencies
-- --------------------------------

local uuidLib = require("/lib/ThirdParty/uuid")








-- --------------------------------
--  Classes
-- --------------------------------

local M = {}

-- Class for 2fa data

M.AuthCode = {}
M.AuthCode.__index = M.AuthCode

-- Create new 2fa data handler
function M.AuthCode:new(digits, resetTime)
    -- Init Randomizers
    math.randomseed(os.time() * 1000)
    _ = math.random(); _ = math.random(); _ = math.random()
    
    if digits == nil or digits < 1 then digits = 6 end
    if resetTime == nil or resetTime < 1 then resetTime = 30 end

    local authCode = {}
    setmetatable(authCode, M.AuthCode)

    authCode.digits = digits
    authCode.resetTime = resetTime

    authCode.aCode = nil
    authCode.pCode = nil
    authCode.time = 0

    authCode.timer = nil
    return authCode
end

-- Generate new active code
function M.AuthCode:gen()
    -- Assign previous code
    self.pCode = self.aCode

    -- Generate digits
    local newCode = ""
    for i = 1, self.digits do
        newCode = newCode .. tostring(math.random(0, 9))
    end

    -- Assign new active code and reset timer
    self.aCode = newCode
    self.time = self.resetTime
end

-- Update status of active code
function M.AuthCode:update()
    self.time = self.time - 1
    if self.time < 1 then self:gen() end

    self.timer = os.startTimer(1)
end



-- Class for ptan data
M.PTAN = {}
M.PTAN.__index = M.PTAN

function M.PTAN:new(hash, users, uses)
    if uses == nil then uses = 1 end

    local ptan = {}
    setmetatable(ptan, M.PTAN)

    ptan.hash = hash
    ptan.users = users
    ptan.uses = uses

    return ptan
end

function M.PTAN:use()
    if self.uses > 0 then
        self.uses = self.uses - 1
        return true
    end

    return false
end




-- Class for user data
M.User = {}
M.User.__index = M.User

function M.User:new(uuid, eName, pinHash, authCodeDigits, authCodeResetTime)
    if uuid == nil then uuid = uuidLib.Generate() end

    local user = {}
    setmetatable(user,  M.User)

    user.uuid = uuid
    user.eName = eName
    user.pinHash = pinHash
    user.authCode = M.AuthCode:new(authCodeDigits, authCodeResetTime)

    user.authCode:update()
    return user
end




-- Class for terminal data
M.Terminal = {}
M.Terminal.__index = M.Terminal

function M.Terminal:new(uuid, name, users, factors, ptanList)
    if uuid == nil then uuid = uuidLib.Generate() end
    if factors == nil then factors = 0xa end
    if ptanList == nil then ptanList = {} end

    local term = {}
    setmetatable(term, M.Terminal)

    term.uuid = uuid
    term.name = name
    term.users = users
    term.factors = factors

    term.ptanList = ptanList

    return term
end

return M