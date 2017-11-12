local frameWidth = 280
local frameHeight = 20
local frameX = SCREEN_WIDTH
local frameY = 10

local sortTable = {
	SortOrder_Preferred 			= 'Preferred',
	SortOrder_Group 				= 'Group',
	SortOrder_Title 				= 'Title',
	SortOrder_BPM 					= 'BPM',
	SortOrder_Popularity 			= 'Popular',
	SortOrder_TopGrades 			= 'Grade',
	SortOrder_Artist 				= 'Artist',
	SortOrder_Genre 				= 'Genre',
	SortOrder_BeginnerMeter 		= 'Beginner Meter',
	SortOrder_EasyMeter 			= 'Easy Meter',
	SortOrder_MediumMeter 			= 'Normal Meter',
	SortOrder_HardMeter 			= 'Hard Meter',
	SortOrder_ChallengeMeter 		= 'Insane Meter',
	SortOrder_DoubleEasyMeter 		= 'Double Easy Meter',
	SortOrder_DoubleMediumMeter 	= 'Double Normal Meter',
	SortOrder_DoubleHardMeter 		= 'Double Hard Meter',
	SortOrder_DoubleChallengeMeter 	= 'Double Insane Meter',
	SortOrder_ModeMenu 				= 'Mode Menu',
	SortOrder_AllCourses 			= 'All Courses',
	SortOrder_Nonstop 				= 'Nonstop',
	SortOrder_Oni 					= 'Oni',
	SortOrder_Endless 				= 'Endless',
	SortOrder_Length 				= 'Song Length',
	SortOrder_Roulette 				= 'Roulette',
	SortOrder_Recent 				= 'Recently Played'
};

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(frameX,frameY)
	end;
	OnCommand = function(self)
		self:y(-frameHeight/2)
		self:smooth(0.5)
		self:y(frameY)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(-frameHeight/2)
	end;
};


t[#t+1] = Def.Quad{
	Name="CurrentSort";
	InitCommand=function(self)
		self:halign(1):zoomto(frameWidth,frameHeight):diffuse(getMainColor('highlight'))
	end;

};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:x(5-frameWidth):halign(0):zoom(0.45):maxwidth((frameWidth-40)/0.45)
	end;
	BeginCommand=function(self)
		self:queuecommand("Set")
	end;
	SetCommand=function(self)
		self:diffuse(color(colorConfig:get_data().main.headerFrameText))
		local sort = GAMESTATE:GetSortOrder()
		local song = GAMESTATE:GetCurrentSong()
		if sort == nil then
			self:settext("Sort: ")
		elseif sort == "SortOrder_Group" and song ~= nil then
			self:settext(song:GetGroupName())
		else
			self:settext("Sort: "..sortTable[sort])
		end

	end;
	SortOrderChangedMessageCommand=function(self)
		self:queuecommand("Set")
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:queuecommand("Set")
	end;
};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:x(-5):halign(1):zoom(0.3):maxwidth(40/0.45)
	end;
	BeginCommand=function(self)
		self:queuecommand("Set")
	end;
	SetCommand=function(self)
		self:diffuse(color(colorConfig:get_data().main.headerFrameText))
		local top = SCREENMAN:GetTopScreen()
		if top:GetName() == "ScreenSelectMusic" or top:GetName() == "ScreenNetSelectMusic" then
			local wheel = top:GetChild("MusicWheel")
			self:settextf("%d/%d",wheel:GetCurrentIndex()+1,wheel:GetNumItems())
		elseif top:GetName() == "ScreenNetRoom" then
			local wheel = top:GetChild("RoomWheel")
			self:settextf("%d/%d",wheel:GetCurrentIndex()+1,wheel:GetNumItems())
		end;
	end;
	SortOrderChangedMessageCommand=function(self)
		self:queuecommand("Set")
	end;
	CurrentSongChangedMessageCommand=function(self)
		self:queuecommand("Set")
	end;
};

return t