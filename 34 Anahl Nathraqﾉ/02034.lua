siniestra_polys = { 9, 10, 28, 33, 66, 80 };
siniestra_bridge = 80;
escape_pod = { 883, 884, 888, 889, 890, 891 };
escape_panel = { 888, 890 };
siniestra_teleport = 115;
teleport_block = 113;
release_switch = 255;
bldg_safety = 785;
security_bridge = 68;
tiny_redisplay = 51;
space_poly = 957;
drop_hole = 934;
bad_platform = 916;
science_roof = 279;
roof_top = 962;
meter_cnt = 0;
cadet_start = 963;
science_teleporter = { 952, 953 };
jahala_pod = { 753, 754, 755, 756 };
jahala_drops = { { poly=214, x=9.88, y=-15, z=6, facing=90 },
		 { poly=203, x=3.38, y=-3.64, z=7, facing=0 },
		 { poly=208, x=13.75, y=-3.53, z=5, facing=180 },
		 { poly=215, x=7.9, y=5.13, z=5.5, facing=-45 },
		 { poly=217, x=10.16, y=8.25, z=6.5, facing=-90 },
		 { poly=213, x=10.28, y=-12.84, z=4.5, facing=135 } };
release_counter = 0;
danger_level = false;
tiny_replay = true;
ship_blown = false;
meter_floor = 0.825;
meter_ceiling = 0.950;
meter_started = false;
destruct_activated = false;
meter_moving = false;
meter_movement = 43;  --[[ ticks ]]
meter_rate = 15;  --[[ seconds ]]
meter_value = 10;  --[[ percent ]]
last_message = false;
underwater_active = false;
sendback = false;
has_tiny = false;
cadet_timer = -1;

heli_wait = 300;  --[[ before helicopter near / return time ]]
heli_approach = 150;  --[[ helicopter approach and exit times - must match light def ]]
heli_hover = 320;   --[[ helicopter hover while cadets descend ]]
heli_stage = 0;  --[[ 1=on the way, 2=approach, 3=hover, 4=leaving, 5=returning, 0=idle ]]
shake_timer = 0;
shake_length = 120;
fire_timer = 0;
bubble_timer = 0;
min_left = 4; 
last_poly = nil;


function do_cheat(arg)
--   add_item(0, "sap card");
   add_item(0, "tiny module");
   has_tiny = true;
   if not arg then
      return;
   end
   --[[
   player = Players[0].monster;
   for g in Monsters() do 
      if (g.index ~= player.index) then
         g:damage_monster(32000, "explosion");
      end
   end
   Polygons[32].platform.active = true;
   Polygons[19].platform.active = true;
   Players[0]:teleport(544);
      set_terminal_text_number(93, 376, 9);
      set_terminal_text_number(180, 816, 10);
      set_terminal_text_number(872, 2792, 11);
      ]]
end

function level_init (rs)
	ItemTypes["nightvision"].mnemonic = "tiny module";
	escape_pod_door = Polygons[882];
	meter = find_platform(868);
release_cover = find_platform(625);
meter_cover = Polygons[879];
heli_light = Lights[44];
grid_light = Lights[51];
	if (Game.difficulty.index <= 1) then
	   cadets_per_placement = 3;
	elseif (Game.difficulty.index == 2) then
	   cadets_per_placement = 2;
	else
	   cadets_per_placement = 1;
	end
	restoring_saved = rs;
   Players[0]:play_sound(253, 1);
   has_tiny = Players[0].items["tiny module"] > 0;
   ai_scan();
   if heli_light.active then
      heli_stage = 2;
      cadet_timer = heli_approach;
   end
   if rs then
      display_tiny = false;
      return;
   end
   if Players[0].items["sap card"] <= 0 then
      Players[0].items["sap card"] = 1;  --[[ if vidmaster jump, then give player the SAP card ]]
      end
   if has_tiny then
      set_terminal_text_number(93, 376, 9);
      set_terminal_text_number(180, 816, 10);
      set_terminal_text_number(872, 2792, 11);
      display_tiny = true;
      end
end

function Triggers.terminal_exit(termNum, player)
   if (termNum.index == 6) or (termNum.index == 11) then
      destruct_activated = true;
   end
end

function ai_scan()
   cadets_left = 0;
   morgana = nil;
   mauvair = nil;
   for g in Monsters() do 
      mtype = g.type;
      mp = g.polygon;
      if (mtype == "white knight") and (mp == cadet_start) then
	 cadets_left = cadets_left + 1;
      elseif (mtype == "morgana") then
	 morgana = g;
      elseif (mtype == "master wizard") then
	 mauvair = g;
      end
   end
end

function in_escape_pod()
   local p = Players[0].polygon.index;
   for i, n in ipairs(escape_pod) do
      if p == n then
         return true;
      end
   end
   return false;
end

function timer_color(e)
   if (e <= min_left) then 
      if not task_done then
         Players[0]:print("モルガナの部隊は止められました！シニエストラは安全です。");
         Players[0]:play_sound(254, 1);
         task_done = true;
      end
      return "green";
   elseif (e < 10) then 
      return "yellow";  --[[ yellow ]]
   else 
      return "red";   --[[ red ]]
   end
