# spawncamping-wallhack
A WIP Stepmania 5 theme aimed primarily for KB players.  
<a href="http://imgur.com/a/RpFvQ" target="_blank">Screenshots</a>

Requirements: StepMania 5.0.12 or later.

---
### Acknowledgements
* The StepMania 5 devs (notably freem and Kyzentun) for making this possible in the first place.
* People in #stepmania-devs and the Rhythm gamers discord for feedback.
* Some of the theme elements are adapted from the default theme or this by jousway https://github.com/Jousway/Stepmania-Zpawn
* Kyzentun's prefs system is used for setting various profile/theme preferences. (which is now available in _fallback for 5.1)

---
### Issues
 * PIU Scores are broken since there's no way to get the total # of checkpoints.
 * Courses are disabled.
 * plus whatever is on the issue tracker

---
### Usage Guide (Not updated for the 5.0.12 branch yet.)   
This is tad outdated now. I'll start updating this over the next few days.

#### Global
* **Theme Color**  
The main theme color can be set by entering "Color Config" from the title menu.  
From there, you can then set the hexadecimal value to a color of your liking.   
To completely reset to default values, delete `%appdata%\StepMania 5\Save\_fallback_config\colorConfig.lua`   


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
  ```Options → Theme Options → Default ScoreType```   
  Currently, the theme supports the 3 most commonly used scoring methods within the keyboard community.
  They are as follows:  

  |ScoreType|W1|W2|W3|W4|W5|Miss|OK|NG|HitMine|   
  |---|---|---|---|---|---|---|---|---|---|   
  |PS/Percentage Scoring (oni EX) <sup>default</sup>|3|2|1|0|0|0|3|0|-2|   
  |DP/Dance Points (MAX2)|2|2|1|0|-4|-8|6|0|-8|   
  |MIGS|3|2|1|0|-4|-8|6|0|-8|   
  Scores are calculated dynamically separate from the game engine's scoring. (aka: everything is done in lua) So any preferences set regarding score weights will have no effect.   
  DP Score will always be used for letter grade calculations regardless of the scoretype set.
  
* **Rate Filter**   
  ```Options → Theme Options → Rate Sort```   
  This option is already enabled by default. When enabled, instead of displaying all scores (with different rate mods) in a single scoreboard, all the scores will be separated by the rate mods that have been used. 

* **Clear Types**   
  The theme uses iidx-esque cleartypes because... huur durrr lr2 wannabe theme.   
  Any life-difficulty based clear types (e.g.`Easy Hard EX-Hard`) requires a ghost data that corresponds to the score. It will default to `Clear` when not available.

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
  ```Options → Theme Options → Tip Type```   
  The theme displays *potentially helpful* tips usually on the bottom center of the screen.
  You can either turn it off or set to `Random Phrases` for memes.


---
#### ScreenSelectMusic
All available tabs in this screen can be accessed either by clicking on the tabs themselves, or pressing ```1 - 5``` on the keyboard for each tab respectively.   
Some Tabs will be disabled for 2 player modes.   

* **General Tab**   
  This tab contains general information about the simfile. Not much else that is worth mentioning here.   
  Hovering the mouse over the letter grade shows the amount of points away from the nearest letter grade.   

* **Simfile Tab** <sup>Incomplete, Disabled for 2p</sup>   
  Contains slightly more detailed information of the currently selected simfile.

* **Score Tab** <sup>Disabled for 2p</sup>   
  This tab will list all the scores and their stats that are currently saved. (Separated by rate mods if Rate Filter is enabled.)    
  Pressing ```<EffectDown>``` and ```<EffectUp>``` will scroll through the scores.   
  Pressing ```<Select>+<EffectDown>``` and ```<Select>+<EffectUp>``` will scroll through available rates.  
  The number of scores saved is capped to 3 by default in StepMania. This can be changed from ```Options → Arcade Options → Max Machine Scores``` and ```Options → Arcade Options → Max Player Scores```.   

* **Profile Tab** <sup>Unimplemented, Disabled</sup>   
  Probably a summary of the profile once I get around adding stuff to this.   

* **Other Tab**   
  This tab contains miscellaneous info about stepmania and the theme that... might... be helpful...?   

* **Help Overlay**   
  ```Options → Theme Options → Help Menu```   
  The help overlay will automatically show after 30 seconds of inactivity on the screen. It currently contains information on how to use the features in ScreenSelectMusic. It is also available by pressing ```F12``` on the keyboard. Default is `on`

* **Song Preview**   
  ```Options → Theme Options → Song Preview```   
  Select how the song's sample preview is played.
  * **SM Style** - The default mode for most (if not all) themes. Preview loops from SAMPLESTART to SAMPLESTART+SAMPLELENGTH.
  * **osu! Style (Current)** - Preview loops from SAMPLESTART to the end of the song.   
    If a person exits midway during gameplay (without going to eval) the preview will start from that point. (and then loop from SAMPLESTART afterwards)
  * **osu! Style (Old)** <sup>Default</sup> - Preview plays from SAMPLESTART to the end of the song. Then the preview loops from the start to the end of the song.   
  If a person exits midway during gameplay (without going to eval) the preview will start from that point. (and then loop from the beginning afterwards)

* **Banner Wheel**   
  ```Options → Theme Options → Banner Wheel```   
  When enabled, a blended image of the simfile banner will appear on the musicwheel. Default is `on`

