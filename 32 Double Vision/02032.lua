teleport_pad = 570;
teleport_dest = 156;
secret_room = 378;
tiny_available = false;
tiny_term = false;
door_unlocked = false;
main_music = "Cavern/M30.mp3";
action_music = "Cavern/M32.mp3";
mid_music = "Cavern/Merlin's Funk.mp3";
special_music = "Cavern/M04.mp3";
last_poly = nil;
current_music = "";
min_left = 4; 


function level_init (rs)
lobby_door = find_platform(159);
ItemTypes["nightvision"].mnemonic = "tiny module";
music_light = Lights[56];
disk_light = Lights[57];
teleporter_light = Lights[58];
inside_light = Lights[60];
scan_light = Lights[61];
   restoring_saved = rs;
   last_light_state = music_light.active;
   danger_compass = scan_light.active;
   teleport_active = teleporter_light.active;
   Players[0]:play_sound(251, 1);
   if rs then
      tiny_available = disk_light.active;
      door_unlocked = lobby_door.floor_height < 1;
      return;
   end
   remove_items("wand", "tiny module");
end
function Triggers.terminal_exit(term, player)
   if term.index == 2 then
      scan_light.active = true;
   end
end

function shift_music(music)
   if music == current_music then
      return;
   end
   Music.fade(60/1000);
   Music.play(music);
   current_music = music;
   if music == main_music then
      music_light.active = true;
   else
      music_light.active = false;
   end
   last_light_state = music_light.active;
end

function level_got_item(item, player)
   if (item == "tiny module") then
      Players[0]:play_sound(15, 1);
      set_terminal_text_number(215, 818, 10);
      set_terminal_text_number(380, 1227, 4);
      set_terminal_text_number(384, 1220, 4);
      Lights[19].active = false;  --[[ just turn off term on line 1220 ]]
      Players[0]:print('Tinyはあなたのコンピュータへアップロードされました。');
   end
end

function timer_color(e)
   if (e <= min_left) then 
      if not task_done then
         Players[0]:print('あなたはこのエリアを離れることができます。');
         Players[0]:play_sound(254, 1);
         task_done = true;
      end
      return "green";
   elseif (e < 15) then 
      return "yellow";
   else 
      return "red";
   end
end

function level_idle ()
   if not danger_compass then
      if scan_light.active then
         danger_compass = true; 
      end
   end
   if danger_compass then
      e = enemies_left(0, 4);  --[[ ignores 4 enemies that are off-grid on poly 594 ]]
      Players[0].overlays[0].text = "残りの敵は"..e;
      Players[0].overlays[0].color = timer_color(e);
      idle_danger(2, 10, 594);
   end
   if restoring_saved and (not music_adjusted) then
      music_adjusted = true;
      if music_light.active and inside_light.active then
         shift_music(main_music);
      elseif inside_light.active then
         shift_music(action_music);
      end
   end
   light_state = music_light.active;
   if (light_state ~= last_light_state) then
      last_light_state = light_state;
      if light_state then
         shift_music(main_music);
      else
         shift_music(action_music);
         end
      end
   if (not door_unlocked) and (lobby_door.floor_height < 1) then
      Players[0]:play_sound(15, 1);
      set_terminal_text_number(212, 809, 6);
      door_unlocked = true;
   end
   if (not teleport_active) and teleporter_light.active then
      teleport_active = true;
   end
   if (not tiny_term) and Lights[55].active then
      set_terminal_text_number(383, 1234, 7);
      tiny_term = true;
   end
   if (not tiny_available) and disk_light.active then
      Items.new(Polygons[secret_room].x, Polygons[secret_room].y, 0, secret_room, "tiny module");
      tiny_available = true;
   end
   poly = Players[0].polygon.index;
   if (poly ~= last_poly) then
      last_poly = poly;
      if (poly == teleport_pad) and teleport_active then
         Players[0]:teleport(teleport_dest);
	 Players[0].yaw = 180;
	 Players[0].pitch = 360;
	 inside_light.active = true;
         shift_music(main_music);
         remove_monsters("laser turret");
      elseif poly == 437 then
         shift_music(special_music);
      elseif (poly == 329) or (poly == 330) then
         shift_music(action_music);
      elseif (poly == 409) or (poly == 191) or (poly == 349) then
         shift_music(main_music);
      elseif (poly == 54) or (poly == 189) or (poly == 258) or (poly == 241) then
         shift_music(mid_music);
      end
   end
end