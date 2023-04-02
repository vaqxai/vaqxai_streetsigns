include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

util.AddNetworkString("VaqxaiStreetSign_Edit")
util.AddNetworkString("VaqxaiStreetSign_OpenMenu")

local function netSendSuccess(ply)
    net.Start("VaqxaiStreetSign_Edit")
    net.WriteBool(true)
    net.Send(ply)
end

local function netSendFailure(ply)
    net.Start("VaqxaiStreetSign_Edit")
    net.WriteBool(false)
    net.Send(ply)
end

net.Receive("VaqxaiStreetSign_Edit", function(ln, ply)
    if not ply:IsAdmin() then netSendFailure(ply) return end

    local ent = net.ReadEntity()
    if not ent:IsValid() then netSendFailure(ply) return end

    local street = net.ReadString()
    local number = net.ReadString()
    local district = net.ReadString()

    ent:SetStreetName(street)
    ent:SetStreetNumber(number)
    ent:SetDistrictName(district)
    print("Street sign edited by " .. ply:Nick() .. " (" .. ply:SteamID() .. ")")
end)

function ENT:Use(ply)
    if not ply:IsPlayer() && ply:IsAdmin() then return end

    -- Prevent spamming
    if !self.NextUse then self.NextUse = 0 end
    if CurTime() < self.NextUse then return end
    self.NextUse = CurTime() + 1

    net.Start("VaqxaiStreetSign_OpenMenu")
    net.WriteEntity(self)
    net.Send(ply)
end