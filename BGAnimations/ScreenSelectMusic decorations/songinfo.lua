local t = Def.ActorFrame{};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=cmd(xy,300,300;visible,true);
	BeginCommand=function(self)
		self:settext("uwaaaaa")
	end;
};

return t