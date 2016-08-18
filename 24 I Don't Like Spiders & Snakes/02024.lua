bell_wait = 60;
bell_timer = 0;
bell_cnt = 0;
bell_rings = 0;
hour_timer = 0;
o2_warning = false;
o2_threshold = 2000;
last_poly = nil;


function level_init (rs)
	bell_poly = find_platform(616);
   restoring_saved = rs;
   Players[0]:play_sound(250, 1);
if (Game.difficulty.index == 0) then  --[[ easiest --]]
   hour_wait = 180 * 30;
elseif (Game.difficulty.index == 1) then
   hour_wait = 120 * 30;
elseif (Game.difficulty.index == 2) then
   hour_wait = 90 * 30;
else
   hour_wait = 60 * 30;
   end
   if rs then
      bell_rings = bell_poly.floor_height * 10;
      bell_rings = math.floor(bell_rings + 0.5);
      if (bell_rings < 1) or (bell_rings > 12) then
         bell_rings = 1;
      end
   end
end

function level_idle ()
   bell_time();
   poly = Players[0].polygon.index;
   if (poly ~= last_poly) then
      last_poly = poly;
      if (poly == 603) or (poly == 617) then
	 Players[0]:teleport_to_level(25);
      end
   end
   bell_tower();
   o2_check();
end

function o2_check()
	local o2 = Players[0].oxygen;
   if (o2 > o2_threshold) and (o2_warning) then
      o2_warning = false;
   elseif (o2 <= o2_threshold) and (not o2_warning) then
      o2_warning = true;
      Players[0]:play_sound(7, 1);
      end
end

function bell_time()

   hour = bell_rings;
   min = math.floor(hour_timer / hour_wait * 60);
   if min > 59 then
      min = 59;
   end
   Players[0].overlays[0].text = "ƒ^ƒ[ "..string.format("%02i",hour)..":"..string.format("%02i",min);
   Players[0].overlays[0].color = "blue";
end

function bell_tower()
   hour_timer = hour_timer + 1;
   if hour_timer > hour_wait then
      hour_timer = 0;
      bell_timer = bell_wait;
      bell_rings = bell_rings + 1;
      if bell_rings > 12 then
         bell_rings = 1;
         end
      end
   if bell_timer > 0 then
      bell_timer = bell_timer + 1;
      end
   if bell_timer > bell_wait then
      Players[0]:play_sound(118, 1);
      bell_cnt = bell_cnt + 1;
      if bell_cnt >= bell_rings then  --[[ Finished chimes for hour --]]
         bell_timer = 0;
         bell_cnt = 0;
         bell_poly.floor_height = bell_rings / 10;       
         if (bell_rings == 12) then
            Players[0]:play_sound(248, 1);
            Players[0]:fade_screen(0, "long bright");
            Monsters.new(Polygons[564].x, Polygons[564].y, 0, 564, "black knight");
            Monsters.new(Polygons[186].x, Polygons[186].y, 0, 186, "fire beast");
            Monsters.new(Polygons[52].x, Polygons[52].y, 0, 52, "spider");
            Monsters.new(Polygons[50].x, Polygons[50].y, 0, 50, "spider");
	    Players[0]:teleport(135);
	 end
      else
         bell_timer = 1;
      end
   end
end

