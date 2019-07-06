stomp_radius = 10 ;
stomp_max_damage = 150;
stomp_min_damage = 30;
stomp_type = "trex";
stomp_term = 3;
hidden_alcove = 552;
gabriel_window = 998;
gabriel_poly = 480;
gabriel_lockdown = false;
gabriel_fight = false;
gabriel_dead = false;
gabriel1 = nil;
gabriel2 = nil;
cleric_deaths = 0;
cleric_exile = { 134, 278, 255 }
gabriel_sequence = 0;
talk_wait = 100;
fight_timer = 0;
fight_wait = 180;
gabriel_life = 1080;
stomp_scrolls = 10;
      stomp_poly = 1006;   --[[ Just in case ]]
stomp_poly_active = false;
bars_destroyed = false;
last_poly = nil;
gabriel_kills = 0;

function level_init (rs)
	ProjectileTypes["special"].mnemonic = "stomp";
	MonsterTypes["cave bob"].mnemonic = "gabriel1";
	MonsterTypes["future bob"].mnemonic = "gabriel2";
	MonsterTypes["major gat"].mnemonic = "weaker knight";
	bridge = find_platform(113);
alcove_door1 = find_platform(1003);
alcove_door2 = find_platform(1001);
outer_window = find_platform(997);
flag_door1 = find_platform(496);
flag_door2 = find_platform(497);
banquet_door = find_platform(950);
banquet_l1 = Polygons[454];
banquet_l2 = Polygons[479];
banquet_l3 = Polygons[478];
banquet_l4 = Polygons[553];
banquet_r1 = Polygons[434];
banquet_r2 = Polygons[464];
banquet_r3 = Polygons[463];
banquet_r4 = Polygons[462];
banquet_r5 = Polygons[461];
banquet_r6 = Polygons[444];
      gabriel_platform = find_platform(1004);   --[[ Just in case ]]
   evil_cleric = find_cleric();
   restoring_saved = rs;
   Players[0]:play_sound(250, 1);
   if rs then
      return;
   end
   remove_items("wand");
   --[[ Players[0]:position(2.5, -6.75, 0, 614); ]]
end

function destroy_bars()
   for g in Monsters() do 
      if g.type == "metal bar" then
	 g:damage(11000, "suffocation");
      end
   end
   bars_destroyed = true;
end

function find_cleric()
   for g in Monsters() do
      if g.type == "cleric" then
	 return g;
      end
   end
   return nil;
end

function level_idle ()
   --[[ If bridge is activated, and bars not yet destroyed, then destroy the bars blocking passage to the courtyard.
   --]]
   if bridge.active and (not bars_destroyed) then
      destroy_bars();
   end
   --[[ 
   Determine if the player has the stomp wand, or has enough scrolls to 
   get the stomp wand.
   --]]
   has_wand = Players[0].items["wand"] > 0;
   scroll_cnt = Players[0].items["magic scroll"];
   stomp_poly_active = (scroll_cnt >= stomp_scrolls) and (not has_wand);
   player_poly = Players[0].polygon.index;
   if (player_poly ~= last_poly) then
      last_poly = player_poly;
      --[[ If player stepped into the Wand chamber, and the chamber is active, then give the player
      the wand and remove 10 scrolls.  If Gabriel has not yet spoken, teleport player in front 
      of him; otherwise, teleport player to cubby alcove.
      --]]
      if (player_poly == stomp_poly) and (not stomp_poly_active) then
	 if has_wand then
	    Players[0]:print("すでに巨大足の杖を持っています。後で来て下さい...");
	 elseif scroll_cnt < stomp_scrolls then
	    Players[0]:print("巨大足の杖に十分な巻き物を持っていません。");
	 end
      end
      if (player_poly == stomp_poly) and stomp_poly_active then
	 stomp_poly_active = false;
	 Players[0].items["wand"] = Players[0].items["wand"] + 1;
	 for i = 1, 10, 1 do
	    if Players[0].items["magic scroll"] > 0 then
	       Players[0].items["magic scroll"] = Players[0].items["magic scroll"] - 1;
	    end
	 end
	 if gabriel_activated then
	    Players[0]:teleport(hidden_alcove);
	 else
	    Players[0]:teleport(gabriel_poly);
	 end
      end
   end
   --[[ 
   If player opens window to Gabriel, place Gabriel in chamber.  After window opens,
   activate Gabriel sequence (kill gabriel, wait, activate term, etc.). 
   --]]
   if ((gabriel1 == nil) and (gabriel_sequence == 0) and 
 (outer_window.active)) then
      gabriel1 = Monsters.new(gabriel_platform.polygon.x, gabriel_platform.polygon.y, 0, gabriel_platform.polygon, "gabriel1");
      gabriel1.yaw = 180;
      Players[0]:position(22.88, -10.88, 1.5, gabriel_poly);
      Players[0].yaw = 0;
      Players[0].pitch = 360;
