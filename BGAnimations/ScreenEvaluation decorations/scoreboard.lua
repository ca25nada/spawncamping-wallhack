

local lines = math.min(8,math.min(themeConfig:get_data().eval.ScoreBoardMaxEntry,PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer"))) -- number of scores to display
local framex = SCREEN_WIDTH-capWideScale(get43size(270),270)
local framey = 150
local frameWidth = capWideScale(get43size(260),260)
local spacing = 34


local song = STATSMAN:GetCurStageStats():GetPlayedSongs()[1]

local profile
local steps
local origTable
local hsTable
local rtTable
local scoreIndex
local score

local player = GAMESTATE:GetEnabledPlayers()[1]

if GAMESTATE:IsPlayerEnabled(player) then
	profile = GetPlayerOrMachineProfile(player)
	steps = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPlayedSteps()[1]
	origTable = getScoreList(player)
	score = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetHighScore()
	rtTable = getRateTable(origTable)
	if themeConfig:get_data().global.RateSort then
		hsTable = sortScore(rtTable[getRate(score)] or {},0)
	else
		hsTable = sortScore(rtTable["All"] or {},0)
	end;
	scoreIndex = getHighScoreIndex(hsTable,score)
end;

--Input event for mouse clicks
local function input(event)
	local scoreBoard = SCREENMAN:GetTopScreen():GetChildren().scoreBoard
	if event.DeviceInput.button == 'DeviceButton_left mouse button' then
		if event.type == "InputEventType_Release" then
			for i=0,math.min(lines,#hsTable)-1 do
				if isOver(scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("mouseOver")) then
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("grade"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("grade"):GetVisible())
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("judge"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("judge"):GetVisible())
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("date"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("date"):GetVisible())
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("option"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("option"):GetVisible())
				end;
			end;
		end;
	end
return false;
end


local t = Def.ActorFrame{
	Name="scoreBoard";
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback(input) end
};

local function scoreitem(pn,index,scoreIndex,drawindex)

	--First box always displays the 1st place score
	if drawindex == 0 then
		index = 1
	end;

	--Whether the score at index is the score that was just played.
	local equals = (index == scoreIndex)

	--
	local t = Def.ActorFrame {
		Name="scoreItem"..tostring(drawindex);

		--The main quad
		Def.Quad{
			InitCommand=cmd(xy,framex,framey+(drawindex*spacing)-4;zoomto,frameWidth,30;halign,0;valign,0;diffuse,getMainColor("frame");diffusealpha,0.8);
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn));
			end;
		};

		--Highlight quad for the current score
		Def.Quad{
			InitCommand=cmd(xy,framex,framey+(drawindex*spacing)-4;zoomto,frameWidth,30;halign,0;valign,0;diffuse,getMainColor("highlight");diffusealpha,0.3);
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn) and equals);
			end;
		};

		--Quad that will act as the bounding box for mouse rollover/click stuff.
		Def.Quad{
			Name="mouseOver";
			InitCommand=cmd(xy,framex,framey+(drawindex*spacing)-4;zoomto,frameWidth,30;halign,0;valign,0;diffuse,getMainColor('highlight');diffusealpha,0.05;);
			BeginCommand=function(self)
				self:visible(false);
			end;
		};

		--ClearType lamps
		Def.Quad{
			InitCommand=cmd(xy,framex,framey+(drawindex*spacing)-4;zoomto,8,30;halign,0;valign,0;diffuse,getClearTypeFromScore(pn,hsTable[index],2));
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn));
			end;
		};

		--Animation(?) for ClearType lamps
		Def.Quad{
			InitCommand=cmd(xy,framex,framey+(drawindex*spacing)-4;zoomto,8,30;halign,0;valign,0;diffusealpha,0.3;diffuse,getClearTypeFromScore(pn,hsTable[index],2));
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn));
				self:diffuseramp()
				self:effectoffset(0.03*(lines-drawindex))
				self:effectcolor2(color("1,1,1,0.6"))
				self:effectcolor1(color("1,1,1,0"))
				self:effecttiming(2,1,0,0)
			end;
		};


		--rank
		LoadFont("Common normal")..{
			InitCommand=cmd(xy,framex-8,framey+12+(drawindex*spacing);zoom,0.35;);
			BeginCommand=function(self)
				if #hsTable >= 1 then
					self:settext(index)
					if equals then
						self:diffuseshift()
						self:effectcolor1(getMainColor("frame"))
						self:effectcolor2(color("#3399cc"))
						self:effectperiod(0.1)
					else
						self:stopeffect()
						self:diffuse(getMainColor("frame"))
					end;
				end;
			end;
		};

		--grade and %score
		LoadFont("Common normal")..{
			Name="grade";
			InitCommand=cmd(xy,framex+10,framey+11+(drawindex*spacing);zoom,0.35;halign,0;maxwidth,(frameWidth-15)/0.35);
			BeginCommand=function(self)
				local curscore = getScore(hsTable[index])
				local maxscore = getMaxScore(pn,0)
				if maxscore == 0 or maxscore == nil then
					maxscore = 1
				end;
				local pscore = (curscore/maxscore)
				self:settextf("%s %.2f%% (x%d)",(getGradeStrings(hsTable[index]:GetGrade())),math.floor((pscore)*10000)/100,hsTable[index]:GetMaxCombo()); 
				--self:settextf("%s",getRate(hsTable[index]))
			end;
		};

		--mods
		LoadFont("Common normal")..{
			Name="option";
			InitCommand=cmd(xy,framex+10,framey+11+(drawindex*spacing);zoom,0.35;halign,0;maxwidth,(frameWidth-15)/0.35);
			BeginCommand=function(self)
				self:settext(hsTable[index]:GetModifiers()); 
				self:visible(false)
			end;
		};

		--cleartype text
		LoadFont("Common normal")..{
			InitCommand=cmd(xy,framex+10,framey+2+(drawindex*spacing);zoom,0.35;halign,0;maxwidth,(frameWidth-15)/0.35);
			BeginCommand=function(self)
				if #hsTable >= 1 and index>= 1 then
					self:settext(getClearTypeFromScore(pn,hsTable[index],0))
					self:diffuse(getClearTypeFromScore(pn,hsTable[index],2))
				end;
			end;
		};

		--judgment
		LoadFont("Common normal")..{
			Name="judge";
			InitCommand=cmd(xy,framex+10,framey+20+(drawindex*spacing);zoom,0.35;halign,0;maxwidth,(frameWidth-15)/0.35);
			BeginCommand=function(self)
				if #hsTable >= 1 and index>= 1 then
					self:settextf("%d / %d / %d / %d / %d / %d",
						hsTable[index]:GetTapNoteScore("TapNoteScore_W1"),
						hsTable[index]:GetTapNoteScore("TapNoteScore_W2"),
						hsTable[index]:GetTapNoteScore("TapNoteScore_W3"),
						hsTable[index]:GetTapNoteScore("TapNoteScore_W4"),
						hsTable[index]:GetTapNoteScore("TapNoteScore_W5"),
						hsTable[index]:GetTapNoteScore("TapNoteScore_Miss"))
				end;
			end;
		};

		--date
		LoadFont("Common normal")..{
			Name="date";
			InitCommand=cmd(xy,framex+10,framey+20+(drawindex*spacing);zoom,0.35;halign,0);
			BeginCommand=function(self)
				if #hsTable >= 1 and index>= 1 then
					self:settext(hsTable[index]:GetDate())
				end;
				self:visible(false)
			end;
		};

		LoadFont("Common normal")..{
			Name="ghostData";
			InitCommand=cmd(xy,framex+frameWidth-5,framey+2+(drawindex*spacing);zoom,0.35;halign,1;maxwidth,(frameWidth-15)/0.35);
			BeginCommand=function(self)
				if ghostDataExists(pn,hsTable[index]) then
					if isGhostDataValid(pn,hsTable[index]) then
						self:settext("GD Available")
						self:diffuse(getMainColor('enabled'))
					else
						self:settext("GD Invalid")
						self:diffuse(getMainColor('negative'))
					end
				else
					self:settext("GD Unavailable")
					self:diffuse(getMainColor('disabled'))
				end;
				self:diffusealpha(0.8)
			end;
		};

	};
	return t;
