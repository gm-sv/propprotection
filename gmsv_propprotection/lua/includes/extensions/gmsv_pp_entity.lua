local ENTITY = FindMetaTable("Entity")

if CLIENT then
	local CurTime = CurTime

	AccessorFunc(ENTITY, "m_bPropProtectionSyncRequested", "OwnerSyncRequested", FORCE_BOOL)
	AccessorFunc(ENTITY, "m_flPropProtectionSyncTime", "OwnerSyncTime", FORCE_NUMBER)

	net.Receive("gmsv_propprotection_sync", function()
		local Target = net.ReadEntity()
		local Owner = net.ReadEntity()
		if not IsValid(Target) then return end

		MsgDev("Received owner of ", Target, ": ", Owner)

		Target:SetCreator(Owner)
		Target:SetOwnerSyncRequested(false)
	end)

	function ENTITY:SetCreator(Creator)
		self.m_hCreator = Creator
	end

	function ENTITY:GetCreator()
		if self.m_hCreator ~= nil then
			return self.m_hCreator
		end

		-- Retry every second
		if CurTime() - (self:GetOwnerSyncTime() or 0) > 1 then
			self:SetOwnerSyncTime(0)
			self:SetOwnerSyncRequested(false)
		end

		if not self:GetOwnerSyncRequested() then
			MsgDev("Requesting owner of ", self)

			net.Start("gmsv_propprotection_sync")
				net.WriteEntity(self)
			net.SendToServer()

			self:SetOwnerSyncTime(CurTime())
			self:SetOwnerSyncRequested(true)
		end

		return NULL
	end
elseif SERVER then
	util.AddNetworkString("gmsv_propprotection_sync")

	net.Receive("gmsv_propprotection_sync", function(_, Requester)
		if not net.TestRateLimit(Requester, "gmsv_propprotection_sync", 0.1) then -- 10 props a second
			return
		end

		local Target = net.ReadEntity()
		if not IsValid(Target) or Target:IsWorld() then return end

		MsgDev("Replicating owner of ", Target, " to '", Requester:GetName(), "'")

		net.Start("gmsv_propprotection_sync")
			net.WriteEntity(Target)
			net.WriteEntity(Target:GetCreator())
		net.Send(Requester)
	end)
end
