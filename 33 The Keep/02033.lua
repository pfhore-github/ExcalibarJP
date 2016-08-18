lost_in_space = 481;
return_poly = 130;
life_cnt = 1;
lift_timer = 0;
lift_cycle = 30;
underwater_active = false;
vortexing = false;
last_poly = nil;

function level_init (rs)
	bottom_lift = find_platform(486);
	top_lift = find_platform(500);
   restoring_saved = rs;
   Players[0]:play_sound(251, 1);
end

function level_idle ()
   player_poly = Players[0].polygon.index;
   p = Players[0].monster;
   h = Players[0].life;
   under = Players[0].head_below_media;
   if under and (player_poly ~= lost_in_space) and (not vortexing) then
      Players[0]:position(-21.95, 19.08, 8, lost_in_space);
   elseif under and (not vortexing) and (life_cnt == 1) then
      life_cnt = life_cnt + 1;
      local solp = Polygons[334];
      nm = Monsters.new(solp.x, solp.y, 0, 334, "soldier");
      nm.yaw = 180;
      solp = Polygons[336];
      nm = Monsters.new(solp.x, solp.y, 0, 336, "soldier");
      nm.yaw = 180;
      p:damage(50, "suffocation");
      Players[0]:teleport(return_poly);
      vortexing = true;
   elseif under and (not vortexing) and (life_cnt == 2) then
      life_cnt = life_cnt + 1;
      local solp = Polygons[173];
      nm = Monsters.new(solp.x, solp.y, 0, 334, "soldier");
      nm.yaw = 180;
      solp = Polygons[175];
      nm = Monsters.new(solp.x, solp.y, 0, 336, "soldier");
      nm.yaw = 180;
      p:damage(100, "suffocation");
      Players[0]:teleport(return_poly);
      vortexing = true;
   elseif under and (not vortexing) and (life_cnt == 3) then
      life_cnt = life_cnt + 1;
      local solp = Polygons[148];
      nm = Monsters.new(solp.x, solp.y, 0, 334, "soldier");
      nm.yaw = 180;
      solp = Polygons[146];
      nm = Monsters.new(solp.x, solp.y, 0, 336, "soldier");
      nm.yaw = 180;
      p:damage(150, "suffocation");
      Players[0]:teleport(return_poly);      
      vortexing = true;
   elseif under and (not player_dead) and (not vortexing) then
      Players[0]:position(-21.95, 19.08, 8, lost_in_space);
   end
   if (player_poly == lost_in_space) and (not player_dead) then
      o2 = Players[0].oxygen - 20;
      if o2 <= 0 then
         o2 = 0;
         p:damage(h+10, "suffocation");
	 Players[0].oxygen = o2;
         player_dead = true;
	 Players[0]:teleport(return_poly);
         vortexing = true;
      end
      Players[0].oxygen = o2;
   end
   if ( bottom_lift.active and (not top_lift.active) and
     (lift_timer == 0) ) then
      top_lift.active = true;
   elseif ( top_lift.active and (not bottom_lift.active) and
	 (lift_timer == 0)) then
      bottom_lift.active = true;
   end
   if ((bottom_lift.active and top_lift.active) and 
    (lift_timer == 0)) then
      lift_timer = lift_cycle;
   end
   if ((not bottom_lift.active) and (not top_lift.active) and 
 (lift_timer > 0)) then
      lift_timer = 0;
   end
   if lift_timer > 0 then
      if lift_timer == lift_cycle then
         if (player_poly == 486) or (player_poly == 500) then
            Players[0]:fade_screen("bright");
	 end
         Players[0]:play_sound(197, 1);
         lift_timer = 0;
      end
      lift_timer = lift_timer + 1;
   end
   if (player_poly == 486) and (bottom_lift.floor_height > 6) then
      top_lift.floor_height = -2;
      top_lift.extending = true;
      top_lift.active = true;
      Players[0]:position(28.63, -20.13, -3, 500);
      end
   if ((player_poly == 500) and (top_lift.floor_height < -3) and
 (not top_lift.extending)) then
      bottom_lift.floor_height = 6;
      bottom_lift.extending = false;
      bottom_lift.active = true;
      Players[0]:position(14.25, -9.5, 6, 486);
      end
   if player_poly ~= last_poly then
      last_poly = player_poly;
      vortexing = false;
   end
end

