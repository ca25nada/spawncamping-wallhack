# spawncamping-wallhack
A WIP Stepmania 5 theme aimed primarily for KB players. 

Requirements: StepMania 5.0.8 or later.

---
### Acknowledgements
* The StepMania 5 devs (notably freem and Kyzentun) for making this possible in the first place.
* people in #vsrg,#stepmania-devs and various other people for feedbacks..!
* ScreenFilter.lua was taken from the Default theme by Midiman.
* CDTitle Resizer, ScreenSelectMusic Backgrounds are adapted from Jousway's code.
* Kyzentun's prefs system is used for setting various profile/theme preferences.

---
### Usage Guide (WIP)
---
#### Global
* Theme Color  
The main theme color can be set by entering "Color Config" from the title menu.  
From there, you can then set the hexadecimal value to a color of your liking.   
(For reference in case you want to revert, the default color is #00AEEF)

* **Avatars**   
You can set an avatar to a profile that is then displayed throughout the theme.
  * Adding new avatars   
  Open up the main theme folder, and navigate to this directory:   
  ```<sc-wh Theme Folder>\Graphics\Player avatar```   
  In this folder you can place any images that you wish to use, they should be at least 50px or larger and have a 1:1 aspect ratio.    
  Also, **DO NOT DELETE _fallback.png**.   
  * Setting avatars ingame   
  Once the images have been added, start up stepmania and head over to ScreenSelectMusic.   
  From this screen, you can either click the avatar, or quickly press the ```<Select>``` key twice.
  A new screen should come up on top of the current one with all the currently available images.   
  Use ```<Left>``` or ```<Right>``` to navigate, and press ```<Start>``` to update with the new image.   
  (You may also press ```<Back>``` to cancel without any changes.)   


* **Score Types**   
  Currently, the theme supports the 3 most commonly used scoring methods within the keyboard community.
  They are as follows:  

  |ScoreType|W1|W2|W3|W4|W5|Miss|OK|NG|HitMine|   
  |---|---|---|---|---|---|---|---|---|---|   
  |PS/Percentage Scoring (oni EX) <sup>default</sup>|3|2|1|0|0|0|3|0|-2|   
  |DP/Dance Points (MAX2)|2|2|1|0|-4|-8|6|0|-8|   
  |MIGS|3|2|1|0|-4|-8|6|0|-8|   
  ScoreTypes can be set from ```Options → Theme Options → Default ScoreType```.   
  Scores are calculated dynamically separate from the game engine's scoring. So any preferences set regarding score weights will have no effect.   
  DP Score will always be used for Letter grade calculations regardless of the scoretype set.
  
* **Rate Filter**   
  This option is already enabled by default. When enabled, instead of displaying all scores (with different rate mods) in a single scoreboard, all the scores will be separated by the ratemods that have been used. 
  ![](http://i.imgur.com/wd3T8wc.png)

* **Clear Types**   
  The theme uses iidx-esque cleartypes because... huur durrr lr2 wannabe theme.
  They should be self-explanatory. (e.g. PFC = ya got all perfect or higher / AAA)

---
#### ScreenSelectMusic
All available tabs in this screen can be accessed either by clicking on the tabs themselves, or pressing ```1 - 5``` on the keyboard for each tab respectively.   
Some Tabs will be disabled for 2 player modes.   
* **General Tab**   
  This tab contains general information about the simfile. Not much else that is worth mentioning here.   
  Hovering the mouse over the letter grade shows the amount of points away from the nearest letter grade.   
* **Simfile Tab** <sup>Incomplete, Disabled for 2p</sup>   
  This tab is supposed to contain more detailed information about the simfile buuuuuut it's incomplete.   
  Aside from the hash values for the .sm files, there's more info in the general tab as of right now mfw.   
* **Score Tab** <sup>Disabled for 2p</sup>   
  This tab will list all the scores and their stats that are currently saved. (Separated by rate mods if Rate Filter is enabled.)   
  Pressing ```<EffectDown>``` and ```<EffectUp>``` will scroll through the scores.   
  Pressing ```<Select>+<EffectDown>``` and ```<Select>+<EffectUp>``` will scroll through available rates.   
* **Profile Tab** <sup>Unimplemented, Disabled</sup>   
  Probably a summary of the profile once I get around adding stuff to this.   
* **Other Tab**   
  This tab contains miscellaneous info about stepmania and the theme that... might... be helpful...?   
* **Help Overlay**   
  By default the help overlay will automatically show after 30 seconds of inactivity on the screen.
  It currently contains information on how to use the features in screenselectmusic.
  You can turn off the overlay from showing up automatically by going to : ```Options → Theme Options → Help Menu``` and setting it to ```Off```.   
  It is also available by pressing ```F12``` on the keyboard. 

---
#### ScreenGameplay
* Judge Counter
* Pacemaker Graph
* Error Bar
* Ghost Score and Average Score
* Screen Filter
* CB Lane Highlights
* Current/Peak NPS Display
* Mid-game Speedmod Change
* Sudden+/Hidden+ Lane Cover

---
#### ScreenEvaluation
* The Eval Screen Itself 
* Scoreboard 
* Judgment Cells 
* Result Background
  * Adding Custom result backgrounds

---
#### Misc.
* Tips and Quotes
