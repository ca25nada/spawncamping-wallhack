--Displays the current life percentage for each player

local t = Def.ActorFrame {
		Def.Quad{
			Name="Player1LifeBG";
			InitCommand=cmd(xy,0,3;halign,0;valign,0;zoomto,270,13;faderight,0.5;diffusealpha,0.5);
		};
		Def.Quad{
			Name="Player2LifeBG";
			InitCommand=cmd(xy,SCREEN_WIDTH,3;halign,1;valign,0;zoomto,270,13;fadeleft,0.5;diffusealpha,0.5);
		};
        LoadFont("Common Normal") .. {
                Name="Player1Life";
				InitCommand=cmd(x,35;y,10;halign,1;zoom,0.45;halign,1;);
        };
        LoadFont("Common Normal") .. {
                Name="Player2Life";
                InitCommand=cmd(x,SCREEN_WIDTH-35;y,10;halign,0;zoom,0.45;);
        };
};
 
local function PLife(pn)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetCurrentLife() or 0
end;
 
local function Update(self)
 
t.InitCommand=cmd(SetUpdateFunction,Update);
 
        if GAMESTATE:IsHumanPlayer(PLAYER_1) then
        	self:GetChild("Player1LifeBG"):faderight(0.5+((1-PLife(PLAYER_1))*0.5))
        	self:GetChild("Player1LifeBG"):zoomx(70+(PLife(PLAYER_1)*200))
			self:GetChild("Player1Life"):settextf("%.0f%%", PLife(PLAYER_1)*100);
			if PLife(PLAYER_1)*100 < 30 and PLife(PLAYER_1)*100 ~= 0 then -- replace with lifemeter danger later
				self:GetChild("Player1Life"):diffuseshift()
				self:GetChild("Player1Life"):effectcolor1(1,1,1,1)
				self:GetChild("Player1Life"):effectcolor2(1,0.9,0.9,0.5)
				self:GetChild("Player1Life"):effectperiod(0.9*PLife(PLAYER_1)+0.15)
			elseif PLife(PLAYER_1)*100 == 100 then -- replace with lifemeter hot later
				self:GetChild("Player1Life"):glowshift()
				self:GetChild("Player1Life"):effectcolor2(1,1,1,0.0)
				self:GetChild("Player1Life"):effectcolor1(1,1,1,0.3)
				self:GetChild("Player1Life"):effectperiod(0.1)
			elseif PLife(PLAYER_1)*100 <= 0 then
				self:GetChild("Player1Life"):stopeffect()
				self:GetChild("Player1Life"):diffuse(color("0,0,0,1"))
			else
				self:GetChild("Player1Life"):stopeffect()
				self:GetChild("Player1Life"):diffuse(color("1,1,1,1"))
			end;
        else
                self:GetChild("Player1Life"):settext("");
                self:GetChild("Player1LifeBG"):visible(false)
        end;
 
        if GAMESTATE:IsHumanPlayer(PLAYER_2) then
        	self:GetChild("Player2LifeBG"):fadeleft(0.5+((1-PLife(PLAYER_2))*0.5))
        	self:GetChild("Player2LifeBG"):zoomx(70+(PLife(PLAYER_2)*200))
            self:GetChild("Player2Life"):settextf("%.0f%%", PLife(PLAYER_2)*100);
			if PLife(PLAYER_2)*100 <= 30 and PLife(PLAYER_2)*100 ~= 0 then
				self:GetChild("Player2Life"):diffuseshift()
				self:GetChild("Player2Life"):effectcolor1(1,1,1,1)
				self:GetChild("Player2Life"):effectcolor2(1,0.9,0.9,0.5)
				self:GetChild("Player2Life"):effectperiod(0.9*PLife(PLAYER_2)+0.15)
			elseif PLife(PLAYER_2)*100 == 100 then
				self:GetChild("Player2Life"):glowshift()
				self:GetChild("Player2Life"):effectcolor2(1,1,1,0.0)
				self:GetChild("Player2Life"):effectcolor1(1,1,1,0.3)
				self:GetChild("Player2Life"):effectperiod(0.1)
			elseif PLife(PLAYER_2)*100 <= 0 then
				self:GetChild("Player2Life"):stopeffect()
				self:GetChild("Player2Life"):diffuse(color("0,0,0,1"))
			else
				self:GetChild("Player2Life"):stopeffect()
				self:GetChild("Player2Life"):diffuse(color("1,1,1,1"))


				
			end;
        else
                self:GetChild("Player2Life"):settext("");
                self:GetChild("Player2LifeBG"):visible(false)
        end;
end;

t.InitCommand=cmd(SetUpdateFunction,Update);
 
return t;