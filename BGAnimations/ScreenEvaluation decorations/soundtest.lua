--some code snippets from waiei i think...?
local t=Def.ActorFrame{};
t[#t+1]=Def.ActorFrame{
};

local song=nil;
t[#t+1]=Def.ActorFrame{
 Def.Sound{
  WaitCommand=function(self)
   self:finishtweening();
   SOUND:PlayMusicPart("_silent.ogg",0,1,0,0,false,false);
   self:sleep(0.3);
   self:queuecommand("Play");
  end;
  PlayCommand=function(self)
   local fn=song:GetMusicPath();
   if fn then
    SOUND:PlayMusicPart(fn,song:GetSampleStart(),song:GetSampleLength(),0,1,false,false);
   else
    SOUND:PlayMusicPart("_silent.ogg",0,1,0,0,false,false);
   end;
  end;
 };
};

local delta=0;
local function update(self,d)
 delta=delta+d;
 if  song~=GAMESTATE:GetCurrentSong() then
  song=GAMESTATE:GetCurrentSong();
  if delta>0.3 then
   self:queuecommand("Wait");
  else
   self:sleep(0.3-delta);
   self:queuecommand("Play");
  end;
 end;
end;

t.InitCommand=cmd(SetUpdateFunction,update);

return t;