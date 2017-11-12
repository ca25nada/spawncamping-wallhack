--Displays the current BPM taking rate/haste mods into account.
local bareBone = isBareBone()

local function getPlayerBPM(pn)
	local ts = SCREENMAN:GetTopScreen()
	if ts:GetScreenType() == 'ScreenType_Gameplay' then
		return ts:GetTrueBPS(pn) * 60
	end
	return 0
end

local t = Def.ActorFrame {}

if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
	t[#t+1] = LoadFont("Common Normal") .. {
	    Name="Player1BPM";
	    BeginCommand = function(self)
	        self:xy(5,25):halign(0):zoom(0.4)
	        if not bareBone then
	        	self:shadowlength(1)
	        end
		end
	};
end

if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
	t[#t+1] = LoadFont("Common Normal") .. {
	    Name="Player2BPM";
	    BeginCommand = function(self)
	        self:xy(SCREEN_WIDTH-5,25):halign(1):zoom(0.4)
	        if not bareBone then
	        	self:shadowlength(1)
	        end
		end
	};
end

-- Updates bpm text.
local function Update(self)
	t.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end	

	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		self:GetChild("Player1BPM"):settextf("%0.2f BPM",getPlayerBPM(PLAYER_1))
	end

	if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		self:GetChild("Player2BPM"):settextf("%0.2f BPM",getPlayerBPM(PLAYER_2))
	end
end

if true then
	t.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end	
end

return t