last_poly = nil;
fart_msgs = { 
   "私はバナナを食べ過ぎたと思います。",
   "それは私がどう安堵をつづるかということです。",
   "その虫だらけなりんごはそうであるに違いありません。",
   "おっと! スーツ圧の損失。",
   "おー、だれかがアヒルを踏みましたか?",
   "エクスキャリバーの次に最も良い兵器。",
   "遅い爆発するグレネード！",
   "私はそれを瓶に入れるべきです… ナパーム弾より強いです!", 
   "えー、おお、オゾンの別の穴…",
   "それで、マーリンは彼の感覚を取り戻すことに関して再考するかもしれません。",
   "3回のタイムスリップと１光年をそのために待っています…",
   "重い食事の後にこのすべての時間旅行がただ良いというわけではありません..." };
last_fart = -1;
bathroom_poly = 94;
bathroom_exit = 81;
was_in_bathroom = false;
hint_done = false;
hq_sword_poly = 259;
hq_sword_index = -1;
merlin_speech_length = 2280;
merlin_gives_wand = 900;
merlin_timer = 0;
merlin_done = false;
teleport_wand_enchanted = false;
teleport_wand_charge = 0;
got_hq_sword = false;
teleport_poly = 234; 
hq_return = 232;
camelot_exit = 213;
camelot_poly = 154;
hud_activate = 155;
cottage_poly = 207;
cottage2 = 208;
cottage3 = 209;
cottage4 = 210;
cottage5 = 211;
cottage_talk = 204;
lobby_poly = 128;
enchant_on_poly = 308;
enchant_off_poly = 329;
crystal_x = -27.875;
crystal_y = -1.75;
merlin_term_poly = 294;
merlin_term = 892;
crystal_poly = 316;

merlinx  = -15.5;
merliny = -21.5;
merlin_state = -1;

hq_theme = "Cavern/Briefing.mp3";
merlin_theme = "Cavern/Homecoming.mp3";
merlin_speech = "Cavern/Merlin Speech.mp3";
sword_theme = "Cavern/O'Fortuna.mp3";
end_theme = "Cavern/Ending.mp3";
theme_length = 155 * 30;
sword_countdown = 0;
merlin_index = -1;
sword_index = -1;
music = hq_theme;
sword_play = false;
sword_gone = false;
guard_greeting = false;
shake_timer = 0;
shake_length = 120;
enchant_fade = false;
player_enchanted = false;
spell_of_life = false;
merlin_arrived = false;
hall_open = false;
remove_sword_flag = false;
has_teleport_wand = false;
merlin_left = false;
spawn_cnt = 0;
message_wait = 0;
sword_check = 0;
sword_failsafe = 10;  


function level_init (rs)
	MonsterTypes["exploding barrel"].mnemonic = "hq sword";
MonsterTypes["barrel"].mnemonic = "sword";
MonsterTypes["grenade"].mnemonic = "crystal"; -- raptor eggs
MonsterTypes["cleric"].mnemonic = "merlin";
MonsterTypes["lesser knight"].mnemonic = "merlin2";
MonsterTypes["black knight"].mnemonic = "merlin3";
	enchant_poly = Polygons[314];
	enchant_door = find_platform(266);
	hall_door = find_platform(297);
in_hall = Polygons[353];
in_forest1 = Polygons[217];
in_forest2 = Polygons[216];
in_forest3 = Polygons[173];
in_forest4 = Polygons[213];
merlin_light = Lights[36];
exit_light = Lights[41];
sword_light = Lights[39];
   merlin_light_state = merlin_light.active;
   prev_light_state = merlin_light_state;
   fog_save = save_fog();
   restoring_saved = rs;
   Players[0]:play_sound(248, 1);
   crystal_ball = nil;
   for g in Monsters() do 
      mtype = g.type;
      mp = g.polygonl
      if (mtype == "crystal") then
	 crystal_ball = g;
      end
   end

