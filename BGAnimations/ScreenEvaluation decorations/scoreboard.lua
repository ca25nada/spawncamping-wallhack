

function gradestring(tier) --to be moved
	if tier == "Grade_Tier01" then
		return 'AAAA'
	elseif tier == "Grade_Tier02" then
		return 'AAA'
	elseif tier == "Grade_Tier03" then
		return 'AA'
	elseif tier == "Grade_Tier04" then
		return 'A'
	elseif tier == "Grade_Tier05" then
		return 'B'
	elseif tier == "Grade_Tier06" then
		return 'C'
	elseif tier == "Grade_Tier07" then
		return 'D'
	elseif tier == 'Grade_Failed' then
		return 'F'
	else
		return tier
	end;
end;

local lines = getTempEvalPref("ScoreBoardMaxEntry") -- number of scores to display
local framex = SCREEN_WIDTH-capWideScale(get43size(270),270)
local framey = 65
local frameWidth = capWideScale(get43size(260),260)
local spacing = 35


local song = STATSMAN:GetCurStageStats():GetPlayedSongs()[1]

local profile
local steps
local hstable
local scoreindex

local player = GAMESTATE:GetEnabledPlayers()[1]

if GAMESTATE:IsPlayerEnabled(player) then
	profile = GetPlayerOrMachineProfile(player)
	steps = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPlayedSteps()[1]
	hstable = profile:GetHighScoreList(song,steps):GetHighScores()
	scoreindex = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPersonalHighScoreIndex()+1
end;

--Input event for mouse clicks
local function input(event)
	local scoreBoard = SCREENMAN:GetTopScreen():GetChildren().scoreBoard
	if event.DeviceInput.button == 'DeviceButton_left mouse button' then
		if event.type == "InputEventType_Release" then
			for i=0,math.min(lines,#hstable)-1 do
				if isOver(scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("mouseOver")) then
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("grade"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("grade"):GetVisible())
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("judge"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("judge"):GetVisible())
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("date"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("date"):GetVisible())
					scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("option"):visible(not scoreBoard:GetChild("scoreItem"..tostring(i)):GetChild("option"):GetVisible())
				end;
			end;
		end;
	end
return true;
end


local t = Def.ActorFrame{
	Name="scoreBoard";
	OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback(input) end
};

local function scoreitem(pn,index,scoreindex,drawindex)

	--First box always displays the 1st place score
	if drawindex == 0 then
		index = 1
	end;

	--Whether the score at index is the score that was just played.
	local equals = (index == scoreindex)

	--
	local t = Def.ActorFrame {
		Name="scoreItem"..tostring(drawindex);

		--The main quad
		Def.Quad{
			InitCommand=cmd(xy,framex,framey+(drawindex*spacing)-4;zoomto,frameWidth,30;halign,0;valign,0;diffuse,color("#333333");diffusealpha,1;diffuserightedge,color("#33333333"));
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn));
			end;
		};

		--Highlight quad for the current score
		Def.Quad{
			InitCommand=cmd(xy,framex,framey+(drawindex*spacing)-4;zoomto,frameWidth,30;halign,0;valign,0;diffuse,color("#66ccff");diffusealpha,0.2;diffuserightedge,color("#33333300"));
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn) and equals);
			end;
		};

		--Quad that will act as the bounding box for mouse rollover/click stuff.
		Def.Quad{
			Name="mouseOver";
			InitCommand=cmd(xy,framex,framey+(drawindex*spacing)-4;zoomto,frameWidth,30;halign,0;valign,0;diffuse,getMainColor(1);diffusealpha,0.2;);
			BeginCommand=function(self)
				self:visible(false);
			end;
		};

		--ClearType lamps
		Def.Quad{
			InitCommand=cmd(xy,framex,framey+(drawindex*spacing)-4;zoomto,8,30;halign,0;valign,0;diffuse,getClearTypeFromScore(pn,hstable[index],2));
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn));
			end;
		};

		--Animation(?) for ClearType lamps
		Def.Quad{
			InitCommand=cmd(xy,framex,framey+(drawindex*spacing)-4;zoomto,8,30;halign,0;valign,0;diffusealpha,0.3;diffuse,getClearTypeFromScore(pn,hstable[index],2));
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn));
				self:diffuseramp()
				self:effectoffset(0.03*(lines-index))
				self:effectcolor2(color("1,1,1,0.6"))
				self:effectcolor1(color("1,1,1,0"))
				self:effecttiming(2,1,0,0)
			end;
		};


		--rank
		LoadFont("Common normal")..{
			InitCommand=cmd(xy,framex-8,framey+12+(drawindex*spacing);zoom,0.35;);
			BeginCommand=function(self)
				if #hstable >= 1 then
					self:settext(index)
					if equals then
						self:diffuseshift()
						self:effectcolor1(color("#ffcccc"))
						self:effectcolor2(color("#3399cc"))
						self:effectperiod(0.1)
					else
						self:stopeffect()
					end;
				end;
			end;
		};

		--grade and %score
		LoadFont("Common normal")..{
			Name="grade";
			InitCommand=cmd(xy,framex+10,framey+11+(drawindex*spacing);zoom,0.35;halign,0;maxwidth,(frameWidth-15)/0.35);
			BeginCommand=function(self)
				self:settextf("%s %.2f%% (x%d)",(gradestring(hstable[index]:GetGrade())),hstable[index]:GetPercentDP()*100,hstable[index]:GetMaxCombo()); 
			end;
		};

		--mods
		LoadFont("Common normal")..{
			Name="option";
			InitCommand=cmd(xy,framex+10,framey+11+(drawindex*spacing);zoom,0.35;halign,0;maxwidth,(frameWidth-15)/0.35);
			BeginCommand=function(self)
				self:settext(hstable[index]:GetModifiers()); 
				self:visible(false)
			end;
		};

		--cleartype text
		LoadFont("Common normal")..{
			InitCommand=cmd(xy,framex+10,framey+2+(drawindex*spacing);zoom,0.35;halign,0;maxwidth,(frameWidth-15)/0.35);
			BeginCommand=function(self)
				if #hstable >= 1 and index>= 1 then
					self:settext(getClearTypeFromScore(pn,hstable[index],0))
					self:diffuse(getClearTypeFromScore(pn,hstable[index],2))
				end;
			end;
		};

		--judgment
		LoadFont("Common normal")..{
			Name="judge";
			InitCommand=cmd(xy,framex+10,framey+20+(drawindex*spacing);zoom,0.35;halign,0;maxwidth,(frameWidth-15)/0.35);
			BeginCommand=function(self)
				if #hstable >= 1 and index>= 1 then
					self:settextf("%d / %d / %d / %d / %d / %d",
						hstable[index]:GetTapNoteScore("TapNoteScore_W1"),
						hstable[index]:GetTapNoteScore("TapNoteScore_W2"),
						hstable[index]:GetTapNoteScore("TapNoteScore_W3"),
						hstable[index]:GetTapNoteScore("TapNoteScore_W4"),
						hstable[index]:GetTapNoteScore("TapNoteScore_W5"),
						hstable[index]:GetTapNoteScore("TapNoteScore_Miss"))
				end;
			end;
		};

		--date
		LoadFont("Common normal")..{
			Name="date";
			InitCommand=cmd(xy,framex+10,framey+20+(drawindex*spacing);zoom,0.35;halign,0);
			BeginCommand=function(self)
				if #hstable >= 1 and index>= 1 then
					self:settext(hstable[index]:GetDate())
				end;
				self:visible(false)
			end;
		};

	};
	return t;
