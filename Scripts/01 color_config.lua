local defaultConfig = {

	main = {
		frame = "#000000",
		highlight = "#00AEEF",
		background = "#CCCCEE",
		underlay = "#CCCCEE",
		warning = "#EEBB00",
		enabled = "#4CBB17",
		disabled = "#666666",
		negative = "#FF9999",
		positive = "#66ccff",
		headerText = "#FFFFFF",
		headerFrameText = "#FFFFFF",
		transition = "#888888",
		tabFrame = "#333333",
		tabButton = "#FFFFFF",
	},

	clearType = {
		ClearType_MFC 	= "#66ccff",
		ClearType_WF 	= "#dddddd",
		ClearType_SDP 	= "#cc8800",
		ClearType_PFC 	= "#eeaa00",
		ClearType_BF 	= "#999999",
		ClearType_SDG	= "#448844",
		ClearType_FC 	= "#66cc66",
		ClearType_MF 	= "#cc6666",
		ClearType_SDCB	= "#33ccff",
		ClearType_EXHC 	= "#ff9933",
		ClearType_HClear 	= "#ff6666",
		ClearType_Clear 	= "#33aaff",
		ClearType_EClear 	= "#66ff66",
		ClearType_AClear 	= "#9966ff",
		ClearType_Failed = "#e61e25",
		ClearType_Invalid = "#e61e25",
		ClearType_Noplay = "#666666",
		ClearType_None = "#666666",
	},

	difficulty = {
		Difficulty_Beginner	= "#66ccff",		-- light blue
		Difficulty_Easy		= "#099948",		-- green
		Difficulty_Medium	= "#ddaa00",		-- yellow
		Difficulty_Hard		= "#ff6666",		-- red
		Difficulty_Challenge= "#c97bff",	-- light blue
		Difficulty_Edit 	= "#666666",	-- gray
		Difficulty_Couple	= "#ed0972",			-- hot pink
		Difficulty_Routine	= "#ff9a00",			-- orange
		Beginner	= "#66ccff",		
		Easy		= "#099948",		-- green
		Medium		= "#ddaa00",		-- yellow
		Hard		= "#ff6666",		-- red
		Challenge 		= "#c97bff",	-- Purple
		Edit 		= "#666666",	-- gray
		Couple		= "#ed0972",			-- hot pink
		Routine		= "#ff9a00",			-- orange
		Crazy 		= "#ff6666",		-- red
		Nightmare	= "#c97bff",	-- Purple
		HalfDouble 	= "#666666",	-- gray
		HalfDouble 	= "#666666",	-- gray
		Freestyle 	= "#666666",	-- gray
	},

	grades = {
		Grade_Tier01 = "#ffffff", -- AAAAA
		Grade_Tier02 = "#66ccff", -- AAAA:
		Grade_Tier03 = "#66ccff", -- AAAA.
		Grade_Tier04 = "#66ccff", -- AAAA
		Grade_Tier05 = "#eebb00", -- AAA:
		Grade_Tier06 = "#eebb00", -- AAA.
		Grade_Tier07 = "#eebb00", -- AAA
		Grade_Tier08 = "#66cc66", -- AA:
		Grade_Tier09 = "#66cc66", -- AA.
		Grade_Tier10 = "#66cc66", -- AA
		Grade_Tier11 = "#da5757", -- A:
		Grade_Tier12 = "#da5757", -- A.
		Grade_Tier13 = "#da5757", -- A
		Grade_Tier14 = "#5b78bb", -- B
		Grade_Tier15 = "#c97bff", -- C
		Grade_Tier16 = "#8c6239", -- D
		Grade_Tier17 = "#000000",
		Grade_Failed = "#cdcdcd", -- F
		Grade_None = "#666666" -- no play
	},

	judgment = { -- Colors of each Judgment types
		TapNoteScore_W1 = "#99ccff",
		TapNoteScore_W2	= "#f2cb30",
		TapNoteScore_W3	 = "#14cc8f",
		TapNoteScore_W4	= "#1ab2ff",
		TapNoteScore_W5	= "#ff1ab3",
		TapNoteScore_Miss = "#cc2929",			
		HoldNoteScore_Held = "#f2cb30",	
		HoldNoteScore_LetGo = "#cc2929"
	},

	downloadStatus = {
		downloaded = "#66ccff",
		completed = "#66cc66",
		downloading = "#eebb00",
		available = "#da5757",
		unavailable = "#666666",
	},

	songLength = {
		short = "#666666", -- grey
		normal = "#FFFFFF", -- normal
		long = "#ff9a00", --orange
		marathon = "#da5757", -- red
		ultramarathon = "#c97bff" -- purple
	},

	gameplay = {
		ScreenFilter = "#000000",
		LaneCover = "#111111",
		PacemakerBest = "#00FF00",
		PacemakerTarget = "#FF9999",
		PacemakerCurrent = "#0099FF",
	},

	combo = {
		NumberFC = "#A4FF00",
		NumberPFC = "#FFF568",
		NumberMFC = "#00AEEF",
		NumberRegular = "#DDDDDD",
		NumberMiss = "#FF0000",
		LabelRegular = "#DDDDDD",
		LabelMiss = "#FF2020",
		LabelRegularGradient = "#888888",
		LabelMissGradient = "#880000"
	},

	leaderboard = {
		background = "#111111CC",
		border = "#000111",
		text = "#9654FD"
	},

	evaluation = {
		BackgroundText = "#000000",
		ScoreCardText = "#FFFFFF",
		ScoreCardDivider = "#FFFFFF",
		ScoreCardCategoryText = "#FFFFFF",
		ScoreBoardText = "#FFFFFF",
	},

	selectMusic = {
		MusicWheelTitleText = "#FFFFFF",
		MusicWheelSubtitleText = "#FFFFFF",
		MusicWheelArtistText = "#FFFFFF",
		MusicWheelSectionCountText = "#FFFFFF",
		MusicWheelDivider = "#FFFFFF",
		UnfinishedGoalGradient = "#FF66FF",
		CompletedGoalGradient = "#66FF66",
		MusicWheelExtraColor = "#FFCCCC",
		ProfileCardText = "#FFFFFF",
		TabContentText = "#FFFFFF",
		BannerText = "#FFFFFF",
		StepsDisplayListText = "#FFFFFF"
	},

	miscellaneous = {
		PreviewProgress = "#00FF66",
		PreviewSeek = "#FF3333",
		ChordGraphGradientDark = "#555555",
		TagPositive = "#5555BB",
		TagNegative = "#BB5555",
	}

}

