
local maxItems = 10
local curPage = 1
local playlists = SONGMAN:GetPlaylists()
local maxPages = math.ceil(#playlists/maxItems)

local pn = GAMESTATE:GetEnabledPlayers()[1]
local steps = GAMESTATE:GetCurrentSteps(pn)
local song = GAMESTATE:GetCurrentSong()

local function movePage(n)
	if n > 0 then 
		curPage = ((curPage+n-1) % maxPages + 1)
	else
		curPage = ((curPage+n+maxPages-1) % maxPages+1)
	end
	MESSAGEMAN:Broadcast("UpdateList")
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

	local playlist = SONGMAN:GetActivePlaylist()

	local t = Def.ActorFrame{
		InitCommand = function(self)
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
		Name = "Delete Button";
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
		Name = "Delete Button";
		InitCommand = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*5-10*3)
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
		Name = "Delete Button";
		InitCommand = function(self)
			self:xy(frameWidth/2, frameHeight-buttonHeight/2*7-10*4)
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
		local playlistIndex = (curPage-1)*10+i

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
			end;
			UpdateListMessageCommand = function(self) -- Pack List updates (e.g. new page)
				packIndex = (curPage-1)*10+i
				if playlists[playlistIndex] ~= nil then
					playlist = playlists[playlistIndex]
					self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
					self:playcommand("Show")
				else
					self:playcommand("Hide")
				end
			end;
		}

		t[#t+1] = quadButton(6) .. {
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(itemWidth, itemHeight)
			end;
			TopPressedCommand = function(self)
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









t[#t+1] = LoadActor("../_mouse")
t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("../_cursor")

return t