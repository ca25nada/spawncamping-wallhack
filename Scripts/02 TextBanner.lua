local mainMaxWidth = capWideScale(get43size(280),280) -- zoom w/subtitle is 0.75 (multiply by 1.25)
local subMaxWidth = capWideScale(get43size(280),280) -- zoom is 0.6 (multiply zoom,1 value by 1.4)
local artistMaxWidth = capWideScale(get43size(280),280)

local mainMaxWidthHighScore = 192 -- zoom w/subtitle is 0.75 (multiply by 1.25)
local subMaxWidthHighScore = 280 -- zoom is 0.6 (multiply zoom,1 value by 1.4)
local artistMaxWidthHighScore = 280/0.8

--[[
-- The old (cmd(blah))(Actor) syntax is hard to read.
-- This is longer, but much easier to read. - Colby
--]]
function TextBannerAfterSet(self,param)
	local Title = self:GetChild("Title")
	local Subtitle = self:GetChild("Subtitle")
	local Artist = self:GetChild("Artist")
	
	if Subtitle:GetText() == "" then
		Title:maxwidth(mainMaxWidth/0.75)
		Title:xy(10,-8)
		Title:zoom(0.75)
		
		-- hide so that the game skips drawing.
		Subtitle:visible(false)

		Artist:zoom(0.35)
		Artist:maxwidth(artistMaxWidth/0.35)
		Artist:xy(10,8)
	else
		Title:maxwidth(mainMaxWidth/0.55)
		Title:xy(10,-10)
		Title:zoom(0.55)

		Subtitle:visible(true)
		Subtitle:xy(10,1)
		Subtitle:zoom(0.35)
		Subtitle:maxwidth(subMaxWidth/0.35)

		Artist:zoom(0.35)
		Artist:maxwidth(artistMaxWidth/0.35)
		Artist:xy(10,10)
	end
end
