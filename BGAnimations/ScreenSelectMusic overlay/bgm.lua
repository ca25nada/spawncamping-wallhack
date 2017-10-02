local curSong = nil
local start = math.max(0,GHETTOGAMESTATE:getLastPlayedSecond())
local delay = 1
local startFromPreview = true
local loop = themeConfig:get_data().global.SongPreview == 2
local curPath = ""
local sampleStart = 0
local musicLength = 0

local test = true

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
	deltaSum = deltaSum + delta
	if deltaSum > delay then
		deltaSum = 0
		if curSong and curPath then
			if startFromPreview then -- When starting from preview point
				SOUND:PlayMusicPart(curPath,sampleStart,musicLength-sampleStart,2,2,loop,true,true)

				if themeConfig:get_data().global.SongPreview == 3 then 
					startFromPreview = false
				end

			else -- When starting from start of from exit point.
				SOUND:PlayMusicPart(curPath,start,musicLength-start,2,2,false,true,false)
				start = 0

				if themeConfig:get_data().global.SongPreview == 2 then
					startFromPreview = true
				end

			end
		end
	end	
end


local t = Def.ActorFrame{
	InitCommand = function(self)
		if themeConfig:get_data().global.SongPreview ~= 1 then
			self:SetUpdateFunction(playMusic)
		end
	end;
	CurrentSongChangedMessageCommand = function(self)
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
		end
	end;
}

return t