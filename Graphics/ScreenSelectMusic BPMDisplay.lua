return Def.BPMDisplay {
	File=THEME:GetPathF("BPMDisplay", "bpm"),
	Name="BPMDisplay",
	InitCommand=function(self)
		self:horizalign(left):zoom(0.50)
	end,
	SetCommand=function(self) self:SetFromGameState() end,
	CurrentSongChangedMessageCommand = function(self) self:playcommand("Set") end,
	CurrentCourseChangedMessageCommand = function(self) self:playcommand("Set") end,
	CurrentRateChangedMessageCommand = function(self) self:playcommand("Set") end,
	CurrentStepsP1ChangedMessageCommand = function(self) self:playcommand("Set") end
}