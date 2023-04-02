AddCSLuaFile()
AddCSLuaFile("cl_init.lua")

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName   = "Street Sign"
ENT.Spawnable   = true
ENT.Category    = "Other"
ENT.Author      = "Vaqxai"
ENT.Contact     = "https://github.com/vaqxai"
ENT.Spawnable   = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model       = "models/props/vaqxai/streetsigns/streetsign_square.mdl"

function ENT:SetupDataTables()

    self:NetworkVar("String", 0, "StreetNumber")
    self:NetworkVar("String", 1, "StreetName")
    self:NetworkVar("String", 2, "DistrictName")
    self:NetworkVar("Bool", 0, "Invalidate")

    if SERVER then
        self:SetStreetNumber("")
        self:SetStreetName("")
        self:SetDistrictName("")
    end

end

hook.Add("InitPostEntity", "VaqxaiStreetSign_InitPostEntity", function()
    for k, v in pairs(ents.FindByClass("vaqxai_street_sign")) do
        print("Creating StreetSign (" .. v:GetStreetName() .. " " .. v:GetStreetNumber() .. ")")
        v.Invalidate = true
        v:SetInvalidate(true)
    end
end)