---
#### ScreenGameplay
* **Judgment Counter**   
  ```Player Options → Gameplay Options → Judge Count```   
  Displays a small window on the side with the amount of judgments made so far and the current letter grade based on these judgments.
  * **On** - Display a subtle highlight for the judgment whenever the corresponding judgment is made during gameplay.   
  * **No Highlight** - No highlights will occur.   

* **Ghost Target**   
  ```Player Options → Gameplay Options → Ghost Target```   
  Sets the target score (in percentage) that will be used by the Ghost Score and the Pacemaker graph. Default is 0.

* **Ghost Score**   
  ```Player Options → Gameplay Options → Ghost ScoreType```   
  When enabled, displays the score difference from the Ghost Target to the player's current score for the scoretype selected.

* **Average Score**   
  ```Player Options → Gameplay Options → Average ScoreType```   
  When enabled, displays the average percentage score for the scoretype selected in the notefield.

* **Pacemaker Graph** <sup>Disabled for 2p</sup>   
   ```Player Options → Gameplay Options → Pacemaker Graph```   
  The very same graph from iidx and lr2. Displays a bar graph showing the `Current`, `Best` and the `Target` score.   
  It follows the `Ghost ScoreType` and the `Ghost Target` settings for the scoretype and the `Target` graph's value respectively. When `Ghost ScoreType` is not specified, the theme will use the theme's default ScoreType instead.
  The `Best` score graph will show the current score of the best previous score at a given time when the ghost data is available.

* **Error Bar** <sup>Disabled for 2p</sup>   
  ```Player Options → Gameplay Options → Error Bar Options → Enable Error Bar```   
  Pretty much the hit error option for the score meter in osu!. This displays the judgment offset visually in a bar that represents the timing window.
  * **Tick Duration**   
    ```Player Options → Gameplay Options → Error Bar Options → Tick Duration```   
    The amount of time for each tick to fade out (in seconds). Default is 1.
  * **Tick Count**   
    ```Player Options → Gameplay Options → Error Bar Options → Tick Count```   
    The maximum number of ticks that can be displayed at a given time. When the maximum number of ticks is reached, older ticks will immediately update to a new position. Default is 100.

* **Screen Filter**   
  ```Player Options → Gameplay Options → Screen Filter```   
  Displays an overlay below the notefield. The Values correspond to the alpha value of the filter.   
  The color of the filter is set from ```gameplay/LaneCover``` inside Color Config.


* **Lane Highlights**   
  ```Player Options → Gameplay Options → CB Highlight```   
  Highlights the lane where a combo breaking judgment has occured.  
  The color of the highlight will correspond to the color of the judgmenht.  


* **Lane Cover**   
  Displays an overlay above the notefield with adjustable height.  
  * **Lane Cover Type**   
    ```Player Options → Gameplay Options → Lane Cover Options → Lane Cover```   
    Sets the type of Lane Cover to use. Hidden+ will cover notes around the receptor while Sudden+ will cover notes from the direction they appear from.
  * **Lane Cover Height**   
    ```Player Options → Gameplay Options → Lane Cover Options → Lane Cover Height```   
    Sets the height of the Lane Cover. The height can also be adjusted during gameplay with ```<Select>+<EffectDown>``` and ```<Select>+<EffectUp>```. 
  * **Lane Cover Layer**   
    ```Player Options → Gameplay Options → Lane Cover Options → Lane Cover Layer```  
    Sets the draw order of the Lane Cover. Objects with higher draw order are rendered higher up on the layer. Generally,  =350 ⇒ Below note explosions, >400 ⇒ Above note explosions, =450 ⇒ Above combo/judgment labels. Default is 350.

* **NPS Display**   
  Displays the current NPS taken from a specified amount of time.
  * **NPS Display**   
    ```Player Options → Gameplay Options → NPS Display Options → NPS Display```   
    Displays the current NPS and the peak value when enabled.
  * **NPS Graph**   
    ```Player Options → Gameplay Options → NPS Display Options → NPS Graph```   
    Displays a graph corresponding to the NPS values. Enabling this option will have a significant impact on performance.
  * **NPS Graph Update Rate**   
    ```Player Options → Gameplay Options → NPS Display Options → NPS Graph Update Rate```   
    Sets how often the NPS graph will update (in seconds). Default is 0.1 .
  * **NPS Graph Max Vertices**   
    ```Player Options → Gameplay Options → NPS Display Options → NPS Graph Update Rate```   
    Sets the max number of points/vertices that will be displayed on the graph. Default is 300.
  * **NPS Window**   
    ```Options → Theme Options → NPS Window```   
    Sets the time window (in seconds) in which the average NPS will be calculated from. A smaller window updates more quickly but with more unstable values, larger windows does the opposite. Default is 2.

* ~~**Mid-game Speed Change**~~ <sup>Removed temporarily</sup>   
  Allows the player to change the scroll speed ingame by pressing ```<EffectDown>``` and ```<EffectUp>```.   
  The speed change increment is dependent on the settings available from ```Options → Advanced Options → Speed Increment```.

* **Mid-game Pause**   
  Ported from default for the 5.1.0 releases.   
  Pause the game during gameplay by quickly pressing ```<Select>``` or ```<Back>``` twice. A pause menu will appear allowing the player to continue, restart or quit out from the song.
  The number of times the game has been paused will show up on the evaluation screen.   

---
