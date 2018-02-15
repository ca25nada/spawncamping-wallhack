
function getCurrentUsername(pn)
	if DLMAN:IsLoggedIn() then
		return DLMAN:GetUsername()

	else

		local profile = PROFILEMAN:GetProfile(pn)


		if profile ~= nil then
			return profile:GetDisplayName()

		else
			return ""

		end

	end
end

-- replace with prefs later
local autoLogin = true
function isAutoLogin()
	if DLMAN:IsLoggedIn() or not autoLogin then
		return false
	else
		return true
	end
end

function getCurrentSSR(pn)

end
