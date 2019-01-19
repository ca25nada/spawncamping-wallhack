

GHETTOGAMESTATE = {
	lastSelectedFolder = "",
	lastPlayedSecond = 0,
	musicwheel = nil,
	musicsearch = ""
}

-- very bad cheaty way to get the music wheel across overlay screens
function GHETTOGAMESTATE.setMusicWheel(self, screen)
	self.musicwheel = screen:GetMusicWheel()
end

function GHETTOGAMESTATE.getMusicWheel(self)
	return self.musicwheel
end

-- store and retrieve the music filter strings when closing and reopening the overlay
function GHETTOGAMESTATE.setMusicSearch(self, given)
	self.musicsearch = given
end
function GHETTOGAMESTATE.getMusicSearch(self)
	return self.musicsearch
end

--returns current autoplay type. returns a integer between 0~2 corresponding to
--human, autoplay and autoplay cpu respectively.
function GHETTOGAMESTATE.getAutoplay()
	return Enum.Reverse(PlayerController)[tostring(PREFSMAN:GetPreference("AutoPlay"))]
end

function GHETTOGAMESTATE.isAutoplay()
	return GHETTOGAMESTATE.getAutoplay() ~= 0
end

--returns true if windowed.
function GHETTOGAMESTATE.isWindowed()
	return PREFSMAN:GetPreference("Windowed")
end

-- Values based on ArrowEffects.cpp
-- Gets the note scale from the mini mod being used.
function GHETTOGAMESTATE.getNoteFieldScale(self, pn)
	local po = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Preferred')
	local val,as = po:Mini()
	local zoom = 1
	zoom = 1-(val*0.5)
	if math.abs(zoom) < 0.01 then
		zoom = 0.01
	end
	return zoom
end

-- Gets the center X position of the notefield.
function GHETTOGAMESTATE.getNoteFieldPos(self, pn)
	local pNum = (pn == PLAYER_1) and 1 or 2
	local style = GAMESTATE:GetCurrentStyle()
	local cols = style:ColumnsPerPlayer()
	local styleType = ToEnumShortString(style:GetStyleType())
	local centered = ((cols >= 6) or PREFSMAN:GetPreference("Center1Player"))

	if centered and GAMESTATE:GetNumPlayersEnabled() == 1 then 
		return SCREEN_CENTER_X
	else
		return THEME:GetMetric("ScreenGameplay",string.format("PlayerP%i%sX",pNum,styleType))
	end
end

-- Gets the width of the note assuming the base width is 64.
function GHETTOGAMESTATE.getNoteFieldWidth(self, pn)
	local baseWidth = 64 -- is there a way to grab a noteskin width..?
	local style = GAMESTATE:GetCurrentStyle()
	local cols = style:ColumnsPerPlayer()
	return cols*baseWidth*GHETTOGAMESTATE:getNoteFieldScale(pn)
end

function GHETTOGAMESTATE.setLastSelectedFolder(self, group)
	if group ~= nil then
		self.lastSelectedFolder = group
	end
end

function GHETTOGAMESTATE.setLastPlayedSecond(self, t)
	self.lastPlayedSecond = t
end

function GHETTOGAMESTATE.getLastPlayedSecond(self)
	if self.lastPlayedSecond then
		return self.lastPlayedSecond
	else
		return 0
	end
end