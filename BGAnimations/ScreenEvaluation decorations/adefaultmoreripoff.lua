t = Def.ActorFrame{}

local judgeTableP1 = getJudgeTableST(PLAYER_1)
local stepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue('RadarCategory_TapsAndHolds')

t[#t+1] = LoadFont("Common Large")..{
	InitCommand=cmd(xy,10,60;zoom,0.8;settext,(#judgeTableP1));
};

local judgeValues = { -- Colors of each Judgment types
	TapNoteScore_W1 = 1,
	TapNoteScore_W2	= 2,
	TapNoteScore_W3	 =3,
	TapNoteScore_W4	= 4,
	TapNoteScore_W5	= 5,
	TapNoteScore_Miss = 6	
}

local judgeColors = { -- Colors of each Judgment types
	[0] = color("#333333"),
	[1] = color("#99ccff"),
	[2] = HSV(48,0.8,0.95),
	[3] = HSV(160,0.9,0.8),
	[4]	= HSV(200,0.9,1),
	[5]	= HSV(320,0.9,1),
	[6] = HSV(0,0.8,0.8),	
};

local cellTable = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
local cells = #cellTable
local availCells = math.floor(#cellTable*(#judgeTableP1/stepsP1))
local maxCellWidth = SCREEN_WIDTH/2 --SCREEN_WIDTH/(math.max(1,GAMESTATE:GetNumPlayersEnabled()))
local cellHeight = 10
local cellX = 0
local cellY = 400

local notesPerCell = math.floor(#judgeTableP1/availCells)
local cellsPerNote = math.floor(availCells/#judgeTableP1)

-- if judgetable is larger or equal to celltable
if notesPerCell ~= 0 then
	for k,v in ipairs(judgeTableP1) do
		cellTable[(math.min(availCells,math.floor(k/notesPerCell)+1))] = math.max(cellTable[(math.min(availCells,math.floor(k/notesPerCell)+1))],judgeValues[v])
	end;
else -- if celltable is larger
	for k,v in ipairs(cellTable) do
		cellTable[k] = judgeValues[judgeTableP1[math.floor(k/cellsPerNote)+1]]
	end;
end;

for k,v in ipairs(cellTable) do
	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,cellX+((k-1)*maxCellWidth/cells),cellY;zoomto,(maxCellWidth/cells),cellHeight;halign,0;valign,0;diffuse,judgeColors[v];);
	};
end

return t