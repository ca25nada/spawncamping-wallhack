
-- Bezier curve tweening test.
function Actor.bouncy(actor,time)
	return actor:tween(time,"TweenType_Bezier",{0,0,0.3,-0.1,0.3,1.5,1,1})
end