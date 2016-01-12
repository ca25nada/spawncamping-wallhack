local c;
local player = Var "Player";

local ghostType = playerConfig:get_data(pn_to_profile_slot(player)).GhostScoreType -- 0 = off, 1 = DP, 2 = PS, 3 = MIGS
local avgScoreType = playerConfig:get_data(pn_to_profile_slot(player)).AvgScoreType-- 0 = off, 1 = DP, 2 = PS, 3 = MIGS
local target  = playerConfig:get_data(pn_to_profile_slot(player)).GhostTarget/100; -- target score from 0% to 100%.


local ShowComboAt = THEME:GetMetric("Combo", "ShowComboAt");
local Pulse = THEME:GetMetric("Combo", "PulseCommand");
local PulseLabel = THEME:GetMetric("Combo", "PulseLabelCommand");

local NumberMinZoom = THEME:GetMetric("Combo", "NumberMinZoom");
local NumberMaxZoom = THEME:GetMetric("Combo", "NumberMaxZoom");
local NumberMaxZoomAt = THEME:GetMetric("Combo", "NumberMaxZoomAt");

local LabelMinZoom = THEME:GetMetric("Combo", "LabelMinZoom");
local LabelMaxZoom = THEME:GetMetric("Combo", "LabelMaxZoom");

local t = Def.ActorFrame {
	InitCommand=cmd(vertalign,bottom);
	LoadFont( "Combo", "numbers" ) .. {
		Name="Number";
		OnCommand = THEME:GetMetric("Combo", "NumberOnCommand"); -- y,240-216-1.5;shadowlength,1;halign,1;valign,1;skewx,-0.125;zoom,0.5;
	};
	LoadFont("Common Normal") .. {
		Name="Label";
		OnCommand = THEME:GetMetric("Combo", "LabelOnCommand"); -- x,6;y,22.5;shadowlength,1;zoom,0.75;diffusebottomedge,color("0.75,0.75,0.75,1");halign,0;valign,1
	};

	LoadFont("Common Normal") .. {
		Name="GhostScore";
		OnCommand = function(self)
			self:xy(48,9):zoom(0.45):halign(0):valign(1):shadowlength(1)
			if avgScoreType == 0 then
				self:x(7)
			end
		end
	};

	LoadFont("Common Normal") .. {
		Name="AvgScore";
		OnCommand = function(self)
			self:xy(48,9):zoom(0.45):halign(1):valign(1):shadowlength(1)
		end
	};
	
	InitCommand = function(self)
		c = self:GetChildren();
		c.Number:visible(false);
		c.Label:visible(false);
		c.GhostScore:visible(false)
		c.AvgScore:visible(false)
	end;

	TwentyFiveMilestoneCommand=function(self,parent)
		(cmd(skewy,-0.125;decelerate,0.325;skewy,0))(self);
	end;
	ComboCommand=function(self, param)
		local iCombo = param.Misses or param.Combo;
		if not iCombo or iCombo < ShowComboAt then
			c.Number:visible(false);
			c.Label:visible(false);
			c.GhostScore:visible(false)
			c.AvgScore:visible(false)
			return;
		end

		local labeltext = "";
		if param.Combo then
			labeltext = "COMBO";
		else
			labeltext = "MISSES";
		end

		local targerDiff = 0
		if ghostType ~= 0 or ghostType ~= nil then
			targetDiff = getCurScoreST(player,ghostType)-(math.ceil(getCurMaxScoreST(player,ghostType)*target))
			if targetDiff > 0 then
				c.GhostScore:settext('+'..targetDiff)
				c.GhostScore:diffuse(color("#66ccff"))
			elseif targetDiff == 0 then
				c.GhostScore:settext('+'..targetDiff)
				c.GhostScore:diffuse(color("#FFFFFF"))
			else
				c.GhostScore:settext('-'..(math.abs(targetDiff)))
				c.GhostScore:diffuse(color("#FF9999"))
			end;
		end;

		if avgScoreType ~= 0 or avgScore ~= nil then
			if getCurMaxScoreST(player,avgScoreType) ~= 0 then
				c.AvgScore:settextf("%.2f%%",(math.floor(getCurScoreST(player,avgScoreType)/getCurMaxScoreST(player,avgScoreType)*10000))/100); 
			else
				c.AvgScore:settext('0.00%')
			end;
		end;

		c.Label:settext( labeltext );
		c.Label:visible(false);

		param.Zoom = scale( iCombo, 0, NumberMaxZoomAt, NumberMinZoom, NumberMaxZoom );
		param.Zoom = clamp( param.Zoom, NumberMinZoom, NumberMaxZoom );
		
		param.LabelZoom = scale( iCombo, 0, NumberMaxZoomAt, LabelMinZoom, LabelMaxZoom );
		param.LabelZoom = clamp( param.LabelZoom, LabelMinZoom, LabelMaxZoom );
		
		c.Number:visible(true);
		c.Label:visible(true);
		if ghostType ~= 0 and ghostType ~= nil then 
			c.GhostScore:visible(true)
			c.GhostScore:finishtweening()
			c.GhostScore:diffusealpha(1)
			c.GhostScore:sleep(0.25)
			c.GhostScore:smooth(0.75)
			c.GhostScore:diffusealpha(0)
		end

		if avgScoreType ~= 0 and avgScoreType ~= nil then 
			c.AvgScore:visible(true)
			c.AvgScore:finishtweening()
			c.AvgScore:diffusealpha(1)
			c.AvgScore:sleep(0.25)
			c.AvgScore:smooth(0.75)
			c.AvgScore:diffusealpha(0)
		end

		c.Number:settext( string.format("%i", iCombo) );
		-- FullCombo Rewards
		if param.FullComboW1 then
			c.Number:diffuse(color("#00aeef"));
			c.Number:glowshift();
		elseif param.FullComboW2 then
			c.Number:diffuse(color("#fff568"));
			c.Number:glowshift();
		elseif param.FullComboW3 then
			c.Number:diffuse(color("#a4ff00"));
			c.Number:stopeffect();
		elseif param.Combo then
			c.Number:diffuse(Color("White"));
			c.Number:stopeffect();
			(cmd(diffuse,Color("White");diffusebottomedge,color("0.5,0.5,0.5,1")))(c.Label);
		else
			c.Number:diffuse(color("#ff0000"));
			c.Number:stopeffect();
			(cmd(diffuse,Color("Red");diffusebottomedge,color("0.5,0,0,1")))(c.Label);
		end
		-- Pulse
		Pulse( c.Number, param );
		PulseLabel( c.Label, param );
		-- Milestone Logic
	end;
--[[ 	ScoreChangedMessageCommand=function(self,param)
		local iToastyCombo = param.ToastyCombo;
		if iToastyCombo and (iToastyCombo > 0) then
-- 			(cmd(thump;effectmagnitude,1,1.2,1;effectclock,'beat'))(c.Number)
-- 			(cmd(thump;effectmagnitude,1,1.2,1;effectclock,'beat'))(c.Number)
		else
-- 			c.Number:stopeffect();
		end;
	end; --]]
};

return t;
