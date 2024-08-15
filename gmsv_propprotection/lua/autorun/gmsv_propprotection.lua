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

		function AddCleanup(Player, Type, Entity)
			Entity:SetCreator(Player)

			return ORIGINAL_FUNCTION(Player, Type, Entity)
		end

		function OnPlayerReliableStream(Player)
			local HasEntities = false
			local PlayerID = Player:SteamID()

			for _, Entity in ents.Iterator() do
				if Entity:GetCreatorID() == PlayerID then
					Entity:SetCreator(Player)

					HasEntities = true
				end
			end

			if not HasEntities then
				MsgDev("No entities to wipe for ", Player:GetName())
				return
			end

			MsgDev("Broadcasting wipe for ", Player:GetName())

			net.Start("gmsv_propprotection_sync")
				net.WriteBool(true)
				net.WriteString(Player:SteamID()) -- Can't use player because this is called before the entity exists for other clients
			net.Broadcast()
		end
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
			hook.Add("OnPlayerReliableStream", self:GetName(), self.OnPlayerReliableStream)

			gmsv.RunOnRegistered("Detours", function(Detours)
				Detours:DetourGeneric("_G[\"cleanup\"][\"Add\"]", self.AddCleanup)
			end)
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
			hook.Remove("OnPlayerReliableStream", self:GetName())

			gmsv.RunOnRegistered("Detours", function(Detours)
				Detours:RestoreGeneric("_G[\"cleanup\"][\"Add\"]")
			end)
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
