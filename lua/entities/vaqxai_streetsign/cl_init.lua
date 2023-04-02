include("shared.lua")

DEFINE_BASECLASS("base_anim")

local font_name = "Arial"

surface.CreateFont("vStreetSigns_Number", {
    font = font_name,
    size = 255,
    weight = 500
})

surface.CreateFont("vStreetSigns_Street", {
    font = font_name,
    size = 45,
    weight = 200
})

surface.CreateFont("vStreetSigns_District", {
    font = font_name,
    size = 45,
    weight = 500
})

function ENT:Draw()
    self:DrawModel()

    if self.Invalidate or self:GetInvalidate() then
        self.Invalidate = false
        self:SetInvalidate(false)
        self:UpdateRenderTarget()
    end
end

function ENT:UpdateRenderTarget()
    if !self.IMat then
        self.IMat = Material(self:GetMaterials()[1])
    end
    local mat = self.IMat
    local w, h = mat:Width(), mat:Height()

    if self.LiveTexture then
        render.PushRenderTarget(self.LiveTexture)
        render.SuppressEngineLighting(true)
        render.OverrideAlphaWriteEnable(true, false)
        render.Clear(0, 0, 0, 255, true, true)

        cam.Start2D()
            surface.SetMaterial(self.ProtoMat)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawTexturedRect(0, 0, w, h)

            surface.SetFont("Default")

            surface.SetTextColor(255, 255, 255, 255)
            surface.SetFont("vStreetSigns_Number")
            local number = self:GetStreetNumber():sub(1,4)
            local tw, th = surface.GetTextSize(number)
            surface.SetTextPos(w * 0.35 - tw * 0.5, h * 0.41)
            surface.DrawText(number)

            surface.SetFont("vStreetSigns_Street")
            local street = self:GetStreetName():sub(1, 19)
            tw, th = surface.GetTextSize(street)
            surface.SetTextPos(w * 0.37 - tw * 0.5, h * 0.34)
            surface.DrawText(street)

            surface.SetFont("vStreetSigns_District")
            local district = self:GetDistrictName():sub(1, 19)
            tw, th = surface.GetTextSize(district)
            surface.SetTextPos(w * 0.37 - tw * 0.5, h * 0.89)
            surface.DrawText(district)

            surface.SetFont("Default")

        cam.End2D()

        render.PopRenderTarget()
        render.OverrideAlphaWriteEnable(false, true)
        render.SuppressEngineLighting(false)
    end
end

function ENT:Initialize()
    BaseClass.Initialize(self)

    local texid = self:EntIndex()
    if !self.IMat then
        self.IMat = Material(self:GetMaterials()[1])
    end

    local mat = self.IMat
    self.ProtoMat = CreateMaterial("Live_ProtoMat_" .. texid, "UnlitGeneric", {
        ["$basetexture"] = mat:GetString("$basetexture_org")
    })
    local w, h = mat:Width(), mat:Height()
    local texture = GetRenderTarget("LiveTexture_" .. texid, w, h)

    self.LiveTexture = texture
    self.Invalidate = true
end

