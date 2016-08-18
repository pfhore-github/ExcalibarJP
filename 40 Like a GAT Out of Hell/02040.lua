glass1 = 522;
glass2 = 571;
glass3 = 596;
fan1 = 721;
fan2 = 723;
cutscene = 519;
cutscene2 = 886;
safe = 987;
rideoff = 675;
hoverbike_park = 975;
termPoly = nil;
underwater_active = false;

bikeSnd = 214;
bikeIdleSnd = 259;
glassSnd = 247;

in_bike = false;
alarm_activated = false;
fan_speed = 0;
eng_timer = 1;
canPlayGlass = 1;
csTimer = 0;
csTimerFlag = 0;
speed = 0.0;
gear = 0;
shift_timer = 0;
maxVel = 16384;
maxSpeed = 150;
maxGears = 5;
shift_length = 72;
bikePitch = 1;


termX = 0.0;
termY = 0.0;
termZ = 0.0;
crosshairs = false;
term_polys = { 102, 108, 109, 110, 111, 112, 993, 995, 107, 105, 609, 106, 103, 104, 495, 100, 101, 785, 97, 98, 99, 835, 834 };
tnt_ignite = false;
shake_timer = 0;
shake_length = 240;
in_repair = false;
docs_timer = -1;
upload_time = 60 * 30;
last_poly = nil;


function level_init(rs)
	doorBlock = find_platform(7);
	timer_platform = find_platform(1001);
repair_light = Lights[29];
timer_light = Lights[22];

	MonsterTypes["metal bar"].mnemonic = "grenade";
   timer_active = timer_light.active;
   restoring_saved = rs;
   Players[0]:play_sound(251, 1);
   if (Game.difficulty.index == 0) then
	   deathMins = 30
	elseif (Game.difficulty.index == 1) then
 	  deathMins = 15
	elseif (Game.difficulty.index == 2) then
   	deathMins = 10
	else
   		deathMins = 5;
   	end
	deathTimer = deathMins * 60 * 30;

   if rs then
      if (Players[0].weapons.current == "wand") then
         activate_bike();
      end
      --[[
      deathTimer = get_platform_floor_height(timer_platform) * deathMins * 60 * 30;
      if deathTimer < 60 then
         deathTimer = 60;
      end
      --]]
      return;
   end
   remove_items("wand");
end

function nice_monsters()
   player = Players[0].monster;
   for g in Monsters() do 
      if (g.index ~= player.index) then
         mtype = g.type;
        mtype.enemies["player"] = false;
	 mtype.friends["player"] = true;
	 g:position(-0.5, -9.0, 0.0, 999);
      end
   end
end

function record_monsters()
   player = Players[0].monster;
   for g in Monsters() do 
      if (g ~= player) then
         mtype = g.type;
         if ((mtype == "minor gat") or (mtype == "major gat") or
       (mtype == "hover gat") or (mtype == "bike cop") or (mtype == "laser turret") or
(mtype == "minor spam") or (mtype == "major spam")) then
            local m = {};
            m.mtype = mtype;
            m.polygon = g.polygon;
            m.facing = g.facing;
            m.x = g.x;
	    m.y = g.y;
	    m.z = g.z;
            m.vitality = g.vitality;
            monsters_name[g] = m; 
	 end
      end
   end
end

function activate_bike()
   Lights[25].active = true;
   in_bike = true;
   doorBlock.player_controllable = false;
   doorBlock.monster_controllable = false;
   Players[0]:print("動作と発射キーは通常通り使います。");
   Players[0]:print("上昇するには[泳ぐ]キーを使います。飛行高度は制限されています！");
   Players[0]:print("第３者視点に切り替えるには[F6]を押します。");
end

--[[ for first entering the hoverbike ]]
function level_got_item(type, player)
   if (type == "wand") then
      activate_bike();
      player.life = 450;
      doorBlock.floor_height = 1.0;
   end
end


function flash_color()
   if (math.modf(tick, 20) < 10) then 
      return "dark red";
   else 
      return "red";
   end
end

function timer_color(timer)
   if (timer >= 30 * 120) then 
      return "yellow";
   elseif (timer >= 30 * 60) then 
      return "red";
   else 
      return flash_color() 
   end
end

function kill_everything()
   for g in Monsters() do 
      g:damage(2000, "explosion");
   end
