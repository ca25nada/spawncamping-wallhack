return Def.ActorFrame {
	LoadFont("Common Bold") .. {
		Text="BPM",
		InitCommand=function(self)
			self:horizalign(right):zoom(0.50)
		end
	}
}

