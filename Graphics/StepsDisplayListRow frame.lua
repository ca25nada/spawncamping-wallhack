local t = Def.ActorFrame{

}


t[#t+1] = quadButton(3) .. {
	InitCommand=function(self)
		self:zoomto(60,60):diffuse(getMainColor("frame")):diffusealpha(0.7):rotationz(90)
	end,
	MouseDownCommand = function(self)
		local s = GAMESTATE:GetCurrentSong()
		if s then
			local idx = self:GetParent():GetParent():GetIndex() - self:GetParent():GetParent():GetParent():GetCurrentIndex()
			if idx ~= 0 then
				SCREENMAN:GetTopScreen():ChangeSteps(idx)
			end
		end
	end
}

t[#t+1] = Def.Quad {
	InitCommand=function(self)
		self:x(-10):zoomto(50,25):diffuse(color("#ffffff")):diffusealpha(0.5):rotationz(90)
	end
}

return t