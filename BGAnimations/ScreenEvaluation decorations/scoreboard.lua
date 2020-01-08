local lines = 4 -- number of scores to display
local frameWidth = capWideScale(160, 260)
local frameX = SCREEN_WIDTH-frameWidth-WideScale(get43size(40),40)/2
local frameY = 165
local spacing = 34

local song = STATSMAN:GetCurStageStats():GetPlayedSongs()[1]

local profile
local steps
local origTable
local hsTable
local rtTable
local scoreIndex
local score
local pss
local player = GAMESTATE:GetEnabledPlayers()[1]


pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
profile = GetPlayerOrMachineProfile(player)
steps = STATSMAN:GetCurStageStats():GetPlayerStageStats(player):GetPlayedSteps()[1]
hsTable = getScoreTable(player, getCurRate())
score = pss:GetHighScore()
scoreIndex = getHighScoreIndex(hsTable, score)

local curPage = 1
local maxPages = math.ceil(#hsTable/lines)

local function movePage(n)
	if n > 0 then 
		curPage = ((curPage+n-1) % maxPages + 1)
	else
		curPage = ((curPage+n+maxPages-1) % maxPages+1)
	end
	MESSAGEMAN:Broadcast("UpdatePage")
end

local function scoreboardInput(event)
	if event.type == "InputEventType_FirstPress" then
		if event.button == "MenuLeft" then
			movePage(-1)
		end

		if event.button == "MenuRight" then
			movePage(1)
		end

	end
end

local t = Def.ActorFrame{
	Name="scoreBoard",
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(scoreboardInput)
	end
}

local function scoreitem(pn,index,scoreIndex,drawindex)

	--Whether the score at index is the score that was just played.
	local equals = (index == scoreIndex)

	--
	local t = Def.ActorFrame {
		Name="scoreItem"..tostring(drawindex),
		InitCommand = function(self)
			self:diffusealpha(0)
			self:x(100)
		end,
        OnCommand = function(self)
			self:stoptweening()
			self:bouncy(0.2+index*0.05)
			self:x(0)
			if hsTable[index] == nil then
				self:diffusealpha(0)
			else
				self:diffusealpha(1)
			end
		end,
		OffCommand = function(self)
			self:stoptweening()
			self:bouncy(0.2+index*0.05)
			self:x(100)
			self:diffusealpha(0)
		end,
		ShowCommand = function(self)
			self:playcommand("Set")
			self:x(100)
			self:diffusealpha(0)
			self:finishtweening()
			self:sleep((drawindex)*0.03)
			self:easeOut(1)
			self:x(0)
			self:diffusealpha(1)
		end,
		HideCommand = function(self)
			self:stoptweening()
			self:easeOut(0.5)
			self:diffusealpha(0)
			self:x(SCREEN_WIDTH*10)
		end,
		UpdatePageMessageCommand = function(self)
			index = (curPage - 1) * lines + drawindex+1
			equals = (index == scoreIndex)
			if hsTable[index] ~= nil then
				self:playcommand("Show")
			else
				self:playcommand("Hide")
			end
		end,

		--The main quad
		Def.Quad{
			InitCommand=function(self)
				self:xy(frameX,frameY+(drawindex*spacing)-4):zoomto(frameWidth,30):halign(0):valign(0):diffuse(getMainColor("frame")):diffusealpha(0.8)
			end,
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn))
			end
		},

		--Highlight quad for the current score
		quadButton(3) .. {
			InitCommand=function(self)
				self:xy(frameX,frameY+(drawindex*spacing)-4):zoomto(frameWidth,30):halign(0):valign(0):diffuse(getMainColor("highlight")):diffusealpha(0.3)
			end,
			BeginCommand=function(self)
				self:visible(GAMESTATE:IsHumanPlayer(pn) and equals)
			end,
			SetCommand = function(self)
				self:playcommand("Begin")
			end,
			MouseDownCommand = function(self)
				self:GetParent():GetChild("grade"):visible(not self:GetParent():GetChild("grade"):GetVisible())
				self:GetParent():GetChild("judge"):visible(not self:GetParent():GetChild("judge"):GetVisible())
				self:GetParent():GetChild("date"):visible(not self:GetParent():GetChild("date"):GetVisible())
				self:GetParent():GetChild("option"):visible(not self:GetParent():GetChild("option"):GetVisible())
			end
		},

		--Quad that will act as the bounding box for mouse rollover/click stuff.
		Def.Quad{
			Name="mouseOver",
			InitCommand=function(self)
				self:xy(frameX,frameY+(drawindex*spacing)-4):zoomto(frameWidth,30):halign(0):valign(0):diffuse(getMainColor('highlight')):diffusealpha(0.05)
			end,
			BeginCommand=function(self)
				self:visible(false)
			end
		},

		--ClearType lamps
		Def.Quad{
			InitCommand=function(self)
				self:xy(frameX,frameY+(drawindex*spacing)-4):zoomto(8,30):halign(0):valign(0)
			end,
			BeginCommand=function(self)
				self:playcommand("Set")
			end,
			SetCommand = function(self)
				if hsTable[index] ~= nil then
					self:diffuse(getClearTypeColor(getClearType(pn,steps,hsTable[index])))
					self:visible(GAMESTATE:IsHumanPlayer(pn))
				end
			end
		},

		--Animation(?) for ClearType lamps
		Def.Quad{
			InitCommand=function(self)
				self:xy(frameX,frameY+(drawindex*spacing)-4):zoomto(8,30):halign(0):valign(0):diffusealpha(0.3)
			end,
			BeginCommand=function(self)
				self:playcommand("Set")
			end,
			SetCommand = function(self)
				if hsTable[index] ~= nil then
					self:diffuse(getClearTypeColor(getClearType(pn,steps,hsTable[index])))
					self:visible(GAMESTATE:IsHumanPlayer(pn))
					self:diffuseramp()
					self:effectoffset(0.03*(lines-drawindex))
					self:effectcolor2(color("1,1,1,0.6"))
					self:effectcolor1(color("1,1,1,0"))
					self:effecttiming(2,1,0,0)
				end
			end
		},


		--rank
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:xy(frameX-8,frameY+12+(drawindex*spacing)):zoom(0.35)
			end,
			BeginCommand=function(self)
				self:playcommand("Set")
			end,
			SetCommand = function(self)
				if #hsTable >= 1 then
					self:settext(index)
					if equals then
						self:diffuseshift()
						self:effectcolor1(color(colorConfig:get_data().evaluation.BackgroundText))
						self:effectcolor2(color("#3399cc"))
						self:effectperiod(0.1)
					else
						self:stopeffect()
						self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText))
					end
				end
			end
		},

		--grade and %score
		LoadFont("Common normal")..{
			Name="grade",
			InitCommand=function(self)
				self:xy(frameX+10,frameY+11+(drawindex*spacing)):zoom(0.35):halign(0):maxwidth((frameWidth-15)/0.35)
			end,
			BeginCommand=function(self)
				self:playcommand("Set")
			end,
			SetCommand = function(self)
				if hsTable[index] ~= nil then
					local pscore = hsTable[index]:GetWifeScore()
					self:diffuse(color(colorConfig:get_data().evaluation.ScoreBoardText))
					self:settextf("%s %.2f%% (x%d)",(getGradeStrings(hsTable[index]:GetWifeGrade())),math.floor((pscore)*10000)/100,hsTable[index]:GetMaxCombo()) 
				end
			end
		},

		--mods
		LoadFont("Common normal")..{
			Name="option",
			InitCommand=function(self)
				self:xy(frameX+10,frameY+11+(drawindex*spacing)):zoom(0.35):halign(0):maxwidth((frameWidth-15)/0.35)
			end,
			BeginCommand=function(self)
				self:playcommand("Set")
			end,
			SetCommand = function(self)
				if hsTable[index] ~= nil then
					self:diffuse(color(colorConfig:get_data().evaluation.ScoreBoardText))
					self:settext(hsTable[index]:GetModifiers())
					self:visible(false)
				end
			end
		},

		--cleartype text
		LoadFont("Common normal")..{
			InitCommand=function(self)
				self:xy(frameX+10,frameY+2+(drawindex*spacing)):zoom(0.35):halign(0):maxwidth((frameWidth-15)/0.35)
			end,
			BeginCommand=function(self)
				self:playcommand("Set")
			end,
			SetCommand = function(self)
				if hsTable[index] ~= nil then
					if #hsTable >= 1 and index>= 1 then
						self:settext(getClearTypeText(getClearType(pn,steps,hsTable[index])))
						self:diffuse(getClearTypeColor(getClearType(pn,steps,hsTable[index])))
					end
				end
			end
		},

		--judgment
		LoadFont("Common normal")..{
			Name="judge",
			InitCommand=function(self)
				self:xy(frameX+10,frameY+20+(drawindex*spacing)):zoom(0.35):halign(0):maxwidth((frameWidth-15)/0.35)
			end,
			BeginCommand=function(self)
				self:playcommand("Set")
			end,
			SetCommand = function(self)
				if hsTable[index] ~= nil then
					if #hsTable >= 1 and index>= 1 then
						self:settextf("%d / %d / %d / %d / %d / %d",
							hsTable[index]:GetTapNoteScore("TapNoteScore_W1"),
							hsTable[index]:GetTapNoteScore("TapNoteScore_W2"),
							hsTable[index]:GetTapNoteScore("TapNoteScore_W3"),
							hsTable[index]:GetTapNoteScore("TapNoteScore_W4"),
							hsTable[index]:GetTapNoteScore("TapNoteScore_W5"),
							hsTable[index]:GetTapNoteScore("TapNoteScore_Miss"))
					end
					self:diffuse(color(colorConfig:get_data().evaluation.ScoreBoardText))
				end
			end
		},

		--date
		LoadFont("Common normal")..{
			Name="date",
			InitCommand=function(self)
				self:xy(frameX+10,frameY+20+(drawindex*spacing)):zoom(0.35):halign(0)
			end,
			BeginCommand=function(self)
				self:playcommand("Set")
			end,
			SetCommand = function(self)
				if hsTable[index] ~= nil then
					self:diffuse(color(colorConfig:get_data().evaluation.ScoreBoardText))
					if #hsTable >= 1 and index>= 1 then
						self:settext(hsTable[index]:GetDate())
					end
					self:visible(false)
				end
			end
		}

	}
	return t
