-- A moving average NPS calculator

-- Do note that this is hardcoded for PLAYER_1 only for simplicity.
-- However, both players are supported for all data structures and functions.

-----------------------------------
-- Constants and Data Structures -- 
-----------------------------------

-- Generally, a smaller window will adapt faster, but a larger window will have a more stable value.
local maxWindow = 10 -- this will be the maximum size of the "window" in seconds. 
local minWindow = 1 -- this will be the minimum size of the "window" in seconds. 
local npsWindow = {
	PlayerNumber_P1 = maxWindow,
	PlayerNumber_P2 = maxWindow,
}

-- This table holds the timestamp of each judgment for each player.
-- being considered for the moving average and the size of the chord.
-- (let's just call this notes for simplicity)
local noteTable = {
	PlayerNumber_P1 = {},
	PlayerNumber_P2 = {},
}

-- Total sum of notes inside the moving average window for each player.
-- The values are added/subtracted whenever we add/remove a note from the noteTable.
-- This allows us to get the total sum of notes that were hit without
-- iterating through the entire noteTable to get the sum. 
local noteSum = {
	PlayerNumber_P1 = 0,
	PlayerNumber_P2 = 0, 
}

local peakNPS = {
	PlayerNumber_P1 = 0,
	PlayerNumber_P2 = 0, 
}

local enabled = {
	PlayerNumber_P1 = GAMESTATE:IsPlayerEnabled(PLAYER_1) and true,
	PlayerNumber_P2 = GAMESTATE:IsPlayerEnabled(PLAYER_2) and true,
}


---------------
-- Functions -- 
---------------

-- This function will take the player, the timestamp,
-- and the size of the chord and appends it to noteTable.
-- The function will also add the size of the chord to noteSum 
-- This function is called whenever a JudgmentMessageCommand for regular tap note occurs.
-- (simply put, whenever you hit/miss a note)
local function addNote(pn,time,size)
	noteTable[pn][#noteTable[pn]+1] = {time,size}
	noteSum[pn] = noteSum[pn]+size
end


-- This function is called every frame to check if there are notes that 
-- are old enough to remove from the table.
-- Every time it is called, the function will loop and remove all old notes
-- from noteTable and subtract the corresponding chord size from noteSum.
local function removeNote(pn)
	local exit = false
	while not exit do
		if #noteTable[pn] >= 1 then
			if noteTable[pn][1][1] + npsWindow[pn] < GetTimeSinceStart() then
				noteSum[pn] = noteSum[pn] - noteTable[pn][1][2]
				table.remove(noteTable[pn],1)
			else
				exit = true
			end
		else
			exit = true
		end
	end
end


-- The function simply Calculates the moving average NPS
-- Generally this is just nps = noteSum/window.
local function getCurNPS(pn)
	return noteSum[pn]/clamp(GAMESTATE:GetSongPosition():GetMusicSeconds(),minWindow,npsWindow[pn])
end



-- This is an update function that is being called every frame while this is loaded.
local function Update(self)
	self.InitCommand=cmd(SetUpdateFunction,Update)

	for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
		-- We want to constantly check for old notes to remove and update the NPS counter text. 
		removeNote(pn)

		curNPS = getCurNPS(pn)

		-- Update peak nps
		peakNPS[pn] = math.max(peakNPS[pn],curNPS)

		-- the actor which called this update function passes itself down as "self".
		-- we then have "self" look for the child named "Text" which you can see down below.
		-- Then the settext function is called (or settextf for formatted ones) to set the text of the child "Text"
		-- every time this function is called. 
		self:GetChild("npsDisplay"..pn):GetChild("Text"):settextf("%0.1f NPS (Max %0.1f)",curNPS,peakNPS[pn])

		-- update the window size. 
		-- This isn't needed at all but it helps the counter
		-- adapt quickly to high-nps bursts.
		-- Ideally, I should be using derivatives or a tangent line to get the rate it changes but I'm lazy.
		npsWindow[pn] = clamp(15/math.sqrt(getCurNPS(pn)),1,maxWindow )
	end;
end

local function npsDisplay(pn)
	local t = Def.ActorFrame{
	Name = "npsDisplay"..pn;
	-- Whenever a MessageCommand is broadcasted,
	-- a table contanining parameters can also be passed along. 
	JudgmentMessageCommand=function(self,params)
		local notes = params.Notes -- this is just one of those parameters.

		local chordsize = 0

		if params.Player == pn then
			if params.TapNoteScore and params.TapNoteScore ~= 'TapNoteScore_HitMine' or params.TapNoteScore ~= 'TapNoteScore_AvoidMine' then
				-- The notes parameter contains a table where the table indices 
				-- correspond to the columns in game. 
				-- The items in the table either contains a TapNote object (if there is a note)
				-- or be simply nil (if there are no notes)
				
				-- Since we only want to count the number of notes in a chord,
				-- we just iterate over the table and count the ones that aren't nil. 
				for i=1,GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() do
					if notes ~= nil and notes[i] ~= nil then
						chordsize = chordsize+1
					end
				end

				-- add the note to noteTable
				addNote(pn,GetTimeSinceStart(),chordsize)
			end
		end
	end;
	}
	-- the text that will be updated by the update function.
	t[#t+1] = LoadFont("Common Normal")..{
		Name="Text"; -- sets the name of this actor as "Text". this is a child of the actor "t".
		InitCommand=cmd(x,5;y,38;halign,0;zoom,0.40;halign,0;valign,0;shadowlength,1;settext,"0.0 NPS");
		BeginCommand=function(self)
			if pn == PLAYER_2 then
				self:x(SCREEN_WIDTH-5)
				self:halign(1)
			end
		end;
	}
	return t
end;

local t = Def.ActorFrame{
	InitCommand=cmd(SetUpdateFunction,Update)
}

for k,v in pairs({PLAYER_1,PLAYER_2}) do
	if enabled[v] then
		t[#t+1] = npsDisplay(v)
	end;
end;

return t