--TODO: refactor this mess

t = Def.ActorFrame{}

local playerDistY = 95

local parameters = {
	PlayerNumber_P1 = {
		X = 157,
		Y = 170+capWideScale(get43size(120),120),
		topScore = nil
	},
	PlayerNumber_P2 = {
		X = 157,
		Y = 170+capWideScale(get43size(120),120)+playerDistY,
		topScore = nil
	}
}

local barWidth = capWideScale(get43size(300),300)-(parameters[PLAYER_1].X-capWideScale(get43size(parameters[PLAYER_1].X),parameters[PLAYER_1].X))
local barHeight = 4
local animationDelay = 0
local animationLength = 1


local function barGraph(pn)
	return Def.ActorFrame{
		InitCommand=cmd(xy,parameters[pn].X,parameters[pn].Y;);
		BeginCommand=function(self)
			self:visible(GAMESTATE:IsHumanPlayer(pn))
		end;
		PlayerJoinedMessageCommand=function(self, params)
			self:visible(params.Player == pn);
		end;
		PlayerUnjoinedMessageCommand=function(self, params)
			self:visible(params.Player ~= pn);
		end;
		LoadFont("Common Normal")..{
			InitCommand=cmd(x,-2;zoom,0.30;halign,1);
			BeginCommand=cmd(settext,"Judge:");
		};

		Def.Quad{
			InitCommand=cmd(zoomto,barWidth,barHeight;halign,0;diffuse,color("#000000"););
		};

		Def.Quad{
			InitCommand=cmd(zoomto,barWidth,barHeight;halign,0);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:stoptweening()
				local notes = getMaxNotes(pn)
				local judge = getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W1")+
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W2") + 
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W3") +
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W4") +
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W5") +
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_Miss")
				if maxscore == 0 or maxscore == nil then
					maxscore = 1
				end;
				--self:zoomx(0)
				self:sleep(animationDelay)
				self:smooth(animationLength)
				self:diffuse(TapNoteScoreToColor("TapNoteScore_Miss"))
				self:zoomx((judge/notes)*barWidth)
			end;
			CurrentSongChangedMessageCommand=function(self)
				self:queuecommand("Set")
			end;
			CurrentStepsP1ChangedMessageCommand=function(self)
				if pn == PLAYER_1 then
					self:queuecommand("Set")
				end
			end;
			CurrentStepsP2ChangedMessageCommand=function(self)
				if pn == PLAYER_2 then
					self:queuecommand("Set")
				end
			end;
		};

		Def.Quad{
			InitCommand=cmd(zoomto,barWidth,barHeight;halign,0);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:stoptweening()
				local notes = getMaxNotes(pn)
				local judge = getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W1")+
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W2") + 
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W3") +
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W4") +
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W5")
				if maxscore == 0 or maxscore == nil then
					maxscore = 1
				end;
				--self:zoomx(0)
				self:sleep(animationDelay)
				self:smooth(animationLength)
				self:diffuse(TapNoteScoreToColor("TapNoteScore_W5"))
				self:zoomx((judge/notes)*barWidth)
			end;
			CurrentSongChangedMessageCommand=function(self)
				self:queuecommand("Set")
			end;
			CurrentStepsP1ChangedMessageCommand=function(self)
				if pn == PLAYER_1 then
					self:queuecommand("Set")
				end
			end;
			CurrentStepsP2ChangedMessageCommand=function(self)
				if pn == PLAYER_2 then
					self:queuecommand("Set")
				end
			end;
		};

		Def.Quad{
			InitCommand=cmd(zoomto,barWidth,barHeight;halign,0);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:stoptweening()
				local notes = getMaxNotes(pn)
				local judge = getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W1")+
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W2") + 
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W3") +
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W4")
				if maxscore == 0 or maxscore == nil then
					maxscore = 1
				end;
				--self:zoomx(0)
				self:sleep(animationDelay)
				self:smooth(animationLength)
				self:diffuse(TapNoteScoreToColor("TapNoteScore_W4"))
				self:zoomx((judge/notes)*barWidth)
			end;
			CurrentSongChangedMessageCommand=function(self)
				self:queuecommand("Set")
			end;
			CurrentStepsP1ChangedMessageCommand=function(self)
				if pn == PLAYER_1 then
					self:queuecommand("Set")
				end
			end;
			CurrentStepsP2ChangedMessageCommand=function(self)
				if pn == PLAYER_2 then
					self:queuecommand("Set")
				end
			end;
		};
		Def.Quad{
			InitCommand=cmd(zoomto,barWidth,barHeight;halign,0);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:stoptweening()
				local notes = getMaxNotes(pn)
				local judge = getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W1")+
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W2") + 
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W3")
				if maxscore == 0 or maxscore == nil then
					maxscore = 1
				end;
				--self:zoomx(0)
				self:sleep(animationDelay)
				self:smooth(animationLength)
				self:diffuse(TapNoteScoreToColor("TapNoteScore_W3"))
				self:zoomx((judge/notes)*barWidth)
			end;
			CurrentSongChangedMessageCommand=function(self)
				self:queuecommand("Set")
			end;
			CurrentStepsP1ChangedMessageCommand=function(self)
				if pn == PLAYER_1 then
					self:queuecommand("Set")
				end
			end;
			CurrentStepsP2ChangedMessageCommand=function(self)
				if pn == PLAYER_2 then
					self:queuecommand("Set")
				end
			end;
		};

		Def.Quad{
			InitCommand=cmd(zoomto,barWidth,barHeight;halign,0);
			BeginCommand=cmd(queuecommand,"Set");
			SetCommand=function(self)
				self:stoptweening()
				local notes = getMaxNotes(pn)
				local judge = getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W1")+
					getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W2")
				if maxscore == 0 or maxscore == nil then
					maxscore = 1
				end;
				--self:zoomx(0)
				self:sleep(animationDelay)
				self:smooth(animationLength)
				self:diffuse(TapNoteScoreToColor("TapNoteScore_W2"))
				self:zoomx((judge/notes)*barWidth)
			end;
			CurrentSongChangedMessageCommand=function(self)
				self:queuecommand("Set")
			end;
			CurrentStepsP1ChangedMessageCommand=function(self)
				if pn == PLAYER_1 then
					self:queuecommand("Set")
				end
			end;
			CurrentStepsP2ChangedMessageCommand=function(self)
				if pn == PLAYER_2 then
					self:queuecommand("Set")
				end
			end;
		};

		Def.Quad{
			InitCommand=cmd(zoomto,barWidth,barHeight;halign,0);
			BeginCommand=cmd(glowshift;effectcolor1,color("1,1,1,0.2");effectcolor2,color("1,1,1,0.5");queuecommand,"Set");
			SetCommand=function(self)
				self:stoptweening()
				local notes = getMaxNotes(pn)
				local judge = getScoreTapNoteScore(parameters[pn].topScore,"TapNoteScore_W1")
				if maxscore == 0 or maxscore == nil then
					maxscore = 1
				end;
				--self:zoomx(0)
				self:sleep(animationDelay)
				self:smooth(animationLength)
				self:diffuse(getMainColor('highlight'))
				self:zoomx((judge/notes)*barWidth)
			end;
			CurrentSongChangedMessageCommand=function(self)
				self:queuecommand("Set")
			end;
			CurrentStepsP1ChangedMessageCommand=function(self)
				if pn == PLAYER_1 then
					self:queuecommand("Set")
				end
			end;
			CurrentStepsP2ChangedMessageCommand=function(self)
				if pn == PLAYER_2 then
					self:queuecommand("Set")
				end
			end;
		};
	};
end


t[#t+1] = Def.ActorFrame{
	BeginCommand=cmd(playcommand,"Set");
	SetCommand=function(self)
		local song = GAMESTATE:GetCurrentSong()
		for _,pn in pairs({PLAYER_1,PLAYER_2}) do
			if GAMESTATE:IsPlayerEnabled(pn) then
				local hsTable = getScoreList(pn)
				if hsTable ~= nil then
					parameters[pn].topScore = getScoreFromTable(hsTable,1)
				end
			end
		end
	end;
	CurrentSongChangedMessageCommand=cmd(playcommand,"Set");
	CurrentStepsP1ChangedMessageCommand=cmd(playcommand,"Set");
	CurrentStepsP2ChangedMessageCommand=cmd(playcommand,"Set");
}

for _,pn in pairs({PLAYER_1,PLAYER_2}) do
	if GAMESTATE:IsPlayerEnabled(pn) then
		t[#t+1] = barGraph(pn)
	end
end

return t