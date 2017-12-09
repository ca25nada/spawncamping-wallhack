local timingWindowScale = PREFSMAN:GetPreference("TimingWindowScale")
local W5Window = PREFSMAN:GetPreference("TimingWindowSecondsW5") -- Timing window for Bads

local dotWidth = 2
local dotHeight = 2

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:RunCommandsOnChildren(function(self)
			local params = {width = 0, height = 0, song = nil, steps = nil, noterow = {}, offset = {}}
			self:playcommand("Update", params) end
		)
	end;
}

t[#t+1] = Def.Quad{
	Name = "Background",
	InitCommand = function(self)
		self:halign(0):valign(0)
		self:diffuse(getMainColor("frame")):diffusealpha(0.6)
	end;
	UpdateCommand = function(self, params)
		self:zoomto(params.width, params.height)
	end;
}

t[#t+1] = Def.Quad{
	Name = "Center Line",
	InitCommand = function(self)
		self:halign(0):valign(0)
		self:diffusealpha(0.4)
	end;
	UpdateCommand = function(self, params)
		self:xy(0,params.height/2)
		self:zoomto(params.width,1)
	end;
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:zoom(0.3):halign(0):valign(0):diffusealpha(0.4)
	end,
	UpdateCommand = function(self)
		self:xy(5,5)
		self:settextf("Early (-%d ms)", timingWindowScale*W5Window*1000)
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand=function(self)
		self:zoom(0.3):halign(0):valign(1):diffusealpha(0.4)
	end,
	UpdateCommand = function(self, params)
		self:xy(5,params.height-5)
		self:settextf("Late (+%d ms)", timingWindowScale*W5Window*1000)
	end
}

t[#t+1] = Def.ActorMultiVertex{
	UpdateCommand = function(self, params)
		local verts = {}
		if params.song == nil or params.steps == nil or params.noterow == nil or params.offset == nil then
			self:SetVertices(verts)
			self:SetDrawState{Mode="DrawMode_Quads", First = 1, Num = #verts}
			return
		end

		local songLength = params.song:GetLastSecond()

		for i=1, #params.noterow do
			local timestamp = params.steps:GetTimingData():GetElapsedTimeFromNoteRow(params.noterow[i])
			local offset = params.offset[i]/1000

			local color = offsetToJudgeColor(offset) -- WHY MULTIPLY BY 1000 IF WE NEED IT DIVIDED BY 1000 AGAIN

			local x = (timestamp/songLength) * params.width
			local y = (offset/W5Window/2/timingWindowScale) * params.height + (params.height/2)

			if math.abs(offset) > (W5Window * timingWindowScale) then
				-- Misses
				verts[#verts+1] = {{x-dotWidth/2, params.height,0}, Alpha(color, 0.3)}
				verts[#verts+1] = {{x+dotWidth/2, params.height,0}, Alpha(color, 0.3)}
				verts[#verts+1] = {{x+dotWidth/2, 0,0}, Alpha(color, 0.3)}
				verts[#verts+1] = {{x-dotWidth/2, 0,0}, Alpha(color, 0.3)}
			else
				-- Everything else
				verts[#verts+1] = {{x-dotWidth/2,y+dotHeight/2,0}, color}
				verts[#verts+1] = {{x+dotWidth/2,y+dotHeight/2,0}, color}
				verts[#verts+1] = {{x+dotWidth/2,y-dotHeight/2,0}, color}
				verts[#verts+1] = {{x-dotWidth/2,y-dotHeight/2,0}, color}
			end

		end

		self:SetVertices(verts)
		self:SetDrawState{Mode="DrawMode_Quads", First = 1, Num = #verts}
	end;
}




return t