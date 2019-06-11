local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = PROFILEMAN:GetProfile(pn)
local onlineStatus = GHETTOGAMESTATE:getOnlineStatus()

local t = Def.ActorFrame{

}

t[#t+1] = Def.Quad{
	InitCommand = function (self)
		self:halign(0)
		self:zoomto(300,100)
		self:diffuse(color(colorConfig:get_data().main.frame)):diffusealpha(0.8)
	end
}

t[#t+1] = LoadActor("avatar") .. {
	InitCommand = function(self)
		self:xy(50,0)
	end
}

t[#t+1] = LoadActor("expbar") .. {
	InitCommand = function(self)
		self:xy(100,5)
	end
}

local function toggleOnlineStatus(given)
	if DLMAN:IsLoggedIn() then
		if given ~= nil then
			GHETTOGAMESTATE:setOnlineStatus(given)
		else
			GHETTOGAMESTATE:setOnlineStatus()
		end
		onlineStatus = GHETTOGAMESTATE:getOnlineStatus()
	else
		GHETTOGAMESTATE:setOnlineStatus("Local")
		onlineStatus = "Local"
	end
end


t[#t+1] = quadButton(3)..{
	InitCommand = function (self)
		self:xy(145,30)
		self:zoomto(90,20)
		self:diffuse(color(colorConfig:get_data().main.disabled))
		if DLMAN:IsLoggedIn() then
			self:diffusealpha(0.8)
		else
			self:diffusealpha(0.2)
		end
	end,
	MouseDownCommand = function(self)
		if DLMAN:IsLoggedIn() then
			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
			toggleOnlineStatus()
			MESSAGEMAN:Broadcast("OnlineTogglePressed")
		end
	end,
	LoginMessageCommand = function(self)
		self:diffusealpha(0.8)
	end,
	LoginFailedMessageCommand = function(self)
		--self:diffusealpha(0.8)
	end,
	LogOutMessageCommand = function(self)
		self:diffusealpha(0.2)
	end
}


t[#t+1] = LoadFont("Common Bold")..{
	InitCommand  = function(self)
		self:xy(145,30)
		self:zoom(0.4)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		if not DLMAN:IsLoggedIn() then
			self:diffusealpha(0.4)
		end
		self:queuecommand('Set')
	end,
	SetCommand = function(self)
		self:settextf("%s", onlineStatus)
	end,
	LogOutMessageCommand = function(self)
		toggleOnlineStatus("Local")
		self:diffusealpha(0.4)
		self:queuecommand("Set")
	end,
	LoginMessageCommand = function(self)
		self:diffusealpha(1)
		toggleOnlineStatus("Online")
		self:queuecommand("Set")
	end,
	OnlineTogglePressedMessageCommand = function(self)
		self:queuecommand("Set")
	end
}

t[#t+1] = quadButton(3)..{
	InitCommand = function (self)
		self:xy(245,30)
		self:zoomto(90,20)

		if DLMAN:IsLoggedIn() then
			self:diffuse(color(colorConfig:get_data().main.negative)):diffusealpha(0.8)
		else
			self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
		end
	end,

	-- Login
	StartLoginCommand = function(self)
		local username = function(answer) user = answer end
		local password = function(answer) 
			pass = answer 
			DLMAN:Login(user, pass)
		end

		easyInputStringWithFunction("Password:", 255, true, password)
		easyInputStringWithFunction("Username:", 255, false, username)
	end,

	-- Save config upon successful login
	LoginMessageCommand = function(self)
		self:diffuse(color(colorConfig:get_data().main.negative)):diffusealpha(0.8)
		playerConfig:get_data(pn_to_profile_slot(pn)).Username = DLMAN:GetUsername()
		playerConfig:get_data(pn_to_profile_slot(pn)).Password = DLMAN:GetToken()
		playerConfig:set_dirty(pn_to_profile_slot(pn))
		playerConfig:save(pn_to_profile_slot(pn))
		SCREENMAN:SystemMessage("Login Successful!")
	end,

	-- Do nothing on failed login
	LoginFailedMessageCommand = function(self)
		SCREENMAN:SystemMessage("Login Failed!")
	end,

	-- delete config upon logout
	StartLogoutCommand = function(self)
		playerConfig:get_data(pn_to_profile_slot(pn)).Username = ""
		playerConfig:get_data(pn_to_profile_slot(pn)).Password = ""
		playerConfig:set_dirty(pn_to_profile_slot(pn))
		playerConfig:save(pn_to_profile_slot(pn))
		DLMAN:Logout()
	end,

	LogOutMessageCommand=function(self)
		self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
		SCREENMAN:SystemMessage("Logged Out!")
	end,

	MouseDownCommand = function(self)
		if not DLMAN:IsLoggedIn() then
			self:playcommand("StartLogin")
		else
			self:playcommand("StartLogout")
		end

		self:finishtweening()
		self:diffusealpha(1)
		self:smooth(0.3)
		self:diffusealpha(0.8)
	end
}

t[#t+1] = LoadFont("Common Bold")..{
	InitCommand  = function(self)
		self:xy(245,30)
		self:zoom(0.4)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		if DLMAN:IsLoggedIn() then
			self:settext("Logout")
		else
			self:settext("Login")
		end
	end,

	LoginMessageCommand = function(self)
		self:settext("Logout")
	end,

	LogOutMessageCommand=function(self)
		self:settext("Login")
	end,

}


-- Player name
t[#t+1] = LoadFont("Common BLarge")..{
	InitCommand  = function(self)
		self:xy(100,-25)
		self:zoom(0.35)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:queuecommand('Set')
	end,
	LoginMessageCommand = function(self) self:queuecommand('Set') end,
	LogOutMessageCommand = function(self) self:queuecommand('Set') end,

	SetCommand = function(self)
		local text = ""
		if profile ~= nil then
			text = getCurrentUsername(pn)
			if text == "" then
				text = pn == PLAYER_1 and "Player 1" or "Player 2"
			end
		end

		self:settext(text)
	end
}

return t