colorConfig =  create_setting("colorConfig", "colorConfig.lua", defaultConfig,-1)
colorConfig:load()

--keys to current table. Assumes a depth of 2.
local curColor = {"",""}

function getTableKeys()
	return curColor
end

function setTableKeys(table)
	curColor = table 
end

function getDefaultColorForCurColor()
	return defaultConfig[curColor[1]][curColor[2]]
end

function getMainColor(type)
	return color(colorConfig:get_data().main[type])
end

function getComboColor(type)
	return color(colorConfig:get_data().combo[type])
end

function getLeaderboardColor(type)
	return color(colorConfig:get_data().leaderboard[type])
end

function getGradeColor(grade)
	return color(colorConfig:get_data().grades[grade]) or color(colorConfig:get_data().grades['Grade_None'])
end

function getDifficultyColor(diff)
	return color(colorConfig:get_data().difficulty[diff]) or color("#ffffff")
end

function getPaceMakerColor(type)
	return color(colorConfig:get_data().gameplay["Pacemaker"..type]) or color("#ffffff")
end

function getMiscColor(type)
	return color(colorConfig:get_data().miscellaneous[type])
end

function getSongLengthColor(s)


	if s < 60 then
		return lerp_color(s/60, color(colorConfig:get_data().songLength["short"]),
			color(colorConfig:get_data().songLength["normal"]))

	elseif s < PREFSMAN:GetPreference("LongVerSongSeconds") then
		return lerp_color((s-60)/(PREFSMAN:GetPreference("LongVerSongSeconds")-60),
			color(colorConfig:get_data().songLength["normal"]),
			color(colorConfig:get_data().songLength["long"]))

	elseif s < PREFSMAN:GetPreference("MarathonVerSongSeconds") then
		return lerp_color((s-PREFSMAN:GetPreference("LongVerSongSeconds"))/
			(PREFSMAN:GetPreference("MarathonVerSongSeconds")-PREFSMAN:GetPreference("LongVerSongSeconds")),
			color(colorConfig:get_data().songLength["long"]), 
			color(colorConfig:get_data().songLength["marathon"]))

	elseif s < 1000 then
		return lerp_color((s-PREFSMAN:GetPreference("MarathonVerSongSeconds"))/
			(1000-PREFSMAN:GetPreference("MarathonVerSongSeconds")), 
			color(colorConfig:get_data().songLength["marathon"]), 
			color(colorConfig:get_data().songLength["ultramarathon"]))

	else
		return color(colorConfig:get_data().songLength["ultramarathon"])

	end
