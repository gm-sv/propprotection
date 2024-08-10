local PANEL = {}

PANEL.m_BlacklistedClasses = {
	["player"] = true,
	["viewmodel_predicted"] = true,
	["gmod_hands"] = true
}

function PANEL:Init()
	self:ParentToHUD()
	self:Hide()

	self:SetBackgroundColor(Color(0, 0, 0, 100))

	local InfoLabel = vgui.Create("DLabel", self)
	InfoLabel:SetFont("BudgetLabel")
	InfoLabel:SetTextColor(Color(255, 255, 255, 255))
	InfoLabel:SetPos(4, 4)
	self.m_InfoLabel = InfoLabel
end

function PANEL:Hide()
	-- Hide without hiding so Think still runs
	if self:GetWide() > 0 then
		self:SetSize(0, 0)
	end
end

function PANEL:GetEntityName(Entity)
	if IsValid(Entity) then
		if Entity:IsPlayer() then
			return Entity:GetName()
		else
			return Entity:GetClass()
		end
	else
		return "World"
	end
end

function PANEL:GetEntityID(Entity)
	if IsValid(Entity) then
		if Entity:IsPlayer() then
			return Entity:SteamID()
		else
			return tostring(Entity) -- bleh
		end
	else
		return "(No Data)"
	end
end

function PANEL:Think()
	local LookingEntity = LocalPlayer():GetEyeTrace().Entity
	if not IsValid(LookingEntity) then return self:Hide() end
	if self.m_BlacklistedClasses[LookingEntity:GetClass()] then return self:Hide() end

	local LookingOwner = LookingEntity:GetPropProtectionOwner()

	local OwnerName = self:GetEntityName(LookingOwner)
	local OwnerID = self:GetEntityID(LookingOwner)

	self.m_InfoLabel:SetText(OwnerName .. "\n" .. OwnerID)
	self.m_InfoLabel:SizeToContents()

	local Width, Height = self.m_InfoLabel:GetSize()

	self:SetSize(Width + 8, Height + 8)

	self:Center()
	self:SetY(self:GetY() + 50) -- Move down
end

function PANEL:PaintOver(Width, Height)
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawOutlinedRect(0, 0, Width, Height)
end

vgui.Register("gmsv_PropProtectionInfoPanel", PANEL, "DPanel")
