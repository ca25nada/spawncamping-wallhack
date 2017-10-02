BGM = {
	path = "",
	start = 0,
	length = 0,
	loop = false,
}

function BGM.set(self, path, start, length, loop)
	self.path = path
	self.start = start
	self.length = length
	self.loop = loop
end

function BGM.play(self)
	SCREENMAN:SystemMessage("Whee")
	SOUND:PlayMusicPart(self.path, self.start, self.length, 2, 2, self.loop, true, true)
end

function BGM.stop()
	SOUND:StopMusic()
end