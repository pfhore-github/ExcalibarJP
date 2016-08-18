last_poly = -1;
timer = 0;
sound_poly = { 9, 118, 163, 120, 176, 15, 245 };
function level_init (rs)
	Players[0]:play_sound(223, 1);
end

function level_idle ()
	player_poly = Players[0].polygon.index;
	if (player_poly == 324) then
		if Players[0].z <= 0 then
			Players[0]:position(.375, -9.125, 4.9, Polygons[35]);
		end
	end
	if (player_poly ~= last_poly) then
		last_poly = player_poly;
		if (timer == 0) then
			for i, v in ipairs(sound_poly) do 
				if (player_poly == v) then
					Players[0]:play_sound(226, 1);
					timer = 1;
			 		break;
				end
			end
		end
	end
	if (timer == 0) then
		if find_platform(194).active or find_platform(195).active or 
			find_platform(196).active or find_platform(197).active then
			Players[0]:play_sound(226, 1);
			timer = 1;
		end
	end
	if (timer > 0) then
		timer = timer + 1;
	end
	if (timer == 240) then
		Players[0]:play_sound(176, 1);
		timer = 0;
	end
	if ( (timer > 15) and (timer < 240) ) then
		for p in Players() do
			local theta = Game.global_random (360);
			local vel = (Game.global_random(100+timer*0.5))/10000;
			p:accelerate(theta, vel, 0);
		end
	end
end
