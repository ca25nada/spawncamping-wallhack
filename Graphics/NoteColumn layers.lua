local t = {}

local function LaneHighlight()
	local alpha = 0.4
	local cbThreshold = Enum.Reverse(TapNoteScore)[ComboContinue()]

	return Def.Quad{
		InitCommand = function(self)
			self:visible(false)
		end;
		PlayerStateSetCommand = function(self, param)
			local enabled = playerConfig:get_data(param.PlayerNumber).CBHighlight
			if not enabled then
				return
			end
			self:SetHeight(SCREEN_HEIGHT*4096)
			self:diffusealpha(alpha)
			self:fadeleft(0.2):faderight(0.2)
			self:visible(false)
		end;
		WidthSetCommand = function(self, param)
			self:SetWidth(param.width)
		end;
		ColumnJudgmentCommand = function(self, param)
			if param.tap_note_score then
				if Enum.Reverse(TapNoteScore)[param.tap_note_score] < cbThreshold and
					param.tap_note_score ~= "TapNoteScore_None" and
					param.tap_note_score ~= "TapNoteScore_HitMine" and
					param.tap_note_score ~= "TapNoteScore_AvoidMine" and
					param.tap_note_score ~= "TapNoteScore_CheckpointHit" then
					param.tap_note_score ~= "TapNoteScore_CheckpointMiss" then
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
end

t[#t+1] = LaneHighlight()

return t