t = Def.ActorFrame{}

local judgeTableP1 = {}
local stepsP1 = 0
local judgeTableP2 = {}
local stepsP2 = 0

if not GAMESTATE:IsCourseMode() then
	judgeTableP1 = {}
	stepsP1 = 0
	judgeTableP2 = {}
	stepsP2 = 0
end;

local cells = 50
local cellX = WideScale(get43size(20),20)
local cellY = 450
local maxCellWidth = (SCREEN_CENTER_X-WideScale(get43size(40),40))
local cellHeight = 5

local judgeValues = { -- Colors of each Judgment types
	TapNoteScore_W1 = 1,
	TapNoteScore_W2	= 2,
	TapNoteScore_W3	 =3,
	TapNoteScore_W4	= 4,
	TapNoteScore_W5	= 5,
	TapNoteScore_Miss = 6	
}

local judgeColors = { -- Colors of each Judgment types
	[0] = color("#666666"),
	[1] = color("#99ccff"),
	[2] = HSV(48,0.8,0.95),
	[3] = HSV(160,0.9,0.8),
	[4]	= HSV(200,0.9,1),
	[5]	= HSV(320,0.9,1),
	[6] = HSV(0,0.8,0.8),	
};

local cellTable = {}
for i=1,cells do
	cellTable[#cellTable+1] = 0
end;

local availcells
local notesPerCell
local cellsPerNote
local judgeTable

-- if judgetable is larger or equal to celltable
if (not GAMESTATE:IsCourseMode()) then
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		availCells = math.max(math.floor((#cellTable-1)*(#judgeTableP1/stepsP1)),0)+1 -- number of available cells, must have at least 1
		notesPerCell = math.floor(#judgeTableP1/availCells)
		cellsPerNote = math.floor(availCells/#judgeTableP1)
		judgeTable = judgeTableP1
	else
		availCells = math.max(math.floor((#cellTable-1)*(#judgeTableP2/stepsP2)),0)+1 -- number of available cells, must have at least 1
		notesPerCell = math.floor(#judgeTableP2/availCells)
		cellsPerNote = math.floor(availCells/#judgeTableP2)
		judgeTable = judgeTableP2
	end

	if notesPerCell ~= 0 then
		for k,v in ipairs(judgeTable) do
			cellTable[(math.min(availCells,math.floor(k/notesPerCell)+1))] = math.max(cellTable[(math.min(availCells,math.floor(k/notesPerCell)+1))],judgeValues[v])
		end;
	else -- if celltable is larger
		for k,v in ipairs(cellTable) do
			cellTable[k] = judgeValues[judgeTable[math.floor(k/cellsPerNote)+1]] or 0
		end
	end

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,cellX,cellY;halign,0;valign,0;zoomto,maxCellWidth,cellHeight;diffuse,color("#333333"));
	}

	for k,v in ipairs(cellTable) do
		t[#t+1] = Def.Quad{
			InitCommand=cmd(xy,0,cellY;zoomto,(maxCellWidth/cells)-2,cellHeight;halign,0;valign,0;diffuse,judgeColors[v];x,((k-1)*maxCellWidth/cells)+cellX+1;diffusealpha,0;sleep,k/cells;smooth,1;diffusealpha,1);
		}
	end
end

cellTable = {}
for i=1,cells do
	cellTable[#cellTable+1] = 0
end;

if GAMESTATE:GetNumPlayersEnabled() >= 2 and (not GAMESTATE:IsCourseMode()) then
	availCells = math.max(math.floor((#cellTable-1)*(#judgeTableP2/stepsP2)),0)+1 -- number of available cells, must have at least 1
	notesPerCell = math.floor(#judgeTableP2/availCells)
	cellsPerNote = math.floor(availCells/#judgeTableP2)
	judgeTable = judgeTableP2

	if notesPerCell ~= 0 then
		for k,v in ipairs(judgeTable) do
			cellTable[(math.min(availCells,math.floor(k/notesPerCell)+1))] = math.max(cellTable[(math.min(availCells,math.floor(k/notesPerCell)+1))],judgeValues[v])
		end
	else -- if celltable is larger
		for k,v in ipairs(cellTable) do
			cellTable[k] = judgeValues[judgeTable[math.floor(k/cellsPerNote)+1]] or 0
		end
	end;

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,SCREEN_CENTER_X+cellX,cellY;halign,0;valign,0;zoomto,maxCellWidth,cellHeight;diffuse,color("#333333"));
	}

	for k,v in ipairs(cellTable) do
		t[#t+1] = Def.Quad{
			InitCommand=cmd(xy,0,cellY;zoomto,(maxCellWidth/cells),cellHeight;halign,0;valign,0;diffuse,judgeColors[v];x,SCREEN_CENTER_X+((k-1)*maxCellWidth/cells)+cellX+1;diffusealpha,0;sleep,k/cells;smooth,1;diffusealpha,1);
		}
	end
end

return t