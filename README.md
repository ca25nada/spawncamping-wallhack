# spawncamping-wallhack
A WIP Stepmania 5 theme aimed primarily for KB players.  
<a href="http://imgur.com/a/ddHZN" target="_blank">Screenshots</a>

Requirements: StepMania 5.0.10 or later. Mouse related functions only work on Windows.
* Midgame pauses do not work properly for versions earlier than 5.0.10.
* RadarCategory_Notes wasn't added until 5.0.8 so earlier versions will output an error.

---
### Acknowledgements
* The StepMania 5 devs (notably freem and Kyzentun) for making this possible in the first place.
* people in #vsrg,#stepmania-devs and various other people for feedbacks..!
* ScreenFilter.lua was taken from the Default theme by Midiman.
* CDTitle Resizer, ScreenSelectMusic Backgrounds are adapted from Jousway's code.
* Kyzentun's prefs system is used for setting various profile/theme preferences.

---
### Issues
 * PIU Scores are broken since there's no way to get the total # of checkpoints.
 * Courses are disabled.

---
### TODO   
* Newfield support and moving towards 5.1 in general.
* Adding back nonstop/course modes.
* Ghost Data stuff. (eventually)
* Moving the notefield around during gameplay.
* Finish Simfile/Profile tabs.
* Korean usage guide.. maybe...?

---
### Usage Guide (WIP)   
#### Global
* **Theme Color**  
The main theme color can be set by entering "Color Config" from the title menu.  
From there, you can then set the hexadecimal value to a color of your liking.   
(For reference in case you want to revert, the default color for Main/Highlight is ```#00AEEF```)

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
  Scores are calculated dynamically separate from the game engine's scoring. (aka: everything is done in lua) So any preferences set regarding score weights will have no effect.   
  DP Score will always be used for letter grade calculations regardless of the scoretype set.
  
