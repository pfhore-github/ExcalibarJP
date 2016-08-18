last_poly = -1;
timer = 0;
main_quake = false;

function level_init(rs)
	Players[0]:play_sound(249, 1);
end

function level_idle()
	player_poly = Players[0].polygon.index;
	if (player_poly ~= last_poly) then
		last_poly = player_poly;
		if (timer == 0) and (player_poly == 198) and (not main_quake) then
			Players[0]:play_sound(226, 1);
			timer = 1;
			main_quake = true;
		end
	end
	if (timer > 0) then
		timer = timer + 1;
	end
	if (timer == 250) or (timer == 500) then
		Players[0]:play_sound( 226, 1);
		if (timer == 500) then
			timer = 0;
		end
	end
	if ( (timer > 15) and (timer < 500) ) then
		for p in Players() do
			local theta = Game.global_random (360);
			local vfactor = timer;
			if (vfactor > 240) then 
				vfactor = 240
			end
			local vel = (Game.global_random (100+vfactor*0.5))/10000;
			p:accelerate(theta, vel, 0);
		end
	end
end

function Triggers.terminal_exit(terminal, player)
   if (terminal.index == 0) then
      Music.fade(60/1000);
      Music.play("Cavern/Lament.mp3");
   end
end