main_music = "Cavern/Mantis Hymn.mp3";
santa_fe_music = "Cavern/Santa Fe.mp3";
mauvair_lives = 3;
mauvair_poly = nil;

mauvair_polys = { 36, 89, 7 };
mauvair_angles = { 135, 315, 270 };
ghoul_polys = { 738, 737, 740, 744, 741, 742, 746, 745, 743, 736 };
ghoul_requirement = # ghoul_polys;
gates = {
   [153] = {dest=57, x=-6.88, y=12.3, z=-4},
   [9] = {dest=27, x=-3.44, y=12.14, z=-3},
   [8] = {dest=74, x=0.88, y=11.0, z=2},
   [55] = {dest=18, x=-5.8, y=14.0, z=-4},
   [776] = {dest=44, x=-3.38, y=13.38, z=-4},
   [104] = {dest=42, x=0.75, y=13.88, z=-4}}
dead_ghouls = 0;
crypt_open = false;
crypt_activated = false;
ghouls_activated = false;
ghoul_timer = 6 * 30;
door_closed = false;
shuttle_activated = false;
quake_timer = 0;
mixed_bag = true;  --[[ some potions, some powerups --]]
santa_fe_enter = 345;
santa_fe_exit = 340;
crypt_poly = 684;
function find_mauvair()
	for g in Monsters() do
		if (g.type == "master wizard") then
			return g;
		end
	end
end

function level_init (rs)
   
	santa_fe_light = Lights[34];
	mauvair_light1 = Lights[31];
	mauvair_light2 = Lights[32];
	crypt_light = Lights[33];
	crypt_door = find_platform(655);
	crypt_cave = find_platform(654);

   on_santa_fe = santa_fe_light.active;
   
   mauvair = find_mauvair();
   Players[0]:play_sound( 250, 1);
   if rs then
      if on_santa_fe then
	 Music.fade(60 / 1000);
	 Music.play(santa_fe_music);
      end
      if mauvair_light1.active then
         mauvair_lives = 1;
         crypt_open = true;
      elseif mauvair_light2.active then
         mauvair_lives = 2;
      end
      crypt_activated = (not crypt_light.active);
      if (mauvair == -1) and (not crypt_activated) then
         respawn_mauvair();
      end
      return;
   end
end

function level_idle ()
   
   if Lights[30].active and (not shuttle_activated) then
      shuttle_activated = true;
      Players[0]:teleport_to_level(22);
      end
   poly = Players[0].polygon.index;
   if on_santa_fe and (poly == santa_fe_exit) then
      Music.fade(60 / 1000);
      Music.play(main_music);
      on_santa_fe = false;
      santa_fe_light.active = false;
  end
  if (not on_santa_fe) and (poly == santa_fe_enter) then
     Music.fade(60/1000);
     Music.play(santa_fe_music);
     on_santa_fe = true;
     santa_fe_light.active = true;
  end
  if (poly ~= last_poly) then
     last_poly = poly;
     if gates[poly] then
        Players[0]:position(gates[poly].x, gates[poly].y, gates[poly].z, gates[poly].dest);
	Players[0]:play_sound( 235, 1);
     end
  end
  if (poly == crypt_poly) and (not crypt_activated) then
     crypt_activated = true;
     Tags[2].active = true;
     crypt_light.active = false;
     crypt_door.active = true;
     door_closed = true;
     quake_timer = 1;
     Players[0]:play_sound( 226, 1);
  end
  if (quake_timer > 0) then
     quake_timer = quake_timer + 1;
  end;
  if (quake_timer == 240) then
     quake_timer = 0;
  end
  if ( (quake_timer > 15) and (quake_timer < 240) ) then
     theta = Game.global_random (360);
     vel = (Game.global_random (100+quake_timer*0.5))/10000;
     Players[0]:accelerate(theta, vel, 0);
  end
  if crypt_activated and (not ghouls_activated) and (ghoul_timer <= 0) then
     for i = 1, # ghoul_polys do
        local gp = Polygons[ghoul_polys[i]];
        Monsters.new( gp.x, gp.y, 0, gp, "clone");
     end
     dead_ghouls = 0;
     ghouls_activated = true;
  end
  if crypt_activated and (not ghouls_activated) then
     ghoul_timer = ghoul_timer - 1;
  end;
  if mauvair and mauvair.valid then
     mauvair_poly = mauvair.polygon;
  end
end

function respawn_mauvair()
   mauvair_lives = mauvair_lives -1;
   if (mauvair_lives > 1) then
      respawn = 1 + Game.global_random (3);
      local mp = Polygons[mauvair_polys[respawn]]
      mauvair = Monsters.new(mp.x, mp.y, 0, mp, "master wizard");
      mauvair.yaw = mauvair_angles[respawn]
      mauvair.vitality = 350;
      mauvair_light2.active = true;
      Players[0]:play_sound(83, 1);
   elseif (mauvair_lives == 1) then
      local mp = Polygons[7]
      mauvair = Monsters.new(mp.x, mp.y, 0, mp, "master wizard");
      mauvair.yaw = 270
      mauvair.vitality =  250;
      crypt_cave.active = true
      mauvair_light1 = true
      Players[0]:play_sound( 83, 1);
      crypt_open = true;
  end
end

function level_monster_killed(victim, victor, projectile)

   mtype = victim.type;
   if (mtype == "master wizard") then
      respawn_mauvair();
      if (mauvair_poly ) then
         Monsters.new(mauvair_poly.x, mauvair_poly.y, 0, mauvair_poly, "skull snake" );
         end
      end
   if (mtype == "clone") and door_closed then
      dead_ghouls = dead_ghouls + 1;
      if (dead_ghouls >= ghoul_requirement) then
         crypt_door.active = true;
         door_closed = false;
         end
      end
end

