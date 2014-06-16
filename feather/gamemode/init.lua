NOTIFY_GENERIC = 0
NOTIFY_ERROR = 1
NOTIFY_UNDO = 2
NOTIFY_HINT = 3
NOTIFY_CLEANUP = 4

include("shared.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

resource.AddWorkshop(199758059)

game.ConsoleCommand("sbox_godmode 0\n")
game.ConsoleCommand("sbox_playershurtplayers 1\n")
game.ConsoleCommand("sbox_maxdynamite 0\n")
game.ConsoleCommand("sbox_maxballoons 0\n")
game.ConsoleCommand("sbox_maxthrusters 1\n")
game.ConsoleCommand("sbox_maxhoverballs 1\n")
game.ConsoleCommand("sbox_maxlamps 1\n")
game.ConsoleCommand("sbox_maxlights 1\n")