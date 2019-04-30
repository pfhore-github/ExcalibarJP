start_theme = "Cavern/Siege.mp3";
end_theme = "Cavern/M11.mp3";
music_on = { 170, 331, 418, 523 };
music_off = { 239, 527, 417 };
firestorm = false;
fire_spells = {};
fire_timers = {};
min_left = 4;
quake = 0;
task_done = false;
   
last_poly = nil;

function level_init (rs)
	ProjectileTypes["special"].mnemonic = "firespray";
	danger_compass = Lights[33].active;
	counter_light = Lights[33];
	restoring_saved = rs;
   Players[0]:play_sound(175, 1);
   if Lights[32].active then
      music = end_theme;
   else
      music = start_theme;
   end
	if (Game.difficulty.index == 0) then
   fire_length = 120 * 30;
elseif (Game.difficulty.index == 1) then
   fire_length = 60 * 30;
elseif (Game.difficulty.index == 2) then
   fire_length = 30 * 30;
else
   fire_length = 20 * 30;
end

   if rs then
      return;
   end
   remove_items("wand");
end

function timer_color(e)
  if (e <= min_left) then 
     if (not task_done) then
	set_terminal_text_number(172, 622, 3);
	set_terminal_text_number(169, 605, 4);
	task_done = true;
     end
     return "green";
  elseif (e < 31) then 
     return "yellow";
  else 
     return "red";
  end
end

function level_idle ()
   if restoring_saved and (not restore_check) then
      remove_monsters("fire");
      restore_check = true;
   end
   if Lights[32].active ~= (music == end_theme) then
      if Lights[32].active then
	 music = end_theme;
      else
	 music = start_theme;
      end
   end      
   player_poly = Players[0].polygon.index;
   if (last_poly ~= player_poly) then
      last_poly = player_poly;
      for i, v in ipairs(music_on) do
	 if(( player_poly == v) and (not music_playing)) then
	    Music.play(music);
	    music_playing = true;
	 end
      end
      for i,v in ipairs(music_off) do
	 if ((player_poly == v) and music_playing) then
	    Music.fade(60 / 1000);
	    music_playing = false;
	 end
      end
   end
   if danger_compass then
      e = enemies_left(Players[0]);
      Players[0].overlays[0].text =  "残りの敵は"..e;
      Players[0].overlays[0].color = timer_color(e);
      idle_danger(2, 10);
   elseif counter_light.active then
      danger_compass = true;
   end
   if (not firestorm) and Tags[1].active then
      firestorm = true;
      Players[0].items["wand"] = Players[0].items["wand"] + 1;
      quake = 1;
      Players[0]:play_sound(226, 1);
   end
   if (quake > 0) then
      quake = quake + 1;
   end
   if (quake == 150) then
      Players[0]:play_sound( 176, 1);
      quake = 0;
   end
   if ( (quake > 15) and (quake < 150) ) then
      theta = Game.global_random (360);
      vel = (Game.global_random (100+quake*0.5))/10000;
      Players[0]:accelerate(theta, vel, 0);
   end
   cnt = # fire_spells;
   i = 1;
   while (i <= cnt) do
      fire_timers[i] = fire_timers[i] - 1;
      if fire_timers[i] <= 0 then
	 fire_spells[i]:damage(10000, "suffocation");
	 table.remove(fire_spells, i);
	 table.remove(fire_timers, i);
	 i = i - 1;
	 cnt = cnt - 1;
      end
      i = i + 1;
   end
end

function level_projectile_detonated(type, owner, polygon, x, y, z)
   if (type == "firespray") then
      spell = Monsters.new(x, y, 0, polygon, "fire");
      spell.active = true;
      table.insert(fire_spells, spell);
      table.insert(fire_timers, fire_length);
   end
end