flint_exists = false;
in_vehicle = false;
milestone_counter = 0;
milestone_polys = { 338, 99, 192, 223, 238, 27 };
respawn = {
   ["minor dinobug"] = 226, ["minor raptor"] = 102,
   ["future bob"] = 148, ["ranger"] = 160,
   ["white knight"] = 154, ["cave bob"] = 138,
   ["dimorph"] = 302, ["trex"] = 6 };
respawn2 = {
   ["ranger"] = 9, ["dimorph"] = 299, ["minor dinobug"] = 346 };
laps = 0;
prev_lap = 0;
lap_timer = 0;
lap_cum = 0;
race_timer = 0;
food_lap = 3;
laps_required = 5;
resident_kills = 0;
death_penalty = 150;
revolt_kills = 5;
revolt = false;

daylight = 0;
dusk = 1;
night = 2;
dawn = 3;
clock_str = { '日中', '夕暮れ', '夜', '夜明け' };
light_clock = daylight;
lights = true;
fog = false;

change_poly = 296;
exit_poly = 345;
exit_activated = false;
last_poly = nil;


function level_init (rs)
food_detour = Polygons[118];
food_replace = Polygons[238];  
	flint_poly = Polygons[259];
	teleporter_light = Lights[23];
	exit_door = find_platform(344);
   restoring_saved = rs;
   Players[0]:play_sound(252, 1);
   if rs then
      return;
   end
   Players[0].life = 150;
end

function level_idle ()
   if not flint_exists then
      flintmobile = Monsters.new(flint_poly.x, flint_poly.y, 0, flint_poly, "throne");
      flintmobile.active = true;
      flint_exists = true;
   end
   if in_vehicle then
      race_timer = race_timer + 1;
      lap_timer = lap_timer + 1;
      racetrack_radar(32);
      display_stats();
      if (Players[0].weapons.active ~= "wand") then
	 Players[0].weapons["wand"]:select();
      end
      xvel = Players[0].internal_velocity.forward;
      if xvel == 0 then
         in_idle = true;
      elseif in_idle and (xvel ~= 0) then
         in_idle = false;
         Players[0]:play_sound(260, 1);
         end
      end
   if (resident_kills >= revolt_kills) and (not revolt) then
      Players[0]:print('ベッドロック琥珀警告: 殺人者が放たれました！死ぬか生きるかです！');
      Players[0]:play_sound(173, 1);
      revolt = true;
      MonsterTypes["future bob"].enemies["player"] = true;
      MonsterTypes["cave bob"].enemies["player"] = true;
      MonsterTypes["white knight"].enemies["player"] = true;
      MonsterTypes["ranger"].enemies["player"] = true;
      MonsterTypes["dimorph"].enemies["player"] = true;
      MonsterTypes["trex"].enemies["player"] = true;
      MonsterTypes["maint bob"].enemies["player"] = true;
   end
   poly = Players[0].polygon;
   if poly.index ~= last_poly then
      last_poly = poly.index;
      if (poly.index == flint_poly.index) and (Players[0].items["key"] > 0) then
         flintmobile:damage(1001, "suffocation");
         Players[0].items["wand"] = 1;
         Players[0].items["key"] = 0;
         Players[0]:play_sound(263, 1);
         in_vehicle = true;
         milestone_counter = 1;
         mpoly = Polygons[milestone_polys[milestone_counter]];
	 Items.new(mpoly.x, mpoly.y, 0, mpoly, "magic scroll");
	 Music.fade(60/1000);
	 Music.play('Cavern/Santa Fe.mp3');
      elseif (poly.index == flint_poly.index) and (not in_vehicle) then
         Players[0]:print(' あなたはメインオフィスに鍵を置いてきました。');
      end
      if poly.type == "goal" then
         if Game.global_random(4) == 0 then
            Players[0]:play_sound(265, 1 + (Game.global_random(2)/10));
	 end
      end
      if (poly.index == change_poly) and in_vehicle and (prev_lap ~= laps + 1) then
         update_lighting();
      end
      if poly.index == exit_poly then
         Players[0]:teleport_to_level(36);
      end
   end
end

function update_lighting()
   prev_lap = laps + 1;
   if math.modf(laps, 5) == 0 then --[[ daylight lasts for two laps ]]
      return;
   end
   light_clock = math.modf(light_clock + 1, 4);
   Players[0]:print('今は'..clock_str[math.floor(light_clock + 1)]..'です。');
   if (light_clock == night) and lights then
      for n = 1, 20 do
         Lights[n].active = false;
      end
      lights = false;
   elseif (light_clock ~= night) and (not lights) then
      for n = 1, 20 do
         Lights[n].active = true;
      end
      lights = true;
   end
   if (light_clock == daylight) and fog then
      Level.fog.present = false;
      fog = false;
   elseif (light_clock ~= daylight) and (not fog) then
      Level.fog.present = true;
      Level.fog.depth = 50;
      fog = true;
   end
   if (light_clock == night) then
      Level.fog.color.r = .16;
      Level.fog.color.g = .16;
      Level.fog.color.b = .16;
   elseif (light_clock == dusk) then
      Level.fog.color.r = .32;
      Level.fog.color.g = .16;
      Level.fog.color.b = 0;
   elseif (light_clock == dawn) then
      Level.fog.color.r = .02;
      Level.fog.color.g = .04;
      Level.fog.color.b = .32;
   end
