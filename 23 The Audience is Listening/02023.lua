underwater_active = false;
gat_cycle = 150;
gat_timer = 0;
gat_poly_in = 391;

minor_gat_cnt = 7;
major_gat_cnt = 9;
gat_max = 10;
gat_status = 0;

detached_bay = 191;
detaching = false;
detached = false;
detach_explosion_delta = 2;
explosions = 0;
detach_timer = 0;
last_poly = -1;
kronos_theme = "Cavern/M01.mp3";
morgana_theme = "Cavern/Morgana.mp3";
maze_theme = "Cavern/Enchant Me.mp3";
music = kronos_theme;
gat_trigger_poly = 192;

mixed_bag = true;  --[[ some potions, some powerups --]]

function level_init (rs)
	bay_door = find_platform(513);
   Players[0]:play_sound(248, 1);
   if rs then
      if (not Lights[46].active) then
         detached = true;
      end
      return;
   end
   remove_items("spear", "rocks", "crossbow", "crossbow bolts",
		"hightech", "missiles", "phaser", "phaser pak"); 
   Players[0].life = 200;
end

function Triggers.platform_activated(poly)
   if (poly == bay_door) then
      if boy_door.active then
         Lights[44].active = true;
         Lights[45].active = true;
      else
         Lights[44].active = false;
         Lights[45].active = false;
      end
   end
   if (poly == detached_bay) and (not detaching) then
      detaching = true;
      Lights[46].active = true;
   end
end

function level_idle ()
   if detaching and (not detached) then
      detach_timer = detach_timer - 1;
      if (detach_timer <= 0) then
         detach_timer = 30*detach_explosion_delta;
         if (explosions == 4) then
            detaching = false;
            detached = true;
            Players[0]:print('シールド回復');
            Lights[46].active = false;
         else
            explosions = explosions + 1;
	    Players[0]:fade_screen("long bright");
            Players[0]:play_sound(198, 1);
	 end
      end
   end
   gat_timer = gat_timer + 1;
   player_poly = Players[0].polygon;
   if (player_poly ~= last_poly) then
      last_poly = player_poly;
      if (gat_status == 0) and (player_poly == gat_trigger_poly) then
	 gat_status = 1;
      end
      if ((player_poly.index == 633) or (player_poly.index == 112)) and (music ~= kronos_theme) then
	 Music.fade(60/1000);
	 Music.play(kronos_theme);
	 music = kronos_theme;
      end
      if ((player_poly.index == 9) or (player_poly.index == 56)) and (music ~= morgana_theme) then
	 Music.fade(60/1000);
	 Music.play(morgana_theme);
	 music = morgana_theme;
      end
      if (player_poly.index == 407) and (music ~= maze_theme) then
	 Music.fade(60/1000);
	 Music.play(maze_theme);
	 music = maze_theme;
      end
   end
   if (gat_status == 1) and (Tags[3].active) then
      gat_status = 2;
      Players[0]:print('シャトルベイ分離起動');
   end
   if (gat_timer >= gat_cycle) and (gat_status == 1) then
      gat_timer = 0;
      minor_gat_cnt = 0;
      major_gat_cnt = 0;
      for n in Monsters() do 
	 if (n.type == "minor gat") then
	    minor_gat_cnt = minor_gat_cnt + 1
	 elseif (n.type == "major gat") then
	    major_gat_cnt = major_gat_cnt + 1
	 end
      end
      if (major_gat_cnt < gat_max) and (minor_gat_cnt < gat_max) then
	 if (major_gat_cnt < minor_gat_cnt) then
	    m1 = Monsters.new(24, 2.75, 0, 181, "major gat");
	    m1.yaw = 180;
	 else
	    m1 = Monsters.new(25.88, 7.13, 0, gat_poly_in, "minor gat");
	    m1.yaw = 180;
	 end
      elseif (major_gat_cnt < gat_max) then
	 m1 = Monsters.new(26.25, 6.13, 0, gat_poly_in, "major gat");
	 m1.yaw = 180;
      elseif (minor_gat_cnt < gat_max) then
	 m1 = Monsters.new(25.63, 5.13, 0, gat_poly_in, "minor gat");
	 m1.yaw = 180;
      end
   end
end
