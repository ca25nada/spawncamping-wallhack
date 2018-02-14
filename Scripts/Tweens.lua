
-- Bunch of cubic bezier curve tweens.

function Actor.bouncy(actor,time)
	return actor:tween(time,"TweenType_Bezier",{0,0,0.3,-0.1,0.3,1.5,1,1})
end

function Actor.bouncyOut(actor,time)
	return actor:tween(time,"TweenType_Bezier",{0,0,0.7,-0.5,0.3,1.5,1,1})
end

function Actor.easeIn(actor,time)
	return actor:tween(time,"TweenType_Bezier",{0,0,0.5,0,1,1,1,1})
end

function Actor.easeOut(actor,time)
	return actor:tween(time,"TweenType_Bezier",{0,0,0,0.5,0,1,1,1})
end





function Actor.offsetTickTween(actor,time)
	return actor:tween(time,"TweenType_Bezier",{0,0,0.25,0.1,0.25,1,1,1})
end
