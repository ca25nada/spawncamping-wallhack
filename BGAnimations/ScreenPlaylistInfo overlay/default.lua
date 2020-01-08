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
local chartlist
local stepslist = {}
local maxPlaylistPages

local playlists = SONGMAN:GetPlaylists()
local maxPages = math.ceil(#playlists/maxItems)
local top

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


local function updatePlaylists()
	detail = false
	playlists = SONGMAN:GetPlaylists()
	maxPages = math.ceil(#playlists/maxItems)
	MESSAGEMAN:Broadcast("UpdateList")
end

-- NOTE: 
-- Doesn't work as SONGMAN:NewPlaylist() failed to add the playlist outside of ScreenSelectMusic.
-- Creates a new playlist and updates the screen.
local function addPlaylist()
	SONGMAN:NewPlaylist()
	detail = false
	updatePlaylists()
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

		if event.DeviceInput.button == "DeviceButton_mousewheel up" then
			movePage(-1)
		end
		if event.DeviceInput.button == "DeviceButton_mousewheel down" then
			movePage(1)
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
		end,
		ShowPlaylistDetailMessageCommand = function(self, params)
			playlist = params.playlist
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end,
		HidePlaylistDetailMessageCommand = function(self)
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end,
		DisplayAllMessageCommand = function(self)
			updatePlaylists()
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

	t[#t+1] = Def.Sprite {
		InitCommand = function (self)
			self:xy(frameWidth/2, 50):valign(0)
			local bnpath = THEME:GetPathG("Common", "fallback banner")
			self:LoadBackground(bnpath)
			self:zoomto(256,80)
		end
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth/2, 80+50+10)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		end,
		SetCommand = function(self)
			if playlist and detail then
				self:settext(playlist:GetName())
			else
				self:settext("No Playlist Selected")
			end
		end
	}


	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(5, 10)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Playlist Info")
		end
	}

	-- Delete Button
	t[#t+1] = quadButton(6) .. {
		Name = "Delete Button",
		InitCommand = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*3-10)
			self:zoomto(buttonWidth, buttonHeight)
		end,
		MouseDownCommand = function(self)
			if not playlist or not detail then
				return
			end

			deletePlaylist(playlist)

			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end,
		SetCommand = function(self)
			if playlist and detail then
				self:diffuse(color(colorConfig:get_data().main.negative)):diffusealpha(0.8)
			else
				self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
			end
		end
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*3-10)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Delete Playlist")
		end
	}

	--[[
	t[#t+1] = quadButton(6) .. {
		Name = "Rename Button",
		InitCommand = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*3-10*2)
			self:zoomto(buttonWidth, buttonHeight)
		end,
		MouseDownCommand = function(self)
			-- force this to do nothing for now since renaming doesnt exist
			if true or not playlist or not detail then
				return
			end
			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end,
		SetCommand = function(self)
			--if playlist and detail then
				--self:diffuse(color(colorConfig:get_data().main.warning)):diffusealpha(0.8)
			--else
				self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
			--end
		end
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*3-10*2)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Rename Playlist")
		end
	}]]

	t[#t+1] = quadButton(6) .. {
		Name = "Add Button",
		InitCommand = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*5-10*2)
			self:zoomto(buttonWidth, buttonHeight)
		end,
		MouseDownCommand = function(self)
			if not playlist or not detail then
				return
			end

			playlist:AddChart(steps:GetChartKey())
			chartlist = playlist:GetAllSteps()
			MESSAGEMAN:Broadcast("UpdateStepsList")

			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end,
		SetCommand = function(self)
			if playlist and detail then
				self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
			else
				self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
			end
		end
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*5-10*2)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Add Current Song to Playlist")
		end
	}

	t[#t+1] = quadButton(6) .. {
		Name = "Play Button",
		InitCommand = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*7-10*3)
			self:zoomto(buttonWidth, buttonHeight)
		end,
		MouseDownCommand = function(self)
			if not playlist or not playlist:IsPlayable() or not detail then
				return
			end

			playPlaylist(playlist)

			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end,
		UpdateStepsListMessageCommand = function(self)
			self:playcommand("Set")
		end,
		SetCommand = function(self)
			if playlist and playlist:IsPlayable() and detail then
				self:diffuse(color(colorConfig:get_data().main.positive)):diffusealpha(0.8)
			else
				self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
			end
		end
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*7-10*3)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Play Playlist")
		end
	}

	return t
end

