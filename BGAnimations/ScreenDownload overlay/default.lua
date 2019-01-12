local top

local packlist = DLMAN:GetPackList()
local downloading = DLMAN:GetDownloadingPacks()

-- make lookup table for installed packs
local installedPacks = {}
for k,v in pairs(SONGMAN:GetSongGroupNames()) do
	installedPacks[v] = true
end

local maxItems = 10
local maxPages = math.ceil(#packlist/maxItems)
local curPage = 1



local function movePage(n)
	if n > 0 then 
		curPage = ((curPage+n-1) % maxPages + 1)
	else
		curPage = ((curPage+n+maxPages-1) % maxPages+1)
	end
	MESSAGEMAN:Broadcast("UpdateList")
end

local function packExists(group)
	if installedPacks[group] then
		return true
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

local downloading = DLMAN:GetDownloadingPacks()
local function update(self, delta)
	for _,pack in ipairs(downloading) do
		local download = pack:GetDownload()
		self:GetChild("PackList"):playcommand("DownloadStatus", {pack = pack, download = download})
	end

end

local t = Def.ActorFrame {
	OnCommand = function(self)

		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
		self:SetUpdateFunction(update)
		MESSAGEMAN:Broadcast("UpdateList")
	end
}



local function packInfo()
	local frameWidth = 300
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
			self:settext("Pack Info")
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
			self:settext("A REALLY LONG SIMFILE PACK TITLE")
		end
	}

	return t
end

