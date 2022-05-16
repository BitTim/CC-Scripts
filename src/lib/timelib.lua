-- ================================
--  timelib.lua
-- --------------------------------
--  A library for various time
--  actions like formatting the
--  current date and time.
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

local M = {}

M.timezone = ""

function M.init(timezone)
	M.timezone = timezone
end




M.DateTime = {}
M.DateTime.__index = M.DateTime

function M.DateTime:new(day, month, year, hour, minute, second, millisecond, dayofweek, dst)
	local dt = {}
	setmetatable(dt, M.DateTime)

	if day == nil and month == nil and year == nil and hour == nil and minute == nil and second == nil and millisecond == nil and dayofweek == nil and dst == nil then
		dt:now()
	else
		dt.day = day
		dt.month = month
		dt.year = year
		dt.hour = hour
		dt.minute = minute
		dt.second = second
		dt.millisecond = millisecond
		dt.dayofweek = dayofweek
		dt.dst = dst
	end

	return dt
end

function M.DateTime:now()
	local httpHandle = http.get("https://www.timeapi.io/api/Time/current/zone?timeZone=" .. M.timezone)
	local now = textutils.unserialiseJSON(httpHandle.readAll())
	httpHandle.close()

	self.day = now.day
	self.month = now.month
	self.year = now.year
	self.hour = now.hour
	self.minute = now.minute
	self.second = now.seconds
	self.millisecond = now.milliSeconds
	self.dayofweek = now.dayOfWeek
	self.dst = now.dstActive
end

function M.DateTime:formatTimeEU(includeSeconds)
	includeSeconds = includeSeconds or false
	local str = ""

	str = str .. string.format("%02d", self.hour)
	str = str .. ":" .. string.format("%02d", self.minute)

	if includeSeconds then
		str = str .. ":" .. string.format("%02d", self.second)
	end

	return str
end

function M.DateTime:formatDateEU()
	local str = ""

	str = str .. string.format("%02d", self.day)
	str = str .. "." .. string.format("%02d", self.month)
	str = str .. "." .. string.format("%04d", self.year)

	return str
end

function M.DateTime:formatDateTimeEU(includeSeconds)
	includeSeconds = includeSeconds or false
	local str = ""

	str = str .. self:formatDateEU() .. " "
	str = str .. self:formatTimeEU(includeSeconds)

	return str
end

return M