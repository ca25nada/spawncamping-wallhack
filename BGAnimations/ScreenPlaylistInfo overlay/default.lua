-- Messages broadcast from the screen:

--  StartPlaylist 
--   - When exitng the screen to play the playlist. The broadcast is handled in ScreenSelectMusic.

--  MoveMusicWheelToSong
--   - When exitng the screen to jump to a specific song. The broadcast is handled in ScreenSelectMusic.
   
--  UpdateStepsList
--   - Broadcast when the list of steps within a playlist to display is updated. (playlist updates or page changes)

--  UpdateList 
--   - Broadcast the list of playlist to display is updated. (new/removed playlists or page changes)

--  ShowPlaylistDetail
--   - Broadcast when a playlist is clicked, displaying all the steps within the playlist.

--  HidePlaylistDetail
--   - Broadcast when exiting the detail view to display the list of playlists again.

local maxItems = 10 -- Max number of items (either playlists or steps) to be shown on the screen.
local curPage = 1 -- Current page for displaying playlists
local curStepsPage = 1 -- current page for displaying steps within a playlist

local playlist
local maxPlaylistPages

local playlists = SONGMAN:GetPlaylists()
local maxPages = math.ceil(#playlists/maxItems)

local pn = GAMESTATE:GetEnabledPlayers()[1]
local steps = GAMESTATE:GetCurrentSteps(pn)
local song = GAMESTATE:GetCurrentSong()

local detail = false -- True if displaying steps within a playlist, false if just displaying available playlists

-- checks whether a playlist only has a single stepstype as the game will crash if attempting to play
-- a playlist with multiple stepstype.
function Playlist.IsPlayable(pl)
	if not pl then
		return false
	end

	local stepsType = {}
	for i,key in ipairs(pl:GetChartkeys()) do
		local steps = SONGMAN:GetStepsByChartKey(key)
		if steps then
			stepsType[steps:GetStepsType()] = true
		else
			return false
		end
	end

	return getTableSize(stepsType) == 1
end

-- Exits the screen while sending a message to begin playing the playlist immediately.
local function playPlaylist(pl)
	MESSAGEMAN:Broadcast("StartPlaylist",{playlist = pl})
	SCREENMAN:GetTopScreen():Cancel()
end

-- NOTE: 
-- Doesn't work as SONGMAN:NewPlaylist() failed to add the playlist outside of ScreenSelectMusic.
-- Creates a new playlist and updates the screen.
local function addPlaylist()
	SONGMAN:NewPlaylist()
	detail = false
	playlists = SONGMAN:GetPlaylists()
	maxPages = math.ceil(#playlists/maxItems)
	MESSAGEMAN:Broadcast("UpdateList")
end

-- Deletes the playlist and updates the screen.
local function deletePlaylist(pl)
	local name = pl:GetName()

	-- Delete playlist and update parameters
	SCREENMAN:SystemMessage(string.format("Playlist \"%s\" deleted.", name))
	SONGMAN:DeletePlaylist(name)
	detail = false
	playlists = SONGMAN:GetPlaylists()
	maxPages = math.ceil(#playlists/maxItems)
	MESSAGEMAN:Broadcast("UpdateList")
	MESSAGEMAN:Broadcast("HidePlaylistDetail")
end

-- No such functionality exists for playlists apparently.
local function editPlaylist(pl)
end


local function movePage(n)

	-- Moves to next page of steps while a playlist is selected.
	if detail then
		if n > 0 then 
			curStepsPage = ((curStepsPage+n-1) % maxPlaylistPages + 1)
		else
			curStepsPage = ((curStepsPage+n+maxPlaylistPages-1) % maxPlaylistPages+1)
		end
		MESSAGEMAN:Broadcast("UpdateStepsList")

	-- Moves to next page of playlists while no playlist is selected.
	else
		if n > 0 then 
			curPage = ((curPage+n-1) % maxPages + 1)
		else
			curPage = ((curPage+n+maxPages-1) % maxPages+1)
		end
		MESSAGEMAN:Broadcast("UpdateList")
	end
end


-- Input callback function
local function input(event)
	if event.type == "InputEventType_FirstPress" then
		if event.button == "Back" or event.button == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
		end

		if event.button == "MenuLeft" then
			movePage(-1)
		end

		if event.button == "MenuRight" then
			movePage(1)
		end

	end

	return false

end

-- Playlist info on the left side.
local function playlistInfo()
	local frameWidth = 300
	local frameHeight = SCREEN_HEIGHT - 60

	local buttonWidth = frameWidth-20
	local buttonHeight = 20

	local playlist

	local t = Def.ActorFrame{
		InitCommand = function(self)
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end;
		ShowPlaylistDetailMessageCommand = function(self, params)
			playlist = params.playlist
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand = function (self)
			self:zoomto(frameWidth,frameHeight)
			self:halign(0):valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand = function (self)
			self:zoomto(256,80)
			self:xy(frameWidth/2, 50):valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth/2, 80+50+10)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end;
		SetCommand = function(self)
			if playlist then
				self:settext(playlist:GetName())
			else
				self:settext("No Playlist Selected")
			end
		end;
	}


	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(5, 10)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Playlist Info")
		end;
	}

	-- Delete Button
	t[#t+1] = quadButton(6) .. {
		Name = "Delete Button";
		InitCommand = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2-10)
			self:zoomto(buttonWidth, buttonHeight)
		end;
		TopPressedCommand = function(self)
			if not playlist then
				return
			end

			deletePlaylist(playlist)

			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end;
		SetCommand = function(self)
			if playlist then
				self:diffuse(color(colorConfig:get_data().main.negative)):diffusealpha(0.8)
			else
				self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
			end
		end;
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2-10)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Delete Playlist")
		end;
	}

	t[#t+1] = quadButton(6) .. {
		Name = "Rename Button";
		InitCommand = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*3-10*2)
			self:zoomto(buttonWidth, buttonHeight)
		end;
		TopPressedCommand = function(self)
			if not playlist then
				return
			end
			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end;
		SetCommand = function(self)
			if playlist then
				self:diffuse(color(colorConfig:get_data().main.warning)):diffusealpha(0.8)
			else
				self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
			end
		end;
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*3-10*2)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Rename Playlist")
		end;
	}

	t[#t+1] = quadButton(6) .. {
		Name = "Add Button";
		InitCommand = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*5-10*3)
			self:zoomto(buttonWidth, buttonHeight)
		end;
		TopPressedCommand = function(self)
			if not playlist then
				return
			end

			playlist:AddChart(steps:GetChartKey())
			MESSAGEMAN:Broadcast("UpdateStepsList")

			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end;
		SetCommand = function(self)
			if playlist then
				self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
			else
				self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
			end
		end;
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*5-10*3)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Add to Playlist")
		end;
	}

	t[#t+1] = quadButton(6) .. {
		Name = "Play Button";
		InitCommand = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*7-10*4)
			self:zoomto(buttonWidth, buttonHeight)
		end;
		TopPressedCommand = function(self)
			if not playlist and playlist:IsPlayable() then
				return
			end

			playPlaylist(playlist)

			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end;
		UpdateStepsListMessageCommand = function(self)
			self:playcommand("Set")
		end;
		SetCommand = function(self)
			if playlist and playlist:IsPlayable() then
				self:diffuse(color(colorConfig:get_data().main.positive)):diffusealpha(0.8)
			else
				self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
			end
		end;
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*7-10*4)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Play Playlist")
		end;
	}

	return t
