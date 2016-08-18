last_poly = nil;
timer = 0;
sound_poly = { 40, 55, 56, 91, 83, 169, 167, 190, 163 };
function level_init (rs)
	Players[0]:play_sound(249, 1);
	if rs then
		return;
	end
	remove_items("spear", "rocks", "crossbow", "crossbow bolts");
end

function level_idle ()
	player_poly = Players[0].polygon.index;
	if (player_poly ~= last_poly) then
		last_poly = player_poly;
		if (timer == 0) then
			for i, sp in ipairs(sound_poly)  do
				if( player_poly == sp ) then
					Players[0]:play_sound(226, 1);
					timer = 1;
			 		break;
				end
			end
		end
	end
	if (timer > 0) then
		timer = timer + 1;
	end
	if (timer == 120) then
		Players[0]:play_sound(176, 1);
		timer = 0;
	end
	if ( (timer > 15) and (timer < 120) ) then
		for p in Players() do
			local theta = Game.global_random(360);
			local vel = (Game.global_random(100+timer*0.5))/10000;
			p:accelerate(theta, vel, 0);
		end
	end
end