end

function level_idle ()
   if not danger_compass then
      if grid_light.active then
         danger_compass = true; 
      end
   end
   if danger_compass then
      e = enemies_left(Players[0], 8);
      Players[0].overlays[0].text = "残りの敵:"..e;
      Players[0].overlays[0].color = timer_color(e);
      idle_danger(2, 10, 177, -7680);
   end
   player_poly = Players[0].polygon.index;
   if (release_counter > 0) then
      release_counter = release_counter - 1;
   end
   if (player_poly == drop_hole) then
      if Players[0].z <= 3 then
         Players[0]:position(.5, 4.125, 3, bad_platform);
      end
   end
   if meter_started then
      meter_cnt = meter_cnt + 1;
      if (meter_cnt >= meter_rate*30) then
         meter_cnt = 0;
         meter.active = true;
         meter_moving = true;
         end
      if (meter_moving and (meter_cnt >= meter_movement)) then
         meter_cnt = 0;
         meter.active = false;
         meter_moving = false;
         meter_value = meter_value + 10;
         Players[0]:print('アクチニウムガスの濃度:'..meter_value.. '%');
         Level.fog.depth = (240 - 3 * meter_value) / 20;
      end
      if (meter_value == 60) and (not danger_level) then
         danger_level = true;
         if in_escape_pod() then
            escape_pod_door.floor.height = -1.1;
            Players[0]:play_sound(28, 1);
            Level.fog.present = false;
         else
            Lights[59].active = false;
	 end
      end
      if (meter_value >= 70) and (not last_message) then
         if in_escape_pod() then
            last_message = true;
            Players[0]:activate_terminal(7);
	 end
      end
      if (meter_value == 80) and (not ship_blown) then
         ship_blown = true;
         Players[0]:play_sound(198, 1);
         Players[0]:fade_screen(0, "long bright");
	 meter_cover.ceiling.height = meter_floor;
         meter_started = false;
         if in_escape_pod() then
	    Players[0]:teleport_to_level(35);
         else
            Players[0]:play_sound(226, 1);
            Players[0]:fade_screen("long bright");
            Level.fog.present = false;
            Players[0]:position(-25.13, 16.5, 0, space_poly);
	 end
      end
   end
   if (destruct_activated) and (not meter_started) and (not ship_blown) then
      meter_started = true;
      Lights[61].active = true;
      Players[0]:play_sound(7, 1);
      meter_cover.ceiling.height = meter_ceiling;
      Level.fog.present = true;
      Level.fog.depth = 12;
      Level.fog.color.r = 0;
      Level.fog.color.g = 0.7;
      Level.fog.color.b = 0.3;
      meter_cnt = 0;
      end
   if (player_poly ~= last_poly) then
      if display_tiny and (last_poly ~= nil) then
         Players[0]:activate_terminal(8);
         display_tiny = false;
      end
      last_poly = player_poly;
      if (player_poly == release_switch) and (release_counter <= 0) then
         Players[0]:play_sound(12, 1);
         release_cover.active = true;
         release_counter = 120;  --[[ wait 4 seconds before switch is active again ]]
      end
      if has_tiny and tiny_replay and (player_poly == tiny_redisplay) then
         if meter_started then
            Players[0]:print('Tiny: 脱出ポッドはここにはありません！動いてください！');
         else
            Players[0]:activate_terminal(8);
            end
         end
	 if (player_poly == science_roof) and Lights[62].active then
	    Players[0]:teleport(roof_top);
         end;
      if (((player_poly == science_teleporter[1]) or (player_poly == science_teleporter[2])) and 
       (Lights[62].active)) then
         Players[0]:teleport(bldg_safety);
         end;
      if (((player_poly == escape_panel[1]) or (player_poly == escape_panel[2])) and 
       (not last_message)) then
         last_message = true;
         Players[0]:activate_terminal(7);
         end
      if (player_poly == siniestra_teleport) and meter_started then
         Players[0]:teleport(security_bridge);
      elseif (player_poly == siniestra_teleport) then
         Players[0]:teleport(bldg_safety);
         tiny_replay = false;
         end
      if (player_poly == jahala_pod[1]) or (player_poly == jahala_pod[2]) or 
         (player_poly == jahala_pod[3]) or (player_poly == jahala_pod[4]) then
         sendback = true;
         tiny_replay = false;
         if (sendback_timer == 0) then
            idx = Game.global_random(6) + 1;
            Players[0]:teleport(siniestra_polys[idx]);
            sendback_timer = -1;
            Players[0]:print('テレポート完了');
            Players[0]:play_sound(175, 1);
            end
         if (sendback_timer < 0) then
            Players[0]:print('テレポーターを再充電中...');
            sendback_timer = 150;
            Players[0]:play_sound(82, 1);
	 end
         if (sendback_timer == 30) or (sendback_timer == 60) or (sendback_timer == 90) then
            Players[0]:print((sendback_timer/30)..'...');
	 end
         sendback_timer = sendback_timer - 1;
      end
      if not sendback then
         sendback_timer = -1;
      end
   end
   if cadet_timer >= 0 then
      cadet_timer = cadet_timer - 1;
      if cadet_timer == 0 then
         if heli_stage == 1 then  --[[ on the way completes ]]
            heli_stage = 2;
            cadet_timer = heli_approach;
            heli_light.active = true;
            Players[0]:print('黒・ドラゴンヘリコプターが接近中です...');
         elseif heli_stage == 2 then  --[[ approach completes ]]
            heli_stage = 3;
            cadet_timer = heli_hover;
            release_cadets();  
         elseif heli_stage == 3 then  --[[ hover completes ]]
            heli_stage = 4;
            cadet_timer = heli_approach;
            heli_light.active = false;
         elseif heli_stage == 4 then  --[[ helicopter leaves town completes ]]
            heli_stage = 5;
            cadet_timer = heli_wait;
         elseif heli_stage == 5 then  --[[ helicopter returns to base completes ]]
            heli_stage = 0;
            cadet_timer = -1;
	 end
      end
   end
   if shake_timer > 0 then
      shake_timer = shake_timer + 1;
      if shake_timer == 1 then
         Players[0]:play_sound(226, 1);
      elseif (shake_timer == 60) or (shake_timer == 110) then
         Players[0]:fade_screen("bright");
         Players[0]:play_sound(168, 1);
      end
      if ((shake_timer > 15) and (shake_timer < shake_length)) then
         theta = Game.global_random(360);
         if (shake_timer <= (shake_length/2)) then
            vel = (Game.global_random(100+shake_timer))/10000;
         else
            vel = (Game.global_random(100+(shake_length-shake_timer)))/10000;
	 end
	 Players[0]:accelerate(theta, vel, 0);
      end
      if (shake_timer > shake_length) then
         shake_timer = 0;
         Players[0]:print('モルガナは倒されました！');
         Players[0]:play_sound(62, 1);
      end
   end
   if bubble_timer > 0 then
      bubble_timer = bubble_timer + 1;
      if bubble_timer >= 64 and morg_poly ~= nil then
         morgie = Monsters.new(morg_x, morg_y, 0, morg_poly, "metal bar");
		 morgie.active = true;
		 morgie:damage(50, "suffocation");
         fire_timer = 1;
         bubble_timer = 0;
      end
   end
   if fire_timer > 0 then
      fire_timer = fire_timer + 1;
      if fire_timer > 70 and morg_poly ~= nil then
         morgie = Monsters.new(morg_x, morg_y, 0, morg_poly, "fire");
	 morgie.active = true;
         fire_timer = 0;
      end
   end
