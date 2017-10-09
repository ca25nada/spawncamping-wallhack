local top 											-- Screen on top of the screen stack. AKA: current screen
local pn = GAMESTATE:GetEnabledPlayers()[1]			-- Usually PLAYER_1
local profile = PROFILEMAN:GetProfile(pn)

local frameWidth = SCREEN_WIDTH - 20				-- Width of the top bar
local frameHeight = 36								-- Height of the top bar

local curPage = 1									-- Current Page index
local curIndex = 1									-- Current Cursor Index
local curName = PROFILEMAN:GetAvatarName(pn)		-- String with the current avatar's filename
local lastClickedIndex = 0							-- Last clicked index for double-click detection

local avatarTable = PROFILEMAN:GetAllAvatarNames() -- Table containing the filename of all installed avatars
local avatarWidth = 50								-- Self explanatory
local avatarHeight = 50
local maxCols = math.floor(capWideScale(7,11))		-- Maximum columns depending on screen aspect ratio.
local maxRows = 5									-- Maximum rows
local maxPage = math.max(1, math.ceil(#avatarTable/(maxCols*maxRows)))	-- Maximum #of pages depending on #of avatars and # of cols/rows

local avatarHSpacing = SCREEN_WIDTH/(maxCols+1)		-- Horizontal spacing between avatars
local avatarVSpacing = (SCREEN_HEIGHT-50)/(maxRows+1) -- Vertical spacing between avatars

local co -- coroutine
local time = 0 -- time it takes for the function to finish
local function updateAvatars()
	time = GetTimeSinceStart()

	for i=1, math.min(maxRows*maxCols, #avatarTable) do
		MESSAGEMAN:Broadcast("UpdateAvatar", {index = i})
		coroutine.yield()
	end

	MESSAGEMAN:Broadcast("UpdateFinished", {time = GetTimeSinceStart()-time})
end

-- Return the index for the avatarTable based on current col/row position and current page.
local function getAvatarIndex()
	return ((curPage-1)*maxCols*maxRows)+curIndex
end

-- Jumps by n pages.
local function movePage(n)
	local newPage = clamp(curPage + n, 1, maxPage)

	-- Only load the new page when there's actually a new page to load.
	if newPage ~= curPage then
		curIndex = n < 0 and math.min(#avatarTable, maxRows*maxCols) or 1
		curPage = newPage
		MESSAGEMAN:Broadcast("PageMoved",{index = curIndex, page = curPage})
		co = coroutine.create(updateAvatars) -- run the coroutine again
	end
end

-- Moves the cursor by x, y units.
local function moveCursor(x, y)
	local move = x + y*maxCols
	local newPage = curPage

	-- Move over a page if it's not an edge page and the cursors are also on the edges.
	if curPage > 1 and curIndex == 1 and move < 0 then
		curIndex = math.min(#avatarTable, maxRows*maxCols)
		newPage = curPage - 1

	elseif curPage < maxPage and curIndex == maxRows*maxCols and move > 0 then
		curIndex = 1
		newPage = curPage + 1
	else
		curIndex = clamp(curIndex + move, 1, math.min(maxRows*maxCols, #avatarTable-(maxRows*maxCols*(curPage-1))))
	end

	-- Only load the new page when there's actually a new page to load.
	-- Otherwise it's just a cursor update
	if curPage == newPage then
		MESSAGEMAN:Broadcast("CursorMoved",{index = curIndex})

	else
		curPage = newPage
		MESSAGEMAN:Broadcast("PageMoved",{index = curIndex, page = curPage})
		co = coroutine.create(updateAvatars)

	end
end

local function topRow()
	local t = Def.ActorFrame{}

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:zoomto(frameWidth, frameHeight)
			self:diffuse(color("#000000")):diffusealpha(0.8)
		end;
	}

	t[#t+1] = Def.Sprite {
		InitCommand = function (self) 
			self:x(-frameWidth/2 + 3)
			self:halign(0)
			self:LoadBackground(PROFILEMAN:GetAvatarPath(pn));
			self:zoomto(30,30)
		end;
	}

	t[#t+1] = LoadFont("Common BLarge") .. {
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 30 +6, -7)
			self:zoom(0.30)
			self:halign(0)
			self:settext(profile:GetDisplayName())
		end;
	}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand = function(self)
			self:xy(-frameWidth/2 + 30 +6, 7)
			self:zoom(0.35)
			self:halign(0)
			self:settextf("%s", avatarTable[getAvatarIndex()])
		end;
		CursorMovedMessageCommand = function(self, params)
			self:settextf("%s", avatarTable[getAvatarIndex()])
		end;
		PageMovedMessageCommand = function(self, params)
			self:settextf("%s", avatarTable[getAvatarIndex()])
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-5,-1)
			self:zoom(0.45)
			self:halign(1)
			self:settextf("Page %d/%d", curPage, maxPage)
		end;
		PageMovedMessageCommand = function(self, params)
			self:settextf("Page %d/%d",params.page, maxPage)
		end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-5,9)
			self:zoom(0.35)
			self:halign(1)
			self:settext("Loading... 0%")
		end;
		PageMovedMessageCommand = function(self, params)
			self:settext("Loading... 0%")
		end;
		UpdateAvatarMessageCommand = function(self, params)
			self:settextf("Loading... %0.0f%%",100*params.index/math.min(maxRows*maxCols, #avatarTable-(maxRows*maxCols*(curPage-1))))
		end;
		UpdateFinishedMessageCommand = function(self, params)
			self:settextf("Loaded in %0.2f Seconds", params.time)
		end;
	}

	return t
end

local function avatarBox(i)
	local avatarName = avatarTable[i]

	local t = Def.ActorFrame {
		Name = tostring(i);
		InitCommand = function(self)
			self:x((((i-1)%maxCols)+1)*avatarHSpacing)
			self:y(((math.floor((i-1)/maxCols)+1)*avatarVSpacing)-10+50)
			self:diffusealpha(0)
		end;
		PageMovedMessageCommand = function(self)
			self:finishtweening()
			self:easeOut(0.5)
			self:diffusealpha(0)
		end;
		UpdateAvatarMessageCommand = function(self, params)
			if params.index == i then
				if i+((curPage-1)*maxCols*maxRows) > #avatarTable then
					self:finishtweening()
					self:easeOut(0.5)
					self:diffusealpha(0)

				else
					avatarName = avatarTable[i+((curPage-1)*maxCols*maxRows)]

					-- Load the avatar image
					self:GetChild("Avatar"):LoadBackground(ProfileManager:GetAvatarFolderPath()..avatarName);
					if i == curIndex then
						self:GetChild("Avatar"):zoomto(avatarHeight+8,avatarWidth+8)
						self:GetChild("Border"):zoomto(avatarHeight+12,avatarWidth+12)
						self:GetChild("Border"):diffuse(getMainColor("highlight")):diffusealpha(0.8)
					else
						self:GetChild("Avatar"):zoomto(avatarHeight,avatarWidth)
					end

					self:y(((math.floor((i-1)/maxCols)+1)*avatarVSpacing)-10+50)
					self:finishtweening()
					self:easeOut(0.5)
					self:diffusealpha(1)
					self:y((math.floor((i-1)/maxCols)+1)*avatarVSpacing+50)
							
				end
			end
		end;
	}

	t[#t+1] = Def.Quad{
		Name = "Border";
		InitCommand = function(self)
			self:zoomto(avatarWidth+4, avatarHeight+4)
			self:queuecommand("Set")

			-- Set the current index if the currently set item is visible on the first page.
			if avatarName == curName then
				curIndex = i
			end


			self:diffuse(getMainColor("frame")):diffusealpha(0.8)

		end;
		CursorMovedMessageCommand = function(self, params)
			self:finishtweening()
			if params.index == i then
				self:easeOut(0.5)
				self:zoomto(avatarWidth+12, avatarHeight+12)
				self:diffuse(getMainColor("highlight")):diffusealpha(0.8)
			else
				self:smooth(0.2)
				self:zoomto(avatarWidth+4, avatarHeight+4)
				self:diffuse(getMainColor("frame")):diffusealpha(0.8)
			end
		end;
		PageMovedMessageCommand = function(self, params)
			self:finishtweening()
			if params.index == i then
				self:easeOut(0.5)
				self:zoomto(avatarWidth+12, avatarHeight+12)
				self:diffuse(getMainColor("highlight")):diffusealpha(0.8)
			else
				self:smooth(0.2)
				self:zoomto(avatarWidth+4, avatarHeight+4)
				self:diffuse(getMainColor("frame")):diffusealpha(0.8)
			end
		end;

	}

	t[#t+1] = quadButton(3) .. {
		InitCommand = function(self)
			self:zoomto(avatarWidth, avatarHeight)
			self:visible(false)
		end;
		TopPressedCommand = function(self, params)
			-- Move the cursor to this index upon clicking
			if params.input == "DeviceButton_left mouse button" then
				-- Save and exit upon double clicking
				if lastClickedIndex == i then
					PROFILEMAN:SaveAvatar(pn, avatarTable[getAvatarIndex()])
					SCREENMAN:GetTopScreen():Cancel()
				end

				lastClickedIndex = i
				curIndex = i
				MESSAGEMAN:Broadcast("CursorMoved",{index = i})
			end
		end;
	}


	-- Avatar
	t[#t+1] = Def.Sprite {
		Name = "Avatar";
		CursorMovedMessageCommand = function(self, params)
			self:finishtweening()
			if params.index == i then
				self:easeOut(0.5)
				self:zoomto(avatarWidth+8, avatarHeight+8)
			else
				self:smooth(0.2)
				self:zoomto(avatarWidth, avatarHeight)
			end
		end;
		PageMovedMessageCommand = function(self, params)
			self:finishtweening()
			if params.index == i then
				self:easeOut(0.5)
				self:zoomto(avatarWidth+8, avatarHeight+8)
			else
				self:smooth(0.2)
				self:zoomto(avatarWidth, avatarHeight)
			end
		end;
	}


	return t
end

function input(event)
	if event.type ~= "InputEventType_Release" then

		-- Screen exits upon first press anyway so no need to check for repeats.
		if event.button == "Back" then
			SCREENMAN:GetTopScreen():Cancel()
		end

		if event.button == "Start" then
			PROFILEMAN:SaveAvatar(pn, avatarTable[getAvatarIndex()])
			SCREENMAN:GetTopScreen():Cancel()
		end

		-- We want repeats for these events anyway
		if event.button == "Left" or event.button == "MenuLeft" then
			moveCursor(-1, 0)
		end

		if event.button == "Right" or event.button == "MenuRight" then
			moveCursor(1, 0)
		end

		if event.button == "Up" or event.button == "MenuUp" then
			moveCursor(0, -1)
		end

		if event.button == "Down" or event.button == "MenuDown" then
			moveCursor(0, 1)
		end

		if event.button == "EffectUp" then
			movePage(-1)
		end

		if event.button == "EffectDown" then
			movePage(1)
		end


	end

	return false

end

local function update(self, delta)
	if coroutine.status(co) ~= "dead" then
		coroutine.resume(co)
	end
end

local t = Def.ActorFrame {
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		top:AddInputCallback(input)
		co = coroutine.create(updateAvatars)
		self:SetUpdateFunction(update)
	end;
}

t[#t+1] = topRow() .. {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, 50)
	end;
}

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(25, 25)
		self:xy(25, SCREEN_CENTER_Y+25)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end;
}
t[#t+1] = quadButton(4)..{
	InitCommand = function(self)
		self:zoomto(25, 25)
		self:xy(25, SCREEN_CENTER_Y+25)
		self:diffuse(color("#FFFFFF")):diffusealpha(0)
	end;
	TopPressedCommand = function(self, params)
		if params.input == "DeviceButton_left mouse button" then
			movePage(-1)
			self:GetParent():GetChild("TriangleLeft"):playcommand("Tween")
		end
		self:finishtweening()
		self:diffusealpha(0.2)
		self:smooth(0.3)
		self:diffusealpha(0)
	end;
}
t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
	Name = "TriangleLeft";
	InitCommand = function(self)
		self:zoom(0.15)
		self:diffusealpha(0.8)
		self:xy(25, SCREEN_CENTER_Y+25)
		self:rotationz(-90)
	end;
	TweenCommand = function(self)
		self:finishtweening()
		self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
		self:smooth(0.5)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
	end;
}

t[#t+1] = Def.Quad{
	InitCommand = function(self)
		self:zoomto(25, 25)
		self:xy(SCREEN_WIDTH-25, SCREEN_CENTER_Y+25)
		self:diffuse(getMainColor("frame")):diffusealpha(0.8)
	end;
}
t[#t+1] = quadButton(4)..{
	InitCommand = function(self)
		self:zoomto(25, 25)
		self:xy(SCREEN_WIDTH-25, SCREEN_CENTER_Y+25)
		self:diffuse(color("#FFFFFF")):diffusealpha(0)
	end;
	TopPressedCommand = function(self, params)
		if params.input == "DeviceButton_left mouse button" then
			movePage(1)
			self:GetParent():GetChild("TriangleRight"):playcommand("Tween")
		end
		self:finishtweening()
		self:diffusealpha(0.2)
		self:smooth(0.3)
		self:diffusealpha(0)
	end;
}
t[#t+1] = LoadActor(THEME:GetPathG("", "_triangle")) .. {
	Name = "TriangleRight";
	InitCommand = function(self)
		self:zoom(0.15)
		self:diffusealpha(0.8)
		self:xy(SCREEN_WIDTH-25, SCREEN_CENTER_Y+25)
		self:rotationz(90)
	end;
	TweenCommand = function(self)
		self:finishtweening()
		self:diffuse(getMainColor('highlight')):diffusealpha(0.8)
		self:smooth(0.5)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.8)
	end;
}

for i=1, math.min(maxRows*maxCols, #avatarTable) do
	t[#t+1] = avatarBox(i)
end


t[#t+1] = LoadActor("../_mouse")
t[#t+1] = LoadActor("../_frame")
t[#t+1] = LoadActor("../_cursor")

return t