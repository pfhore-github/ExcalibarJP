last_poly = nil;
wall_busted = false;
timer = 0;

function level_init (rs)
	weak_brick = find_platform(355);
	   Players[0]:play_sound(251, 1);   
end

function level_idle ()

   player_poly = Players[0].polygon.index;
   if (player_poly ~= last_poly) then
      last_poly = player_poly;
      end
   if weak_brick.active and (not wall_busted) then
      timer = 1;
      wall_busted = true;
      Players[0]:play_sound(226, 1);
      end
   if (timer > 0) then
      timer = timer + 1;
      end;
   if (timer == 90) then
      timer = 0;
      end
   if ( (timer > 15) and (timer < 90) ) then
      theta = Game.global_random (360);
      vel = (Game.global_random(130+timer*0.5))/10000;
      Players[0]:accelerate(theta, vel, 0);
      end
end

