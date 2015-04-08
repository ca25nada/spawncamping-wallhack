t = Def.ActorFrame{}


	local judgeTableP1 = getJudgeTableST(PLAYER_1)
	local stepsP1 = GAMESTATE:GetCurrentSteps(PLAYER_1):GetRadarValues(PLAYER_1):GetValue('RadarCategory_TapsAndHolds')



	local judgeTableP2 = getJudgeTableST(PLAYER_2)
	local stepsP2 = GAMESTATE:GetCurrentSteps(PLAYER_2):GetRadarValues(PLAYER_2):GetValue('RadarCategory_TapsAndHolds')


local cells = 200 / GAMESTATE:GetNumPlayersEnabled()
local cellX = 0
local cellY = 415
local maxCellWidth = SCREEN_WIDTH/(math.max(1,GAMESTATE:GetNumPlayersEnabled())) - (GAMESTATE:GetNumPlayersEnabled()-1)*30
local cellHeight = 10

local judgeValues = { -- Colors of each Judgment types
	TapNoteScore_W1 = 1,
	TapNoteScore_W2	= 2,
	TapNoteScore_W3	 =3,
	TapNoteScore_W4	= 4,
	TapNoteScore_W5	= 5,
	TapNoteScore_Miss = 6	
}

local judgeColors = { -- Colors of each Judgment types
	[0] = color("#FFFFFF"),
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
if GAMESTATE:GetNumPlayersEnabled() >= 1 then
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		availCells = math.max(math.floor((#cellTable-1)*(#judgeTableP1/stepsP1)),0)+1 -- number of available cells, must have at least 1
		notesPerCell = math.floor(#judgeTableP1/availCells)
		cellsPerNote = math.floor(availCells/#judgeTableP1)
		judgeTable = judgeTableP1
	elseif GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		availCells = math.max(math.floor((#cellTable-1)*(#judgeTableP2/stepsP2)),0)+1 -- number of available cells, must have at least 1
		notesPerCell = math.floor(#judgeTableP2/availCells)
		cellsPerNote = math.floor(availCells/#judgeTableP2)
		judgeTable = judgeTableP2
	end;


	if notesPerCell ~= 0 then
		for k,v in ipairs(judgeTable) do
			cellTable[(math.min(availCells,math.floor(k/notesPerCell)+1))] = math.max(cellTable[(math.min(availCells,math.floor(k/notesPerCell)+1))],judgeValues[v])
		end;
	else -- if celltable is larger
		for k,v in ipairs(cellTable) do
			cellTable[k] = judgeValues[judgeTable[math.floor(k/cellsPerNote)+1]] or 0
		end;
	end;

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,cellX,cellY;halign,0;valign,0;zoomto,maxCellWidth,cellHeight;diffuse,color("#333333"));
	}

	for k,v in ipairs(cellTable) do
		t[#t+1] = Def.Quad{
			InitCommand=cmd(xy,0,cellY;zoomto,(maxCellWidth/cells)-1,cellHeight;halign,0;valign,0;diffuse,judgeColors[v];diffusealpha,0;sleep,k/cells;smooth,1;x,math.random(0,maxCellWidth);diffusealpha,1;smooth,0.5;x,((k-1)*maxCellWidth/cells)+cellX);
		};
	end
end;


cellTable = {}
for i=1,cells do
	cellTable[#cellTable+1] = 0
end;


if GAMESTATE:GetNumPlayersEnabled() == 2 then
		availCells = math.max(math.floor((#cellTable-1)*(#judgeTableP2/stepsP2)),0)+1 -- number of available cells, must have at least 1
		notesPerCell = math.floor(#judgeTableP2/availCells)
		cellsPerNote = math.floor(availCells/#judgeTableP2)

	if notesPerCell ~= 0 then
		for k,v in ipairs(judgeTableP2) do
			cellTable[(math.min(availCells,math.floor(k/notesPerCell)+1))] = math.max(cellTable[(math.min(availCells,math.floor(k/notesPerCell)+1))],judgeValues[v])
		end;
	else -- if celltable is larger
		for k,v in ipairs(cellTable) do
			cellTable[k] = judgeValues[judgeTableP2[math.floor(k/cellsPerNote)+1]] or 0
		end;
	end;

	t[#t+1] = Def.Quad{
		InitCommand=cmd(xy,SCREEN_WIDTH-cellX,cellY;halign,1;valign,0;zoomto,maxCellWidth,cellHeight;diffuse,color("#333333"));
	}

	for k,v in ipairs(cellTable) do
		t[#t+1] = Def.Quad{
			InitCommand=cmd(xy,SCREEN_WIDTH,cellY;zoomto,((maxCellWidth/cells)-1),cellHeight;halign,1;valign,0;diffuse,judgeColors[v];diffusealpha,0;sleep,k/cells;smooth,1;x,SCREEN_WIDTH-math.random(0,maxCellWidth);diffusealpha,1;smooth,0.5;x,SCREEN_WIDTH-((k-1)*maxCellWidth/cells)-cellX);
		};
	end
end;

return t