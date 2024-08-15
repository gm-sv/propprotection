local ENTITY = FindMetaTable("Entity")

AccessorFunc(ENTITY, "m_strCreatorID", "CreatorID", FORCE_STRING)

if CLIENT then
	local CurTime = CurTime

	AccessorFunc(ENTITY, "m_bPropProtectionSyncRequested", "OwnerSyncRequested", FORCE_BOOL)
	AccessorFunc(ENTITY, "m_flPropProtectionSyncTime", "OwnerSyncTime", FORCE_NUMBER)

	net.Receive("gmsv_propprotection_sync", function()
		local Wipe = net.ReadBool()

		if Wipe then
			local OwnerID = net.ReadString()

			MsgDev("Received owner wipe for ", OwnerID)

			for _, Entity in ents.Iterator() do
				if Entity:GetCreatorID() == OwnerID then
					Entity:SetCreator(nil)
					Entity:SetCreatorID(nil)
					Entity:SetOwnerSyncRequested(false)
					-- self:SetOwnerSyncTime(0)
				end
			end

			return
		end

		local Target = net.ReadEntity()
		local Owner = net.ReadEntity()
		local ValidOwner = net.ReadBool()

		if not IsValid(Target) then return end

		MsgDev("Received owner of ", Target, ": ", Owner)

		if ValidOwner then
			Target:SetCreator(Owner)
		else
			Target:SetCreator(nil)
		end

		Target:SetOwnerSyncRequested(false)
	end)

	function ENTITY:SetCreator(Creator)
		self.m_hCreator = Creator

		if IsValid(Creator) and Creator:IsPlayer() then
			self:SetCreatorID(Creator:SteamID())
		else
			self:SetCreatorID(nil)
		end
	end

	function ENTITY:GetCreator()
		if self.m_hCreator ~= nil then
			return self.m_hCreator
		end

		-- Retry every second
		-- if CurTime() - (self:GetOwnerSyncTime() or 0) > 1 then
		-- 	self:SetOwnerSyncTime(0)
		-- 	self:SetOwnerSyncRequested(false)
		-- end

		if not self:GetOwnerSyncRequested() then
			MsgDev("Requesting owner of ", self)

			net.Start("gmsv_propprotection_sync")
				net.WriteEntity(self)
			net.SendToServer()

			-- self:SetOwnerSyncTime(CurTime())
			self:SetOwnerSyncRequested(true)
		end

		return nil
	end
elseif SERVER then
	ENTITY.SetCreatorInternal = ENTITY.SetCreatorInternal or ENTITY.SetCreator

	function ENTITY:SetCreator(Creator)
		if IsValid(Creator) and Creator:IsPlayer() then
			self:SetCreatorID(Creator:SteamID())
		else
			self:SetCreatorID(nil)
		end

		self:SetCreatorInternal(Creator)
	end

	util.AddNetworkString("gmsv_propprotection_sync")

	net.Receive("gmsv_propprotection_sync", function(_, Requester)
		if not net.TestRateLimit(Requester, "gmsv_propprotection_sync", 0.1) then -- 10 props a second
			return
		end

		local Target = net.ReadEntity()
		if not IsValid(Target) or Target:IsWorld() then return end

		local Creator = Target:GetCreator()

		MsgDev("Replicating owner of ", Target, " to '", Requester:GetName(), "'")

		net.Start("gmsv_propprotection_sync")
			net.WriteBool(false)
			net.WriteEntity(Target)
			net.WriteEntity(Creator)
			net.WriteBool(IsValid(Creator))
		net.Send(Requester)
	end)
end
