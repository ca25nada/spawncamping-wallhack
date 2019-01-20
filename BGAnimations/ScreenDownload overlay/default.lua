local top

local initpacklist = PackList:new()
local packlist = initpacklist:GetPackTable()
local downloading = DLMAN:GetDownloadingPacks()

-- make lookup table for installed packs
local installedPacks = {}
local function refreshInstalledPacks()
	for k,v in pairs(SONGMAN:GetSongGroupNames()) do
		installedPacks[v] = true
	end
end
refreshInstalledPacks()

local function packExists(group)
	if installedPacks[group] then
		return true
	end
end

local maxItems = 10
local maxPages = math.ceil(#packlist/maxItems)
local curPage = 1

local sorts = {
	"ABC",
	"MSD",
	"Size",
	"Installed"
}
local curSort = 1
local ascending = true

local function moveSortForward()
	curSort = (curSort % 4) + 1
end

local function sortPacks()
	local rawsort = false
	if sorts[curSort] == "ABC" then
		initpacklist:SortByName()
	elseif sorts[curSort] == "MSD" then
		initpacklist:SortByDiff()
	elseif sorts[curSort] == "Size" then
		initpacklist:SortBySize()
	else
		ascending = not ascending
		table.sort(packlist, function(left, right)
			if not packExists(left:GetName()) and not packExists(right:GetName()) then
				return left:GetName() < right:GetName()
			else
				if ascending then
					return packExists(left:GetName()) and not packExists(right:GetName())
				else
					return not packExists(left:GetName()) and packExists(right:GetName())
				end
			end
		end)
		rawsort = true
	end
	if not rawsort then
		packlist = initpacklist:GetPackTable()
	end
end

local curInput = ""
local inputting = false

local function movePage(n)
	if maxPages > 1 then
		if n > 0 then 
			curPage = ((curPage+n-1) % maxPages + 1)
		else
			curPage = ((curPage+n+maxPages-1) % maxPages+1)
		end
	end
	MESSAGEMAN:Broadcast("UpdateList")
end

local function updateFilter()
	initpacklist:FilterAndSearch(
		tostring(curInput), 0, 0, 0, 0
	)
	packlist = initpacklist:GetPackTable()
	maxPages = math.ceil(#packlist/maxItems)
	MESSAGEMAN:Broadcast("UpdateList")
end

local function input(event)
	if event.type == "InputEventType_FirstPress" then

		if event.button == "MenuLeft" then
			movePage(-1)
		end

		if event.button == "MenuRight" then
			movePage(1)
		end

		if event.DeviceInput.button == "DeviceButton_mousewheel up" then
			MESSAGEMAN:Broadcast("WheelUpSlow")
		end
		if event.DeviceInput.button == "DeviceButton_mousewheel down" then
			MESSAGEMAN:Broadcast("WheelDownSlow")
		end
		
		if inputting then
			if event.button == "Start" then
				inputting = false
				updateFilter()
			elseif event.button == "Back" then
				curInput = ""
				inputting = false
				updateFilter()
			elseif event.DeviceInput.button == "DeviceButton_backspace" then
				curInput = curInput:sub(1, -2)
				updateFilter()
			elseif event.DeviceInput.button == "DeviceButton_delete" then
				curInput = ""
				updateFilter()
			elseif event.DeviceInput.button == "DeviceButton_space" then
				curInput = curInput .. " "
				updateFilter()
			elseif event.DeviceInput.button == "DeviceButton_left mouse button" or event.DeviceInput.button == "DeviceButton_right mouse button" then
				inputting = false
			else
				if event.char and event.char:match('[%%%+%-%!%@%#%$%^%&%*%(%)%=%_%.%,%:%;%\'%"%>%<%?%/%~%|%w]') and event.char ~= "" then
					curInput = curInput .. event.char
					updateFilter()
				end
			end
			MESSAGEMAN:Broadcast("UpdateText")
			return true
		end

		if event.button == "Back" or event.button == "Start" then
			SCREENMAN:GetTopScreen():Cancel()
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
			self:diffuse(getMainColor("background"))
			self:diffusealpha(0.8)
		end
	}

	t[#t+1] = Def.Sprite{
		InitCommand = function (self)
			self:Load(THEME:GetPathG("Common", "fallback banner"))
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
			self:settext("This is a placeholder section for Pack Information.")
		end
	}

	return t
end

local function packList()
	local frameWidth = 430
	local frameHeight = SCREEN_HEIGHT - 60

	-- Pack item information
	local packItemWidth = frameWidth-30
	local packItemHeight = 25

	local packItemX = 20
	local packItemY = 70+packItemHeight/2
	local packItemYSpacing = 5
	----

	local t = Def.ActorFrame{
		DownloadStatusCommand = function(self, params)
			self:RunCommandsOnChildren(function(self) self:playcommand("DownloadStatus", params) end)
		end,
		DFRFinishedMessageCommand = function(self) -- Download Finished, a Diff Reload happens (forced by the game)
			refreshInstalledPacks()
			downloading = DLMAN:GetDownloadingPacks()
			MESSAGEMAN:Broadcast("UpdateList")
		end,
	}

	-- The background quad for the Packs section
	t[#t+1] = Def.Quad{
		InitCommand = function (self)
			self:zoomto(frameWidth,frameHeight)
			self:halign(0):valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end,
		WheelUpSlowMessageCommand = function(self)
			if self:isOver() then
				movePage(-1)
			end
		end,
		WheelDownSlowMessageCommand = function(self)
			if self:isOver() then
				movePage(1)
			end
		end
	}

	-- The text in the top left of the Packs section
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(5, 10)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:settext("Simfile Packs")
		end
	}

	-- The sort toggle button
	t[#t+1] = quadButton(6) .. {
		Name = "Sort",
		InitCommand = function(self)
			self:xy(packItemX - 15, packItemY - packItemHeight - packItemYSpacing)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(packItemWidth / 6, packItemHeight - packItemYSpacing)
		end,
		TopPressedCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.2)
			moveSortForward()
			sortPacks()
			curPage = 1
			MESSAGEMAN:Broadcast("UpdateList")
		end
	}

	-- The sort text
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand = function(self)
			self:xy(packItemX - 12, packItemY - packItemHeight - packItemYSpacing):halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:settextf("Sort: %s", sorts[curSort])
			self:maxwidth(packItemWidth / 3 + 15)
		end,
		UpdateListMessageCommand = function(self)
			self:settextf("Sort: %s", sorts[curSort])
		end
	}

	-- Sort Ascending/Descending button
	t[#t+1] = quadButton(6) .. {
		Name = "ToggleAscending",
		InitCommand = function(self)
			self:xy(packItemX + packItemWidth / 6 - 10, packItemY - packItemHeight - packItemYSpacing)
			self:halign(0)
			self:diffusealpha(0.2)
			self:zoomto(packItemWidth / 6, packItemHeight - packItemYSpacing)
		end,
		TopPressedCommand = function(self)
			self:finishtweening()
			self:diffusealpha(0.4)
			self:smooth(0.3)
			self:diffusealpha(0.2)
			sortPacks()
			curPage = 1
			MESSAGEMAN:Broadcast("UpdateList")
		end
	}

	-- The toggle ascending/descending text
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand = function(self)
			self:xy(packItemX + 60, packItemY - packItemHeight - packItemYSpacing):halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:settext("Toggle Ascending", sorts[curSort])
			self:maxwidth(packItemWidth / 3 + 15)
		end
	}

	-- The search-by-name box
	t[#t+1] = quadButton(6) .. {
		Name = "Search",
		InitCommand = function(self)
			self:xy(packItemX + 128, packItemY - packItemHeight - packItemYSpacing)
			self:halign(0)
			self:zoomto(packItemWidth - 128, packItemHeight - packItemYSpacing)
			self:diffusealpha(0.2)
		end,
		TopPressedCommand = function(self)
			self:diffusealpha(0.4)
			inputting = true
		end,
		UpdateTextMessageCommand = function(self)
			if inputting then
				self:diffusealpha(0.4)
			else
				self:diffusealpha(0.2)
			end
		end
	}

	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand = function(self)
			self:xy(packItemX + 131, packItemY - packItemHeight - packItemYSpacing):halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
			self:zoom(0.4)
			self:settext("Click to Start Typing")
			self:maxwidth(packItemWidth * 1.65)
		end,
		UpdateListMessageCommand = function(self)
			if curInput ~= "" then
				self:settextf("%s", curInput)
			else
				self:settext("Click to Start Typing")
			end
		end
	}
	

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
				downloading = DLMAN:GetDownloadingPacks()
				if not packExists(packlist[packIndex]:GetName()) then
					self:GetChild("Status"):diffuse(color(colorConfig:get_data().downloadStatus.downloading)):diffusealpha(0.8)
					self:GetChild("ProgressBar"):diffuse(color(colorConfig:get_data().downloadStatus.downloading)):diffusealpha(0.2)
				end
			end,
			StopDownloadCommand = function(self) -- Stop download
				download:Stop()
				downloading = DLMAN:GetDownloadingPacks()
			end,
			PackDownloadedMessageCommand = function(self, params) -- Download Stopped/Finished
				downloading = DLMAN:GetDownloadingPacks()
			end,
			DownloadFailedMessageCommand = function(self, params) -- Download Failed
				if packlist[packIndex] ~= nil and packlist[packIndex]:GetName() == params.pack:GetName() then 
					downloading = DLMAN:GetDownloadingPacks()
					self:GetChild("Status"):playcommand("Set")
					self:GetChild("ProgressBar"):diffuse(color(colorConfig:get_data().downloadStatus.available)):diffusealpha(0.2)
					self:GetChild("Size"):settextf("Download Failed or Cancelled")
				end
			end
		}

		-- Pack index number
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

		-- The download progress bar (background of the pack buttons)
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

		-- The pack button
		t[#t+1] = quadButton(6) .. {
			Name = "Size",
			InitCommand = function(self)
				self:halign(0)
				self:diffusealpha(0.2)
				self:zoomto(packItemWidth, packItemHeight)
			end,
			TopPressedCommand = function(self)
				if packlist[packIndex] ~= nil and packlist[packIndex]:IsDownloading() then -- IsDownloading() returns the wrong boolean for some reason.
					self:GetParent():playcommand("StartDownload")
				elseif packlist[packIndex] ~= nil then
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

		-- Color of the tab for the pack (downloaded/not downloaded)
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

		-- MSD average for the pack
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

		-- Pack name
		t[#t+1] = LoadFont("Common Bold")..{
			InitCommand  = function(self)
				self:xy(40,-6):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.4)
			end,
			SetCommand = function(self)
				self:settextf("%s",packlist[packIndex]:GetName())

				-- The pack names can get really long. Set the max width to double the button width
				-- because not setting it to double the width makes the text half the width ????
				self:maxwidth(packItemWidth * 2)
			end
		}

		-- Pack file size
		t[#t+1] = LoadFont("Common Normal")..{
			Name = "Size",
			InitCommand  = function(self)
				self:xy(40,5):halign(0)
				self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
				self:zoom(0.3)
			end,
			SetCommand = function(self)
				if packExists(packlist[packIndex]:GetName()) then
					self:settext("Installed (Or a pack with an identical name exists)")
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