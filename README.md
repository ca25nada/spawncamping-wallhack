# spawncamping-wallhack
A WIP Stepmania 5 theme aimed primarily for KB players.
Hopefully won't be as broken as the ultralight-fork I made previously.


It's being made on StepMania 5.0.7 for a 16:9 display. (Anything between 4:3 and 16:9 will work now but some elements will be cut for non-widescreen displays)

Currently, it'll only run properly on a SM5 nightly build. which you can grab from: http://smnightly.katzepower.com/ 

---
##### Current Issues
* Every screen except for like 3 is still _fallback (rip)
* Scoretracking still tracks scores while autoplay is enabled.
* Everything blows up for rave and various course modes. (I disabled it from the menus for now)
* SMO works but it's somewhat messy, also you can't grab any server-side scores.
* Scripts for fetching various stuff are kinda everywhere right now. Needs some cleanup.
* The cells at the bottom of the eval screen doesn't fill completely when there are less judgments than the cells themselves. 
* Overlapping elements for screens that are not wide enough.

---
##### To be added soon 
* Title menu
* IIDX-esque Pacemaker graph
* Info for various tabs on ScreenSelectMusic
* General Protiming stuff (fast/slow indicator, ms offsets)

---
##### Acknowledgements
* The StepMania 5 devs (notably freem and Kyzentun) for making this possible in the first place.
* people in #vsrg,#stepmania-devs and various other people for feedbacks..!
* ScreenFilter.lua was taken from the Default theme by Midiman.
* CDTitle Resizer, ScreenSelectMusic Backgrounds are adapted from Jousway's code.
