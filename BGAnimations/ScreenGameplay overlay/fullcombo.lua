-- Stuff that shows effects upon fullcombo ,etc.

local flag = false
local song = GAMESTATE:GetCurrentSong()
local curBeat = 0 
local lastBeat = song:GetLastBeat()

local style = GAMESTATE:GetCurrentStyle()
local cols = style:ColumnsPerPlayer()

local randMagnitude = 0.3

local barCount = cols*5
local barHeight = 150
local barWidth = 5

local text = {'F','u','l','l',' ','C','o','m','b','o'} -- RIP
local leamtokem = {28,20,14,14,16,32,36,36,30,30} -- THIS IS DUMB BUT WHATEVER
local totalSpacing = 226 -- sun of above minus the last element. 

local enabled = {
	PlayerNumber_P1 = GAMESTATE:IsPlayerEnabled(PLAYER_1),
	PlayerNumber_P2 = GAMESTATE:IsPlayerEnabled(PLAYER_2)
}

local function FCEffect(pn)
	local t = Def.ActorFrame{
		InitCommand=function(self)
			self:x(getNoteFieldPos(pn))
			self:visible(false)
		end;
		FullComboMessageCommand=function(self)
			self:visible(true)
		end;
	}

	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:visible(false)
			self:y(SCREEN_BOTTOM)
			self:valign(1)
			self:zoomto(getNoteFieldWidth(pn)+8,0)
			self:fadetop(1)
			self:diffusealpha(0):diffuse(getMainColor())
		end;
		FullComboMessageCommand=function(self)
			self:sleep(0.2)
			self:visible(true)
			self:diffusealpha(1)
			self:linear(1)
			self:diffusealpha(0)
			self:zoomy(SCREEN_HEIGHT*4)
		end;
	}

	for i=1,barCount do
		t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:visible(false)
			self:x(-(getNoteFieldWidth(pn)/2)+math.random(getNoteFieldWidth(pn))):y(SCREEN_BOTTOM+barHeight+400*math.random())
			self:valign(1)
			self:zoomto(barWidth,barHeight-math.random()*100)
			self:fadetop(0.5)
			self:fadebottom(0.5)
			self:fadeleft(0.2)
			self:faderight(0.2)
			self:diffusealpha(0)
		end;
		FullComboMessageCommand=function(self)
			self:sleep(0.1)
			self:visible(true)
			self:diffusealpha(0.4)
			self:accelerate(2)
			self:diffusealpha(0)
			self:y((-SCREEN_HEIGHT)-(SCREEN_HEIGHT*math.random()*10))
		end;
	}	
	end

	for i=1,#text do
		t[#t+1] = LoadFont("Common Large") .. {
			InitCommand=function(self)
				local spacing = 0
				local zoom = 0.6*getNoteFieldScale(pn)
				if i>1 then
					for j=1,i-1 do
						spacing = leamtokem[j]+spacing
					end
				end
				self:visible(false)
				self:settext(text[i])
				self:zoom(1)
				if i>1 then
					self:x((-totalSpacing/2)*zoom + spacing*zoom)
				else
					self:x((-totalSpacing/2)*zoom)
				end
				self:diffusealpha(0)
				self:zoom(zoom)
			end;
			FullComboMessageCommand=function(self)
				--SCREENMAN:SystemMessage("FC")
				local random = math.random()*randMagnitude
				self:sleep(0.20+random)
				self:visible(true)
				self:y(SCREEN_BOTTOM-(400*math.random()))
				self:diffusealpha(0.0)
				self:decelerate(0.5-random)
				random = math.random()*randMagnitude
				self:y(SCREEN_CENTER_Y)
				self:diffusealpha(1)
				self:sleep(0.3)
				self:accelerate(0.6-random)
				--self:y(SCREEN_TOP+(400*math.random()))
				self:diffusealpha(0.0)
			end;
		}
	end



	return t
end

local t = Def.ActorFrame{}

for _,pn in pairs({PLAYER_1,PLAYER_2}) do
	if enabled[pn] then
		t[#t+1] = FCEffect(pn)
	end
end

local function Update(self)
	t.InitCommand=cmd(SetUpdateFunction,Update);
    curBeat = GAMESTATE:GetSongBeat()
    if curBeat > lastBeat and flag == false then
    	flag = true
    	if isFullCombo(PLAYER_1) then
    		MESSAGEMAN:Broadcast("FullCombo")
    	--else
    		--SCREENMAN:SystemMessage("NOT FC")
    	end
    end
end; 
t.InitCommand=cmd(SetUpdateFunction,Update);

return t