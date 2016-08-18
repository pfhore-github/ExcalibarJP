timebomb_in_hand = false;
timebomb_current = false;
timebomb_active = false;
click_sound_length = 35;
click_timer = 0;
timebomb_wait = click_sound_length * 5;
timebomb_counter = 0;
timebomb_power = 1000;
timebomb_range = 4;
tb_monster = nil;
last_weapon2 = nil;
last_poly = nil;
exit_poly = 865;
blast_poly1 = 826;
blast_poly2 = 790;
blast_poly3 = 872;
shake_timer = 0;
shake_length = 120;
exit_locked = true;

function level_init (rs)
ProjectileTypes["bone"].mnemonic = "timebomb activate";
ProjectileTypes["spear"].mnemonic = "timebomb place";
ItemTypes["wand"].mnemonic = "timebomb";
ItemTypes["magic scroll"].mnemonic = "timebomb ignition";
WeaponTypes["wand"].mnemonic = "bomb";
MonsterTypes["evil tree"].mnemonic = "timebomb";
bomb_poly = Polygons[915];
blast_door = find_platform(870);
   restoring_saved = rs;
   Players[0]:play_sound(251, 1);
   if rs then
      return;
   end
   remove_items("timebomb", "timebomb ignition");
end

function level_idle()
   player_poly = Players[0].polygon.index;
   if (player_poly ~= last_poly) then
      last_poly = player_poly;
      if (player_poly == exit_poly) then
         Players[0]:teleport_to_level(30);
      end
   end
   weapon = Players[0].weapons.current;
   if ( weapon ~= nil and weapon.index ~= last_weapon2) then 
      last_weapon2 = weapon.index;
      timebomb_current = (weapon.index == 9);
   end
   if shake_timer > 0 then
      shake_timer = shake_timer + 1;
      if (shake_timer == 10) then
         Players[0]:play_sound(226, 1);
         end
      if (shake_timer == 30) then
         Players[0]:fade_screen("long bright");
         explosion(timebomb_range, timebomb_power, Polygons[tb_poly], tb_x, tb_y);
         if (tb_poly == blast_poly1) or (tb_poly == blast_poly2) or (tb_poly == blast_poly3) then
            Players[0]:play_sound(218, 1);
            blast_door.active = true;
            exit_locked = false;
         else
            Players[0]:play_sound(198, 1);
	    Items.new(bomb_poly.x, bomb_poly.y, 0, bomb_poly, "timebomb");
	 end
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
      end
   end
   if timebomb_active then
      click_timer = click_timer + 1;
      timebomb_counter = timebomb_counter + 1;
      if (math.modf(timebomb_counter, 30) == 0) then
         Players[0]:print("時限爆弾カウントダウン: "..
                      1+math.floor((timebomb_wait-timebomb_counter)/30));
      end
      if (timebomb_counter >= timebomb_wait) then
         Players[0]:play_sound(198, 1);
         Players[0]:fade_screen("long bright");
         if tb_monster.valid then
            tb_monster:damage(32000, "explosion");
         else
            tb_poly = Players[0].polygon.index;
            tb_x = Players[0].x;
            tb_y = Players[0].y;
	 end
         shake_timer = 1;
         timebomb_active = false;
         timebomb_counter = 0;
         click_timer = 0;
      elseif (click_timer >= click_sound_length) then
         Players[0]:play_sound(209, 1);
         click_timer = 0;
      end
   end
end

function level_got_item(item, player)
   if (item == "timebomb") then
       timebomb_in_hand = true;
       end
end

function level_projectile_detonated(type, owner, polygon, x, y, z)
	if ((type == "timebomb activate") and timebomb_current and (not timebomb_active)) then
		timebomb_active = true;
      	click_timer = 0;
     	 Players[0]:play_sound(209, 1);
    end
   if ((type == "timebomb place") and timebomb_current and (not timebomb_active)) then
      Players[0]:print('最初に二次引き金を引いてタイマーを起動してください');
      Players[0].items["timebomb"] = Players[0].items["timebomb"] - 1;
      Players[0].items["timebomb"] = Players[0].items["timebomb"] + 1;
      Players[0].weapons["bomb"]:select();
   end
   if ((type == "timebomb place") and timebomb_current and timebomb_active) then
	      tb_poly = polygon.index;
    	  tb_x = x;
      	tb_y = y;
      	tb_monster = Monsters.new(x, y, 0, polygon, "timebomb");
      	tb_monster.active = true;
      	if (Players[0].items["timebomb"] > 0 ) then 
	 		Players[0].items["timebomb"] = Players[0].items["timebomb"] - 1;
      	end
   end
end

function explosion(radius, power, poly, x, y)
	for g in Monsters() do 
		if (g.index ~= tb_monster.index) then
			local mx = g.x;
			local my = g.y;
			local mz = g.z;
			local mp = g.polygon;
			local dist = (mx - x)^2 + (my - y)^2;
			local wu_dist = math.sqrt(dist) / 1024;
			local floor_delta = math.abs(mp.floor.height - poly.floor.height);
			if (wu_dist <= radius) and (floor_delta < 1.0) then
				local damage = power - (power*wu_dist/radius);
				g:damage(damage, "explosion");
			end
		end
	end
end



