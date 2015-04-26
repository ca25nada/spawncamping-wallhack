local t = Def.ActorFrame{}

-- A somewhat naive implementation of the osu's error bar.
-- Single Player only until I figure out where to put everything
-- Hopefully I can change it so I don't have to initialize 300 quads beforehand.
local enabled = (((playerConfig:get_data(pn_to_profile_slot(pn)).ErrorBar == true) and GAMESTATE:IsHumanPlayer(PLAYER_1)) or 
				((playerConfig:get_data(pn_to_profile_slot(pn)).ErrorBar == true) and GAMESTATE:IsHumanPlayer(PLAYER_1))) and 
				GAMESTATE:GetNumPlayersEnabled() == 1
local pn = GAMESTATE:GetEnabledPlayers()[1]

--=======================================
--ONLY EDIT THESE VALUES
--=======================================
local maxOffsetRange = 0.18 --timing range to show in seconds. 0.18 for upto bads, 0.135 for goods, 0.09 for greats, etc.
local barcount = 300 -- Number of bars to initialize.
local frameX = SCREEN_CENTER_X -- X Positon (Center of the bar)
local frameY = SCREEN_BOTTOM-35 -- Y Positon (Center of the bar)
local frameHeight = 10 -- Height of the bar
local frameWidth = capWideScale(get43size(300),300) -- Width of the bar
local tickWidth = 2 -- Width of the ticks
local tickDuration = 5 -- Time duration in seconds before the ticks fade out
--=======================================


local currentbar = 1
local protimingsum = 0
local offset = 0
local protimingsum = 0
local currentbar = 1
local offset = 0

function proTimingTicks(pn,index)
	return Def.Quad{
		InitCommand=cmd(xy,frameX,frameY;zoomto,tickWidth,frameHeight;diffusealpha,0;);
		JudgmentMessageCommand=function(self,params)
			if params.Player == pn and params.TapNoteScore then
				if currentbar == index and 
					params.TapNoteScore ~= 'TapNoteScore_HitMine' and 
					params.TapNoteScore ~= 'TapNoteScore_AvoidMine' and 
					params.TapNoteScore ~= 'TapNoteScore_Miss' and 
					math.abs(offset) <= maxOffsetRange then

					self:stoptweening()
					self:diffusealpha(1)
					self:diffuse(offsetToJudgeColor(offset))
					self:x(frameX+(((offset)/maxOffsetRange)*(frameWidth/2)))
					self:linear(tickDuration)
					self:diffusealpha(0)
				end;
			end;
		end;
	};
end;

if enabled then
	t[#t+1] = Def.Actor{
		JudgmentMessageCommand=function(self,params)
			offset = 0
			if params.Player == pn then
				if params.HoldNoteScore then
					--dosomething
				elseif params.TapNoteScore == 'TapNoteScore_HitMine' or params.TapNoteScore == 'TapNoteScore_AvoidMine' then
					--dosomething
				else
					if params.TapNoteScore ~= 'TapNoteScore_Miss' then
						currentbar = ((currentbar+1)%barcount)+1
						if params.Early then
							offset = params.TapNoteOffset
							protimingsum = protimingsum + params.TapNoteOffset
						else
							offset = params.TapNoteOffset
							protimingsum = protimingsum + params.TapNoteOffset
						end;
					end;
				end;
			end;
		end;
	};

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,frameX,frameY;zoomto,frameWidth,frameHeight;diffuse,color("#666666");diffusealpha,0.7);
	};

	--[[ Debug
	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,300,300;halign,0;zoom,2;diffuse,getMainColor(2));
		BeginCommand=cmd(queuecommand,"Set");
		SetCommand=function(self)
			self:settext(offset)
		end;
		JudgmentMessageCommand=cmd(playcommand,"Set");
	};
	--]]
	-- Initialize a bunch of bars
	for i=1,barcount do
		t[#t+1] = proTimingTicks(pn,i)
	end;
end;

-- 



return t