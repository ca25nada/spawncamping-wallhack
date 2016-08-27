--Displays the current life percentage for each player

local function PLife(pn)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetCurrentLife() or 0
end;

local t = Def.ActorFrame {}

local function lifeBar(pn)
	local t = Def.ActorFrame {
		InitCommand = function(self) self:queuecommand("Set") end;
		JudgmentMessageCommand = function(self) self:queuecommand("Set") end;
		SetCommand = function(self)
			self:GetChild(pn.."LifeBG"):faderight(0.5+((1-PLife(pn))*0.5))
	        self:GetChild(pn.."LifeBG"):zoomx(70+(PLife(PLAYER_1)*200))
	        self:GetChild(pn.."LifeVal"):target_number(PLife(pn)*100)
        	if PLife(pn)*100 < 30 and PLife(pn)*100 ~= 0 then -- replace with lifemeter danger later
				self:diffuseshift()
				self:effectcolor1(1,1,1,1)
				self:effectcolor2(1,0.9,0.9,0.5)
				self:effectperiod(0.9*PLife(pn)+0.15)
			elseif PLife(pn)*100 <= 0 then
				self:stopeffect()
				self:diffuse(color("0,0,0,1"))
			else
				self:stopeffect()
				self:diffuse(color("1,1,1,1"))
			end;
		end;
		Def.Quad{
			Name = pn.."LifeBG";
			InitCommand = function(self)
				self:zoomto(270,13)
				self:diffusealpha(0.5)
				if pn == PLAYER_1 then
					self:xy(0,3):halign(0):valign(0)
					self:faderight(0.5)
				else
					self:xy(SCREEN_WIDTH,3):halign(1):valign(0)
					self:fadeleft(0.5)
				end
				self:queuecommand("Set")
			end;
		};
		Def.RollingNumbers{
			Name = pn.."LifeVal";
			Font = "Common Normal", 
			InitCommand = function(self)
				if pn == PLAYER_1 then
					self:xy(35,9):zoom(0.45):halign(1)
				else
					self:xy(SCREEN_WIDTH-35,9):zoom(0.45):halign(0)
				end
			    self:set_chars_wide(2):set_text_format("%.0f%%"):set_approach_seconds(0.1)
			    self:queuecommand("Set")
			end;
		};
	}
	return t
end

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	t[#t+1] = lifeBar(pn)
end

return t;