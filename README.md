# spawncamping-wallhack
A WIP Stepmania 5 theme aimed primarily for KB players.
Hopefully won't be as broken as the ultralight-fork I made previously.


It's being made on StepMania 5.0.7 for a 16:9 display. 

Currently it'll only run on a SM5 nightly 20150410 or later. which you can grab from: http://smnightly.katzepower.com/ 
(However, do note there are issues with the 20150410's nightly regarding timingdata that kyzentun pointed out here: http://www.flashflashrevolution.com/vbz/showthread.php?p=4303796#post4303796 )

---
##### Current Issues
* Every screen except for like 3 is still _fallback (rip)
* Scoretracking still tracks scores while autoplay is enabled.
* Everything blows up for rave and various course modes. (I disabled it from the menus for now)
* SMO works but it's somewhat messy, also you can't grab any server-side scores.
* Scripts for fetching various stuff are kinda everywhere right now. Needs some cleanup.
* The cells at the bottom of the eval screen doesn't fill when there are less judgments than the cells themselves. 


---
##### To be added soon 
* Title menu
* CDTitles for ScreenSelectMusic
* Pacemaker graph (not porting the ultralight-edit one because it's really messy-)
* Info for various tabs on ScreenSelectMusic
* scoreboard for eval screen from ultralight-edit


---
##### Acknowledgements
* The StepMania 5 devs (notably freem and Kyzentun) for making this possible in the first place.
* lurker,rulululull, and people in #vsrg for feedbacks..!
* ScreenFilter.lua was taken from the Default theme.
* Some of the codebase that uses UpdateFunctions are based off of Jousway's code snippets.