local function packList()
	local frameWidth = 430
	local frameHeight = SCREEN_HEIGHT - 60

	local t = Def.ActorFrame{
		DownloadStatusCommand = function(self, params)
			self:RunCommandsOnChildren(function(self) self:playcommand("DownloadStatus", params) end)
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
			self:settext("Simfile Packs")
		end
	}

	local packItemWidth = frameWidth-30
	local packItemHeight = 25

	local packItemX = 20
	local packItemY = 70+packItemHeight/2
	local packItemYSpacing = 5

	local function packItem(i)
		local download
		local packIndex = (curPage-1)*10+i

		local t = Def.ActorFrame{
			InitCommand = function(self)
				self:diffusealpha(0)
				self:xy(packItemX, packItemY + (i-1)*(packItemHeight+packItemYSpacing)-10)
				self:playcommand("Show")
			end,
			ShowCommand = function(self)
				self:y(packItemY + (i-1)*(packItemHeight+packItemYSpacing)-10)
				self:diffusealpha(0)
				self:finishtweening()
				self:sleep((i-1)*0.03)
				self:easeOut(1)
				self:y(packItemY + (i-1)*(packItemHeight+packItemYSpacing))
				self:diffusealpha(1)
			end,
			HideCommand = function(self)
				self:stoptweening()
				self:easeOut(0.5)
				self:diffusealpha(0)
			end,
			UpdateListMessageCommand = function(self) -- Pack List updates (e.g. new page)
				packIndex = (curPage-1)*10+i
				if packlist[packIndex] ~= nil then
					self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
					self:playcommand("Show")
				else
					self:playcommand("Hide")
				end
			end,
			DownloadStatusCommand = function(self, params) -- Download status update from updatefunction
				if not params.download then
					return 
				end

				if params.pack == packlist[packIndex] then
					download = params.download

					self:GetChild("Status"):diffuse(color(colorConfig:get_data().downloadStatus.downloading)):diffusealpha(0.8)
					self:GetChild("ProgressBar"):diffuse(color(colorConfig:get_data().downloadStatus.downloading)):diffusealpha(0.2)
					self:GetChild("Size"):settextf("Downloading %5.2f MB / %5.2f MB", download:GetKBDownloaded()/1048576, download:GetTotalKB()/1048576)
					self:GetChild("ProgressBar"):zoomx(download:GetKBDownloaded()/download:GetTotalKB()*packItemWidth)
				end
			end,
			StartDownloadCommand = function(self) -- Start download
				download = packlist[packIndex]:DownloadAndInstall()

				-- Will crash the game if the pack is already downloaded for the time being.
				downloading = DLMAN:GetDownloadingPacks()

				self:GetChild("Status"):diffuse(color(colorConfig:get_data().downloadStatus.downloading)):diffusealpha(0.8)
				self:GetChild("ProgressBar"):diffuse(color(colorConfig:get_data().downloadStatus.downloading)):diffusealpha(0.2)
			end,
			StopDownloadCommand = function(self) -- Stop download
				download:Stop()
				downloading = DLMAN:GetDownloadingPacks()
				self:GetChild("Status"):playcommand("Set")
				self:GetChild("ProgressBar"):diffuse(color(colorConfig:get_data().downloadStatus.available)):diffusealpha(0.2)
				self:GetChild("Size"):settextf("Download Cancelled")
			end,
			FinishDownloadCommand = function(self) -- Download Finished
				downloading = DLMAN:GetDownloadingPacks()
				self:GetChild("Status"):diffuse(color(colorConfig:get_data().downloadStatus.completed)):diffusealpha(0.8)
				self:GetChild("ProgressBar"):diffuse(color(colorConfig:get_data().downloadStatus.completed)):diffusealpha(0.2)
				self:GetChild("Size"):settextf("Download Complete!")
			end,
			PackDownloadedMessageCommand = function(self, params) -- Download Stopped/Finished
				downloading = DLMAN:GetDownloadingPacks()
			end,
			DownloadFailedMessageCommand = function(self, params) -- Download Failed
				if packlist[packIndex]:GetName() == params.pack:GetName() then 
					downloading = DLMAN:GetDownloadingPacks()
					self:GetChild("Status"):playcommand("Set")
					self:GetChild("ProgressBar"):diffuse(color(colorConfig:get_data().downloadStatus.available)):diffusealpha(0.2)
					self:GetChild("Size"):settextf("Download Failed")
				end
			end
		}

		t[#t+1] = LoadFont("Common Normal")..{
			InitCommand  = function(self)
				self:xy(-10,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				self:settextf("%d", packIndex)
			end
		}

		t[#t+1] = Def.Quad{
			Name = "ProgressBar",
			InitCommand = function(self)
				self:halign(0)
				self:diffuse(color(colorConfig:get_data().main.highlight))
				self:diffusealpha(0)
				self:xy(0, 0)
				self:zoomy(packItemHeight)
			end,
			SetCommand = function(self)
				self:zoomx(0)
			end
		}

		t[#t+1] = quadButton(6) .. {
			Name = "Size",
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(packItemWidth, packItemHeight)
			end,
			TopPressedCommand = function(self)
				if packlist[packIndex]:IsDownloading() then -- IsDownloading() returns the wrong boolean for some reason.
					self:GetParent():playcommand("StartDownload")
				else
					self:GetParent():playcommand("StopDownload")
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

		t[#t+1] = Def.Quad{
			Name = "Status",
			InitCommand = function(self)
				self:halign(0)
				self:diffuse(color(colorConfig:get_data().main.highlight))
				self:diffusealpha(0.8)
				self:xy(0, 0)
				self:zoomto(3, packItemHeight)
			end,
			SetCommand = function(self)
				if packExists(packlist[packIndex]:GetName()) then
					self:diffuse(color(colorConfig:get_data().downloadStatus.downloaded)):diffusealpha(0.8)
				else
					self:diffuse(color(colorConfig:get_data().downloadStatus.available)):diffusealpha(0.8)
				end
			end
		}


		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(20,0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				local msd = packlist[packIndex]:GetAvgDifficulty()
				self:settextf("%5.2f",msd)
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
				self:settextf("%s",packlist[packIndex]:GetName())
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
				if packExists(packlist[packIndex]:GetName()) then
					self:settext("Downloaded (Or a pack with an identical name exists)")
				else
					self:settextf("Download %5.2f MB",packlist[packIndex]:GetSize()/1048576)
				end
			end
		}


		return t
	end

	for i=1, maxItems do
		t[#t+1] = packItem(i)
	end

	return t
end



t[#t+1] = packInfo() .. {
	InitCommand = function(self)
		self:xy(10,30)
		self:delayedFadeIn(1)
	end
}

t[#t+1] = packList() .. {
	Name = "PackList",
	InitCommand = function(self)
		self:xy(320,30)
		self:delayedFadeIn(2)
	end
}




t[#t+1] = LoadActor("../_mouse")
t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("../_cursor")

return t