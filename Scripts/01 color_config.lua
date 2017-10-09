local defaultConfig = {

	main = {
		frame = "#000000",
		highlight = "#00AEEF",
		background = "#FFFFFF",
		enabled = "#4CBB17",
		disabled = "#666666",
		negative = "#FF9999",
		positive = "#66ccff",
		headerText = "#FFFFFF",
		headerFrameText = "#FFFFFF",
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
		ClearType_SDCB	= "#666666",
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

	grade = {
		Grade_Tier01	= "#66ccff", -- AAAA
		Grade_Tier02	= "#eebb00", -- AAA
		Grade_Tier03	= "#66cc66", -- AA
		Grade_Tier04	= "#da5757", -- A
		Grade_Tier05	= "#5b78bb", -- B
		Grade_Tier06	= "#c97bff", -- C
		Grade_Tier07	= "#8c6239", -- D
		Grade_Tier08	= "#000000", -- ITG PLS
		Grade_Tier09	= "#000000", -- ITG PLS
		Grade_Tier10	= "#000000", -- ITG PLS
		Grade_Tier11	= "#000000", -- ITG PLS
		Grade_Tier12	= "#000000", -- ITG PLS
		Grade_Tier13	= "#000000", -- ITG PLS
		Grade_Tier14	= "#000000", -- ITG PLS
		Grade_Tier15	= "#000000", -- ITG PLS
		Grade_Tier16	= "#000000", -- ITG PLS
		Grade_Tier17	= "#000000", -- ITG PLS
		Grade_Failed	= "#cdcdcd", -- F
		Grade_None		= "#666666", -- no play
	},

	etternaTier = {
		Tier01  = "#c97bff",  -- THE PURPLE
		Tier02 	= "#66ccff", -- 25+ AAAA Color
		Tier03 	= "#eebb00", -- <25 AAA
		Tier04 	= "#ddaa00", -- 25+ yellow
		Tier05	= "#66cc66", -- 20+ AA
		Tier06	= "#da5757", -- 15+ A
		Tier07	= "#5b78bb", -- 10+ B
		Tier08	= "#8c6239", -- 0+ D
		None	= "#FFFFFF", -- None
		Invalid	= "#666666", -- None
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
		MusicWheelExtraColor = "#FFCCCC",
		ProfileCardText = "#FFFFFF",
		TabContentText = "#FFFFFF",
		BannerText = "#FFFFFF",
		StepsDisplayListText = "#FFFFFF"
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

function getMainColor(type)
	return color(colorConfig:get_data().main[type])
end

function getGradeColor (grade)
	return color(colorConfig:get_data().grade[grade]) or color(colorConfig:get_data().grade['Grade_None']);
end

function getDifficultyColor(diff)
	return color(colorConfig:get_data().difficulty[diff]) or color("#ffffff");
end

function getPaceMakerColor(type)
	return color(colorConfig:get_data().gameplay["Pacemaker"..type]) or color("#ffffff");
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

function TapNoteScoreToColor(tns) return color(colorConfig:get_data().judgment[tns]) or color("#ffffff"); end;


-- Only used for avatar borders, use getMSDColor for everything else.
function getSRColor(SR)
	if SR > 30 then 
		return color(colorConfig:get_data().etternaTier["Tier01"])
	elseif SR > 25 then
		return color(colorConfig:get_data().etternaTier["Tier02"])
	elseif SR > 20 then
		return lerp_color((SR-20)/5, color(colorConfig:get_data().etternaTier["Tier04"]), color(colorConfig:get_data().etternaTier["Tier03"]))
	elseif SR > 15 then
		return lerp_color((SR-15)/5, color(colorConfig:get_data().etternaTier["Tier05"]), color(colorConfig:get_data().etternaTier["Tier04"]))
	elseif SR > 10 then
		return lerp_color((SR-10)/5, color(colorConfig:get_data().etternaTier["Tier06"]), color(colorConfig:get_data().etternaTier["Tier05"]))
	elseif SR > 5 then
		return lerp_color((SR-5)/5, color(colorConfig:get_data().etternaTier["Tier07"]), color(colorConfig:get_data().etternaTier["Tier06"]))
	elseif SR > 0 then
		return lerp_color(SR/5, color(colorConfig:get_data().etternaTier["Tier08"]), color(colorConfig:get_data().etternaTier["Tier07"]))
	else
		return color(colorConfig:get_data().etternaTier["None"])
	end
end

-- a tad-bit desaturated with a wider color range vs til death
function getMSDColor(MSD)
	if MSD then
		return HSV(math.max(200 - math.sin(MSD/40*math.pi/2.2)*250, -50), 0.5, 1)
	end
	return HSV(0, 0.9, 0.9)
end