-- Displays available playlists
local function playlistList()

	local frameWidth = capWideScale(300, 430)
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
			end,
			ShowCommand = function(self)
				hidden = false
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing)-10)
				self:diffusealpha(0)
				self:finishtweening()
				self:sleep((i-1)*0.03)
				self:easeOut(1)
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing))
				self:diffusealpha(1)
			end,
			HideCommand = function(self)
				hidden = true
				self:y(SCREEN_HEIGHT*10)
			end,
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
			end,
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
			end,
			HidePlaylistDetailMessageCommand = function(self)
				if playlist then 
					self:playcommand("Show")
				end
			end,
			UpdateStepsListMessageCommand = function(self)
				if playlist then
					playlistIndex = (curPage-1)*maxItems+i
					self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
				end
			end
		}

		t[#t+1] = quadButton(6) .. {
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(itemWidth, itemHeight)
			end,
			MouseDownCommand = function(self, params)
				if hidden then
					return
				end

				if params.button == "DeviceButton_left mouse button" then
					if not detail and playlist then
						detail = true
						chartlist = playlist:GetAllSteps()
						stepslist = {}
						local keylist = playlist:GetChartkeys()
						for j = 1, #keylist do
							stepslist[j] = SONGMAN:GetStepsByChartKey(keylist[j])
						end
						MESSAGEMAN:Broadcast("ShowPlaylistDetail", {playlist = playlist, playlistIndex = playlistIndex, index = i})
					end

				elseif params.button == "DeviceButton_right mouse button" then
					detail = false
					MESSAGEMAN:Broadcast("HidePlaylistDetail")
				end

				self:finishtweening()
				self:diffusealpha(0.4)
				self:smooth(0.3)
				self:diffusealpha(0.2)
			end,

			SetCommand = function(self)
				self:diffusealpha(0.2)
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(-10,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				self:settextf("%d", playlistIndex)
			end,
			ShowPlaylistDetailMessageCommand = function(self)
				self:easeOut(0.5)
				self:diffusealpha(0)
			end,
			HidePlaylistDetailMessageCommand = function(self)
				self:easeOut(0.5)
				self:diffusealpha(1)
			end
		}

		t[#t+1] = Def.Quad{
			Name = "Status",
			InitCommand = function(self)
				self:halign(0)
				self:diffuse(color(colorConfig:get_data().main.highlight))
				self:diffusealpha(0.8)
				self:xy(0, 0)
				self:zoomto(3, itemHeight)
			end,
			SetCommand = function(self)
				self:diffuse(getMainColor("highlight"))
			end
		}

		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(20,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				local msd = playlist:GetAverageRating()
				self:settextf("%5.2f",playlist:GetAverageRating())
				self:diffuse(getMSDColor(msd))
			end
		}

		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(40,-6):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				self:settextf("%s",playlist:GetName())
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			Name = "Size",
			InitCommand  = function(self)
				self:xy(40,5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				self:settextf("%s Steps",#playlist:GetStepslist())
			end
		}

		--[[ --kind of redundant
		t[#t+1] = quadButton(7) .. {
			Name = "Add",
			InitCommand = function(self)
				self:xy(itemWidth-5-20, 0)
				if song and steps then
					self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
				else
					self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
				end
				self:zoomto(40, 17)
			end,
			MouseDownCommand = function(self)
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
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(itemWidth-5-20, 0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:settextf("Add")
			end
		}
		]]

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
		end
	}

	-- Add playlist button
	t[#t+1] = quadButton(6) .. {
		Name = "Add Button",
		InitCommand = function(self)
			self:xy(frameWidth-50-10, itemY - 30)
			self:zoomto(100, 20)
			self:playcommand("Set")
		end,
		MouseDownCommand = function(self)
			-- Doesn't work yet outside of ScreenSelectMusic apparently.
			if detail then return end
			addPlaylist()
			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end,
		SetCommand = function(self)
			if detail then
				self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
			else
				self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
			end
		end,
		HidePlaylistDetailMessageCommand = function(self)
			self:playcommand("Set")
		end,
		ShowPlaylistDetailMessageCommand = function(self)
			self:playcommand("Set")
		end
	}

	-- Add playlist button text
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth-50-10, itemY - 30)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("New Playlist")
		end
	}

	for i=1, maxItems do
		t[#t+1] = item(i)
	end

	return t
end

-- Displays the steps when a playlist is clicked
local function playlistStepsList()

	local frameWidth = capWideScale(300, 430)
	local itemWidth = frameWidth-30
	local itemHeight = 25

	local itemX = 20
	local itemY = 70+itemHeight/2
	local itemYSpacing = 5
	local itemCount = maxItems-1
	local selectedStepsIndex = -1 -- -1 for no selection

	local function item(i)
		local song
		local steps
		local rate
		local hidden = true -- Ignore button inputs if true

		local stepsIndex = (curStepsPage-1)*itemCount+i-1

		local t = Def.ActorFrame{
			Name = "StepsItem"..i,
			InitCommand = function(self)
				self:diffusealpha(0)
				self:xy(itemX, itemY + (i-1)*(itemHeight+itemYSpacing)-10)
				self:playcommand("Hide")
			end,
			ShowCommand = function(self)
				hidden = false
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing)-10)
				self:diffusealpha(0)
				self:finishtweening()
				self:sleep((i-1)*0.03)
				self:easeOut(1)
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing))
				self:diffusealpha(1)
			end,
			HideCommand = function(self)
				song = nil
				steps = nil
				hidden = true
				self:y(SCREEN_HEIGHT*10)
			end,
			ShowPlaylistDetailCommand = function(self, params)
				local key = params.playlist:GetChartkeys()[stepsIndex]
				if not key then
					return
				end
				song = SONGMAN:GetSongByChartKey(key)
				steps = SONGMAN:GetStepsByChartKey(key)

				self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
				self:playcommand("Show")
			end,
			HidePlaylistDetailMessageCommand = function(self)
				self:stoptweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
				self:queuecommand("Hide")
			end,
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
				end

				song = SONGMAN:GetSongByChartKey(key)
				steps = SONGMAN:GetStepsByChartKey(key)

				self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
				self:playcommand("Show")
			end,
			SetStepsListMessageCommand = function(self)
				local key = playlist:GetChartkeys()[stepsIndex]
				if not key then return end
				self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
			end
		}

		t[#t+1] = quadButton(6) .. {
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(itemWidth, itemHeight)
			end,
			MouseDownCommand = function(self)
				self:finishtweening()
				self:diffusealpha(0.4)
				selectedStepsIndex = stepsIndex
				MESSAGEMAN:Broadcast("MadeStepsSelection")
			end,
			SetCommand = function(self)
				if selectedStepsIndex == stepsIndex then
					self:diffusealpha(0.4)
				else
					self:diffusealpha(0.2)
				end
			end,
			MadeStepsSelectionMessageCommand = function(self)
				self:playcommand("Set")
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(-10,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				self:settextf("%d", stepsIndex)
			end
		}

		t[#t+1] = getClearTypeLampQuad(3, itemHeight)..{
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.8)
			end,
			SetCommand = function(self)
				local scoreList = getScoreTable(pn, '1.0x', steps)
				self:playcommand("SetClearType", {clearType = getHighestClearType(pn,steps,scoreList)})
			end
		}

		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(20,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				if steps then
					local msd = steps:GetMSD(chartlist[stepsIndex]:GetRate(), 1)
					self:settextf("%5.2f", msd)
					self:diffuse(getMSDColor(msd))
				else
					self:settext("0.00")
					self:diffuse(color("#666666"))
				end
			end
		}

		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(40,-6):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
				self:maxwidth((itemWidth - 40 - 10-60 - 40/2 - 10 - 20) / 0.4)
			end,
			SetCommand = function(self)
				self:settext(chartlist[stepsIndex]:GetSongTitle())
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			Name = "Artist",
			InitCommand  = function(self)
				self:xy(40,5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:maxwidth((itemWidth - 40 - 10-60 - 40/2 - 10 - 20) / 0.3)
			end,
			SetCommand = function(self)
				if song then
					self:settextf("// %s",song:GetDisplayArtist())
				else
					self:settext("//")
				end
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			Name = "Rate",
			InitCommand  = function(self)
				self:xy(itemWidth-10-60 - 40/2 - 10, 0):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:halign(1)
			end,
			SetCommand = function(self)
				if not playlist then
					self:settext("")
					return
				end
				local ratestr = string.format("%.2f", chartlist[stepsIndex]:GetRate()):gsub("%.?0+$", "") .. "x"
				self:settext(ratestr)
			end
		}

		t[#t+1] = quadButton(7) .. {
			Name = "Remove",
			InitCommand = function(self)
				self:xy(itemWidth-5-20, 0)
				self:zoomto(40, 17)
			end,
			MouseDownCommand = function(self)
				if not playlist or hidden then
					return
				end

				playlist:DeleteChart(stepsIndex)
				MESSAGEMAN:Broadcast("UpdateStepsList")

				self:finishtweening()
				self:diffusealpha(1)
				self:smooth(0.3)
				self:diffusealpha(0.8)
			end,
			SetCommand = function(self)
				--if song and steps then
				self:diffuse(color(colorConfig:get_data().main.negative)):diffusealpha(0.8)
				--else
				--	self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
				--end
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(itemWidth-5-20, 0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
				self:settextf("Remove")
			end
		}

		t[#t+1] = quadButton(7) .. {
			Name = "Play",
			InitCommand = function(self)
				self:xy(itemWidth-10-60, 0)
				self:zoomto(40, 17)
			end,
			MouseDownCommand = function(self)
				if not playlist or hidden or not song or not steps then
					return
				end

				SCREENMAN:GetTopScreen():Cancel()
				MESSAGEMAN:Broadcast("MoveMusicWheelToSong",{song = song})

				self:finishtweening()
				self:diffusealpha(1)
				self:smooth(0.3)
				self:diffusealpha(0.8)
			end,
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
				self:settextf("Go To")
			end
		}

		return t
	end

	local t = Def.ActorFrame{
		ShowPlaylistDetailMessageCommand = function(self, params)
			playlist = params.playlist

			maxPlaylistPages = math.ceil(playlist:GetNumCharts()/(itemCount))
			selectedStepsIndex = -1
			self:RunCommandsOnChildren(function(self) self:playcommand("ShowPlaylistDetail", params) end)
		end,
		HidePlaylistDetailMessageCommand = function(self)
			selectedStepsIndex = -1
		end,
		UpdateStepsListMessageCommand = function(self)
			selectedStepsIndex = -1
			if playlist then
				maxPlaylistPages = math.ceil(playlist:GetNumCharts()/(itemCount))
			end
		end
	}

	-- Edit Rate Button up
	t[#t+1] = quadButton(6) .. {
		Name = "Edit Rate Up",
		InitCommand = function(self)
			self:xy(frameWidth-50-10, itemY + 20 + maxItems * (itemHeight + itemYSpacing))
			self:halign(0)
			self:zoomto(50, 20)
			self:playcommand("Set")
		end,
		MouseDownCommand = function(self)
			if not detail or selectedStepsIndex == -1 then return end
			self:finishtweening()
			self:diffusealpha(1)
			chartlist[selectedStepsIndex]:ChangeRate(0.05)
			self:smooth(0.3)
			self:diffusealpha(0.8)
			MESSAGEMAN:Broadcast("SetStepsList")
		end,
		SetCommand = function(self)
			if detail and selectedStepsIndex ~= -1 then
				self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
			else
				self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
			end
		end,
		MadeStepsSelectionMessageCommand = function(self)
			self:playcommand("Set")
		end,
		HidePlaylistDetailMessageCommand = function(self)
			self:playcommand("Set")
		end,
		ShowPlaylistDetailMessageCommand = function(self)
			self:playcommand("Set")
		end,
		UpdateStepsListMessageCommand = function(self)
			self:queuecommand("Set")
		end
	}
	-- Edit Rate Button down
	t[#t+1] = quadButton(6) .. {
		Name = "Edit Rate Down",
		InitCommand = function(self)
			self:xy(frameWidth-50-10, itemY + 20 + maxItems * (itemHeight + itemYSpacing))
			self:halign(1)
			self:zoomto(50, 20)
			self:playcommand("Set")
		end,
		MouseDownCommand = function(self)
			if not detail or selectedStepsIndex == -1 then return end
			self:finishtweening()
			self:diffusealpha(1)
			chartlist[selectedStepsIndex]:ChangeRate(-0.05)
			self:smooth(0.3)
			self:diffusealpha(0.8)
			MESSAGEMAN:Broadcast("SetStepsList")
		end,
		SetCommand = function(self)
			if detail and selectedStepsIndex ~= -1 then
				self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
			else
				self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
			end
		end,
		MadeStepsSelectionMessageCommand = function(self)
			self:playcommand("Set")
		end,
		HidePlaylistDetailMessageCommand = function(self)
			self:playcommand("Set")
		end,
		ShowPlaylistDetailMessageCommand = function(self)
			self:playcommand("Set")
		end,
		UpdateStepsListMessageCommand = function(self)
			self:queuecommand("Set")
		end
	}

	-- Edit Rate text
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth-50-10, itemY + maxItems * (itemHeight + itemYSpacing))
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Rate")
		end
	}
	-- Edit Rate button text up
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth-50-10 + 25, itemY + 20 + maxItems * (itemHeight + itemYSpacing))
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("+")
		end
	}
	-- Edit Rate button text up
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth-50-10 - 25, itemY + 20 + maxItems * (itemHeight + itemYSpacing))
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("-")
		end
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
	end
}

t[#t+1] = playlistInfo() .. {
	InitCommand = function(self)
		self:xy(10,30)
	end
}

t[#t+1] = playlistList() .. {
	InitCommand = function(self)
		self:xy(320,30)
	end
}

t[#t+1] = playlistStepsList() .. {
	InitCommand = function(self)
		self:xy(320,30)
	end
}

t[#t+1] = LoadActor("../_mouse", "ScreenPlaylistInfo")
t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("../_cursor")

return t