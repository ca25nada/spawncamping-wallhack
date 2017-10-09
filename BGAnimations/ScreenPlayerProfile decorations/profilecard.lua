local t = Def.ActorFrame{}
local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = PROFILEMAN:GetProfile(pn)

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
	end;
}

t[#t+1] = LoadActor("expbar") .. {
	InitCommand = function(self)
		self:xy(100,30)
	end;
}


-- Player name
t[#t+1] = LoadFont("Common Large")..{
	InitCommand  = function(self)
		self:xy(100,-25)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:queuecommand('Set')
	end;
	SetCommand = function(self)
		local text = ""
		if profile ~= nil then
			text = profile:GetDisplayName()
			if text == "" then
				text = pn == PLAYER_1 and "Player 1" or "Player 2"
			end
		end
		self:settext(text)
	end;
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand  = function(self)
		self:xy(100,-5)
		self:zoom(0.3)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:settextf("Rating:",rating)
	end;
}


t[#t+1] = LoadFont("Common Normal")..{
	InitCommand  = function(self)
		self:xy(100,5)
		self:zoom(0.3)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:queuecommand('Set')
	end;
	SetCommand = function(self)
		local rating = profile:GetPlayerRating()
		if profile ~= nil then
			self:settextf("%0.2f",rating)
		end
		self:diffuse(getMSDColor(rating))
	end;
}

return t