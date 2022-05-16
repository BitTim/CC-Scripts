-- ================================
--  install.lua
-- --------------------------------
--  Script for installing Bank
--  and all of its dependencies
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

term.clear()
term.setCursorPos(1, 1)

term.setTextColor(colors.yellow)
print("Welcome to the setup of Bank v2.0!")

term.setTextColor(colors.lightGray)
print("Please enter the type of installation (server, taxServer, terminal):")

local installType = nil
while installType == nil do
	term.setTextColor(colors.white)
	local input = read()
	
	if input == "server" or input == "taxServer" or input == "terminal" then
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

print("Downloading aeslua")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/ThirdParty/aeslua", "lib/ThirdParty/aeslua")

print("Downloading bigtext")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/ThirdParty/biftext.lua", "lib/ThirdParty/bigtext.lua")

print("Downloading ecnet")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/ThirdParty/ecnet.lua", "lib/ThirdParty/ecnet.lua")

print("Downloading sha")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/ThirdParty/sha", "lib/ThirdParty/sha")

print("Downloading uuid")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/ThirdParty/uuid.lua", "lib/ThirdParty/uuid.lua")

print("Downloading comlib")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/comlib.lua", "lib/comlib.lua")

print("Downloading dnslib")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/dnslib.lua", "lib/dnslib.lua")

print("Downloading loglib")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/loglib.lua", "lib/loglib.lua")

print("Downloading timelib")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/timelib.lua", "lib/timelib.lua")

print("Downloading uilib")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/uilib.lua", "lib/uilib.lua")

if installType == "server" then
	print("Downloading server")
	shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/apps/Bank/server.lua", "startup.lua")

	print("Downloading bankutil")
	shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/apps/Bank/bankutil.lua", "bankutil.lua")

elseif installType == "taxServer" then
	print("Downloading taxServer")
	shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/apps/Bank/taxServer.lua", "startup.lua")

elseif installType == "terminal" then
	print("Downloading terminal")
	shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/apps/Bank/terminal.lua", "startup.lua")
end

term.setTextColor(colors.green)
print("Installation success! Please configure the downloaded program manually")
sleep(1)