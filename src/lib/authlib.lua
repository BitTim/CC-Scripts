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
    if digits == nil or digits < 1 then digits = 6 end
    if resetTime == nil or resetTime < 1 then resetTime = 30 end

    local authCode = {}
    setmetatable(authCode, AuthCode)

    authCode.digits = digits
    authCode.resetTime = resetTime

    authCode.aCode = nil
    authCode.pCode = nil
    authCode.time = nil

    authCode.timer = nil
    return authCode
end

-- Generate new active code
function M.AuthCode:gen()
    -- Init Randomizers
    math.randomseed(os.time())
    _ = math.random(); _ = math.random();_ = math.random()

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
function M.AuthCode.update()
    self.time = self.time - 1
    if self.time < 1 then self:gen() end

    self.timer = os.startTimer(1)
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

    return user
end




-- Class for terminal data
M.Terminal = {}
M.Terminal.__index = M.Terminal

function M.Terminal:new(uuid, name, users)
    if uuid == nil then uuid = uuidLib.Generate() end

    local term = {}
    setmetatable(term, M.Terminal)

    term.uuid = uuid
    term.name = name
    term.users = users

    return term
end

return M