--[[  If crystal ball is already placed in map, then we know that Merlin has already returned ]]

   if crystal_ball ~= nil then
      merlin_left = true;
      merlin_index = -2;
      merlin_state = -2;
      teleport_wand_enchanted = true;
      merlin_done = true;
   end

   if rs then
      --[[ If restoring a saved game, we're in the kitchen, and need to figure out if the player has completed his mission or not to determine music.  We also need to establish some other globals to keep things in order.
      --]]
      guard_greeting = true;
      sword_gone = sword_light.active;
      got_hq_sword = (Players[0].items["sword"] > 0) or sword_gone;
      if sword_gone then
         music = end_theme;
         set_terminal_text_number(385, 1185, 6);
      else
         music = hq_theme;
      end
      Music.fade(60/1000);
      Music.play(music);
      merlin_light_state = merlin_light.active;
      return;
   end
   remove_items("sword");
   hq_sword_index = Monsters.new(1.0, 4.875, 0, hq_sword_poly, "hq sword");
end

function cut_scene()

   camera_index = Cameras.new();
   camera_index:deactivate();
   camera_index:clear();
   camera_index.path_points:new(-17.25, -22.13, 1.0, 204, 150);
   camera_index.path_angles:new( 0, -10, 150);
   c = 150;
   camera_index.path_points:new(-17.72, -23.5, 1.0, 203, 120);
   camera_index.path_angles:new( 45, -10, 120);
   c = c + 120;
   camera_index.path_points:new(-19.22, -23.53, 1.0, 161, 100);
   camera_index.path_angles:new( 30, -10, 100);
   c = c + 100;
   camera_index.path_points:new(-21.16, -21.69, 1.5, 177, 80);
   camera_index.path_angles:new( 0, -20, 80);
   c = c + 80;
   camera_index.path_points:new(-20.13, -18.38, 1.5, 178, 60);
   camera_index.path_angles:new( -45, -20, 60);
   c = c + 60;
   camera_index.path_points:new(-18.7, -19.48, 1.25, 159, 80);
   camera_index.path_angles:new( -45, -15, 80);
   c = c + 80;
   camera_index.path_points:new(-17.39, -20, 1.0, 205, 120);
   camera_index.path_angles:new( -60, -10, 120);
   c = c + 120;
   camera_index.path_points:new(-16.41, -21.96, 0.7, 204, 150);
   camera_index.path_angles:new( 0, 0, 150);
   c = c + 150;
   r = merlin_speech_length - c;
   camera_index.path_points:new(-20.38, -23.83, 1.5, 161, r);
   camera_index.path_angles:new( 25, -20, r);
   camera_index:activate(Players[0]);
   disable_player(0);
   Players[0]:position(-17.0, -21.5, 0.6, 160);
   Players[0].yaw = 0;
   Players[0].pitch = 360;
end

