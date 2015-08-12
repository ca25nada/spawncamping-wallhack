
local cursor = 1
local count = 0
local themeColor = themeConfig:get_data().color.main
local colorTable = {}
for i=2,#themeColor do --First string is a "#", ignore.
	colorTable[i-1] = themeColor:sub(i,i)
end;

local function scroller(index)
	count = count+1
	local number = tonumber(colorTable[index],16)
	local t = Def.ActorFrame{}

	t[#t+1] = LoadFont("Common Normal") .. {
		InitCommand=cmd(xy,SCREEN_CENTER_X+index*10,SCREEN_CENTER_Y;zoom,0.4;);
		OnCommand=function(self)
			self:settext(string.format("%01X",number or 0))
			if index == cursor then
				self:diffuse(color("#FFFFFF"))
			else
				self:diffuse(color("#666666"))
			end;
		end;
		CodeMessageCommand=function(self,params)
			if params.Name == "ColorUp" then
				if index == cursor then
					number = (number + 1)%16
					self:settext(string.format("%01X",number or 0))
					colorTable[index] = string.format("%01X",number or 0)
				end
			end
			if params.Name == "ColorDown" then
				if index == cursor then
					number = (number - 1)%16
					self:settext(string.format("%01X",number or 0))
					colorTable[index] = string.format("%01X",number or 0)
				end
			end
			if params.Name == "ColorLeft" then
				if index == cursor then
					self:diffuse(color("#FFFFFF"))
				else
					self:diffuse(color("#666666"))
				end
			end
			if params.Name == "ColorRight" then
				if index == cursor then
					self:diffuse(color("#FFFFFF"))
				else
					self:diffuse(color("#666666"))
				end
			end
		end;
	}

	return t

end

local t = Def.ActorFrame{
	CodeMessageCommand=function(self,params)
		if params.Name == "ColorCancel" then
			SCREENMAN:GetTopScreen():Cancel()
		end
		if params.Name == "ColorStart" then
			SCREENMAN:GetTopScreen():Cancel()
			themeConfig:get_data().color.main = "#"..table.concat(colorTable)
		end
		if params.Name == "ColorRight" then
			cursor = ((cursor)%(count))+1
		end
		if params.Name == "ColorLeft" then
			cursor = ((cursor-2)%(count))+1
		end
	end;
}


for i=1,6 do
	t[#t+1] = scroller(i)
end

return t