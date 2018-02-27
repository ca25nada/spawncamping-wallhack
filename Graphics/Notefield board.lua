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
	local judgeThreshold = Enum.Reverse(TapNoteScore)[ComboContinue()]

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
				local reverse = GAMESTATE:GetPlayerState(pn):GetCurrentPlayerOptions():UsingReverse()
				local receptor = reverse and THEME:GetMetric("Player", "ReceptorArrowsYStandard") or THEME:GetMetric("Player", "ReceptorArrowsYReverse")
				local border = 4

				if i > cols or not enabled then
					self:visible(false)
					self:hibernate(math.huge)
				end

				self:SetWidth(colWidth-border)
				self:SetHeight(SCREEN_HEIGHT)
				self:diffusealpha(alpha)
				self:xy((i-(cols/2)-(1/2))*colWidth,-receptor)
				self:fadebottom(0.6):fadetop(0.6)
				self:visible(false)
			end;
			JudgmentMessageCommand=function(self,params)
				local enabled = playerConfig:get_data(pn_to_profile_slot(pn)).CBHighlight
				if not enabled then
					self:visible(false)
					self:hibernate(math.huge)
					return
				end

				local notes = params.Notes
				local firstTrack = params.FirstTrack+1

				if params.Player == pn and params.TapNoteScore then
					local enum  = Enum.Reverse(TapNoteScore)[params.TapNoteScore]

					if enum < judgeThreshold and enum > 3 and
						i == firstTrack then

						self:stoptweening();
						self:visible(true);
						self:diffuse(color(colorConfig:get_data().judgment[params.TapNoteScore]));
						self:diffusealpha(alpha)
						self:easeIn(0.25)
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