start_term_dead = false;
last_poly = nil;
exit_poly = 235; 
start_poly = 100;
bridge_poly = 473;

function level_init(rs)
ProjectileTypes["special"].mnemonic = "teleport";
	exit_door = find_platform(213);
	kronos_door = find_platform(214);
   Players[0]:play_sound(250, 1);
   if rs then
      return;
   end
   remove_items("wand");
end

function level_got_item(item_type, player)
   if (item_type == "wand") and (not start_term_dead) then
      Players[0]:activate_terminal(6);
   end
end

function level_idle ()
   if (not start_term_dead) and exit_door.active then
      start_term_dead = true;
   end
   player_poly = Players[0].polygon.index;
   if (player_poly ~= last_poly) then
      last_poly = player_poly;
      if (player_poly == exit_poly) and (not exit_attempt) then
	 Players[0]:play_sound(235, 1);
	 Players[0]:teleport_to_level(20);
	 exit_attempt = true;
      end
   end
end

function Triggers.projectile_detonated(type, owner, polygon, x, y, z)
   if (type == "teleport") then
      floor = polygon.floor.height;
      height =  polygon.ceiling.height - floor;
      poly_type = polygon.type;
      if height < 0.8 then
	 Players[0]:print("呪文失敗：目的地はテレポートするには狭すぎます");
	 Players[0]:play_sound(5, 1);
	 Players[0]:fade_screen("bright");
      elseif poly_type == "monster impassable" then
	 Players[0]:print("呪文失敗：テレポート座標は塞がれています");
	 Players[0]:play_sound(5, 1);
	 Players[0]:fade_screen("bright");
      elseif poly_type == "platform" then
	 Players[0]:print("呪文失敗：目的地はテレポートするには不安定です");
	 Players[0]:play_sound(5, 1);
	 Players[0]:fade_screen("bright");
      else
	 Players[0]:position(x, y, floor, polygon);
         Players[0]:play_sound( 235, 1);
         Players[0]:fade_screen("cinematic fade out");
         Players[0]:fade_screen("cinematic fade in");
         if Players[0].head_below_media then
            Players[0]:print("呪文警告：溶岩へテレポートするのは悪い考えだったかもしれません");
	 end
      end
   end
end

