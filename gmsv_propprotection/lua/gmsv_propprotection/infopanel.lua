local PANEL = {}

PANEL.m_BlacklistedClasses = {
	["class C_BaseEntity"] = true,
	["func_brush"] = true,
	["func_reflective_glass"] = true,
	["gmod_hands"] = true,
	["player"] = true,
	["viewmodel_predicted"] = true,
	["worldspawn"] = true
}

function PANEL:Init()
	self:ParentToHUD()
	self:Hide(true)

	self:SetBackgroundColor(Color(0, 0, 0, 100))
	self:DockPadding(4, 4, 4, 4)

	local InfoLabel = vgui.Create("DLabel", self)
	InfoLabel:SetFont("BudgetLabel")
	InfoLabel:SetTextColor(Color(255, 255, 255, 255))
	self.m_InfoLabel = InfoLabel
end

function PANEL:Hide(Instant)
	if Instant then
		-- Hide without hiding so Think still runs
		if self:GetWide() > 0 then
			self:SetSize(0, 0)
		end
	else
		self:Stop()

		self:AlphaTo(0, 3, 0, function(_, self)
			self:Hide(true)
		end)
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
		return Entity == nil and "World" or "Disconnected"
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
	if FrameNumber() % 2 == 0 then return end -- Only update on odd frames

	local LookingEntity = LocalPlayer():GetEyeTrace().Entity
	if not IsValid(LookingEntity) then return self:Hide() end
	if self.m_BlacklistedClasses[LookingEntity:GetClass()] then return self:Hide() end

	self:Stop()
	self:SetAlpha(255)

	local LookingOwner = LookingEntity:GetCreator()

	local OwnerName = self:GetEntityName(LookingOwner)
	local OwnerID = self:GetEntityID(LookingOwner)

	self.m_InfoLabel:SetText(OwnerName .. "\n" .. OwnerID)
	self.m_InfoLabel:SizeToContents()

	local Width, Height = self.m_InfoLabel:GetSize()
	local Left, Top, Right, Bottom = self:GetDockPadding()

	self.m_InfoLabel:SetPos(Left, Top)
	self:SetSize(Width + (Left + Right), Height + (Top + Bottom))

	self:Center()
	self:SetY(self:GetY() + 50) -- Move down
end

function PANEL:PaintOver(Width, Height)
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawOutlinedRect(0, 0, Width, Height)
end

vgui.Register("gmsv_PropProtectionInfoPanel", PANEL, "DPanel")
