floor_wait = 60;
wait_timer = 0;
last_floor = -1;
elevator_active = false;
elevator_sound_polys = { 349, 350, 351, 352, 380, 24, 26, 19, 22, 25,
       381, 456, 454, 330, 63, 348, 347 };
dir = '';

function level_init (rs)
	main_platform = Polygons[349].platform;
	power_light = Lights[31];
   Players[0]:play_sound(252, 1);
   last_h = main_platform.floor_height;
   if rs then
      elevator_active = power_light.active;
      if not main_platform.active then
         wait_timer = 1;
      end
      return;
   end
end

function is_elevator_sound_poly(poly)
   local i;
   for i, v in ipairs(elevator_sound_polys) do
      if v == poly.index then
         return true;
      end
   end
   return false;
end

function play_elevator_sound(poly, snd)
   if is_elevator_sound_poly(poly) then
      Players[0]:play_sound(snd, 1);
   end
end

function calc_floor(height, direction)
   
   f = ((height + 6) / 2) + 1;
   if direction == 'UP' then
      f = math.floor(f);
   else
      f = math.ceil(f);
      end
   return f;
end

function level_idle ()
   poly = Players[0].polygon;
   if (not elevator_active) and power_light.state then
      elevator_active = true;
      main_platform.active = true;
      play_elevator_sound(poly, 145);
   end
   h = main_platform.floor_height;
   if h < last_h then
      dir = '下';
   elseif h > last_h then
      dir = '上';
   end
   last_h = h;
   if last_floor == -1 then
      last_floor = calc_floor(last_h, dir);
   end
   floor = calc_floor(h, dir);
   if (floor ~= last_floor) and (wait_timer == 0) then
      wait_timer = 1;
      main_platform.active = false;
      if (floor == 1) or (floor == 7) then
	 play_elevator_sound(poly, 148);
      else
	 play_elevator_sound(poly, 147);
      end
      last_floor = floor;
   end
   if wait_timer > 0 then
      wait_timer = wait_timer + 1;
   end
   if wait_timer > floor_wait then
      wait_timer = 0;
      main_platform.active = true;
      play_elevator_sound(poly, 145);
   end
   if elevator_active then
      Players[0].overlays[0].text = "現在:" .. floor .. "階"
      Players[0].overlays[0].color = "cyan";
      Players[0].overlays[1].text = "方向:" .. dir
      if dir == 'UP' then
	 Players[0].overlays[0].color = "dark green";
      else
	 Players[0].overlays[0].color = "dark red";
      end
   end
end