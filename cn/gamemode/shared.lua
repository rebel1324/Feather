DeriveGamemode("sandbox")

cn = cn or {}
cn.util = {}

if (CLIENT) then cn.gui = cn.gui or {} end

include("sh_util.lua")

if (SERVER) then AddCSLuaFile("sh_util.lua") end

GM.Name = "Chessnut's Base"
GM.Author = "Chessnut"

cn.util.includeFolder("libs")