--      disable_player(0);
   end
   if ((not outer_window.active) and (gabriel1 ~= nil) and 
 (gabriel_sequence == 0) and (not gabriel_dead)) then
      Players[0]:play_sound(150, 1);
      gabriel_sequence = 1;
      if gabriel1 and gabriel1.valid then
	 gabriel1:damage(150, "suffocation");
      end
   end
   --[[ Continue incrementing sequence until sequence is reset to 0 (when Gabriel dies). ]]
   if (gabriel_sequence > 0) then
      gabriel_sequence = gabriel_sequence + 1;
   end
   --[[ 
   After a few seconds, activate Gabriel terminal and set lockdown.  Terminal 4 activates
   tag that starts service elevator down. 
   --]]
   if (gabriel_sequence > talk_wait) and (not gabriel_lockdown) then
      gabriel_lockdown = true;
      Players[0]:play_sound(150, 1);
      Players[0]:activate_terminal(4);
      flag_door1.player_controllable = false;
      flag_door2.player_controllable = false;
      MonsterTypes["black knight"].enemies["player"] = false;
      MonsterTypes["black knight"].friends["player"] = true;
--      enable_player(0);
      Players[0].items["key"] = Players[0].items["key"] + 1;
   end
   --[[ If service elevator at bottom, then activate fight timer.   Once fight timer reaches fight time,
    activate the fighting gabriel.
   --]]
   if ((gabriel_platform.floor_height == 0) and (fight_timer == 0) and 
 (gabriel_lockdown)) then
      Players[0]:print('ガブリエルはあなたに王座の部屋へのカギを渡しました');
      fight_timer = 1;
   end
   if (fight_timer > 0) then
      fight_timer = fight_timer + 1;
   end
   if gabriel_lockdown and (not gabriel_fight) and (fight_timer > fight_wait) then
      gabriel_fight = true;
      Players[0]:print('ガブリエルはドアをロックしました！');
      gabriel2 = Monsters.new(banquet_l1.x, banquet_l1.y, 0, banquet_l1, "gabriel2");
      gabriel2.yaw = 180;
      
      m = Monsters.new(banquet_l2.x, banquet_l2.y, 0, banquet_l2, "weaker knight");
      m = Monsters.new(banquet_l3.x, banquet_l3.y, 0, banquet_l3, "weaker knight");
      m = Monsters.new(banquet_l4.x, banquet_l4.y, 0, banquet_l4, "weaker knight");
      w1 = Monsters.new(banquet_r1.x, banquet_r1.y, 0, banquet_r1, "weaker knight");
      w2 = Monsters.new(banquet_r2.x, banquet_r2.y, 0, banquet_r2, "weaker knight");
      
      m = Monsters.new(banquet_r3.x, banquet_r3.y, 0, banquet_r3, "weaker knight");
      m = Monsters.new(banquet_r4.x, banquet_r4.y, 0, banquet_r4, "weaker knight");
      m = Monsters.new(banquet_r5.x, banquet_r5.y, 0, banquet_r5, "lesser knight");
      m = Monsters.new(banquet_r6.x, banquet_r6.y, 0, banquet_r6, "lesser knight");
   end
   --[[ 
   Just in case Gabriel kills everyone, have him die from wounds after awhile...
   --]]
   if (fight_timer > gabriel_life) then
      if gabriel2 and gabriel2.valid then
	 gabriel2:damage(700, "suffocation");
      end
   end
   --[[
   Once Gabriel is dead, release lockdown and turn off sequence...
   --]]
   if gabriel_lockdown and gabriel_dead then
      gabriel_lockdown = false;
      gabriel_sequence = 0;
      fight_timer = 0;
      MonsterTypes["black knight"].enemies["player"] = true;
      MonsterTypes["black knight"].friends["player"] = false;
      flag_door1.player_controllable = true;
      flag_door2.player_controllable = true;
      alcove_door1.active = true;
      alcove_door2.active = true;
      flag_door1.active = true;
      flag_door2.active = true;
      banquet_door.active = true;
      m = Monsters.new(banquet_r1.x, banquet_r1.y, 0, banquet_r1, "black knight");
      m = Monsters.new(banquet_r6.x, banquet_r6.y, 0, banquet_r6, "black knight");
      m = Monsters.new(banquet_l2.x, banquet_l2.y, 0, banquet_l2, "novice sorcerer");
      m = Monsters.new(banquet_l3.x, banquet_l3.y, 0, banquet_l3, "novice sorcerer");
   end
