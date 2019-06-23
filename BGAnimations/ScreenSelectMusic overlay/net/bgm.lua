local curSong = nil
local start = math.max(0,GHETTOGAMESTATE:getLastPlayedSecond())
local delay = 0.02
local startFromPreview = true
local loop = themeConfig:get_data().global.SongPreview == 2
local curPath = ""
local sampleStart = 0
local musicLength = 0
local loops = 0
local musicNotPaused = 1
local goNow = false

local sampleEvent = false

GHETTOGAMESTATE:setLastPlayedSecond(0)

-- SongPreview == 1 (SM STYLE)
-- 		Disable this stuff, loops from SampleStart to SampleStart+SampleLength

-- SongPreview == 2 (current osu!)
-- 		Loops from SampleStart to end of the song.
--		If a player exits midway in a song, play from last point to end of song, then loop from SampleStart.

-- SongPreview == 3 (old osu!)
-- 		Play from SampleStart to end of the song. then Loop from the start of the song to the end.
--		If a player exits midway in a song, play from last point to end of song, then loop from start.


local deltaSum = 0
local function playMusic(self, delta)
	deltaSum = deltaSum + delta * musicNotPaused
	if musicLength + 3 < GAMESTATE:GetSongPosition():GetMusicSeconds() then
		goNow = true
	end

	if (deltaSum > delay and sampleEvent) or goNow then
		goNow = false
		local s = GHETTOGAMESTATE:getSSM()
		if s:GetName() == "ScreenNetSelectMusic" then
			if s:GetMusicWheel():IsSettled() and loops <= 1 then
				deltaSum = 0
				if curSong and curPath then
					if startFromPreview then -- When starting from preview point
						amountOfWait = musicLength - sampleStart
						
						SOUND:PlayMusicPart(curPath,sampleStart,amountOfWait,2,2,loop,true,true)
						self:SetUpdateFunctionInterval(amountOfWait)

						if themeConfig:get_data().global.SongPreview == 3 then 
							startFromPreview = false
						end

					else -- When starting from start of from exit point.
						amountOfWait = musicLength - start

						if loops == 1 then
							SOUND:PlayMusicPart(curPath,start,amountOfWait,2,2,true,true,false)
						else
							SOUND:PlayMusicPart(curPath,start,amountOfWait,2,2,false,true,false)
						end
						self:SetUpdateFunctionInterval(math.max(0.02, amountOfWait))
						start = 0

						if themeConfig:get_data().global.SongPreview == 2 then
							startFromPreview = true
						end

					end
					loops = loops + 1
				end
			end
		end
	else
		self:SetUpdateFunctionInterval(0.025)
	end
end

local t = Def.ActorFrame{
	InitCommand = function(self)
		if themeConfig:get_data().global.SongPreview ~= 1 then
			self:SetUpdateFunction(playMusic)
		end
	end,
	CurrentSongChangedMessageCommand = function(self)
		musicNotPaused = 1
		goNow = false
		sampleEvent = false
		loops = 0
		SOUND:StopMusic()
		deltaSum = 0
		curSong = GAMESTATE:GetCurrentSong()
		if curSong ~= nil then
			curPath = curSong:GetMusicPath()
			if not curPath then
				SCREENMAN:SystemMessage("Invalid music file path.")
				return
			end
			sampleStart = curSong:GetSampleStart()
			musicLength = curSong:MusicLengthSeconds()
			startFromPreview = start == 0
			if themeConfig:get_data().global.SongPreview ~= 1 then
				self:SetUpdateFunctionInterval(0.002)
			end
		end
	end,
	PlayingSampleMusicMessageCommand = function(self)
		musicNotPaused = 1
		goNow = false
		sampleEvent = true
		if themeConfig:get_data().global.SongPreview ~= 1 then
			self:SetUpdateFunctionInterval(0.002)
			SOUND:StopMusic()
		end
	end,
	--[[
		--- ---
		---	NOTE FOR THE FUTURE: Need to add oldRate to the messages ingame or something.
		-------
	--]]
	CurrentRateChangedMessageCommand = function(self, params)
		if themeConfig:get_data().global.SongPreview ~= 1 and params.oldRate ~= nil then
			amountOfWait = amountOfWait / (1 / params.oldRate) / params.rate -- fun math, this works.
			self:SetUpdateFunctionInterval(amountOfWait)
		end
	end,
	PreviewPausedMessageCommand = function(self)
		if themeConfig:get_data().global.SongPreview ~= 1 then
			if musicNotPaused == 1 then
				musicNotPaused = 0
				goNow = false
			else
				musicNotPaused = 1
				sampleEvent = true
				startFromPreview = false
				loops = 0
				start = GAMESTATE:GetSongPosition():GetMusicSeconds()
				self:SetUpdateFunctionInterval(0.002)
				SOUND:StopMusic()
				goNow = true
			end
		end
	end,
	PreviewNoteFieldDeletedMessageCommand = function(self)
		musicNotPaused = 1
		goNow = false
		sampleEvent = true
		loops = 0
		if themeConfig:get_data().global.SongPreview ~= 1 then
			self:SetUpdateFunctionInterval(0.002)
			SOUND:StopMusic()
		end
	end
}

return t