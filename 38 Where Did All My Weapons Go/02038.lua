got_pistol = false;
got_dachron = false;
got_phaser = false;
got_flamer = false;
got_railgun = false;
got_hightech = false;
got_excalibur = false;
exit_release = false;
exit_poly = 759;
sword_poly = 742;
last_poly = nil;
camera_timer = 0;
camera_index = nil;
underwater_active = false;

function new_monster_poly(type, poly)
   Monsters.new(Polygons[poly].x, Polygons[poly].y, 0, Polygons[poly], type);
end
function level_init(rs)
	ItemTypes["crossbow"].mnemonic ="railgun";
	ItemTypes["spear"].mnemonic = "dragon flamer";
exit_door = Polygons[758];
final_term = find_platform(760);
   restoring_saved = rs;
   Players[0]:play_sound(248, 1);
   if Players[0].items["snyper"] > 0 then
      got_pistol = true;
   end
   if Players[0].items["railgun"] > 0 then
      got_railgun = true;
   end
   if Players[0].items["dachron"] > 0 then
      got_dachron = true;
   end
   if Players[0].items["hightech"] > 0 then
      got_hightech = true;
   end
   if Players[0].items["sword"] > 0 then
      got_excalibur = true;
   end
   if Players[0].items["phaser"] > 0 then
      got_phaser = true;
   end
   if Players[0].items["dragon flamer"] > 0 then
      got_flamer = true;
   end
   if rs then
      return;
   end
   remove_items("epotion", "magic scroll"); 
end

function Triggers.platform_activated(poly)
   if poly.index == sword_poly then
      Polygons[698].floor.height = 4.8;
   end
end

function level_idle ()
   player_poly = Players[0].polygon.index;
   if (player_poly ~= last_poly) then
      last_poly = player_poly;
      if player_poly == exit_poly then
         Players[0]:teleport_to_level(28);
      end
   end
   if camera_timer > 0 then
      camera_timer = camera_timer - 1;
      if camera_timer == 0 then
--         camera_index:deactivate();
      end
   end
   if (got_pistol and got_dachron and got_phaser and got_flamer and
       got_railgun and got_hightech and got_excalibur and (not exit_release)) then
      exit_release = true;
      exit_door.floor.height = 5.0;
      final_term.active = true;
      Lights[20].active = false;
      Players[0]:print("ì]ëóé∫7ÇcÇ÷êiÇÒÇ≈Ç≠ÇæÇ≥Ç¢"); 
      new_monster_poly("minor gat", 75);
      new_monster_poly("major gat", 77);
      new_monster_poly("minor gat", 92);
      new_monster_poly("major gat", 591);
      new_monster_poly("minor gat", 636);
      new_monster_poly("major gat", 585);
      new_monster_poly("cave bob", 576);
      new_monster_poly("cave bob", 575);
      new_monster_poly("cave bob", 574);
      --[[
      camera_index = create_camera();
      add_path_point(camera_index, 752,  23.125, -10.25, 6.0);
      activate_camera(0, camera_index);
      camera_timer = 150;
      --]]
   end
end

function level_got_item(item, player)
   if (item == "snyper") and (not got_pistol) then
      got_pistol = true;
      Players[0]:play_sound(233, 1);
      Players[0]:activate_terminal(4);
   elseif (item == "railgun") then
      got_railgun = true;
      Players[0]:play_sound(233, 1);
      Players[0]:activate_terminal(9);
   elseif (item == "dachron") then
      got_dachron = true;
      Players[0]:play_sound(233, 1);
      Players[0]:activate_terminal(5);
   elseif (item == "hightech") then
      got_hightech = true;
      Players[0]:play_sound(233, 1);
      Players[0]:activate_terminal(7);
   elseif (item == "sword") then
      got_excalibur = true;
      Players[0]:play_sound(233, 1);
   elseif (item == "phaser") then
      got_phaser = true;
      Players[0]:play_sound(233, 1);
      Players[0]:activate_terminal(6);
   elseif (item == "dragon flamer") then
      got_flamer = true;
      Players[0]:play_sound(233, 1);
      Players[0]:activate_terminal(8);
   end
end

