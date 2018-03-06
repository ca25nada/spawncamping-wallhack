
local maxItems = 10
local curPage = 1
local curStepsPage = 1

local playlist
local maxPlaylistPages

local playlists = SONGMAN:GetPlaylists()
local maxPages = math.ceil(#playlists/maxItems)

local pn = GAMESTATE:GetEnabledPlayers()[1]
local steps = GAMESTATE:GetCurrentSteps(pn)
local song = GAMESTATE:GetCurrentSong()

local detail = false

local function movePage(n)
	if detail then
		if n > 0 then 
			curStepsPage = ((curStepsPage+n-1) % maxPlaylistPages + 1)
		else
			curStepsPage = ((curStepsPage+n+maxPlaylistPages-1) % maxPlaylistPages+1)
		end
		MESSAGEMAN:Broadcast("UpdateStepsList")
	else
		if n > 0 then 
			curPage = ((curPage+n-1) % maxPages + 1)
		else
			curPage = ((curPage+n+maxPages-1) % maxPages+1)
		end
		MESSAGEMAN:Broadcast("UpdateList")
	end
end

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

local t = Def.ActorFrame{
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
		MESSAGEMAN:Broadcast("UpdateList")
	end;
}

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
			MESSAGEMAN:Broadcast("PlaylistChanged")

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
			if not playlist then
				return
			end

			MESSAGEMAN:Broadcast("StartPlaylist",{playlist = playlist})
			SCREENMAN:GetTopScreen():Cancel()

			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end;
		SetCommand = function(self)
			if playlist then
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

local function playlistList()

	local frameWidth = 430
	local frameHeight = SCREEN_HEIGHT - 60

	local t = Def.ActorFrame{}

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
			self:settext("Available Playlists")
		end;
	}


	local itemWidth = frameWidth-30
	local itemHeight = 25

	local itemX = 20
	local itemY = 70+itemHeight/2
	local itemYSpacing = 5

	t[#t+1] = quadButton(6) .. {
		Name = "Delete Button";
		InitCommand = function(self)
			self:xy(frameWidth-50-10, itemY - 30)
			self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
			self:zoomto(100, 20)
		end;
		TopPressedCommand = function(self)
			self:finishtweening()
			self:diffusealpha(1)
			self:smooth(0.3)
			self:diffusealpha(0.8)
		end;
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(frameWidth-50-10, itemY - 30)
			self:zoom(0.4)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("New Playlist")
		end;
	}

	local function item(i)
		local playlist
		local playlistIndex = (curPage-1)*maxItems+i

		local t = Def.ActorFrame{
			InitCommand = function(self)
				self:diffusealpha(0)
				self:xy(itemX, itemY + (i-1)*(itemHeight+itemYSpacing)-10)
				self:playcommand("Show")
			end;
			ShowCommand = function(self)
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing)-10)
				self:diffusealpha(0)
				self:finishtweening()
				self:sleep((i-1)*0.03)
				self:easeOut(1)
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing))
				self:diffusealpha(1)
			end;
			HideCommand = function(self)
				self:stoptweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
				self:y(SCREEN_HEIGHT*10) -- Throw it offscreen
			end;
			UpdateListMessageCommand = function(self) -- Pack List updates (e.g. new page)
				playlistIndex = (curPage-1)*10+i
				if playlists[playlistIndex] ~= nil then
					playlist = playlists[playlistIndex]
					self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
					self:playcommand("Show")
				else
					self:playcommand("Hide")
				end
			end;
			ShowPlaylistDetailMessageCommand = function(self, params)
				if params.index == i then
					detail = true
					self:finishtweening()
					self:easeOut(0.5)
					self:y(itemY)
					self:valign(0)
				else
					self:playcommand("Hide")
				end
			end;
			HidePlaylistDetailMessageCommand = function(self)
				detail = false
				if playlist ~= nil then 
					self:playcommand("Show")
				end
			end;
			PlaylistChangedMessageCommand = function(self)
				self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
			end;
		}

		t[#t+1] = quadButton(6) .. {
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(itemWidth, itemHeight)
			end;
			TopPressedCommand = function(self, params)
				if params.input == "DeviceButton_left mouse button" then
					if not detail and playlist then
						MESSAGEMAN:Broadcast("ShowPlaylistDetail", {playlist = playlist, playlistIndex = playlistIndex, index = i})
					end

				elseif params.input == "DeviceButton_right mouse button" then
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
				if not (steps and song) then
					return
				end
				SONGMAN:SetActivePlaylist(playlist:GetName())
				playlist:AddChart(steps:GetChartKey())
				MESSAGEMAN:Broadcast("PlaylistChanged")
				self:GetParent():RunCommandsOnChildren(function(self) self:playcommand("Set") end)

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

	for i=1, maxItems do
		t[#t+1] = item(i)
	end

	return t
end

local function playlistStepsList()


	local frameWidth = 430
	local frameHeight = SCREEN_HEIGHT - 60

	local itemWidth = frameWidth-30
	local itemHeight = 25

	local itemX = 20
	local itemY = 70+itemHeight/2
	local itemYSpacing = 5
	local itemCount = maxItems-1

	local t = Def.ActorFrame{
		ShowPlaylistDetailMessageCommand = function(self, params)
			playlist = params.playlist
			maxPlaylistPages = math.ceil(playlist:GetNumCharts()/(itemCount))
		end;
		PlaylistChangedMessageCommand = function(self)
			if playlist then
				maxPlaylistPages = math.ceil(playlist:GetNumCharts()/(itemCount))
			end
		end;
	}

	local function item(i)
		local song
		local steps
		local rate

		local stepsIndex = (curStepsPage-1)*itemCount+i-1

		local t = Def.ActorFrame{
			InitCommand = function(self)
				self:diffusealpha(0)
				self:xy(itemX, itemY + (i-1)*(itemHeight+itemYSpacing)-10)
				self:playcommand("Hide")
			end;
			ShowCommand = function(self)
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing)-10)
				self:diffusealpha(0)
				self:finishtweening()
				self:sleep((i-1)*0.03)
				self:easeOut(1)
				self:y(itemY + (i-1)*(itemHeight+itemYSpacing))
				self:diffusealpha(1)
			end;
			HideCommand = function(self)
				self:stoptweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
				self:y(SCREEN_HEIGHT*10) -- Throw it offscreen
			end;
			UpdateStepsListMessageCommand = function(self)
				stepsIndex = (curStepsPage-1)*itemCount+i-1
				local key = playlist:GetChartkeys()[stepsIndex]
				if not key then
					self:playcommand("Hide")
					return
				end
				song = SONGMAN:GetSongByChartKey(key)
				steps = SONGMAN:GetStepsByChartKey(key)

				self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
				self:playcommand("Show")
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
				self:playcommand("Hide")
			end;
			PlaylistChangedMessageCommand = function(self)
				if not detail then
					return
				end

				stepsIndex = (curStepsPage-1)*itemCount+i-1
				local key = playlist:GetChartkeys()[stepsIndex]
				if not key then
					self:playcommand("Hide")
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
				if not playlist then
					return
				end

				playlist:DeleteChart(stepsIndex)
				MESSAGEMAN:Broadcast("PlaylistChanged")

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
				if not playlist then
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

	for i=1, itemCount do
		t[#t+1] = item(i+1)
	end

	return t
end


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









t[#t+1] = LoadActor("../_mouse")
t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("../_cursor")

return t