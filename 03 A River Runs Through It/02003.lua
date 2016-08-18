timer = 0;

function master_init (rs)
	Players[0]:play_sound(249, 1);
end

function master_idle ()
	if (timer == 0) then
		if (Tags[11].active) then
			Players[0]:play_sound(226, 1);
			timer = 1;
		end
	end
	if (timer > 0) then
		timer = timer + 1;
	end
	if (timer == 1050) then
		Players[0]:play_sound(176, 1);
		timer = 0;
	end
	if ( (timer > 15) and (timer < 1050) ) then
		for p in Players() do
			local theta = Game.global_random(360);
			local vfactor = timer;
			if (vfactor > 240) then 
				vfactor = 240
			 end
			local vel = (Game.global_random (100+vfactor*0.5))/10000;
			p:accelerate(theta, vel, 0);
		end
	end
end
