# spawncamping-wallhack
A WIP Stepmania 5 theme aimed primarily for KB players.
Hopefully won't be as broken as the ultralight-fork I made previously.


It's currently being made on StepMania 5.0.6 for a 16:9 display. 
(I don't think I can do 4:3 because everything is already cramped as is)

---
##### [Global] Adding avatar/profile images to a profile
Drop the image you wish to use into the following folder
```
Themes\spawncamping-wallhack\Graphics\Player avatar
```

Go to the folder directory for the profile 

By default it's under the following directory:
```
AppData\Roaming\StepMania 5\Save\LocalProfiles\<some8digitnumber>
you can type %appdata% if you don't know how to access the appdata folder
```
Now create and save a text file named "avatar.txt" in the profile folder with the filename of the image as the text.


##### [ScreenSelectMusic] Switching to different tabs
Press the key to which you mapped the <Select> button to rotate between tabs.


##### [ScreenSelectMusic] Using different scoretypes for scores
Since i'm too lazy to make this into a preference at this moment,
Open the file:
```
Themes\spawncamping-wallhack\Scripts\Scores.lua
```
Then change the variable below to the number corresponding to the scoretype you want to use.
```lua
local defaultScoreType = 2 --1DP 2PS 3MIGS
```
