local t = Def.ActorFrame{}

local function ScreenFilter()
	return Def.Quad{
		InitCommand = function(self)
			self:visible(false)
		end;
		PlayerStateSetCommand = function(self,param)
			local pn = param.PlayerNumber
			local style = GAMESTATE:GetCurrentStyle(pn)
			local width = style:GetWidth(pn) + 8
			local filterColor = color(colorConfig:get_data().gameplay.ScreenFilter)
			local filterAlpha = playerConfig:get_data(pn_to_profile_slot(pn)).ScreenFilter
			if filterAlpha == 0 then
				self:visible(false)
				return
			end
			self:visible(true)
			self:SetWidth(width)
			self:SetHeight(SCREEN_HEIGHT*4096)
			self:diffuse(filterColor)
			self:diffusealpha(filterAlpha)
		end
	}
end

local function LaneHighlight()
	local t = Def.ActorFrame{}
	local alpha = 0.4
	local pn 
	local cbThreshold = Enum.Reverse(TapNoteScore)[ComboContinue()]

	for i=1,16 do
		t[#t+1] = Def.Quad{
			InitCommand = function(self)
				self:visible(false)
			end;
			PlayerStateSetCommand = function(self,param)
				pn = param.PlayerNumber
				local style = GAMESTATE:GetCurrentStyle(pn)
				local width = style:GetWidth(pn)
				local cols = style:ColumnsPerPlayer()
				local colWidth = width/cols
				local enabled = playerConfig:get_data(pn_to_profile_slot(pn)).CBHighlight
				if not enabled then
					return
				end
				if i > cols then
					self:visible(false)
					self:hibernate(math.huge)
				end
				self:SetWidth(colWidth)
				self:SetHeight(SCREEN_HEIGHT*4096)
				self:diffusealpha(alpha)
				self:fadeleft(0.2):faderight(0.2)
				self:x((i-(cols/2)-(1/2))*colWidth)
				self:visible(false)
			end;
			JudgmentMessageCommand=function(self,params)
				local notes = params.Notes
				if params.Player == pn and 
					params.TapNoteScore and
					notes ~= nil and notes[i] ~= nil then
					if Enum.Reverse(TapNoteScore)[params.TapNoteScore] < cbThreshold and
						params.TapNoteScore ~= "TapNoteScore_None" and
						params.TapNoteScore ~= "TapNoteScore_AvoidMine" and
						params.TapNoteScore ~= "TapNoteScore_CheckpointMiss" and
						(notes[i]:GetTapNoteType() == 'TapNoteType_Tap' or
						notes[i]:GetTapNoteType() == 'TapNoteType_HoldHead' or
						notes[i]:GetTapNoteType() == 'TapNoteType_Lift') then

						self:stoptweening();
						self:visible(true);
						self:diffusealpha(0);
						self:linear(0.1);
						self:diffuse(color(colorConfig:get_data().judgment[params.TapNoteScore]));
						self:diffusealpha(alpha)
						self:linear(0.25)
						self:diffusealpha(0)
					end;
				end
			end;
		}
	end

	return t
end


t[#t+1] = ScreenFilter()
t[#t+1] = LaneHighlight()

return t