end

function getClearTypeColor(clearType)
	return color(colorConfig:get_data().clearType[clearType])
end

function offsetToJudgeColor(offset)
	local offset = math.abs(offset)
	local scale = PREFSMAN:GetPreference("TimingWindowScale")
	if offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW1") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W1"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW2") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W2"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW3") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W3"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW4") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W4"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW5") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W5"])
	else
		return color(colorConfig:get_data().judgment["TapNoteScore_Miss"])
	end
end

-- expecting ms input (153, 13.321, etc) so convert to seconds to compare to judgment windows -mina
function offsetToJudgeColor(offset, scale)
	local offset = math.abs(offset / 1000)
	if not scale then
		scale = PREFSMAN:GetPreference("TimingWindowScale")
	end
	if offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW1") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W1"])
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW2") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W2"])
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW3") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W3"])
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW4") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W4"])
	elseif offset <= math.max(scale * PREFSMAN:GetPreference("TimingWindowSecondsW5"), 0.180) then
		return color(colorConfig:get_data().judgment["TapNoteScore_W5"])
	else
		return color(colorConfig:get_data().judgment["TapNoteScore_Miss"])
	end
end

-- 30% hardcoded, should var but lazy atm -mina
function offsetToJudgeColorAlpha(offset, scale)
	local offset = math.abs(offset / 1000)
	if not scale then
		scale = PREFSMAN:GetPreference("TimingWindowScale")
	end
	if offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW1") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W1"] .. "48")
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW2") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W2"] .. "48")
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW3") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W3"] .. "48")
	elseif offset <= scale * PREFSMAN:GetPreference("TimingWindowSecondsW4") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W4"] .. "48")
	elseif offset <= math.max(scale * PREFSMAN:GetPreference("TimingWindowSecondsW5"), 0.180) then
		return color(colorConfig:get_data().judgment["TapNoteScore_W5"] .. "48")
	else
		return color(colorConfig:get_data().judgment["TapNoteScore_Miss"] .. "48")
	end
end

-- 30% hardcoded, should var but lazy atm -mina
function customOffsetToJudgeColor(offset, windows)
	local offset = math.abs(offset)
	if offset <= windows.marv then
		return color(colorConfig:get_data().judgment["TapNoteScore_W1"] .. "48")
	elseif offset <= windows.perf then
		return color(colorConfig:get_data().judgment["TapNoteScore_W2"] .. "48")
	elseif offset <= windows.great then
		return color(colorConfig:get_data().judgment["TapNoteScore_W3"] .. "48")
	elseif offset <= windows.good then
		return color(colorConfig:get_data().judgment["TapNoteScore_W4"] .. "48")
	elseif offset <= math.max(windows.boo, 0.180) then
		return color(colorConfig:get_data().judgment["TapNoteScore_W5"] .. "48")
	else
		return color(colorConfig:get_data().judgment["TapNoteScore_Miss"] .. "48")
	end
end

function getBorderColor()
	return HSV(Hour()*360/12, 0.7, 1)
end

function TapNoteScoreToColor(tns) return color(colorConfig:get_data().judgment[tns]) or color("#ffffff") end

function byJudgment(judge)
	return color(colorConfig:get_data().judgment[judge])
end

function byDifficulty(diff)
	return color(colorConfig:get_data().difficulty[diff])
end

-- i guess if i'm going to use this naming convention it might as well be complete and standardized which means redundancy -mina
function byGrade(grade)
	return color(colorConfig:get_data().grades[grade]) or color(colorConfig:get_data().grades["Grade_None"])
end

-- Colorized stuff
function byMSD(x)
	if x then
		return HSV(math.max(95 - (x / 40) * 150, -50), 0.9, 0.9)
	end
	return HSV(0, 0.9, 0.9)
end

function byMusicLength(x)
	if x then
		x = math.min(x, 600)
		return HSV(math.max(95 - (x / 900) * 150, -50), 0.9, 0.9)
	end
	return HSV(0, 0.9, 0.9)
end

function byFileSize(x)
	if x then
		x = math.min(x, 600)
		return HSV(math.max(95 - (x / 1025) * 150, -50), 0.9, 0.9)
	end
	return HSV(0, 0.9, 0.9)
end

-- a tad-bit desaturated with a wider color range vs til death
function getMSDColor(MSD)
	if MSD then
		return HSV(math.min(220,math.max(280 - MSD*11, -40)), 0.5, 1)
	end
	return HSV(0, 0.9, 0.9)
end
