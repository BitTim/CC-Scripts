-- ================================
--  install.lua
-- --------------------------------
--  Script for installing Essentia
--  and all of its dependencies
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

term.clear()
term.setCursorPos(1, 1)

term.setTextColor(colors.yellow)
print("Welcome to the setup of Essentia v1.0!")

term.setTextColor(colors.lightGray)
print("Please enter the type of installation (display, server or controller):")

local installType = nil
while installType == nil do
	term.setTextColor(colors.white)
	local input = read()
	
	if input == "display" or input == "server" or input == "controller" then
		installType = input
		break
	end
	
	term.setTextColor(colors.red)
	print("Invalid install type")
end

term.setTextColor(colors.lightGray)
print("Creating folder for libraries")
shell.run("mkdir", "lib")

print("Creating folder for third party libraries")
shell.run("mkdir", "lib/ThridParty")

print("Downloading ecnet")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/ThirdParty/ecnet.lua", "lib/ThirdParty/ecnet.lua")

print("Downloading comlib")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/comlib.lua", "lib/comlib.lua")

print("Downloading dnslib")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/dnslib.lua", "lib/dnslib.lua")

print("Downloading loglib")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/loglib.lua", "lib/loglib.lua")

print("Downloading uilib")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/uilib.lua", "lib/uilib.lua")

if installType == "display" then
	print("Downloading display")
	shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/apps/Essentia/display.lua", "startup.lua")
elseif installType == "server" then
	print("Downloading server")
	shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/apps/Essentia/server.lua", "startup.lua")
elseif installType == "controller" then
	print("Downloading controller")
	shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/apps/Essentia/controller.lua", "startup.lua")
end

term.setTextColor(colors.green)
print("Installation success! Please configure the downloaded program manually")
sleep(5)