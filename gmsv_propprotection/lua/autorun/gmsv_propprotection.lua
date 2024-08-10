require("gmsv")

IncludeShared("includes/extensions/gmsv_pp_entity.lua")

gmsv.StartModule("propprotection")
do
	if SERVER then
		-- Yay ugly
		function PlayerSpawnedEffect(Player, Model, Entity) Entity:SetPropProtectionOwner(Player) end
		function PlayerSpawnedNPC(Player, Entity) Entity:SetPropProtectionOwner(Player) end
		function PlayerSpawnedProp(Player, Model, Entity) Entity:SetPropProtectionOwner(Player) end
		function PlayerSpawnedRagdoll(Player, Model, Entity) Entity:SetPropProtectionOwner(Player) end
		function PlayerSpawnedSENT(Player, Entity) Entity:SetPropProtectionOwner(Player) end
		function PlayerSpawnedSWEP(Player, Entity) Entity:SetPropProtectionOwner(Player) end
		function PlayerSpawnedVehicle(Player, Entity) Entity:SetPropProtectionOwner(Player) end

		function OnEnabled(self)
			hook.Add("PlayerSpawnedEffect", self:GetName(), self.PlayerSpawnedEffect)
			hook.Add("PlayerSpawnedNPC", self:GetName(), self.PlayerSpawnedNPC)
			hook.Add("PlayerSpawnedProp", self:GetName(), self.PlayerSpawnedProp)
			hook.Add("PlayerSpawnedRagdoll", self:GetName(), self.PlayerSpawnedRagdoll)
			hook.Add("PlayerSpawnedSENT", self:GetName(), self.PlayerSpawnedSENT)
			hook.Add("PlayerSpawnedSWEP", self:GetName(), self.PlayerSpawnedSWEP)
			hook.Add("PlayerSpawnedVehicle", self:GetName(), self.PlayerSpawnedVehicle)
		end

		function OnDisabled(self)
			hook.Remove("PlayerSpawnedEffect", self:GetName())
			hook.Remove("PlayerSpawnedNPC", self:GetName())
			hook.Remove("PlayerSpawnedProp", self:GetName())
			hook.Remove("PlayerSpawnedRagdoll", self:GetName())
			hook.Remove("PlayerSpawnedSENT", self:GetName())
			hook.Remove("PlayerSpawnedSWEP", self:GetName())
			hook.Remove("PlayerSpawnedVehicle", self:GetName())
		end
	elseif CLIENT then
		function HUDPaint()
			local TargetEntity = LocalPlayer():GetEyeTrace().Entity
			if not IsValid(TargetEntity) then return end

			surface.SetFont("BudgetLabel")
			surface.SetTextPos(ScrW() / 2, ScrH() / 2)
			surface.SetTextColor(255, 255, 255, 255)
			surface.DrawText(tostring(TargetEntity:GetPropProtectionOwner()))
		end

		function OnEnabled(self)
			hook.Add("HUDPaint", self:GetName(), self.HUDPaint)
		end

		function OnDisabled(self)
			hook.Remove("HUDPaint", self:GetName())
		end
	end
end
gmsv.EndModule()
