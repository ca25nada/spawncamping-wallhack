local t = Def.ActorFrame{}

-- A somewhat naive implementation for now.
-- Single Player only until I figure out where to put everything
-- Hopefully I can change it so I don't have to initialize 300 quads beforehand.
local enabled = (((GetUserPref("ErrorBarP1") == "1") and GAMESTATE:IsHumanPlayer(PLAYER_1)) or 
				((GetUserPref("ErrorBarP2") == "1") and GAMESTATE:IsHumanPlayer(PLAYER_1))) and 
				GAMESTATE:GetNumPlayersEnabled() == 1
local pn = GAMESTATE:GetEnabledPlayers()[1]

local frameX = SCREEN_CENTER_X
local frameY = SCREEN_BOTTOM-35
local frameHeight = 10
local frameWidth = 300
local maxOffsetRange = 0.18 --in seconds. 0.18 for upto bads, 0.135 for goods, 0.09 for greats, etc.

local barcount = 500 -- Number of bars to initialize.
local protimingsum = 0
local duration = 5
local currentbar = 1

local offset = 0
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

	function proTimingTicks(pn,index)
		return Def.Quad{
			InitCommand=cmd(xy,frameX,frameY;zoomto,2,frameHeight;diffusealpha,0;);
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
						self:smooth(duration)
						self:diffusealpha(0)
					end;
				end;
			end;
		};
	end;

	-- Initialize a bunch of bars
	for i=1,barcount do
		t[#t+1] = proTimingTicks(pn,i)
	end;
end;

-- 



return t