end

function level_monster_killed(monster, player, shot)
   mtype = monster.type
   if (w1 ~= nil and monster.index == w1.index) and (not gabriel_dead) then
      w1 = Monsters.new(banquet_l1.x, banquet_l1.y, 0, banquet_l1, "weaker knight");
      w1.yaw = 180;
   end
   if (w2 ~= nil and monster.index == w2.index) and (not gabriel_dead) then
      w2 = Monsters.new(banquet_l1.x, banquet_l1.y, 0, banquet_l1, "weaker knight");
      w2.yaw = 180;
   end
   if (mtype == "gabriel2") then
      Players[0]:print("英雄は倒れました。");
      Players[0]:fade_screen("long bright");
      Players[0]:play_sound(248, 1);
      gabriel_dead = true;
   elseif gabriel_fight and (player == nil) then
      gabriel_kills = gabriel_kills + 1;
      end;
   if monster.index == evil_cleric.index then
      Players[0]:print('アルガンタンは破壊されました');
      Players[0]:print('ディアブロの巻き物が現れました！');
      Players[0]:fade_screen("long bright");
      set_terminal_text_number(934,2867,5);
   end
end

function Triggers.player_damaged(victim, aggressor, monster, damage_type, 
                                      damage_amount, projectile)

   if (victim.index == 0) and (monster == evil_cleric) and (cleric_deaths < 3) then
      life = Players[0].life;
      if life <= 1 then
         cleric_deaths = cleric_deaths + 1;
         Players[0].life = 30;
         Players[0]:play_sound(83, 1);
         Players[0]:teleport(cleric_exile[cleric_deaths]);
      end
   end
end

function projectile_detonated(type, owner, polygon, x, y, z)
   if (type == "stomp") then
      stomp(owner, polygon, x*1024, y*1024, z*1024)
   end
end

function stomp(caster, pp, px, py, pz)
   player = Players[0].monster;
   for g in Monsters() do 
      if ((caster.index ~= g.index)) then
         mx = g.x;
	 my = g.y;
	 mz = g.z;
         mp = g.polygon;
         mfloor = mp.floor.height;
         dist = (mx - px)^2 + (my - py)^2
         wu_dist = math.sqrt(dist) / 1024
         floor_delta = math.abs(mfloor - pp.floor.height);
         hover = (mz/1024) - mfloor;
         if (wu_dist <= stomp_radius) and (hover <= 0) and (floor_delta < 1.0) then
            stomp_damage = stomp_max_damage - 
                        (stomp_max_damage*wu_dist/stomp_radius);
            g:damage(stomp_damage, stomp_type);
	 end
      end
   end
end
