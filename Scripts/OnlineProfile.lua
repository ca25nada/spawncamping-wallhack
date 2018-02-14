
function getCurrentUsername(pn)
	if DLMAN:IsLoggedIn() then
		return DLMAN:GetUsername()

	else
		local profile = PROFILEMAN:GetLocalProfile(pn)

		if profile ~= nil then
			return profile:GetDisplayName()

		else
			return ""

		end

	end
end

function getCurrentSSR(pn)

end