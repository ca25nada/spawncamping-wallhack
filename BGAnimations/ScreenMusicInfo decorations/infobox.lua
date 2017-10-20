local steps
local song = GAMESTATE:GetCurrentSong()
local scoreList

local frameWidth = capWideScale(360,430)
local frameHeight = 340

local scoreItemWidth = frameWidth-30
local scoreItemHeight = 25

local scoreItemX = 20
local scoreItemY = 30+scoreItemHeight/2
local scoreItemYSpacing = 5
local pn = GAMESTATE:GetEnabledPlayers()[1]

local maxScoreItems = 10

local t = Def.ActorFrame{
	SetStepsMessageCommand = function(self, params)
		steps = params.steps
		scoreList = getScoreTable(pn, getCurRate(), steps)
		if scoreList ~= nil then
			self:RunCommandsOnChildren(cmd(playcommand, "UpdateList"))
			self:GetChild("NoScore"):visible(false)
		else
			self:RunCommandsOnChildren(cmd(playcommand, "Hide"))
			self:GetChild("NoScore"):visible(true):playcommand("Set")
		end
	end

}



t[#t+1] = Def.Quad{
	InitCommand = function (self)
		self:zoomto(frameWidth,frameHeight)
		self:halign(0):valign(0)
		self:diffuse(getMainColor("frame"))
		self:diffusealpha(0.8)
	end
}

t[#t+1] = LoadFont("Common Bold")..{
	InitCommand  = function(self)
		self:xy(5, 10)
		self:zoom(0.4)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:settext("Top Scores")
	end;
}

t[#t+1] = LoadFont("Common Normal")..{
	Name = "NoScore";
	InitCommand  = function(self)
		self:xy(frameWidth/2, frameHeight/2)
		self:zoom(0.4)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.6)
		self:settext("No scores here!\n(* ` ω´)")
	end;
	SetCommand = function(self)
		self:finishtweening()
		self:y(frameHeight/2-5)
		self:easeOut(0.5)
		self:y(frameHeight/2)
	end
}

local function scoreListItem(i)

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:diffusealpha(0)
			self:xy(scoreItemX-10, scoreItemY + (i-1)*(scoreItemHeight+scoreItemYSpacing))
		end;
		ShowCommand = function(self)
			self:diffusealpha(0)
			self:x(scoreItemX-10)
			self:finishtweening()
			self:sleep((i-1)*0.05)
			self:easeOut(1)
			self:x(scoreItemX)
			self:diffusealpha(1)
		end;
		HideCommand = function(self)
			self:finishtweening()
			self:sleep((i-1)*0.05)
			self:easeOut(1)
			self:diffusealpha(0)
			self:x(scoreItemX-10)
		end;
		UpdateListCommand = function(self)
			if scoreList[i] ~= nil then
				self:RunCommandsOnChildren(cmd(playcommand, "Set"))
				self:playcommand("Show")
			else
				self:playcommand("Hide")
			end
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(-10,0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.3)
			self:settextf("%d",i)
		end;
	}

	t[#t+1] = quadButton(6) .. {
		InitCommand = function(self)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(scoreItemWidth, scoreItemHeight)
		end;
		TopPressedCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.2)
		end;
		SetCommand = function(self)
			if scoreList[i]:GetEtternaValid() then
				self:diffuse(color("#FFFFFF"))
			else
				self:diffuse(color(colorConfig:get_data().clearType.ClearType_Invalid))
			end
			self:diffusealpha(0.2)
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().main.highlight))
			self:diffusealpha(0.8)
			self:xy(0, 0)
			self:zoomto(3, scoreItemHeight)
		end;
		SetCommand = function(self)
			local clearType = getClearType(pn,steps,scoreList[i])
			self:diffuse(getClearTypeColor(clearType))
		end;
	}


	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(20,0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
		end;
		SetCommand = function(self)
			local ssr = scoreList[i]:GetSkillsetSSR("Overall")
			self:settextf("%0.2f",ssr)
			self:diffuse(getMSDColor(ssr))
		end;
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(40,-6)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:halign(0)
		end;
		SetCommand = function(self)
			local clearType = getClearType(pn,steps,scoreList[i])

			self:settext(getClearTypeText(clearType))
			self:diffuse(getClearTypeColor(clearType))
		end
	}

	t[#t+1] = LoadFont("Common Bold")..{
		Name = "Grade";
		InitCommand  = function(self)
			self:xy(40,5)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:halign(0)
		end;
		SetCommand = function(self)
			local grade = scoreList[i]:GetWifeGrade()
			self:settext(THEME:GetString("Grade",ToEnumShortString(grade)))
			self:diffuse(getGradeColor(grade))
		end
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name = "PercentScore";
		InitCommand  = function(self)
			self:xy(40,5)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.3)
			self:halign(0)
		end;
		SetCommand = function(self)
			local score = scoreList[i]:GetWifeScore()
			local w1 = scoreList[i]:GetTapNoteScore("TapNoteScore_W1")
			local w2 = scoreList[i]:GetTapNoteScore("TapNoteScore_W2")
			local w3 = scoreList[i]:GetTapNoteScore("TapNoteScore_W3")
			local w4 = scoreList[i]:GetTapNoteScore("TapNoteScore_W4")
			local w5 = scoreList[i]:GetTapNoteScore("TapNoteScore_W5")
			local miss = scoreList[i]:GetTapNoteScore("TapNoteScore_Miss")
			self:settextf("%0.2f%% - %d / %d / %d / %d / %d / %d",math.floor(score*10000)/100, w1, w2, w3, w4, w5, miss)
			self:x(self:GetParent():GetChild("Grade"):GetX()+(self:GetParent():GetChild("Grade"):GetWidth()*0.4)+5)
		end
	}

	return t
end


for i=1, maxScoreItems do
	t[#t+1] = scoreListItem(i)
end

-- t[#t+1] = songDisplay()


return t