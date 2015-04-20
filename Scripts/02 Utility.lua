function get43size(size4_3)
	return 640*(size4_3/854)
end;


function capWideScale(AR4_3,AR16_9)
	if AR4_3 < AR16_9 then
		return math.max(AR4_3,math.min(AR16_9,WideScale(AR4_3, AR16_9)))
	else
		return math.min(AR4_3,math.max(AR16_9,WideScale(AR4_3, AR16_9)))
	end;
end;