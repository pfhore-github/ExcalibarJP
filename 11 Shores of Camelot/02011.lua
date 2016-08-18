
caves_open = false;
hyperporter_on = false;
hyper_polys = { 61, 40, 304, 370, 307 };

danger_compass = false;
task_complete = false;
min_left = 2;
jumping = false;
gate_open = false;
fireball = false;
freed = false;
last_poly = nil;
function level_init (rs)
	jumppad = Polygons[447];
	rampart_pod = find_platform(509);
	moat_gate = find_platform(573);
	moat_cave = find_platform(577);
	hyperporter = Polygons[587];
	pond = Polygons[252];
	cave_entrance = Polygons[90];
	cave_gate = find_platform(418);
	hyperporter_light = Lights[23];

	restoring_saved = rs;
	Players[0]:play_sound(104, 1);
	if rs then
		return;
	end
	remove_items("wand");
end

function timer_color(e)
   if (e <= min_left) then 
      return "green";
   elseif (e < 12) then 
      return "yellow";
   else 
      return "red";
   end
end

function level_idle ()   
   if not danger_compass then
      if hyperporter_light.active then
         danger_compass = true; 
      end
   end
   if danger_compass then
      e = enemies_left(Players[0], 6);
      if (e <= min_left) and (not task_complete) then
         Players[0]:print('城壁へと戻って下さい...');
         Players[0]:print('次の任務への準備ができています。');
         Players[0]:play_sound(233, 1);
         task_complete = true;
      end
      Players[0].overlays[0].text = "残りの敵は" .. e
      Players[0].overlays[0].color = timer_color(e)
      idle_danger(2, 10, 606);
   end
   if (not fireball) and Tags[10].active then
      fireball = true;
      Items.new(Polygons[327].x, Polygons[327].y, 0, 327, "wand");
      Items.new(Polygons[176].x, Polygons[176].y, 0, 176, "wand");
      Players[0].items["wand"] = Players[0].items["wand"] + 1;
   end
   if (not hyperporter_on) and Tags[3].active then
      hyperporter_on = true;
   end
   if (not caves_open) and (cave_gate.floor_height < 2.5) then
      caves_open = true;
   end
   if (not freed) and (rampart_pod.floor_height < 3.5) then
      freed = true;
      if (not restoring_saved) then
         Monsters.new(9,-11, 0, 159, "white knight");
	 Monsters.new(-5.7, -18.3, 0, 557, "white knight");
      end
   end
   if (not gate_open) and (moat_gate.floor_height < 1.0) then
      gate_open = true;
   end
   loc = Players[0].polygon;
   if (not jumping) and (loc.index == jumppad.index) then
      if (not gate_open) then
	 moat_gate.active = true;
	 moat_cave.active = true;
	 gate_open = true;
      end
      Players[0]:position(15.6, 1.6, 3.0, pond);
      jumping = true;
   end
   if jumping and (loc.index ~= jumppad.index) then
      jumping = false;
   end
   if (loc.index ~= last_poly) then
      last_poly = loc.index;
      if (loc.index == hyperporter.index) and (hyperporter_on) then
         hyper = Polygons[hyper_polys[1+Game.global_random (5)]];
         if (hyper.index == 307) and (caves_open) then
            hyper = cave_entrance;
	 end
	 Players[0]:teleport(hyper);
      end
      if (loc.index == cave_entrance) and (not caves_open) then
         Players[0]:print('救出の巻き物を覚えたら戻ってきて下さい');
      end
      poly_type = loc.type;
      if (poly_type == "hill" ) then
         if Lights[21].active then
            Players[0]:teleport_to_level(12);
	 elseif freed then
	    e = enemies_left(Players[0], 6);  --[[ buffer of 6 to represent unreachable monsters --]]
	    Players[0]:print('このエリアに残っている敵は'..e);
	    Players[0]:print('詳しい情報は城壁のパッドに入って下さい');
	 else
	    Players[0]:print('地下牢に閉じ込められた者達を自由にしてからここに戻って下さい');
	 end
      end
   end
end