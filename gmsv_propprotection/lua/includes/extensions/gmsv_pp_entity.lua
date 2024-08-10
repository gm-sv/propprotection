local ENTITY = FindMetaTable("Entity")

function ENTITY:SetPropProtectionOwner(Owner)
	if not IsValid(Owner) then
		self.m_hOwner = NULL
	else
		self.m_hOwner = Owner
	end
end

if CLIENT then
	AccessorFunc(ENTITY, "m_bPropProtectionSyncRequested", "OwnerSyncRequested", FORCE_BOOL)

	net.Receive("gmsv_propprotection_sync", function()
		local Target = net.ReadEntity()
		local Owner = net.ReadEntity()
		if not IsValid(Target) then return end

		Target:SetPropProtectionOwner(Owner)
		Target:SetOwnerSyncRequested(false)
	end)

	function ENTITY:GetPropProtectionOwner()
		if self.m_hOwner ~= nil then
			return self.m_hOwner
		end

		if not self:GetOwnerSyncRequested() then
			MsgDev("Requesting owner of ", self)

			net.Start("gmsv_propprotection_sync")
				net.WriteEntity(self)
			net.SendToServer()

			self:SetOwnerSyncRequested(true)
		end

		return NULL
	end
elseif SERVER then
	util.AddNetworkString("gmsv_propprotection_sync")

	net.Receive("gmsv_propprotection_sync", function(_, Requester)
		local Target = net.ReadEntity()
		if not IsValid(Target) or Target:IsWorld() then return end

		MsgDev("Replicating owner of ", Target)

		net.Start("gmsv_propprotection_sync")
			net.WriteEntity(Target)
			net.WriteEntity(Target:GetPropProtectionOwner())
		net.Send(Requester)
	end)

	function ENTITY:GetPropProtectionOwner()
		return self.m_hOwner
	end
end