end

function morgana_bubble(monster, poly)
	if poly ~= nil then
   morg_poly = poly;
   morg_x = monster.x;
   morg_y = monster.y;
   shake_timer = 1;
   bubble_timer = 1;
   morgana = nil;
   end
end

function level_monster_killed(victim, victor, projectile)
   if victim then
      mtype = victim.type;
      mp = victim.polyogn;
      if mtype == "morgana" then
         morgana_bubble(victim, mp);
      elseif mtype == "master wizard" then
         Players[0]:print('モーベアは倒されました！');
         Players[0]:play_sound(233, 1);
         mauvair = nil;
      elseif (mtype == "future bob") and (not meter_started) then
         Players[0]:print('ブリゲード戦士は倒されました！');
      elseif (mtype == "white knight") and (mp.index ~= cadet_start) and (not meter_started) then
         Players[0]:print('ブーメラン士官生徒は倒されました！');
      end
   end
end

function release_cadets()
   local found = 0;
   for g in Monsters() do 
      mtype = g.type;
      mp = g.polygon;
      if (mtype == "white knight") and (mp.index == cadet_start) then
	 found = found + 1;
	 g:damage(1000, "explosion");
	 cadets_left = cadets_left - 1;
	 if (found == 2) or (cadets_left <= 0) then
	    break;
	 end
      end
   end
   local idx = random_select(found*cadets_per_placement, 6);
   for i, v in ipairs(idx) do 
      local jahala = jahala_drops[v];
      local wk = Monsters.new(v.x, v.y, v.z, v.poly, "white knight");
      wk.yaw = wk.facing;
   end
end

function level_projectile_detonated(type, owner, polygon, x, y, z)
   player = Players[0].monster;
   if ((type == "plasma") and (not plasma_message) and 
 (owner == player) and (morgana and morgana.valid) ) then
      mp = morgana.polygon;
      if mp == polygon then
         Players[0]:print('プラズマはモルガナには効果はありません。');
         plasma_message = true;
      end
   end
   if (((type == "missile") or (type == "lightning") or (type == "fireball") or
(type == "biggrenade") or (type == "photon")) and 
    (has_tiny) and (heli_stage == 0) and (polygon == roof_top)) then
      if cadets_left <= 0 then
         Players[0]:print('あなたの信号を受け取る士官生徒はもういません。');
      else
         cadet_timer = heli_wait;
         heli_stage = 1;
      end
   end
end

function level_cleanup()
   remove_items("sword");  --[[ Next level switches to Lightsaber ]]
end