end

function display_stats()

   Players[0].overlays[0].text = "ラップ: "..laps+1;
   Players[0].overlays[0].color = "blue";
   timerStr = string.format("%02d:%02d.%02d", race_timer / 30 / 60,
           math.modf(race_timer / 30, 60), math.modf(race_timer, 30) * 100 / 30);
   Players[0].overlays[1].text = "経過時間: "..timerStr;
   Players[0].overlays[1].color = "green";
   Players[0].overlays[2]:clear();
   timerStr = string.format("%02d:%02d.%02d", lap_timer / 30 / 60,
           math.modf(lap_timer / 30, 60), math.modf(lap_timer, 30) * 100 / 30);
   Players[0].overlays[3].text = "ラップ時間: "..timerStr;
   Players[0].overlays[3].color = "yellow";
   Players[0].overlays[4]:clear();
   if laps > 0 then
      lap_avg = lap_cum / laps;
      timerStr = string.format("%02d:%02d.%02d", lap_avg / 30 / 60,
           math.modf(lap_avg / 30, 60), math.modf(lap_avg, 30) * 100 / 30);
      Players[0].overlays[5].text = "平均ラップ時間: "..timerStr;
      Players[0].overlays[5].color = "red";
   end
end

function Triggers.player_killed(player, killer, action, projectile)

   poly = player.polygon;
   x = player.x;
   y = player.y;
   facing = player.yaw;
   local car = Monsters.new(x, y, 0, poly, "throne");
   car.yaw = facing;
end

function level_got_item(type, player)
   if type == "key" then
      Players[0]:play_sound(254, 1);
   end
   if type == "magic scroll" then
      milestone_counter = milestone_counter + 1;
      if milestone_counter > # milestone_polys then
         milestone_counter = 1;
         laps = laps + 1;
         lap_cum = lap_cum + lap_timer;
         timerStr = string.format("%02d:%02d.%02d", lap_timer / 30 / 60,
				  math.modf(lap_timer / 30, 60), math.modf(lap_timer, 30) * 100 / 30);
         Players[0]:print('ラップ #'..laps..'の時間は'..timerStr);
         lap_timer = 0;
         Players[0]:play_sound(263, 1);
         if (laps >= laps_required) and (not exit_activated) then
            exit_activated = true;
            teleporter_light.active = true;
            exit_door.active = true;
            Players[0]:print('クロノス割り込み：静止終了は起動されました');
	 end
      elseif mpoly.index == food_detour.index then
         Players[0]:play_sound(229, 1);
         Players[0]:print('それらを愛してください、雷鳴バーガー!');
      else
         Players[0]:play_sound(228, 1);
      end
      mpoly = Polygons[milestone_polys[milestone_counter]];
      if (math.modf(laps, food_lap) == 2) and (mpoly.index == food_replace.index) then
	 mpoly = food_detour;
	 Players[0]:print('あなたの胃は痛んでいます');
      end
      Items.new(mpoly.x, mpoly.y, 0, mpoly, "magic scroll");
   end
end

function level_monster_killed(victim, victor, projectile)

   if (victor == Players[0]) then
      mtype = victim.type;
      if respawn[mtype] then
	 local resp = Polygons[respawn[mtype]];
         Monsters.new(resp.x, resp.y, 0, resp, mtype);
      end
      if respawn2[mtype] then
	 local resp = Polygons[respawn2[mtype]];
	 Monsters.new(resp.x, resp.y, 0, resp, mtype);
         end
      mclass = MonsterTypes[mtype].class;
      if (mclass == "friend") or (mclass == "raptor") then
         Players[0]:print('10秒ペナルティ: ベッドロック住民殺傷');
         Players[0]:play_sound(197, 1);
         lap_timer = lap_timer + 300;
         race_timer = race_timer + 300;
         resident_kills = resident_kills + 1;
         end
      end
end

function racetrack_radar(range)
   if not range then
      range = 10;
   end
   if (Players[0].dead) then
      Players[0].compass.lua = false;  --[[ no compass if dead ]]
   else
      Players[0].compass.lua = true;
      local px = Players[0].x;
      local py = Players[0].y;
      local pz = Players[0].z;   --[[ coordinate offset ]]
      local face = Players[0].direction;   --[[ angle offset ]]
      for n in Items() do
         if (n.type == "magic scroll") then
            local ipoly = n.polygon;
            local ix = ipoly.x;
	    local iy = ipoly.y;
            local iz = ipoly.z;
            local d = math.sqrt((ix-px)*(ix-px)+(iy-py)*(iy-py)+(iz-pz)*(iz-pz));
            in_range = (d < range);
            local ang = math.atan2(iy-py,ix-px) * 180 / math.pi - face;
            while (ang < 0) do 
               ang = ang + 360;
               end
            while (ang >= 360) do 
               ang = ang - 360;
	    end
	    Players[0].compass:all_off();
	    if ((ang < 100) or (ang > 350)) and in_range then 
               Players[0].compass.ne = true;
	    end
            if (ang < 190) and (ang > 80) and in_range then 
               Players[0].compass.se = true;
	    end
            if (ang < 280) and (ang > 170) and in_range then 
               Players[0].compass.sw = true;
	    end
            if ((ang < 10) or (ang > 260)) and in_range then
               Players[0].compass.nw = true;
	    end
            if in_range then
               break;
	    end
	 end
      end
   end
end