end

--can't have more lines than the # of scores huehuehu
if lines > #hsTable then
	lines = #hsTable
end;

local drawindex = 0
local startind = 1
local finishind = lines+startind-1

-- Sets the range of indexes to display depending on your rank
if scoreIndex>math.floor(#hsTable-lines/2) then
	startind = #hsTable-lines+1
	finishind = #hsTable 
elseif scoreIndex>math.floor(lines/2) then
	finishind = scoreIndex + math.floor(lines/2)
	if lines%2 == 1 then
		startind = scoreIndex - math.floor(lines/2)
	else
		startind = scoreIndex - math.floor(lines/2)+1
	end;
end;

while drawindex<#hsTable and startind<=finishind do
	t[#t+1] = scoreitem(player,startind,scoreIndex,drawindex)
	startind = startind+1
	drawindex  = drawindex+1
end;

--Text that sits above the scoreboard with some info
t[#t+1] = LoadFont("Common normal")..{
	InitCommand=cmd(xy,framex,framey-15;zoom,0.35;halign,0;);
	BeginCommand=function(self)
		local text = ""
		if scoreIndex ~= 0 then
			if themeConfig:get_data().global.RateSort then
				text = string.format("Rate %s - Rank %d/%d",getRate(score),scoreIndex,(#hsTable))
			else
				text = string.format("Rank %d/%d",scoreIndex,(#hsTable))
			end
		else
			if themeConfig:get_data().global.RateSort then
				text = string.format("Rate %s - Out of rank",getRate(score))
			else
				text = "Out of rank"
			end
		end
		self:settext(text)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end;
};

t[#t+1] = LoadFont("Common normal")..{
	InitCommand=cmd(xy,framex+frameWidth,framey+drawindex*spacing;zoom,0.35;halign,1;diffusealpha,0.8);
	BeginCommand=function(self)
		self:settextf("%d/%s Scores saved",(#origTable),PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer") or 0)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end;
}

if tonumber(PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer")) ~= 3 then
	themeConfig:get_data().global.ScoreBoardNag = false
	themeConfig:set_dirty()
	themeConfig:save()
end

if themeConfig:get_data().global.ScoreBoardNag and #origTable == tonumber(PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer")) then
	t[#t+1] = LoadFont("Common normal")..{
		InitCommand=cmd(xy,framex+frameWidth/2,framey+4*spacing;zoom,0.30;valign,0;diffusealpha,0.8;maxwidth,frameWidth/0.30);
		BeginCommand=function(self)
			local text = string.format("You have reached the maximum number of saved scores for this chart."..
							" \n Lower ranked scores will be removed as you save more scores.\n\n"..
							" Please increase the values for 'Max Machine Scores' and \n'Max Player Scores'"..
							" from the Arcade Options to raise this limit.\n\n\n"..
							"This will no longer appear once the limit is set to any non-default value.\n(You may change back afterwards if you want)\n\n"..
							"The current limit is %s. (Default is 3)",PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer") or 0)
			self:settext(text)
		end;
	}
end

--Update function for showing mouse rollovers
local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
	for i=0,drawindex-1 do
		if isOver(self:GetChild("scoreItem"..tostring(i)):GetChild("mouseOver")) then
			self:GetChild("scoreItem"..tostring(i)):GetChild("mouseOver"):visible(true)
		else
			self:GetChild("scoreItem"..tostring(i)):GetChild("mouseOver"):visible(false)
			self:GetChild("scoreItem"..tostring(i)):GetChild("grade"):visible(true)
			self:GetChild("scoreItem"..tostring(i)):GetChild("judge"):visible(true)
			self:GetChild("scoreItem"..tostring(i)):GetChild("date"):visible(false)
			self:GetChild("scoreItem"..tostring(i)):GetChild("option"):visible(false)
		end
	end
end
t.InitCommand=cmd(SetUpdateFunction,Update)

return t;