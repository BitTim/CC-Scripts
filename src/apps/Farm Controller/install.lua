-- ================================
--  install.lua
-- --------------------------------
--  Script for installing Farm
--  Controller and all of its
--  dependencies
-- --------------------------------
--  (C) Copyright 2022,
--  Tim Anhalt (BitTim)
-- ================================

term.clear()
term.setCursorPos(1, 1)

term.setTextColor(colors.yellow)
print("Welcome to the setup of Farm Controller v1.0!")

term.setTextColor(colors.lightGray)
print("Creating folder for libraries")
shell.run("mkdir", "lib")

print("Creating folder for third party libraries")
shell.run("mkdir", "lib/ThridParty")

print("Downloading bigtext")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/ThirdParty/bigtext.lua", "lib/ThirdParty/bigtext.lua")

print("Downloading uilib")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/lib/uilib.lua", "lib/uilib.lua")

print("Downloading controller")
shell.run("wget", "https://raw.githubusercontent.com/BitTim/CC-Scripts/master/src/apps/Farm Controller/controller.lua", "startup.lua")

term.setTextColor(colors.green)
print("Installation success! Please configure the downloaded program manually")
sleep(5)