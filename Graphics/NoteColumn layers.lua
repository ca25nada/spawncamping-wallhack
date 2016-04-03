local t = Def.ActorFrame{}

local function LaneHighlight()
	local t = Def.ActorFrame{}
	local alpha = 0.4
	local pn 
	local cbThreshold = Enum.Reverse(TapNoteScore)[ComboContinue()]

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:visible(false)
		end;
		PlayerStateSetCommand = function(self, param)
			pn = param.PlayerNumber
			local enabled = playerConfig:get_data(pn_to_profile_slot(pn)).CBHighlight
			if not enabled then
				return
			end
			self:SetHeight(SCREEN_HEIGHT*4096)
			self:diffusealpha(alpha)
			self:fadeleft(0.2):faderight(0.2)
			self:visible(false)
			self:SetWidth(64)-- Temporary
		end;
		WidthSetCommand = function(self, param)
			SCREENMAN:SystemMessage("uwaa")
			self:SetWidth(param.width)
		end;
		ColumnJudgmentCommand = function(self, param)
			if param.tap_note_score then
				if Enum.Reverse(TapNoteScore)[param.tap_note_score] < cbThreshold and
					param.tap_note_score ~= "TapNoteScore_None" and
					param.tap_note_score ~= "TapNoteScore_AvoidMine" and
					param.tap_note_score ~= "TapNoteScore_CheckpointMiss" then
					Trace("Notes"..param.tap_note_score)
					self:stoptweening()
					self:visible(true)
					self:diffusealpha(0)
					self:linear(0.1)
					self:diffuse(color(colorConfig:get_data().judgment[param.tap_note_score]));
					self:diffusealpha(alpha)
					self:linear(0.25)
					self:diffusealpha(0)
				end
			end
		end;
	}

	return t
end

t[#t+1] = LaneHighlight()

return t