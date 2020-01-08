local inSongSearch = false
local transitioning = false

local function input(event)

	if event.type == "InputEventType_FirstPress" then

		if event.button == "EffectUp" and not inSongSearch then
			changeMusicRate(0.05)
		end

		if event.button == "EffectDown" and not inSongSearch then
			changeMusicRate(-0.05)
		end

		if event.DeviceInput.button == "DeviceButton_mousewheel up" then
			wheel:Move(-1)
			wheel:Move(0)
		end

		if event.DeviceInput.button == "DeviceButton_mousewheel down" then
			wheel:Move(1)
			wheel:Move(0)
		end

		if event.DeviceInput.button == "DeviceButton_middle mouse button" then
			lastY = INPUTFILTER:GetMouseY()
		end

		local CtrlPressed = INPUTFILTER:IsBeingPressed("left ctrl") or INPUTFILTER:IsBeingPressed("right ctrl")
		local numpad = event.DeviceInput.button == "DeviceButton_KP "..event.char

		-- im fired for writing this
		if event.DeviceInput.button == "DeviceButton_g" and CtrlPressed then
			GHETTOGAMESTATE:resetGoalTable()
			wheel:Move(1)
			wheel:Move(-1)
			wheel:Move(0)
		end
		if not numpad and event.char and tonumber(event.char) and not inSongSearch and not transitioning then
			if tonumber(event.char) == 1 then
				SCREENMAN:AddNewScreenToTop("ScreenPlayerProfile")
			elseif tonumber(event.char) == 2 then
				if GAMESTATE:GetCurrentSong() then
					SCREENMAN:AddNewScreenToTop("ScreenNetMusicInfo")
				end
			elseif tonumber(event.char) == 3 then
				SCREENMAN:AddNewScreenToTop("ScreenGroupInfo")
			elseif tonumber(event.char) == 4 then
				if CtrlPressed then
					MESSAGEMAN:Broadcast("StartSearch", {hotkey = true})
				else
					GHETTOGAMESTATE:setMusicWheel(SCREENMAN:GetTopScreen())
					SCREENMAN:AddNewScreenToTop("ScreenFiltering")
				end
			elseif tonumber(event.char) == 5 then
				SCREENMAN:AddNewScreenToTop("ScreenDownload")
			end
		end

	end

	if event.type == "InputEventType_Repeat" then
		if event.DeviceInput.button == "DeviceButton_middle mouse button" then
			curY = INPUTFILTER:GetMouseY()
			if curY-lastY > 0 then
				wheel:Move(math.floor((curY-lastY)/50))
			elseif curY-lastY < 0 then
				wheel:Move(math.ceil((curY-lastY)/50))
			end
			wheel:Move(0)
		end
	end

	return false

end

local lastY
local curY

local top
local wheel
local t = Def.ActorFrame{
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		wheel = SCREENMAN:GetTopScreen():GetMusicWheel()
		top:AddInputCallback(input)
		self:diffusealpha(0)
		self:smooth(0.5)
		self:diffusealpha(1)
	end,
	TriggerReplayBeginMessageCommand = function(self)
		transitioning = true
	end,
	OffCommand = function(self)
		transitioning = true
		self:smooth(0.5)
		self:diffusealpha(0)
	end,
	StartPlaylistMessageCommand=function(self, params)
		top:StartPlaylistAsCourse(params.playlist:GetName())
	end,
	StartSearchMessageCommand = function(self)
		inSongSearch = true
	end,
	EndSearchMessageCommand = function(self)
		inSongSearch = false
	end
}

t[#t+1] = LoadActor("../../_mouse", "ScreenSelectMusic")

-- Profile contains: Profile breakdown (local and online)
-- Song Info contains: MSD, Scores, Chart Preview, Online Leaderboard, (and something to let you tag the song)
-- Group info contains: misc info (tags in this pack?)
-- Filtering contains: filters, tags
-- Downloads contains: Downloads, Bundles
local tab = TAB:new({"Profile", "Song Info", "Group Info", "Filtering", "Downloads"})
t[#t+1] = tab:makeTabActors() .. {
	OnCommand = function(self)
		self:y(SCREEN_HEIGHT+tab.height/2 - 17)
		self:easeOut(0.5)
		self:y(SCREEN_HEIGHT-tab.height/2 - 17)
	end,
	OffCommand = function(self)
		self:y(SCREEN_HEIGHT+tab.height/2 - 17)
	end,
	TabPressedMessageCommand = function(self, params)
		if params.params.button ~= "DeviceButton_left mouse button" then
			return
		end
		if inSongSearch then
			MESSAGEMAN:Broadcast("EndSearch")
			SCREENMAN:set_input_redirected(PLAYER_1, false)
		end
		if params.name == "Profile" then
			SCREENMAN:AddNewScreenToTop("ScreenPlayerProfile")
		elseif params.name == "Song Info" then
			if GAMESTATE:GetCurrentSong() then
				SCREENMAN:AddNewScreenToTop("ScreenNetMusicInfo")
			end
		elseif params.name == "Group Info" then
			SCREENMAN:AddNewScreenToTop("ScreenGroupInfo")
		elseif params.name == "Downloads" then
			SCREENMAN:AddNewScreenToTop("ScreenDownload")
		elseif params.name == "Filtering" then
			GHETTOGAMESTATE:setMusicWheel(top)
			SCREENMAN:AddNewScreenToTop("ScreenFiltering")

		--[[ -- No playlists in multiplayer.
			elseif params.name == "Playlist" then
			SCREENMAN:AddNewScreenToTop("ScreenPlaylistInfo")
		]]

		end
	end
}

return t