net.Receive("VaqxaiStreetSign_OpenMenu", function()

    local ent = net.ReadEntity()

    local menu = vgui.Create("DFrame")
    local w, h = 600, 400
    menu:SetSize(w, h)
    menu:Center()
    menu:SetTitle("Street Sign Editor")
    menu:MakePopup()

    local left_panel = vgui.Create("DPanel", menu)
    left_panel:Dock(LEFT)
    left_panel:SetWide(w * 0.32)
    left_panel:SetBackgroundColor(Color(105, 105, 105, 107))

    local streetfield_label = left_panel:Add("DLabel")
    streetfield_label:Dock(TOP)
    streetfield_label:DockMargin(5, 5, 5, 5)
    streetfield_label:SetText("Street Name")
    local street_field = left_panel:Add("DTextEntry")
    street_field:Dock(TOP)
    street_field:SetValue(ent:GetStreetName())
    street_field:DockMargin(5, 5, 5, 5)

    local numberfield_label = left_panel:Add("DLabel")
    numberfield_label:Dock(TOP)
    numberfield_label:DockMargin(5, 5, 5, 5)
    numberfield_label:SetText("Street Number")
    local number_field = left_panel:Add("DTextEntry")
    number_field:Dock(TOP)
    number_field:SetValue(ent:GetStreetNumber())
    number_field:DockMargin(5, 5, 5, 5)

    local districtfield_label = left_panel:Add("DLabel")
    districtfield_label:Dock(TOP)
    districtfield_label:DockMargin(5, 5, 5, 5)
    districtfield_label:SetText("District Name")
    local district_field = left_panel:Add("DTextEntry")
    district_field:Dock(TOP)
    district_field:SetValue(ent:GetDistrictName())
    district_field:DockMargin(5, 5, 5, 5)

    local save_button = left_panel:Add("DButton")
    save_button:Dock(BOTTOM)
    save_button:DockMargin(5, 5, 5, 5)
    save_button:SetText("Save")

    local right_panel = vgui.Create("DPanel", menu)
    right_panel:Dock(RIGHT)
    right_panel:SetWide(w * 0.66)
    right_panel:SetBackgroundColor(Color(105, 105, 105, 107))

    local model_panel = vgui.Create("DModelPanel", right_panel)
    model_panel:Dock(FILL)
    model_panel:DockMargin(5, 5, 5, 5)

    local mp_ent = ents.CreateClientside("vaqxai_streetsign")
    mp_ent:SetStreetNumber(ent:GetStreetNumber())
    mp_ent:SetStreetName(ent:GetStreetName())
    mp_ent:SetDistrictName(ent:GetDistrictName())
    mp_ent:SetModel(ent:GetModel())
    mp_ent:Initialize()

    number_field.OnChange = function(self)
        local val = self:GetValue()
        if val:len() > 3 then
            self:SetText(val:sub(1, 3))
        end
        mp_ent:SetStreetNumber(self:GetText())
        mp_ent.Invalidate = true
    end

    street_field.OnChange = function(self)
        local val = self:GetValue()
        if val:len() > 19 then
            self:SetText(val:sub(1, 19))
        end
        mp_ent:SetStreetName(self:GetText())
        mp_ent.Invalidate = true
    end

    district_field.OnChange = function(self)
        local val = self:GetValue()
        if val:len() > 19 then
            self:SetText(val:sub(1, 19))
        end
        mp_ent:SetDistrictName(self:GetText())
        mp_ent.Invalidate = true
    end

    model_panel:SetEntity(mp_ent)
    model_panel:SetFOV(40)
    model_panel:SetAmbientLight(Color(255, 255, 255))
    model_panel:SetDirectionalLight(BOX_BOTTOM, Color(48,48,48))
    model_panel:SetDirectionalLight(BOX_BACK, Color(116,116,116))
    model_panel:SetLookAt(mp_ent:OBBCenter())
    model_panel:SetCamPos(mp_ent:OBBCenter() + Vector(-50, 15, 15))

    function model_panel:LayoutEntity(ent)
        local sine = (math.sin(CurTime()/2) + 1) / 2
        local cosine = (math.cos(CurTime()/2) + 1) / 2

        local step1 = Lerp(sine, -15, 15)
        local step2 = Lerp(cosine, -15, 15)
        model_panel:SetCamPos(mp_ent:OBBCenter() + Vector(-50, step1, step2))
    end

    save_button.DoClick = function(self)
        net.Start("VaqxaiStreetSign_Edit")
            net.WriteEntity(ent)
            net.WriteString(street_field:GetText())
            net.WriteString(number_field:GetText())
            net.WriteString(district_field:GetText())
        net.SendToServer()

        menu:Close()
    end

end)