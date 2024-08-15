require("gmsv")

IncludeClient("gmsv_propprotection/infopanel.lua")

IncludeShared("includes/extensions/gmsv_pp_entity.lua")

gmsv.StartModule("PropProtection")
do
	local InfoPanel -- Client only

	if SERVER then
		-- Yay ugly
		function PlayerSpawnedEffect(Player, Model, Entity) Entity:SetCreator(Player) end
		function PlayerSpawnedNPC(Player, Entity) Entity:SetCreator(Player) end
		function PlayerSpawnedProp(Player, Model, Entity) Entity:SetCreator(Player) end
		function PlayerSpawnedRagdoll(Player, Model, Entity) Entity:SetCreator(Player) end
		function PlayerSpawnedSENT(Player, Entity) Entity:SetCreator(Player) end
		function PlayerSpawnedSWEP(Player, Entity) Entity:SetCreator(Player) end
		function PlayerSpawnedVehicle(Player, Entity) Entity:SetCreator(Player) end
	end

	function PhysgunPickup(Player, Entity)
		if Entity:GetCreator() ~= Player then
			return false
		end
	end

	function CanTool(Player, Trace)
		local TargetEntity = Trace.Entity
		if not IsValid(TargetEntity) then return end

		if TargetEntity:GetCreator() ~= Player then
			return false
		end
	end

	function CanProperty(Player, _, Entity)
		if Entity:GetCreator() ~= Player then
			return false
		end
	end

	function OnEnabled(self)
		if SERVER then
			hook.Add("PlayerSpawnedEffect", self:GetName(), self.PlayerSpawnedEffect)
			hook.Add("PlayerSpawnedNPC", self:GetName(), self.PlayerSpawnedNPC)
			hook.Add("PlayerSpawnedProp", self:GetName(), self.PlayerSpawnedProp)
			hook.Add("PlayerSpawnedRagdoll", self:GetName(), self.PlayerSpawnedRagdoll)
			hook.Add("PlayerSpawnedSENT", self:GetName(), self.PlayerSpawnedSENT)
			hook.Add("PlayerSpawnedSWEP", self:GetName(), self.PlayerSpawnedSWEP)
			hook.Add("PlayerSpawnedVehicle", self:GetName(), self.PlayerSpawnedVehicle)
		elseif CLIENT then
			InfoPanel = vgui.Create("gmsv_PropProtectionInfoPanel")
		end

		hook.Add("PhysgunPickup", self:GetName(), self.PhysgunPickup)
		hook.Add("CanTool", self:GetName(), self.CanTool)
		hook.Add("CanProperty", self:GetName(), self.CanProperty)
	end

	function OnDisabled(self)
		if SERVER then
			hook.Remove("PlayerSpawnedEffect", self:GetName())
			hook.Remove("PlayerSpawnedNPC", self:GetName())
			hook.Remove("PlayerSpawnedProp", self:GetName())
			hook.Remove("PlayerSpawnedRagdoll", self:GetName())
			hook.Remove("PlayerSpawnedSENT", self:GetName())
			hook.Remove("PlayerSpawnedSWEP", self:GetName())
			hook.Remove("PlayerSpawnedVehicle", self:GetName())
		elseif CLIENT then
			if IsValid(InfoPanel) then
				InfoPanel:Remove()
			end
		end

		hook.Remove("PhysgunPickup", self:GetName())
		hook.Remove("CanTool", self:GetName())
		hook.Remove("CanProperty", self:GetName())
	end
end
gmsv.EndModule()