end

function calc_bike_speed()

   xVel = Players[0].internal_velocity.forward * 65536;
   yVel = Players[0].internal_velocity.perpendicular * 65536;
   local newgear = 1 + math.floor((xVel-1) * maxGears / maxVel);
   if (newgear > gear) and (newgear == 4) and (shift_timer == 0) then
      shift_timer = shift_length;
   end
   if (xVel == 0) then
      Players[0]:play_sound(bikeIdleSnd, 1.0);
   else
      Players[0]:play_sound(bikeSnd, bikePitch);
   end
   if (shift_timer > 0) then
      shift_timer = shift_timer - 1;
   end
   if (shift_timer == 0) and (newgear ~= gear) then
      gear = newgear;
   end
   if gear < 0 then
      bikePitch = 0.8;
   else
      bikePitch = 1 + (gear - 1) * 0.02;
   end
   speed = math.floor(xVel * maxSpeed / maxVel);
   Players[0].overlays[1]:clear();
   Players[0].overlays[2]:clear();
--[[
   if gear < 0 then
      Players[0].overlays[3].text = 'ギア: R';
   else
      Players[0].overlays[3].text = 'ギア: '..gear;
   end
   Players[0].overlays[3].color = "blue";
--]]
   Players[0].overlays[3]:clear();
   Players[0].overlays[4]:clear();
   Players[0].overlays[5].text = '速度: '..math.abs(speed)..' mph   ';
   if speed < 0 then
      Players[0].overlays[5].color = "red";
   elseif speed > 0 then
      Players[0].overlays[5].color = "green";
   else
      Players[0].overlays[5].color = "white";
   end 
end

