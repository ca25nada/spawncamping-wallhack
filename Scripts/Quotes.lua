--Random quotes,phrases and memes from various rhythm gaming communities /o/ 
--(that you may or may not be familar with.... heck i don't even know the references for some of these)
--mainly from ossu, stepman and bms

-- Also (hopefully helpful) tips regarding the game/theme,etc.
-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
local function contains(table, value)
  for _, v in pairs(table) do
    if v == value then
      return true;
    end;
  end;
  return false;
end;

local Tips = {
    --SM Tips
    "Pressing <Scroll Lock> immediately allows you to go to options",
    "You can mute action scounds by pressing <Pause/Break>",
    "Holding <F3> brings up the debug menu",
    "Hold down <Tab> to make things go fast, <~> for making things slow, and both to make things stop.",
    "Press <Ctrl>+<Backspace> on ScreenSelectMusic delete the song from the music wheel. Make sure \"Allow Song Deletion\" is On from \"Advanced Options\"",
    "Press <Ctrl>+<Shift>+<R> on ScreenSelectMusic to reload the selected song",
    "Pressing <PrintScr/SysRq> takes a screenshot of the game, pressing <Shift>+<PrintScr/SysRq> will do so in a .png format and in original size.",
    "You can make profiles by going into \"Options > Profiles > Create Profile\"",
    "You can map keys/inputs by going into \"Options > Config Key/Joy Mappings\"",
    "(Windows only) typing \"%appdata%\" into your explorer bar opens the AppData folder. You can find your stepmania settings folder from there.",
    "StepMania by default will only save the top 3 scores on your profile. This can be changed in \"Arcade Options\"",
    "Pressing <F8> Enables the autoplay. <Alt>+<F8> will do so without displaying the autoplay text.",

    --Theme Specific
    "Please don't bug the StepMania devs regarding bugs on this theme. (bug whoever made this theme instead.!! who will likely bug the devs anyway-)",
    "Feel free to suggest feature requests on the github issue tracker or on the forum thread.",
    "You can change the default scoring type in \"Theme Options\"",
    "You can change the color scheme of the theme by editing the values in \"scripts/02 Colors.lua\"",
    "Press <EffectUp>+<EffectDown> Both at the same time in ScreenSelectMusic to bring up the avatar switch screen.",
    "Press a button that is mapped to <Select> on your key bindings to select different tabs on ScreenSelectMusic",
    "You can set preferences for various theme functions in \"Options > Theme Options\"",
    "The theme is only supported for SM 5.0.8 or newer.",
    "This theme updates rather often, so make sure to check the thread/github page once every while for bugfixes and updates.",
    "Check the \"Other\" tab for general information regarding StepMania and the theme",
    "Rave and Course modes are disabled in this theme because it's terribly broken right now.",
    "SMO should work without errors but do note that the theme can't display server-side scores at the moment.",
    "You can change the speedmods ingame by pressing <EffectUp> or <EffectDown> during gameplay.",
    "You can adjust the lanecover height by holding <Select> and then pressing <EffectUp> or <EffectDown>",

    --Other SM related Tips
    "Check http://www.flashflashrevolution.com/vbz/showthread.php?t=133223 for a huge list of simfile packs",
    "Poke Jousway in the forums for anything noteskin related."

}

local Phrases = {
    "That guy is saltier than the dead sea.",
    "not even kaiden yet",
    "a noodle soup a day and your skills won't decay",
    "hey girl im kaiden want to go out",
    --"now with more drops, sadly rain does not produce dubstep.",
    "i dropped out of school to play music games",
    --"tropical storm more like tropical fart",
    --"protip: dolphins are not capable of playing music games, let alone make music for them.",
    "did you hear about this cool game called beatmani?",
    "to be honest, it's not ez to dj.",
    "at least we won't lose our source code.", -- rip LR2
    "less woosh more drop", -- SDVX
    "studies show that certain rhythm game communities contain more cancerous and autistic people than other communities.",
    --"hot new bonefir remix knife party",
    "i'll only date you if you're kaiden",
    "it's called overjoy because the people who plays those charts are masochists",
    "studies show that combo-based scoring is the biggest factor of broken equipment in the rhythm game community",
    "YOU GET 200 GOLD CROWNS! IT IS EXTRAORDINARY!! YOU ARE THE TRUE TATSUJIN",
    "ayy lmao",
    "nice meme",
    "S P A C E  T I M E",
    "You gonna finish that ice cream sandwich?",
    "TWO DEE ECKS GOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOLD",
    "dude nice",
    "You know what it is, bitch.",
    "You're a master of karate and friendship for everyone!",
    "\"your face is buggy\" - peppy",
    "holy firetruck",
    --"CHAMPION OF THE ssssssssssssssssssssSUN",
    --"what a dumb ass nightingale",
    "C H A O S M A I D  G U Y",
    "What the hell is that.", -- insane techniuques
    --"I'm not good enough for Blocko.",
    --"Evasiva coches.",
    "future metallic can - premium skin",
    "2/10",
    "\"what the fuck is VOS\"",
    "Party like it's BM98.",
    --"Everyone seems a bit too obsessed with the moon. I wonder if they're werewolves...",
    --"thanks mr. skeltal",
    "rice and noodles erryday",
    --"reticulating splines",
    ":^)",
    --"hi spy",
    --"hi arcwin",
    "protip: to be overjoy you just have to avoid missing",
    --"have you visited theaquila today?",
    --"Find us at http://vsrg.club !",
    "\"Eating children is part of our lives.\"",
    "Don't you put it in your mouth.",
    "\"Like the game you may all know stepmania\"",
    "Time to enjoy. I guess.",
    "Are you kaiden yet?",
    "\"Overmapping is a mapping style.\"",
    "\"I play volumax.\" - Hazelnut-",
    "\"mario paint music!!\" - peppy",
    "very spammy",
    "your favourite chart is shit",
    "1.33 -> 0.33 -> 1.0 <=/=> 1.5 -> 0.5 -> 1.0",
    "rip words",
    "misses are bad",
    "aiae lmao",
    "\"573 or nothing\"",
    "wats ur favrit 2hu",
    --"canmusic makes you ET",
    "youdo me and ideu- you",
    "As easy as ABCD.",
    "You'll full combo it this time.",
    "You're gonna carry that weight.",
    --"fappables/duck.gif",
    --"16 hours of B.O. blocko power!",
    "\"how can there be 714 bpm if theres only 60 seconds in a minute?\"",
    "Far East Nightbird (Twitch remix)",
    "Just hold on. You'll be fine, I promise. Everyday.",
    "2spooky",
    "i'm not a kaiden i'm a ninja gaiden",
    "\"did you seriously pay peppy 4$ to upload a fucking thomas the tank engine dump\"",
    "\"mania is a pile of unmanageblae shit i'm not fixing it\" - peppy",
    "\"Korean Mmorpg\"", -- For a free 42 hour silence and a potential ban 
    "\"I had a SV change trauma this SV change requires my no response in flying ball towards me\"", -- ABCD
    "Re:apparantly wearing a fedora improves sightreading???", -- a thread on oss
    "\"How does your osu have all notes go to one place?\"", -- Taiko 
    "Fuga Fuuuga Fuuuuuckga Fuuuuuuuuckga Darkstar PAZO light TRASH ACE WOOD HELL", -- Fuga Hall of Shame
    "JESUS WON'T COME TO SAVE YOU IN RHYTHM GAME HELL SON",
    "slapping colorful hamburgers is one of my many hobbies", -- popn
    "our park isn't very sunny in fact its raining", -- popn
    "big colorful buttons", -- popn
    --"\"did you seirously pay peppy $4 to upload a fucking dump chart for the thomas and friends theme\" - fullerene-",
    "\"I'LL NEVER PLAY 'BEAT-BEAT REVELATION' AGAIN!\"", -- some movie
    "\"What is SOWS? I tried to Google it but all I get is pictures of female pigs\"",
    "To Abcdullah: your cheating is obvious, doing 100.00% on lv.26-28 maps from the first attempt is cheating, admit it.",
    "konmai", -- konami
    "haha facerolling",
	"gonz:pork",
	"BMS = Button Mashing Simulator", -- Some yt comment... might have been doorknob
	"leonid fucking hard", -- LUXURY"
	"in Norway every girl is blonde, blue eyed and 300BPMs", -- Roar176
	"vROFL",
	"Sandbaggerrrrrrr", -- How to win FFR tourneys 
	"\"I'm gonna suee your ass to pakistan\"", -- Gundam-Dude
	"what is the romaji of 皿 : scratches", -- AKA: sarachan >~<
	"solo rulz",
	"(o:",
	"TSUMOOOOOO", -- Chiitoitsu dora2 4000/2000 and y'all owe me a simfile
	"maniera fuck", -- ideu
	"Solord State Squad", 
	"fripSide noodle factory", -- EVERY 17VA MAP
	"StepMania changed my life!",
	"Lincle Prim is best Prim", 
	"Bubububub~", 
	"Lovery Radio", 
	"えいニャ！　えいニャ！", 
	"Dat MA",
	"IT HAS MEI IN IT", -- Toy's march 
	"J1L1", -- Pr0 settings 
	"(KOOKY)", -- EVERY BMS DUMP
	"bruh...",
	"(^^)/★★", -- ABCD
	"less apm for more swage", -- Roar
	"\"people age at a rate of about 1 year per year\"", -- Choofers
	"Overjoy in 6 months", -- Yume
	"FDFD in 6 months", -- what Yume could've done if he didn't rq bms for popn
	"FUCGELO", -- ↓YOU FUC 
	"earbleed",
	"にっこにっこにー☆", -- raburaibu
	"%E3%83%96%E3%83%B3%E3%82%BF%E3%83%B3 ～Falling in \"B\" mix～", -- buntan
	"~koreastep~",
	"solocock.png", -- "Mine is Bigger" also solorulz
	"Gigadelicious",
	"hot sexy touhou", -- AKA: HST
	"Today's Popn", -- leonid
	"B..bbut... you're supposed to play this on a dance mat", -- Every youtube comment ever on stepmania vids
	"WinDEU hates you",
	"nerd",
	"~kawaii chordsmash~", -- https://www.youtube.com/watch?v=52laML7s9y0
	">~<",
	";w;",
	"uwaaaa",
	"tatataatatatatattatatattatatataii hihhihihihihhihhihihihihiihihhihihihihhihhi",
	"\"Is dis a game? If it is can I ask for da link and I need to play dis so badly and I wanna know if dere is any vocaloid songs on it\"",
	"Korea team for 4k: Captain:abcd right hand, player 2: abcd left hand", -- longgone
	"hory shiet", -- Zak
	"(=^._.^)/☆", --0
	"if i train a cat to play bms for 15 years it will pass overjoy", -- Leonid
    "\"You're in denial, your SVs suck and your map needs work\"", -- moar ossu drama
    "StepMania Detected", -- choof
    "\"listen to the music carefully. my jacks always have it own means\"", -- victorica_db
    "\"i dont think my sv is bad . i dont know how you use sv changes but my sv changes are actually comfortable.\"", -- victorica_db
    "you will kill players", -- Spy killing players
    "\"standard is the only mod worth playing, the other mods require basically less than half the skill\"",
    "\"mania is the easiest I think.  I can clear a lot of ranked maps compare to standard.\"", -- entozer
    "\"you can't ask consistency in players because the next day they could be drunk while playing. or ate a lot of carbo and meat.\"",
    "\"Don't do nazi mods,then it will no drama happen.\"", -- Spy
    "\"jackhammers are nothing on an IIDX controller.\"", -- kidlat020
    "\"but then good players will have more advantage in the rankings\"",
    "EXTRA CRISPY ORIGINAL RECIPE RASIS BREAST", -- foal irc bot
    "\"what's a fuckin town without ducks, j-tro?\"",
    "mfw",
    "gross",
    "\"I bet you were gettin the red face and fast heartbeat...then fucked up and the feeling kinda wore off\"",
    "\"I beat off to this background dancer in DDR Supernova once too\"",
    "\"Shut the fuck up Trance Core\"",
    "==Planet KARMA==",
    "STOP FUCKING ARGUING OVER STEPMANIA -- IT'S STEPMANIA, FUCKING DDR ON KEYBOARD", -- Xoon Drama Pack
    "WookE Seal of Approval",
    "invisible 16th streams", -- QED
    "Subjectivemanias",
    "THE FACE OF A QUAD", -- https://www.youtube.com/watch?v=PTQmhbnsid8
    "16th notes Stream file, fun factor based; \"Too generic, 2/10\"",
    "Color theory, Pirtech relevance, Technicality based; \"Masterpiece, I cried playing, 10/10\"", -- hipster stepmania
    "Oooooh yeah, Feel the notes....",
    "\"can someone send me helvetica so i can make gfx\"",--for solo rulz 3 http://www.flashflashrevolution.com/vbz/showpost.php?p=4253999&postcount=13
    "\"I'm not gonna fight for anime titties, but I'm gonna fight for the right to know if my anime titties are rankable or not.\"", -- https://osu.ppy.sh/forum/p/3592977
    "Human Sequencer", -- mei
    "\"i am DEFGullah trust me\"", -- o2jam_guy
    "\"you're not even WXYZullah\"", -- hazelnut in response to o2jam_guy
    "\"just because you collect loli girls doesn't make it weeaboo\"", -- aqo
    "\"are you a women xD your profile picture look like women\"", -- https://osu.ppy.sh/forum/p/3871389
    "Everlasting Message", -- AKA: For UltraPlayers hoooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
    "\"And I'm not a noob I got 227 pp\"",
    "whats more dense, a black hole or an icyworld file", -- choof
    "fuk LN", -- Staiain's twitch chat
    "\"Which edition of IIDX is |999999^999999 from?\"", --  ARC of #bemaniso
    "\"78%\"", -- rip iidx players
    "\"Mine Infested Files Killed The Game\"", -- http://www.flashflashrevolution.com/vbz/showthread.php?p=4300456#post4300456
    "STEPMANIA BROKEN", -- does anyone still remember the yt vid mfw-
    "HOLY SAMBALAND", -- the land of (^^)
    "\"i have a problem. spada keeps asking me for an eamusement pass and then says game over. this happens after i played 3 songs\"",
    "\"lying sack of shit i want to play pop'n but im gonna type moonrunes at you\"", -- foal
    "\"like if there's a L.E.D. song titled GIGANTIC ONION CANNON I won't be shocked\"", -- UBerserker
    "2D IS GOOOOOOOOOOOOOOLD!", -- TWO DEEKS GOOOOOLD-
    "\"I seriously can't go to clubs and dance with random girls because they're so freaking off sync. -- change their global offset\"",
    "eyelid sudden+",
    "\"Nanahira is love. I hope she makes collab with Prim sometime.\"", -- shortly followed by "Have mercy on our ears"
    "\"we should impersonize the scratch from lr2 into some annoying anime chick\"", -- sarachan >w
    "be-music salt",
    "fry EOS", -- Hazelnut: try*
    "real overjoys use magic", --nekro
    "\"I'M NOT A LOLICON HATER, SOME OF MY BEST FRIENDS ARE LOLICON\"", -- bemanisows QDB
    "\"iidx song titles as nicknames for body parts. like. those are some huge valangas.\"", -- bemanisows QDB
    "\"I'm used to another mania style game called osu!mania where the notes come from above and are clicked at the bottom, in stepmania it seems to be the opposite.\"",
    "717x616 c987", -- someone's sm3.95 settings
    "\"don't go into osu with some converted sims you might get busted at a checkpoint... friend was raided after a controlled delivery the other day... tryna fence some hot dumps...\"", -- arch0wl how to pp
    "10th dan is too cynical", -- LG
}

--tip

function getRandomQuotes(tipType)
    if tipType == 2 then
        return "TIP: "..Tips[math.random(#Tips)];
    elseif tipType == 3 then
        return Phrases[math.random(#Phrases)];
    else
        return "";
    end;
end;