end

--can't have more lines than the # of scores huehuehu
if lines > #hstable then
	lines = #hstable
end;

local drawindex = 0
local startind = 1
local finishind = lines+startind-1

-- Sets the range of indexes to display depending on your rank
if scoreindex>math.floor(#hstable-lines/2) then
	startind = #hstable-lines+1
	finishind = #hstable 
elseif scoreindex>math.floor(lines/2) then
	finishind = scoreindex + math.floor(lines/2)
	if lines%2 == 1 then
		startind = scoreindex - math.floor(lines/2)
	else
		startind = scoreindex - math.floor(lines/2)+1
	end;
end;

while drawindex<#hstable and startind<=finishind do
	t[#t+1] = scoreitem(player,startind,scoreindex,drawindex)
	startind = startind+1
	drawindex  = drawindex+1
end;

--Text that sits above the scoreboard with some info
t[#t+1] = LoadFont("Common normal")..{
	InitCommand=cmd(xy,framex,framey-15;zoom,0.35;halign,0);
	BeginCommand=function(self)
		if scoreindex ~= 0 then
			self:settextf("Rank %d/%d (Max Scores: %d)",scoreindex,(#hstable),PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer") or 0)
		else
			self:settextf("Out of rank (Max Scores: %d)",PREFSMAN:GetPreference("MaxHighScoresPerListForPlayer") or 0)
		end;
	end;
};

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
		end;
	end;

end; 
t.InitCommand=cmd(SetUpdateFunction,Update);


--[[
t[#t+1] = LoadFont("Common normal")..{
	InitCommand=cmd(xy,framex,framey+10+(spacing);zoom,1;halign,0);
	BeginCommand=function(self)
		self:settext(scoreindex)
	end;
};
--]]

return t;