function level_idle()
   
   --[[if player gets pushed through force field, send them back to garage]]
   x = Players[0].x;
   y = Players[0].y;
   if ((x > -9.5) or (x < -26.1)) and (y > 20.8) and (y < 23.5) then
      Players[0]:teleport(27);
   end

   --[[timers]]
   if (tick) then 
      tick = tick + 1
   else 
      tick = 0 
   end
   if timer_active and (docs_timer == -1) then
      docs_timer = 0;
   end
   if (docs_timer >= 0) and (docs_timer < upload_time) then
      docs_timer = docs_timer + 1;
      if docs_timer >= upload_time then
	 set_terminal_text_number(1003, 2508, 4);
	 Players[0]:print('文書更新完了');
      end
   end
   if (csTimerFlag == 1) then
      csTimer = csTimer + 1;
   end
   if (eng_timer ~= 0 ) then
      eng_timer = eng_timer - 1;
   end
   if (not timer_active) and (not in_bike) and timer_light.active then
      timer_active = true;
      Players[0]:print('破壊タイマー起動！');
   end
   if (deathTimer > 0) and (timer_active) then
      timerStr = string.format("%02d:%02d.%02d", deathTimer / 30 / 60,
			       math.modf(deathTimer / 30, 60), math.modf(deathTimer, 30) * 100 / 30);
      Players[0].overlays[0].text = timerStr;
      Players[0].overlays[0].color = timer_color(deathTimer);
      --[[ timer_platform.floor_height = (deathTimer / (deathMins * 60 * 30));  ]]
   elseif (timer_active) then
      Players[0].overlays[0].text = "死と大混乱";
      Players[0].overlays[0].color = flash_color();
   end
   if (not alarm_activated) and (deathTimer < 30*30) then
      alarm_activated = true;
      Lights[27].active = true;
   end
   if shake_timer > 0 then
      shake_timer = shake_timer + 1;
      if (shake_timer == 10) then
         Players[0]:play_sound(226, 1);
      end
      if (shake_timer == 30) then
         Players[0]:fade_screen("long bright");
         Players[0]:play_sound(198, 1);
         kill_everything();
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
   if (deathTimer <= 0) and (not tnt_ignite) then
      Players[0]:fade_screen("long bright");
      Players[0]:play_sound(198, 1.0);
      Music.stop();
      Level.fog.depth = 5;
      Level.fog.color.r = 0.3;
      Level.fog.color.g = 0.3;
      Level.fog.color.b = 0.3;
      Level.fog.present = true;
      Level.underwater_fog.depth = 5;
      Level.underwater_fog.color.r = 0.3;
      Level.underwater_fog.color.g = 0.3;
      Level.underwater_fog.color.b = 0.3;
      Level.underwater_fog.present = true;
      shake_timer = 1;
      tnt_ignite = true;
   end
   if (timer_active) then
      deathTimer = deathTimer - 1;
   end
   
   --[[in-hoverbike stuff]]
   if in_bike then
      calc_bike_speed();
      if (Players[0].weapons.current ~= "wand") then
	 Players[0].weapons["wand"]:select();
      end
      if (last_poly ~= poly) then
	 last_poly = poly;
	 if (poly == hoverbike_park) then
	    in_repair = true;
	    Players[0]:print('ホバーバイク修理起動');
	 else
	    in_repair = false;
	 end
      end
      if in_repair then
	 h = Players[0].life;
	 if h < 450 then
	    h = h + 2;
	    if h > 450 then
	       h = 450;
	    end
	    Players[0].life = h;
	 else
	    in_repair = false;
	 end
      end
      if repair_light.active == in_repair then
	 repair_light.active = not in_repair;
      end
   end
   
   --[[breaking glass]]
   poly = Players[0].polygon.index;
   if ((poly == glass1 or poly == glass2 or poly == glass3) and canPlayGlass == 1) then
      canPlayGlass = 0;
      Players[0]:play_sound(glassSnd, 1);
   elseif (poly == glass1 or poly == glass2 or poly == glass3) then
      canPlayGlass = 0;
   else
      canPlayGlass = 1;
   end
   
   --[[just in case player is stuck in safe area]]
   if (timer_active) and ((poly == 986) or (poly == safe)) then
      if (termPoly == nil) or (termPoly.index == 986) or (termPoly == safe) then
	 Players[0]:position(-3.25, 16.0, 0.0, 854);
      else
	 Plyers[0]:position(termX, termY, termZ, termPoly);
      end
   end
   
   --[[fan propulsion]]
   if ((poly == fan1 or poly == fan2) and Tags[1].active) then
      Players[0]:accelerate(0, 0, 10);
   end
   
   --[[cutscene stuff]]
   if (poly == cutscene) then
      csTimerFlag = 1;
      timer_active = false;
      Players[0].overlays[0]:clear();
      Music.stop();
      nice_monsters();
      playCutsceneShot1();
      disable_player(0);
      Players[0].yaw = 90;
      Players[0].pitch = 360;
   end
   if (csTimer == 90) then
      cutsceneCam1:deactivate();
      playCutsceneShot2();
      Players[0]:position(-13, 29.5, 0.0, rideoff);
      Players[0].yaw = 0;
      Players[0].pitch = 360;
   end
   if (csTimer > 90 and csTimer < 240) then
      Players[0].external_velocity.i = 20000 / 1024;
      Players[0].external_velocity.j = 0;
      Players[0].external_velocity.k = 0;
   end
   if (csTimer == 60) then
      Players[0]:fade_screen("long bright");
      Players[0]:play_sound(198, 1.0);
      Music.stop();
   end
   if (csTimer == 210) then
      Players[0]:fade_screen("cinematic fade out");
      Players[0].crosshairs.active = crosshairs;
   end
   if (csTimer == 240) then
      Players[0]:teleport_to_level(32);
   end
end

function playCutsceneShot1()
   cutsceneCam1 = Cameras.new();
   cutsceneCam1:deactivate();
   Players[0].yaw = 90;
   Players[0].pitch = 360;
   crosshairs = Players[0].crosshairs.active;
   Players[0].crosshairs.active = false;
   cutsceneCam1.path_points:new(-18.125, 23.875, 6.8, cutscene, 90);
   cutsceneCam1.path_angles:new(0, 0, 90);
   cutsceneCam1:activate(Players[0]);
end

function playCutsceneShot2()
   cutsceneCam2 = Cameras.new();
   cutsceneCam2:deactivate();
   cutsceneCam2.path_points:new(-27.625, 28.125, 0.5, cutscene2, 30);
   cutsceneCam2.path_angles:new(0, 0, 30);
   cutsceneCam2.path_points:new(-27.625, 28.125, 3.0, cutscene2, 90);
   cutsceneCam2.path_angles:new(0, -5, 90);
   cutsceneCam2:activate(Players[0]);
end