end

-- Displays available playlists
local function playlistList()

	local frameWidth = 430
	local frameHeight = SCREEN_HEIGHT - 60
	local itemWidth = frameWidth-30
	local itemHeight = 25

	local itemX = 20
	local itemY = 70+itemHeight/2
	local itemYSpacing = 5

	local function item(i)
		local playlist
		local playlistIndex = (curPage-1)*maxItems+i
		local hidden = true

		local t = Def.ActorFrame{
			InitCommand = function(self)
				self:diffusealpha(0)
				self:xy(itemX, itemY + (i-1)*(itemHeight+itemYSpacing)-10)
				self:playcommand("Show")
			end;
			ShowCommand = function(self)
				hidden = false
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing)-10)
				self:diffusealpha(0)
				self:finishtweening()
				self:sleep((i-1)*0.03)
				self:easeOut(1)
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing))
				self:diffusealpha(1)
			end;
			HideCommand = function(self)
				hidden = true
				self:y(SCREEN_HEIGHT*10)
			end;
			UpdateListMessageCommand = function(self) -- Pack List updates (e.g. new page)
				playlistIndex = (curPage-1)*10+i
				playlist = playlists[playlistIndex]

				if playlist then
					self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
					self:playcommand("Show")
				else
					self:stoptweening()
					self:easeOut(0.5)
					self:diffusealpha(0)
					self:queuecommand("Hide")
				end
			end;
			ShowPlaylistDetailMessageCommand = function(self, params)
				if params.index == i then
					self:finishtweening()
					self:easeOut(0.5)
					self:y(itemY)
					self:valign(0)
				else
					self:stoptweening()
					self:easeOut(0.5)
					self:diffusealpha(0)
					self:playcommand("Hide")
				end
			end;
			HidePlaylistDetailMessageCommand = function(self)
				if playlist then 
					self:playcommand("Show")
				end
			end;
			UpdateStepsListMessageCommand = function(self)
				if playlist then
					self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
				end
			end;
		}

		t[#t+1] = quadButton(6) .. {
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(itemWidth, itemHeight)
			end;
			TopPressedCommand = function(self, params)
				if hidden then
					return
				end

				if params.input == "DeviceButton_left mouse button" then
					if not detail and playlist then
						detail = true
						MESSAGEMAN:Broadcast("ShowPlaylistDetail", {playlist = playlist, playlistIndex = playlistIndex, index = i})
					end

				elseif params.input == "DeviceButton_right mouse button" then
					detail = false
					MESSAGEMAN:Broadcast("HidePlaylistDetail")
				end

				self:finishtweening()
				self:diffusealpha(0.4)
				self:smooth(0.3)
				self:diffusealpha(0.2)
			end;

			SetCommand = function(self)
				self:diffusealpha(0.2)
			end;
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(-10,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
			end;
			SetCommand = function(self)
				self:settextf("%d", playlistIndex)
			end;
			ShowPlaylistDetailMessageCommand = function(self)
				self:easeOut(0.5)
				self:diffusealpha(0)
			end;
			HidePlaylistDetailMessageCommand = function(self)
				self:easeOut(0.5)
				self:diffusealpha(1)
			end;
		}

		t[#t+1] = Def.Quad{
			Name = "Status";
			InitCommand = function(self)
				self:halign(0)
				self:diffuse(color(colorConfig:get_data().main.highlight))
				self:diffusealpha(0.8)
				self:xy(0, 0)
				self:zoomto(3, itemHeight)
			end;
			SetCommand = function(self)
				self:diffuse(getMainColor("highlight"))
			end;
		}

		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(20,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end;
			SetCommand = function(self)
				self:settextf("%5.2f",playlist:GetAverageRating())
			end
		}

		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(40,-6):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end;
			SetCommand = function(self)
				self:settextf("%s",playlist:GetName())
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			Name = "Size";
			InitCommand  = function(self)
				self:xy(40,5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
			end;
			SetCommand = function(self)
				self:settextf("%s Steps",#playlist:GetStepslist())
			end
		}

		t[#t+1] = quadButton(7) .. {
			Name = "Add";
			InitCommand = function(self)
				self:xy(itemWidth-5-20, 0)
				if song and steps then
					self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
				else
					self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
				end
				self:zoomto(40, 17)
			end;
			TopPressedCommand = function(self)
				if not (steps and song) or hidden then
					return
				end
				SONGMAN:SetActivePlaylist(playlist:GetName())
				playlist:AddChart(steps:GetChartKey())
				MESSAGEMAN:Broadcast("UpdateStepsList")

				self:finishtweening()
				self:diffusealpha(1)
				self:smooth(0.3)
				self:diffusealpha(0.8)
			end;
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(itemWidth-5-20, 0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:settextf("Add")
			end;
		}

		return t
	end

	local t = Def.ActorFrame{}

	-- Background box
	t[#t+1] = Def.Quad{
		InitCommand = function (self)
			self:zoomto(frameWidth,frameHeight)
			self:halign(0):valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end
	}

	-- Box text
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(5, 10)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Available Playlists")
		end;
	}

	-- Add playlist button
	t[#t+1] = quadButton(6) .. {
		Name = "Add Button";
		InitCommand = function(self)
			self:xy(frameWidth-50-10, itemY - 30)
			self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
			self:zoomto(100, 20)
		end;
		TopPressedCommand = function(self)
			-- Doesn't work yet outside of ScreenSelectMusic apparently.
			addPlaylist()
			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end;
	}

	-- Add playlist button text
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth-50-10, itemY - 30)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("New Playlist")
		end;
	}

	for i=1, maxItems do
		t[#t+1] = item(i)
	end

	return t
end

-- Displays the steps when a playlist is clicked
local function playlistStepsList()

	local frameWidth = 430
	local itemWidth = frameWidth-30
	local itemHeight = 25

	local itemX = 20
	local itemY = 70+itemHeight/2
	local itemYSpacing = 5
	local itemCount = maxItems-1

	local function item(i)
		local song
		local steps
		local rate
		local hidden = true -- Ignore button inputs if true

		local stepsIndex = (curStepsPage-1)*itemCount+i-1

		local t = Def.ActorFrame{
			InitCommand = function(self)
				self:diffusealpha(0)
				self:xy(itemX, itemY + (i-1)*(itemHeight+itemYSpacing)-10)
				self:playcommand("Hide")
			end;
			ShowCommand = function(self)
				hidden = false
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing)-10)
				self:diffusealpha(0)
				self:finishtweening()
				self:sleep((i-1)*0.03)
				self:easeOut(1)
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing))
				self:diffusealpha(1)
			end;
			HideCommand = function(self)
				song = nil
				steps = nil
				hidden = true
				self:y(SCREEN_HEIGHT*10)
			end;
			ShowPlaylistDetailMessageCommand = function(self, params)
				local key = params.playlist:GetChartkeys()[stepsIndex]
				if not key then
					return
				end
				song = SONGMAN:GetSongByChartKey(key)
				steps = SONGMAN:GetStepsByChartKey(key)

				self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
				self:playcommand("Show")
			end;
			HidePlaylistDetailMessageCommand = function(self)
				self:stoptweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
				self:queuecommand("Hide")
			end;
			UpdateStepsListMessageCommand = function(self)
				if not detail then
					return
				end

				stepsIndex = (curStepsPage-1)*itemCount+i-1
				local key = playlist:GetChartkeys()[stepsIndex]
				if not key then
					self:stoptweening()
					self:easeOut(0.5)
					self:diffusealpha(0)
					self:queuecommand("Hide")
					return
				elseif steps and key == steps:GetChartKey() then
					return
				end

				song = SONGMAN:GetSongByChartKey(key)
				steps = SONGMAN:GetStepsByChartKey(key)

				self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
				self:playcommand("Show")
			end;
		}

		t[#t+1] = quadButton(6) .. {
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(itemWidth, itemHeight)
			end;
			TopPressedCommand = function(self, params)
				self:finishtweening()
				self:diffusealpha(0.4)
				self:smooth(0.3)
				self:diffusealpha(0.2)
			end;
			SetCommand = function(self)
				self:diffusealpha(0.2)
			end;
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(-10,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
			end;
			SetCommand = function(self)
				self:settextf("%d", stepsIndex)
			end;
		}

		t[#t+1] = Def.Quad{
			Name = "Status";
			InitCommand = function(self)
				self:halign(0)
				self:diffuse(color(colorConfig:get_data().main.highlight))
				self:diffusealpha(0.8)
				self:xy(0, 0)
				self:zoomto(3, itemHeight)
			end;
			SetCommand = function(self)
				self:diffuse(getMainColor("highlight"))
			end;
		}

		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(20,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end;
			SetCommand = function(self)
				self:settextf("%5.2f",steps:GetMSD(1, 1))
			end
		}

		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(40,-6):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end;
			SetCommand = function(self)
				self:settextf("%s",song:GetMainTitle())
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			Name = "Size";
			InitCommand  = function(self)
				self:xy(40,5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
			end;
			SetCommand = function(self)
				self:settextf("// %s",song:GetDisplayArtist())
			end
		}

		t[#t+1] = quadButton(7) .. {
			Name = "Remove";
			InitCommand = function(self)
				self:xy(itemWidth-5-20, 0)
				self:zoomto(40, 17)
			end;
			TopPressedCommand = function(self)
				if not playlist or hidden then
					return
				end

				playlist:DeleteChart(stepsIndex)
				MESSAGEMAN:Broadcast("UpdateStepsList")

				self:finishtweening()
				self:diffusealpha(1)
				self:smooth(0.3)
				self:diffusealpha(0.8)
			end;
			SetCommand = function(self)
				if song and steps then
					self:diffuse(color(colorConfig:get_data().main.negative)):diffusealpha(0.8)
				else
					self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
				end
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(itemWidth-5-20, 0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:settextf("Remove")
			end;
		}

		t[#t+1] = quadButton(7) .. {
			Name = "Play";
			InitCommand = function(self)
				self:xy(itemWidth-10-60, 0)
				self:zoomto(40, 17)
			end;
			TopPressedCommand = function(self)
				if not playlist or hidden then
					return
				end

				SCREENMAN:GetTopScreen():Cancel()
				MESSAGEMAN:Broadcast("MoveMusicWheelToSong",{song = song})

				self:finishtweening()
				self:diffusealpha(1)
				self:smooth(0.3)
				self:diffusealpha(0.8)
			end;
			SetCommand = function(self)
				if song and steps then
					self:diffuse(color(colorConfig:get_data().main.positive)):diffusealpha(0.8)
				else
					self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
				end
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(itemWidth-10-60, 0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:settextf("Play")
			end;
		}

		return t
	end

	local t = Def.ActorFrame{
		ShowPlaylistDetailMessageCommand = function(self, params)
			playlist = params.playlist
			maxPlaylistPages = math.ceil(playlist:GetNumCharts()/(itemCount))
		end;
		UpdateStepsListMessageCommand = function(self)
			if playlist then
				maxPlaylistPages = math.ceil(playlist:GetNumCharts()/(itemCount))
			end
		end;
	}


	for i=1, itemCount do
		t[#t+1] = item(i+1)
	end

	return t
end


-- Parent actorframe
local t = Def.ActorFrame{
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
		MESSAGEMAN:Broadcast("UpdateList")
	end;
}

t[#t+1] = playlistInfo() .. {
	InitCommand = function(self)
		self:xy(10,30)
		self:delayedFadeIn(1)
	end
}

t[#t+1] = playlistList() .. {
	InitCommand = function(self)
		self:xy(320,30)
		self:delayedFadeIn(2)
	end
}

t[#t+1] = playlistStepsList() .. {
	InitCommand = function(self)
		self:xy(320,30)
	end
}

t[#t+1] = LoadActor("../_mouse")
t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("../_cursor")

return t