last_poly = -1;
timer = 0;
grail_free = false;
camelot_theme = "Cavern/M11.mp3";
grail = nil;
grail_song_length = 38 * 30;

grail_trigger_poly = 254;
mordred_poly = 150;

mordred_timer = 0;
mordred_wait = 5 * 30;
wand_poly = 373;
wand_scrolls = 10;
wand_poly_active = false;
well_poly = 191;
well_drop = 379;
mordred = -1;
mordred_dead = false;
card_pickup = false;
danger_compass = false;
task_complete = false;
min_left = 0;


function level_init (rs)
MonsterTypes["trex"].mnemonic = "grail";
grail_light = Lights[29];
card_poly_light = Lights[30];
card_ceiling_light = Lights[31];
radar_light = Lights[32];
grail_door = find_platform(255);
mordred_door1 = find_platform(151);
mordred_door2 = find_platform(54);
mordred_gate = find_platform(15);
wand_flag_poly = Polygons[376];
card_poly = Polygons[150];

   restoring_saved = rs;
   Players[0]:play_sound(250, 1);
   grail = find_monster("grail");
   mordred = find_monster("mordred");
   if rs then
      grail_free = grail_light.active;
      if grail_free then
	 Music.fade(60/1000);
	 Music.play(camelot_theme);
      end
      wand_chamber_active = wand_flag_poly.floor_height > 0;
      --[[ If we cannot find Mordred, he must be dead, and if he is dead, then we have already 
      used the card (since we are loading a saved game, and using the card is the only 
		     way to get to a save buffer).
      --]]
      if mordred == nil then
         mordred_dead = true;
         card_pickup = true;
      end
      return;
   end
   remove_items("wand");
end

function level_got_item(item, player)
   if (item == "sap card") then
      card_poly_light = true;
      card_ceiling_light = true;
      card_pickup = true;
      player:play_sound(228, 1);
      end
end

function found_item(itype)
   if Players[0].items[itype] > 0 then
      return true;
   end
   for g in Items() do
      if g.type == itype then
	 return true;
      end
   end
   return false;
end

function find_monster(mtype)
   for g in Monsters() do 
      if g.type == mtype then
	 return g;
      end
   end
   return nil;
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
      if radar_light.active then
         danger_compass = true; 
      end
   end
   if danger_compass then
      e = enemies_left(Players[0], 8);
      if (e <= min_left) and (not task_complete) then
         Players[0]:print('敵はいなくなりました！');
         Players[0]:play_sound(233, 1);
         task_complete = true;
      end
      Players[0].overlays[0].text = "残りの敵は "..e;
      Players[0].overlays[0].color = timer_color(e);
      idle_danger(2, 10, 239);
   end
   has_wand = (Players[0].items["wand"] > 0);
   scroll_cnt = Players[0].items["magic scroll"];
   if (not wand_chamber_active) then
      if wand_flag_poly.platform.floor_height > 0 then
         if (not has_wand) then
		    Players[0].items["wand"] = Players[0].items["wand"] + 1;
            has_wand = true;
		 end
         wand_chamber_active = true;
      end
   end
   wand_poly_active = ((scroll_cnt >= wand_scrolls) and 
		    (not has_wand) and wand_chamber_active);
   if mordred and mordred.valid then
      mordred_poly = mordred.polygon.index;
   end
   player_poly = Players[0].polygon.index;
   if (player_poly == well_poly) then
      z = Players[0].z;
      if z <= -3 then
         Players[0]:position(4.25, -7.75, 4, well_drop);
      end
   end
   if (player_poly ~= last_poly) then
      last_poly = player_poly;
      if (player_poly == wand_poly) and wand_chamber_active and (not wand_poly_active) then
         if has_wand then
            Players[0]:print("すでに魔法の杖を持っています。また後で来て下さい...");
         elseif scroll_cnt < wand_scrolls then
            Players[0]:print("魔法の杖を使うのに十\分な巻き物を持っていません。");
	 	end
      end
      if (player_poly == wand_poly) and wand_poly_active then
         wand_poly_active = false;
         for i = 1, 10, 1 do
            if Players[0].items["magic scroll"] > 0 then
               Players[0].items["magic scroll"] = Players[0].items["magic scroll"] - 1;
	    end
	 end
	 Players[0].items["wand"] = Players[0].items["wand"] + 1;
      end
      if (player_poly == grail_trigger_poly) and (not grail_free) then
         free_grail();
      elseif (player_poly == mordred_poly) and (mordred_timer == 0) then
         mordred_timer = 1;
      end
   end
   if mordred_timer > 0 then
      mordred_timer = mordred_timer + 1;
   end
   --[[ Just in case Mordred doesn't activate properly, open the secret doors
   after 30 seconds.
   --]]
   if (mordred_timer >= mordred_wait) then
      mordred_timer = -1;
      mordred_door1.active = true;
      mordred_door2.active = true;
   end
   if (timer > 0) then
      timer = timer + 1;
      end
   if (timer >= grail_song_length) then
      timer = 0;
      Music.fade(60/1000);
      Music.play(camelot_theme);
      grail_exit();
      find_platform(347).active = true;
   end
   --[[ If Mordred is not flagged as dead and is no longer in map, and there is no card in map, and grail door is still locked, then fail safe is to force card into map.
   --]]
   if (mordred == -1) and (mordred_gate.floor_height < 1) then
      mordred = find_monster("mordred");
   end
   if (not mordred_dead) and (mordred == -1) then
      if not found_item("sap card") then
         if (grail_door.floor_height > 2.6) then
            mordred_dies();
	 end
      end
   end
end

function free_grail()
   grail_free = true;
   timer = 1;
   Music.fade(60/1000);
   Music.play("Cavern/Found Grail.mp3");
   grail_light.active = true;
end

function mordred_dies()
   mordred_dead = true;
   Players[0]:print('モードレッドは倒れました！');
   Players[0]:play_sound(62, 1);
   Players[0]:fade_screen(0, "long bright");
   Items.new(card_poly.x, card_poly.y, 512, card_poly, "sap card");
   card_poly_light.active = false;
   card_ceiling_light.active = false;
end

function level_monster_killed(monster, player, shot)
   mtype = monster.type;
   if (monster == mordred) and (not mordred_dead) then
      mordred_dies();
   end
   if (mtype == "mordred") and (not mordred_dead) then
      mordred_dies();
   end
end

function grail_exit()
   player = Players[0].monster;
   for g in Monsters() do
      if (player.index ~= g.index) then
         if g.type == "grail" then
            g:damage(160, "suffocation");
	 end
      end
   end
   grail = nil;
end

function level_cleanup()
   remove_items("sword");  --[[ Next level switches to Lightsaber ]]
end