* **Rate Filter**   
  This option is already enabled by default. When enabled, instead of displaying all scores (with different rate mods) in a single scoreboard, all the scores will be separated by the ratemods that have been used. 
  ![](http://i.imgur.com/wd3T8wc.png)

* **Clear Types**   
  The theme uses iidx-esque cleartypes because... huur durrr lr2 wannabe theme.   
  They should be self-explanatory. (e.g. PFC = ya got all perfect or higher / AAA)

* **Backgrounds**   
  On ScreenSelectMusic and ScreenEvaluation, it will show the current song's background by default. It can be turned off at ```Options → Theme Options → Show Background```   
  It also has a parallax effect with the mouse just because it looks cool on osu..! It can be turned off at ```Options → Theme Options → Move Background```  
  * **Adding Custom backgrounds for ScreenEvaluation**   
    The theme also allows users to display their own images/waifu pics in the evaluation screen instead of the song's background image.   
     First enable the option from ```Options → Theme Options → Eval Background Type``` and set it to either ```Clear+Grade Background``` or ```Grade Background only``` depending on what you want.   

     Then open up the main theme folder, and navigate to this directory:   
     ```<sc-wh Theme Folder>\Graphics\Eval background```   
     
     **DO NOT DELETE**   
     ```Grade_Cleared``` or    
     ```Grade_Failed``` folders   
     *you may remove the placeholder background images inside if you wish.*   
     
     Images in "Grade_Failed" will be loaded for failing scores.   
     Images in "Grade_Cleared" will be loaded for all passing scores.   
     
     In addition, to add backgrounds that are grade-specific, (e.g. only shows upon AA)
     create additional folders with the SM's grade tier as the title.   
     (```Grade_Tier01``` or AAAA has already been done for you as an example)
     
     The theme will then load the backgrounds from the ```Grade_Cleared``` and the ```Grade_Tierxx``` folder.
     (If the grade specific folder is empty while set to ```Grade Background Only```, the theme will revert back to grade_cleared folder for background images.)
    
* **Tips and Quotes**   
  The theme displays *potentially helpful* tips usually on the bottom center of the screen. 
  Options to turn off/toggle types can be found at ```Options → Theme Options → Tip Type```.   
  Set to ```Random Phrases``` for memes.


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
  The number of scores saved is capped to 3 by default in StepMania. This can be changed from ```Options → Arcade Options → Max Machine Scores``` and ```Options → Arcade Options → Max Player Scores```.   
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

* **Song Preview**   
  Select how the song's sample preview is played. It is available in ```Options → Theme Options → Song Preview```.   
  * **SM Style** <sup>Default</sup> - Default. Preview loops from SAMPLESTART to SAMPLESTART+SAMPLELENGTH.
  * **osu! Style (Current)** - Preview loops from SAMPLESTART to the end of the song.   
    If a person exits midway during gameplay (without going to eval) the preview will start from that point. (and then loop from SAMPLESTART afterwards)
  * **osu! Style (Old)** - Preview plays from SAMPLESTART to the end of the song. Then the preview loops from the start to the end of the song.   
  If a person exits midway during gameplay (without going to eval) the preview will start from that point. (and then loop from the beginning afterwards)


---
#### ScreenGameplay
* **Judge Counter**   
  Displays a small window on the side with the amount of judgments made so far and the current letter grade based on these judgments.   
  There are two options for Judge Counter which are available in ```Player Options → Judge Count```. Having it set as ```on``` also shows a subtle highlight for that judgment whenever the corresponding judgment is made. The other ```No Highlight``` option doesn't.   

* **Ghost Score**   
  When enabled, displays the score difference from the target for the scoretype selected.   
  Available from ```Player Options  → Ghost ScoreType```. The target for the ghost score can be set from ```Player Options  → Ghost Target```.

* **Average Score**   
  When enabled, displays the average percentage score for the scoretype selected.   
  Available from ```Player Options  → Average ScoreType```.

* **Pacemaker Graph** <sup>Disabled for 2p</sup>   
  The very same stuff from iidx and lr2. Displays a bar graph showing the current, best and the target score.   
  It follows the ```Ghost ScoreType``` and the ```Ghost Target``` settings for the scoretype and the target graph's value respectively.   
  Available from ```Player Options → PaceMaker Graph```.   

* **Error Bar** <sup>Disabled for 2p</sup>   
  Pretty much the hit error option for the score meter in osu!. This displays the judgment offset visually in a bar that represents the timing window of StepMania. 
  Available from ```Player Options  → Error Bar```.

* **Screen Filter**   
  Displays an overlay below the notefield.   
  Available from ```Player Options  → Screen Filter```. The Values correspond to the alpha value of the filter.   

* **CB Lane Highlights**
  Highlights the lane in which a combo breaking judgment has occured.  
  The color of the highlight will correspond to the color of the judgmenht as well.  
  Available from ```Player Options  → CB Highlight```

* **Sudden+/Hidden+ Lane Cover**   
  Displays an overlay above the notefield with adjustable height.  
  Available from ```Player Options  → Lane Cover```. The height can be adjusted ingame with ```<Select>+<EffectDown>``` and ```<Select>+<EffectUp>```. The white number represents the height of the cover, The green number shows the equivalent scroll speed.   
  Currently, unlike screen filters, lane covers are not tied to the notefield. So it will not work properly with perspective mods or any mods that move the notefield around.


* **Current/Peak NPS Display**   
  Displays the current NPS and the peak nps value.   
  It takes the average NPS taken from the past ```X``` seconds.   
  Available from ```Player Options  → NPS Display```. The time window for the ```X``` seconds above can be set from ```Options → Theme Options → NPS Window``` where the values correspond to seconds.   
  A smaller window updates more quickly but with more unstable values, larger windows does the opposite. 

* **Mid-game Speed Change**   
  Allows the player to change the scroll speed ingame by pressing ```<EffectDown>``` and ```<EffectUp>```.   
  The speed change increment is dependent on the settings available from ```Options → Advanced Options → Speed Increment```.

* **Mid-game Pause**   
  Pause the game during gameplay by quickly pressing ```<Select>``` twice. Doing the same while paused or pressing ```<Start>``` will unpause the game.   
  The number of times the game has been paused will show up on the evaluation screen.   

---
