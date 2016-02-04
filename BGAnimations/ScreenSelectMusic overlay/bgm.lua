local curSong = nil
local start = math.max(0,getLastSecond())
local delay = 0.5
local curTime = 0
local startFromPreview = false
local loop = themeConfig:get_data().global.SongPreview == 2

setLastSecond(0)

-- SongPreview == 1 (SM STYLE)
-- 		Disable this stuff, loops from SampleStart to SampleStart+SampleLength

-- SongPreview == 2 (current osu!)
-- 		Loops from SampleStart to end of the song.
--		If a player exits midway in a song, play from last point to end of song, then loop from SampleStart.

-- SongPreview == 3 (old osu!)
-- 		Play from SampleStart to end of the song. then Loop from the start of the song to the end.
--		If a player exits midway in a song, play from last point to end of song, then loop from start.

local t = Def.ActorFrame{}

if themeConfig:get_data().global.SongPreview ~= 1 then
	t[#t+1]  =  Def.Sound{
		OnCommand = function(self)
			curSong = GAMESTATE:GetCurrentSong()
		end;
		OffCommand = function(self)
			self:queuecommand("StopPlayingMusic")
		end;
		CurrentSongChangedMessageCommand=function(self)
			self:finishtweening()
			curSong = GAMESTATE:GetCurrentSong()
			curTime = GetTimeSinceStart()
			if curSong ~= nil then
				startFromPreview = false
				if start == 0 then
					startFromPreview = true
				end
				self:queuecommand("StartPlayingMusic")
			end
		end;
		StopPlayingMusicMessageCommand = function(self)
			SOUND:PlayMusicPart("_silent.ogg",0,1,0,0,false,false);
		end;
		StartPlayingMusicMessageCommand = function(self)
			self:finishtweening()

			if GetTimeSinceStart() - curTime < delay then
				SOUND:PlayMusicPart("_silent.ogg",0,1,0,0,false,false);
				--SCREENMAN:SystemMessage("Waiting")
			else
				if curSong ~= nil then
					local path = curSong:GetMusicPath();
					if path ~= nil then
						
						if startFromPreview then -- When starting from preview point
							SOUND:PlayMusicPart(path,curSong:GetSampleStart(),song:MusicLengthSeconds()-curSong:GetSampleStart(),2,2,loop,true,true);
							if themeConfig:get_data().global.SongPreview == 3 then 
								startFromPreview = false
							end
							start = 0
						else -- When starting from start of from exit point.
							SOUND:PlayMusicPart(path,start,song:MusicLengthSeconds()-start,2,2,false,true,true);
							--SCREENMAN:SystemMessage("Playing: "..path.." from "..start.." seconds")
							start = 0
							if themeConfig:get_data().global.SongPreview == 2 then
								startFromPreview = true
							end
						end
					else
						SOUND:PlayMusicPart("_silent.ogg",0,1,0,0,false,false);
					end
				end
			end
			self:sleep(delay)
			self:queuecommand("StartPlayingMusic")
		end;
	}
end

return t