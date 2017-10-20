local MAX_WIDTH = SCREEN_WIDTH*2/3

TAB = {
	choices = {},
	width = 100,
	height = 20
}

function TAB.new(self, choices)
	TAB.choices = choices
	TAB.width = math.min(100, SCREEN_WIDTH*2/3 / #choices)

	return self
end

function TAB.makeTabActors(tab)
	local t = Def.ActorFrame{}

	for i,v in pairs(tab.choices) do
		t[#t+1] = Def.Quad {
			InitCommand = function(self)
				self:halign(0)
				self:zoomto(tab.width, tab.height)
				self:x(tab.width*(i-1))
				self:diffuse(color("#333333"))
			end;
			TopPressedCommand = function(self, params)
				if params.input == "DeviceButton_left mouse button" then
					MESSAGEMAN:Broadcast("TabPressed",{name = v})
				end
			end;
		}

		t[#t+1] = quadButton(3)..{
		InitCommand = function(self)
			self:halign(0)
			self:zoomto(tab.width, tab.height)
			self:x(tab.width*(i-1))
			self:diffuse(color("#FFFFFF")):diffusealpha(0)
		end;
		TopPressedCommand = function(self, params)
			if params.input == "DeviceButton_left mouse button" then
				MESSAGEMAN:Broadcast("TabPressed",{name = v})
				self:finishtweening()
				self:diffusealpha(0.2)
				self:smooth(0.3)
				self:diffusealpha(0)
			end
		end;
	}

		t[#t+1] = LoadFont("Common Bold") .. {
			InitCommand = function(self)
				self:x((tab.width/2)+(tab.width*(i-1)))
				self:zoom(0.4)
				self:settext(v)
			end;
		}
	end

	return t
end