function display_random_fart()

   idx = 1+Game.global_random(# fart_msgs);
   if idx == last_fart then
      display_random_fart()
   else
      Players[0]:print(fart_msgs[idx]);
      last_fart = idx;
   end
end

function level_idle ()

   --[[  Fail safe to handle when Lua doesn't return the sword because it thinks you already have one.  Let's wait 10 ticks to make sure player has the sword.  ]]
   if sword_check > 0 then
      if Players[0].items["sword"] < 1 then
         Players[0].items["sword"] = 1;
      end
      sword_check = sword_check - 1;
   end
   if exit_light.active and (not game_over) then
      game_over = true;
      Players[0]:teleport_to_level(256);
   end
   if message_wait > 0 then
      message_wait = message_wait - 1;
   end
   if remove_sword_flag then
      if Players[0].items["sword"] > 0 then
	 Players[0].items["sword"] = 0;
      end
      remove_sword_flag = false;
   end
   if (merlin_state == "merlin") and (player_enchanted) then
      if merlin_index and merlin_index.valid then
         merlin_index:damage(10000, "suffocation");
      end
      merlin_index = Monsters.new(merlinx, merliny, 0, cottage_poly, "merlin2");
      merlin_index.yaw = 180;
      Players[0]:fade_screen("long bright");
      merlin_state = "merlin2";
   end
   if (merlin_state == "merlin2") and (spell_of_life) then
      if merlin_index and merlin_index.valid then
         merlin_index:damage(10000, "suffocation");
         end
      merlin_index = Monsters.new(merlinx, merliny, 0, cottage_poly, "merlin3");
      merlin_index.yaw = 180;
      Music.fade(60/1000);
      Music.play(merlin_speech);
      merlin_timer = 1;
      Players[0]:fade_screen("long bright");
      merlin_state = "mariln3";
      cut_scene();
   end
   if merlin_timer > 0 then
      merlin_timer = merlin_timer + 1;
      if (merlin_timer > merlin_gives_wand) and (not has_teleport_wand) then
         Players[0].items["spear"] = Players[0].items["spear"] + 1;
         has_teleport_wand = true;
      end
      if (merlin_timer > merlin_speech_length) and (not merlin_done) then
         merlin_done = true;
         merlin_timer = 0;
         camera_index:deactivate();
         enable_player(0);
	 Music.fade(60/1000);
	 Music.play(music);
      end
   end
   if merlin_done and (not teleport_wand_enchanted) then
      teleport_wand_charge = teleport_wand_charge + 1;
      if teleport_wand_charge > 60 then
         teleport_wand_enchanted = true;
         Players[0]:print('テレポートの杖は今起動中です');
         Players[0]:play_sound(69, 1);
      end
   end
   if (sword_countdown > 0) then
      sword_countdown = sword_countdown - 1;
      if (sword_countdown <= 0) then
         sword_gone = true;
         set_terminal_text_number(385, 1185, 6);
         sword_light.active = true;
         Players[0]:fade_screen("white");
	 Music.fade(60/1000);
	 Music.play(merlin_theme);
         music = merlin_theme;
         if sword_index and sword_index.valid then
            sword_index:damage(10000, "suffocation");
            end
      elseif (math.modf(sword_countdown,500) == 0) and (spawn_cnt < 7)then
         Monsters.new(in_hall.x, in_hall.y, 0, in_hall, "ranger");
         Monsters.new(in_forest1.x, in_forest1.y, 0, in_forest1, "white knight");
         Monsters.new(in_forest2.x, in_forest2.y, 0,in_forest2, "novice sorcerer");
         Monsters.new(in_forest3.x, in_forest3.y, 0, in_forest3, "magus sorcerer");
         Monsters.new(in_forest4.x, in_forest4.y, 0, in_forest4, "soldier");
         spawn_cnt = spawn_cnt + 1;
      end
   end
   --[[  Do a special check on sword_gone, because the counter tends to get hosed when the player Cmd-Tabs out of application.  ]]
   if (not sword_gone) and (sword_countdown <= 0) and (merlin_state == "mariln3") then
      sword_countdown = 10;
   end
   if shake_timer > 0 then
      shake_timer = shake_timer + 1;
      if (shake_timer == 60) then
         Players[0]:fade_screen("long bright");
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
      if (shake_timer > 120) then
         shake_timer = 0;
      end
   end
   player_poly = Players[0].polygon.index;
   if (player_poly == lobby_poly) and (not guard_greeting) then
      guard_greeting = true;
      Players[0]:play_sound(256, 1);
      end
   if was_in_bathroom and (player_poly == bathroom_exit) then
      if hint_done then
         display_random_fart()
      else
         Players[0]:print('トイレの水を流すのを忘れていませんか？');
         hint_done = true;
      end
      Players[0]:play_sound(200, 1);
      was_in_bathroom = false;
   end
   if (not was_in_bathroom) and (player_poly == bathroom_poly) then
      was_in_bathroom = true;
   end
   if (player_poly == hq_sword_poly) and (not got_hq_sword) then
      got_hq_sword = true;
      Players[0].items["sword"] = 1;
      if hq_sword_index and hq_sword_index.valid then
	 hq_sword_index:damage(10000, "suffocation");
      end
      Players[0]:play_sound(62, 1);
   end
   if (player_poly == enchant_on_poly) and (not enchant_fade) then
      enchant_fade = true;
      MonsterTypes["crystal"].enemies["raptor"] = true;
      MonsterTypes["crystal"].friends["raptor"] = false;
   end
   if (player_poly == enchant_off_poly) and (enchant_fade) then
      enchant_fade = false;
      MonsterTypes["crystal"].enemies["raptor"] = false;
      MonsterTypes["crystal"].friends["raptor"] = true;
   end
   merlin_light_state = merlin_light.active;
   if (merlin_light_state ~= prev_light_state) and (merlin_state == -1) then
      Players[0]:activate_terminal(2);
      prev_light_state = merlin_light_state;
   end;
   if (merlin_light_state ~= prev_light_state) and (merlin_state == "merlin") then
      Players[0]:activate_terminal(3);
      prev_light_state = merlin_light_state;
   end
   if (merlin_light_state ~= prev_light_state) and (merlin_state == "merlin2") then
      Players[0]:activate_terminal(4);
      prev_light_state = merlin_light_state;
   end;
   if (merlin_light_state ~= prev_light_state) and (merlin_state == "mariln3") then
      Players[0]:activate_terminal(5);
      if (not has_teleport_wand) then
         Players[0].items["spear"] = 1;
         has_teleport_wand = true;
      end
      prev_light_state = merlin_light_state;
   end;
   if (not hall_open) and (Players[0].items["key"] > 0) then
      hall_door.active = true;
      hall_open = true;
      remove_items("key");
      Players[0]:print('あなたは今アバロンのホールにアクセスできます！');
      Players[0]:play_sound(17, 1);
   end
   if (player_poly ~= last_poly) then
      last_poly = player_poly;
      if (not key_found) and (player_poly == 413) then
         Players[0]:play_sound(254, 1);
         key_found = true;
      end
      if (player_poly == hud_activate) and (merlin_state == -1) then
         Players[0]:activate_terminal(2);
      end
      if ((player_poly == cottage_talk) and (merlin_state == "merlin") and 
    (not merlin_arrived)) then
         Players[0]:activate_terminal(3);
         merlin_arrived = true;
      end
      if ((player_poly == cottage_talk) and (merlin_state == "merlin2") and 
    (not almost_merlin)) then
         Players[0]:activate_terminal(4);
         almost_merlin = true;
      end
--[[
      if ((player_poly == cottage_talk) and (merlin_state == "mariln3") and 
    (not has_teleport_wand)) then
         Players[0]:activate_terminal(5);
         Players[0].items["spear"] = 1;
         has_teleport_wand = true;
      end
--]]
      if (not sword_gone) and (not got_hq_sword) and (Lights[29].active) then
         Lights[29].active = false;
         Players[0]:print('テレポートパッドを起動する前にエクスキャリバーを取ってください。');
      end;
      if (player_poly == teleport_poly) and (Lights[29].active) and got_hq_sword then
         Players[0]:teleport(camelot_poly);
         Level.fog.present = true;
         Level.fog.depth = 6;
	 Players[0].yaw = 270;
	 Players[0].pitch = 1024+360;
	 Music.fade(60/1000);
	 Music.play(merlin_theme);
         music = merlin_theme;
         if (crystal_ball == nil) then
            crystal_ball = Monsters.new(crystal_x, crystal_y, 0, crystal_poly, "crystal");
	 end
         if merlin_left then
	    Items.new(cottage_talk.x, cottage_talk.y, 0, cottage_talk, "spear");
	 end
      end
   end
end
       
function level_got_item(item, player)
   if (item == "sword") and sword_gone then
      remove_sword_flag = true;
   end
end

function level_projectile_detonated(type, owner, polygon, x, y, z)

   if (type == "lightning") then
      poly_type = polygon.type;
      if (poly_type == "must be explored") then
         Players[0]:print('その水は十\分深くありません。');
	 Players[0].items["sword"] = 1;
         sword_check = sword_failsafe;
         return;
      end
      if (poly_type ~= "goal") then
         Players[0]:print('エクスキャリバーを魔法の水へ投げなくてはなりません。');
	 Players[0].items["sword"] = 1;
         sword_check = sword_failsafe;
         return;
      end
      Players[0].items["sword"] = 0;
      sword_countdown = theme_length;
      sword_index = Monsters.new(polygon.x, polygon.y, 0, polygon, "sword");
      merlin_index = Monsters.new(merlinx, merliny, 0, cottage_poly, "merlin");
      merlin_index.yaw = 180;
      merlin_state = "merlin";
      Music.fade(60/1000);
      Music.play(sword_theme);
      music = sword_theme;
      Players[0]:fade_screen(0, "long bright");
      Players[0]:play_sound(168, 1);
      Players[0]:play_sound(226, 1);
      shake_timer = 1;
      enchant_door.active = true;
      Polygons[55].platform.active = true;
      Polygons[148].platform.active = true;
      Polygons[360].platform.active = true;
   end
   if (type == "fireball") then
      Players[0].items["wand"] = 0;
      if (sword_countdown > 0) then
         if message_wait <= 0 then
            Players[0]:print('あなたは湖のレディがエクスキャリーを受け取るのを待たなくてはなりません。');
            message_wait = 30;
	 end
	 Players[0].items["wand"] = 1;
         return;
      end
      if (polygon.index ~= cottage_poly) and (polygon.index ~= cottage2) and
         (polygon.index ~= cottage3) and (polygon.index ~= cottage4) and
         (polygon.index ~= cottage5) then
         if message_wait <= 0 then
            Players[0]:print('あなたはマーリンにこの呪文を投げなければなりません。');
            message_wait = 30;
	 end
         Players[0].items["wand"] = 1;
         return;
      end
      Players[0]:fade_screen("long bright");
      spell_of_life = true;
   end
   if (type == "freeze") then
      Players[0].items["spear"] = 0;
      if (not teleport_wand_enchanted) then
         if message_wait <= 0 then
            Players[0]:print('テレポートの杖は力を蓄えています...');
            message_wait = 30;
	 end
	 Players[0].items["spear"] = 1;
         return;
      end;
      if (not merlin_done) then
         Players[0]:print('マーリンが話している間にテレポートするのは失礼です。');
	 Players[0].items["spear"] = 1;
         return;
      end;
      if (sword_countdown > 0) then
         if message_wait <= 0 then
            Players[0]:print('あなたは湖のレディがエクスキャリーを受け取るのを待たなくてはなりません。');
            message_wait = 30;
	 end
         Players[0].items["spear"] = 1;
         return;
      end;
      Players[0]:play_sound(254, 1);
      Players[0]:fade_screen(0, "long bright");
      Lights[29].active = false;
      Players[0]:teleport(teleport_poly);
      load_fog(fog_save);
      Players[0].yaw = 0;
      Players[0].pitch = 360;
      Music.fade(60/1000);
      Music.play(end_theme);
      music = end_theme;
      if (not merlin_left) then
         merlin_left = true;
         if merlin_index and merlin_index.valid then
            merlin_index:damage(10000, "suffocation");
	 end
         merlin_index = -2;
         merlin_state = -2;
      end
   end
end

function level_monster_killed(monster, player, projectile)
   if (monster.type == "throne") then
      if (not player_enchanted) then
         player_enchanted = true;
         Players[0]:print('あなたは悟られました');
      end
      if enchant_fade then
         Players[0]:fade_screen("tint blue");
      end
      Monsters.new(enchant_poly.x, enchant_poly.y, 1, enchant_poly,"throne");
   end
end