end

--can't have more lines than the # of scores huehuehu
if lines > #hsTable then
	lines = #hsTable
end

local drawindex = 0
curPage = math.ceil(scoreIndex / lines)
local startind = (curPage-1) * lines + 1

while drawindex < 4 do
	t[#t+1] = scoreitem(player,startind,scoreIndex,drawindex)
	startind = startind+1
	drawindex  = drawindex+1
end

--Text that sits above the scoreboard with some info
t[#t+1] = LoadFont("Common normal")..{
	InitCommand=function(self)
		self:xy(frameX + frameWidth/2,frameY-15):zoom(0.35)
	end,
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
		self:diffuse(color(colorConfig:get_data().evaluation.BackgroundText)):diffusealpha(0.8)
	end,
	TabChangedMessageCommand = function(self, params)
		if params.index == 1 then
			self:stoptweening()
			self:bouncy(0.3)
			self:diffusealpha(1)
		else
			self:stoptweening()
			self:bouncy(0.3)
			self:diffusealpha(0)
		end
	end
}

--Update function for showing mouse rollovers
local function Update(self)
	t.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end	
	for i=0,drawindex-1 do
		if self:GetChild("scoreItem"..tostring(i)):GetChild("mouseOver"):isOver() then
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
t.InitCommand=function(self)
	self:SetUpdateFunction(Update)
end	

t[#t+1] = Def.Quad {
	InitCommand = function(self)
		self:xy(frameX - 20,frameY - 20)
		self:valign(0):halign(0)
		self:diffusealpha(0)
		self:zoomto(20 + frameWidth, 20 + (30) * lines + lines * (5))
	end,
	WheelUpSlowMessageCommand = function(self)
		if self:isOver() then
			movePage(-1)
		end
	end,
	WheelDownSlowMessageCommand = function(self)
		if self:isOver() then
			movePage(1)
		end
	end

}

return t