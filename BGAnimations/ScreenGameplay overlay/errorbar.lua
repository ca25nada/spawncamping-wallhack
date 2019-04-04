-- A somewhat naive implementation of the osu's error bar.
-- Single Player only until I figure out where to put everything
-- Hopefully I can change it so I don't have to initialize like 300 quads beforehand.
local enabled = ((playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).ErrorBar == true) and GAMESTATE:IsHumanPlayer(PLAYER_1)) and 
				GAMESTATE:GetNumPlayersEnabled() == 1
local pn = GAMESTATE:GetEnabledPlayers()[1]
local bareBone = isBareBone()
--=======================================
--ONLY EDIT THESE VALUES
--=======================================
local timingScale = PREFSMAN:GetPreference("TimingWindowScale") -- Timing window scale (e.g. 1.0 for J4)
local maxOffsetRange = 0.18*timingScale -- timing range to show in seconds. 0.18 for upto bads, 0.135 for goods, 0.09 for greats, etc.
local barcount = 100 -- Number of bars to initialize. Older bars will just move to the newest offset before they fade out if it's not high enough.
local frameX = SCREEN_CENTER_X -- X Positon (Center of the bar)
local frameY = SCREEN_BOTTOM-35 -- Y Positon (Center of the bar)
local frameHeight = 10 -- Height of the bar
local frameWidth = capWideScale(get43size(300),300) -- Width of the bar
local tickWidth = 2 -- Width of the ticks
local tickDuration = 1 -- Time duration in seconds before the ticks fade out
local backgroundOpacity = bareBone and 1 or 0.6
--=======================================

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(frameX,frameY)
	end
}


local currentbar = 1 -- Index to be updated

local function proTimingTicks(pn,index)
	return Def.Quad{
		Name = tostring(index),
		InitCommand = function(self)
			self:zoomto(tickWidth,frameHeight):diffusealpha(0)
		end,
		UpdateTickCommand = function(self,params)
			local enumVal = Enum.Reverse(TapNoteScore)[params.TapNoteScore]

			if params.Player == pn then

				if params.TapNoteScore and not params.HoldNoteScore and
				enumVal >= 5 and enumVal < 10 then

					if math.abs(params.TapNoteOffset) <= maxOffsetRange then
						self:stoptweening()
						self:diffusealpha(1)
						self:diffuse(offsetToJudgeColor(params.TapNoteOffset))
						self:x(((params.TapNoteOffset)/maxOffsetRange)*(frameWidth/2))
						self:linear(tickDuration)
						self:diffusealpha(0)
					end
				end
			end
		end
	}
end

if enabled then
		-- Initialize a bunch of bars
	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:zoomto(frameWidth,frameHeight):diffuse(color("#666666")):diffusealpha(backgroundOpacity)
		end
	}

	for i=1,barcount do
		t[#t+1] = proTimingTicks(pn,i)
	end

	t[#t+1] = Def.Actor{
		JudgmentMessageCommand=function(self,params)
			if params.Player == pn then	
				if params.TapNoteScore and not params.HoldNoteScore and
				Enum.Reverse(TapNoteScore)[params.TapNoteScore] >= 5 and
				Enum.Reverse(TapNoteScore)[params.TapNoteScore] < 10 then
					currentbar = ((currentbar)%barcount)+1
					self:GetParent():GetChild(tostring(currentbar)):playcommand("UpdateTick",params)
				end
			end
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:zoomto(2,frameHeight):diffuse(color("#FFFFFF")):diffusealpha(0.5)
		end
	}

	if not bareBone then
		t[#t+1] = LoadFont("Common Normal") .. {
	        InitCommand=function(self)
	        	self:x(frameWidth/4):zoom(0.35)
	        end,
	        BeginCommand=function(self)
	        	self:settext("Late"):diffusealpha(0):smooth(0.5):diffusealpha(0.5):sleep(1.5):smooth(0.5):diffusealpha(0)
	        end
	    }

	    t[#t+1] = LoadFont("Common Normal") .. {
	        InitCommand=function(self)
	        	self:x(-frameWidth/4):zoom(0.35)
	        end,
	        BeginCommand=function(self)
	        	self:settext("Early"):diffusealpha(0):smooth(0.5):diffusealpha(0.5):sleep(1.5):smooth(0.5):diffusealpha(0)
	        end
	    }
	end

end




return t