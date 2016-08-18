songs = {"Cavern/Merlin's Funk.mp3", "Cavern/M01.mp3", "Cavern/M15.mp3"};
camelot_music = "Cavern/M11.mp3";
clone_music = "Cavern/Clones.mp3";
raptor_music = "Cavern/M04.mp3";
spewie_music = "Cavern/Burn.mp3";
enter_8b = 755;
enter_8 = 747;
exit_8b = 756;
exit_8 = 748;
in_holodeck8 = false;
in_holodeck8b = false;
in_holodeck9 = false;
in_holodeck10 = false;
holodeck8_enter = 81;
holodeck8_exit = 750;
holodeck8b_enter = 629;
holodeck8b_exit = 753;
holodeck9_enter = 111;
holodeck9_exit = 70;
holodeck10_enter = 172;
holodeck10_exit = 75;
tiny_bot_poly = 649;  --[[ Angle 90 degrees --]]
tiny_bot = nil;
marcel_bot_poly = 662;  --[[ Angle 90 degrees --]]

marcel_bot = nil;
tiny_kills = 0;
marcel_kills = 0;
player_kills = 0;
clones = { { 635, 90, -30.5, -29.5 },
                { 676, 180, -13.5, -27.5 },
                { 671, 0, -25.5, -21.5 },
                { 636, 0, -29.5, -25.5 },
                { 670, 270, -22.5, -19.5 },
                { 669, 180, -20.5, -21.5 },
                { 677, 90, -14.5, -28.5 },
                { 678, 180, -14.5, -22.5 },
                { 639, 0, -29.5, -23.5 } };
clone_timer = 0;
clone_wait = 3*30;
start_gallery = 81;
end_gallery = 750;
gallery_on = false;
gallery_shots = 0;
gallery_kills = 0;
gallery_score = 0;
items_to_restore = {};
holodeck_8b = false;
start_clones = 629;
end_clones = 753;
clones_on = false;
xtimer = 0;
xwait = 60;
holo8_term_poly = 80;
holo8_term_line = 349;
sickbay_term_alt = 7;
eng_term_alt = 8;
holo8_term_alt = 9;
holo8b_term = 10;
clone_gallery = 630;
holo9_term_alt = 11;
holo10_term_alt = 12;
bridge_term_alt = 13;
exit_active = false;
teleport_poly = 775;
last_loc = -1;


function level_init (rs)
MonsterTypes["shadow sorcerer"].mnemonic = "tiny bot";
MonsterTypes["magus sorcerer"].mnemonic = "marcel bot";
ItemTypes["spear"].mnemonic = "axe";
ItemTypes["crossbow"].mnemonic = "railgun";
ItemTypes["nightvision"].mnemonic = "tiny module";
ItemTypes["vial"].mnemonic = "water vial";
--Players[0].items["tiny module"] = 1;
door_8b = find_platform(754);
door_8 = find_platform(749);
music_box = find_platform(757);
holo8_entrance = find_platform(92);
holodeck_switch = find_platform(763);
teleport_light = Lights[53];
bridge_light = Lights[55];

   has_tiny = ( Players[0].items["tiny module"] > 0 );
   if has_tiny then
      set_terminal_text_number(7, 36, sickbay_term_alt);
      set_terminal_text_number(151, 226, eng_term_alt);
      set_terminal_text_number(holo8_term_poly, holo8_term_line, holo8_term_alt);
      set_terminal_text_number(152, 612, holo9_term_alt);
      set_terminal_text_number(153, 615, holo10_term_alt);
      set_terminal_text_number(425, 1361, bridge_term_alt);
   end
   song_playing = 1;
   Music.play(songs[song_playing]);
   music_playing = true;
   restoring_saved = rs;
   Players[0]:play_sound(248, 1);
   if rs then
      return;
   end
   remove_items("sword", "axe");
end

function store_inventory(keep_item)

   items_to_remove = {
      "snyper",
      "spear",
      "dachron",
      "crossbow",
      "phaser",
      "sword",
      "wand",
      "hightech"
   }
   items_to_restore = {};

   for i, v in ipairs(items_to_remove) do 
      if (v ~= keep_item) then	 
         for j = 1, Players[0].items[v], 1 do
            table.insert(items_to_restore, items_to_remove[i]);
	 end
	 Players[0].items[v] = 0;
      end
   end 
   Players[0].items["water vial"] = 0;
end

function load_inventory()
   for i, v in ipairs(items_to_restore) do 
      Players[0].items[v] = Players[0].items[v] + 1;
   end
end

function launch_clone()

   idx = 1+Game.global_random (# clones);
   while (idx == last_clone1) or (idx == last_clone2) or (idx == last_clone3) do
      idx = idx + 1;
      if idx > # clones then
         idx = 1;
      end
   end
   last_clone3 = last_clone2;
   last_clone2 = last_clone1;
   last_clone1 = idx;
   --[[   Players[0]:print('クローン生成 - クローン番号'..idx); ]]
   local m = Monsters.new(clones[idx][3], clones[idx][4], 0, clones[idx][1], "clone");
   m.yaw = clones[idx][2];
end

function level_idle ()

   if teleport_light.active and (not exit_active) then
      exit_active = true;
      Players[0]:print('静止棒はレース・夢プログラムにセットされました');
      Players[0]:print('睡眠室に入ることができます');
      Players[0]:play_sound(15, 1);
      end
   if (loc ~= teleport_poly) and (not teleport_light.active) and exit_active then
      exit_active = false;
      Players[0]:print('睡眠室は無効化されました');
      Players[0]:play_sound(131, 1);
   end
   if Lights[51].active and (xtimer == 0) then
      if has_tiny then
         xtimer = xwait;
         holodeck_switch.active = true;
         Players[0]:play_sound(15, 1);
         holodeck_8b = not holodeck_8b;
         if holodeck_8b then
            Players[0]:print('ホロデッキプログラム 「Tiny X」をロード中...');
         else
            Players[0]:print('ホロデッキプログラム「ラプトル・ギャラリー」をロード中...');
	 end
      else
         Lights[41].active = false;
         Players[0]:print('ホロデッキＸを起動する適切なモジュールを持っていません');
         end
      end
   if xtimer > 0 then
      xtimer = xtimer - 1;
      if xtimer == 0 then
         if holodeck_8b then
            Players[0]:print('ホロデッキプログラム 「Tiny X」ロード完了');
            set_terminal_text_number(holo8_term_poly, holo8_term_line, holo8b_term);
         else
            Players[0]:print('ホロデッキプログラム「ラプトル・ギャラリー」ロード完了');
            set_terminal_text_number(holo8_term_poly, holo8_term_line, holo8_term_alt);
	 end
	 holo8_entrance.active = true;
	 Lights[51].active = false;
      elseif holo8_entrance.active then
         holo8_entrance.active = false;
         Players[0]:print('ホロデッキは準備できていません - アクセス拒否');      
         Players[0]:play_sound(26, 1);
      end
   end  
   loc = Players[0].polygon.index;
   if (in_holodeck8) and (loc == holodeck8_exit) then
      Music.fade(60/1000);
      Music.play(songs[song_playing]);
      in_holodeck8 = false;
   end
   if (not in_holodeck8) and (loc == holodeck8_enter) then
      Music.fade(60/1000);
      Music.play(raptor_music);
      in_holodeck8 = true;
   end
   if (in_holodeck8b) and (loc == holodeck8b_exit) then
      Music.fade(60/1000);
      Music.play(songs[song_playing]);
      in_holodeck8b = false;
   end
   if (not in_holodeck8b) and (loc == holodeck8b_enter) then
      Music.fade(60/1000);
      Music.play(clone_music);
      in_holodeck8b = true;
   end
   if (in_holodeck9) and (loc == holodeck9_exit) then
      Music.fade(60/1000);
      Music.play(songs[song_playing]);
      in_holodeck9 = false;
   end
   if (not in_holodeck9) and (loc == holodeck9_enter) then
      Music.fade(60/1000);
      Music.play(camelot_music);
      in_holodeck9 = true;
   end
   if (in_holodeck10) and (loc == holodeck10_exit) then
      Music.fade(60/1000);
      Music.play(songs[song_playing]);
      in_holodeck10 = false;
   end
   if (not in_holodeck10) and (loc == holodeck10_enter) then
      Music.fade(60/1000);
      Music.play(spewie_music);
      in_holodeck10 = true;
   end
   if door_8.active and (not door_8b.active) then
      door_8b.active = true;
   end
   holodeck_switching = holodeck_switch.active;
   if loc ~= last_loc then
      last_loc = loc;
      if (loc == clone_gallery) and (not bridge_light.active) then
         bridge_light.active = true;
      end
      if (loc == teleport_poly) and teleport_light.active then
         teleport_light.active = false;
         Players[0]:teleport_to_level(41);
      end
      if (loc == exit_8) and holodeck_8b then
         Players[0]:position(-22.375, -31.5, 0, enter_8b);
      elseif loc == exit_8b then
         Players[0]:position(-7.875, 8.25, 2.0, enter_8);
      end
   end
   if (loc == start_clones) and (not clones_on) then
      clones_on = true;
      store_inventory("railgun");
      tiny_bot = Monsters.new(tiny_bot_poly.x, tiny_bot_poly.y, 0, tiny_bot_poly, "tiny bot");
      tiny_bot.yaw = 90;
      marcel_bot = Monsters.new(marcel_bot_poly.x, marcel_bot_poly.y, 0, marcel_bot_poly, "marvel bot");
      marcel_bot.yaw = 90;
      tiny_kills = 0;
      marcel_kills = 0;
      player_kills = 0;
   end
   if (loc == end_clones) and (clones_on) then
      clones_on = false;
      load_inventory();
      Players[0]:print('クローンプログラム終了');
      Players[0]:print('プレーヤーの点数は = '..player_kills);
      Players[0]:print('マーセルの点数は = '..marcel_kills);
      Players[0]:print('タイニーの点数は = '..tiny_kills);
      if tiny_bot and tiny_bot.valid then
         tiny_bot:damage(400, "suffocation");
      end
      if marcel_bot and marcel_bot.valid then
         marcel_bot:damage(400, "suffocation");
      end
   end
   if clones_on then
      clone_timer = clone_timer + 1;
      if clone_timer >= clone_wait then
         clone_timer = 0;
         launch_clone();
         launch_clone();
         launch_clone();
      end
   end
   if (loc == start_gallery) and (not gallery_on) then
      gallery_on = true;
      gallery_shots = 0;
      gallery_kills = 0;
      gallery_score = 0;
      store_inventory("snyper");
      Players[0]:print('灰色と緑は１点');
      Players[0]:print('金は５点');
      Players[0]:print('赤は１０点');
   end
   if (loc == end_gallery) and (gallery_on) then
      gallery_on = false;
      load_inventory();
      Players[0]:print('ラプトル・ギャラリー・プログラム終了');
      Players[0]:print('合計発射数： '..gallery_shots);
      Players[0]:print('合計殺数： '..gallery_kills);
      if gallery_shots > 0 then
         ratio = math.floor(100 * gallery_kills / gallery_shots);
         Players[0]:print('命中率：'..ratio..'%');
      end
      Players[0]:print('合計点： '..gallery_score);
      end
   if music_playing and (music_box.active) then
      music_playing = false;
      Music.fade(60/1000);
   end
   if (not music_playing) and (not music_box.active) then
      song_playing = song_playing + 1;
      if song_playing > # songs  then
         song_playing = 1;
      end
      Music.play(songs[song_playing]);
      music_playing = true;
   end
end

function level_monster_killed(monster, player, shot)

   mtype = monster.type;
   if ((mtype == "minor dinobug") or (mtype == "major dinobug")) and gallery_on then
      gallery_kills = gallery_kills + 1;
      gallery_score = gallery_score + 1;
      Players[0]:print('得点！  (１点)');
      end
   if (mtype == "minor raptor") and gallery_on then
      gallery_kills = gallery_kills + 1;
      gallery_score = gallery_score + 5;
      Players[0]:print('得点！  (5 点)');
      end
   if (mtype == "major raptor") and gallery_on then
      gallery_kills = gallery_kills + 1;
      gallery_score = gallery_score + 10;
      Players[0]:print('得点！  (10 点)');
      end
   if (mtype == "clone") and clones_on then
      owner = shot.owner;
      p = Players[0].monster;
      if owner == tiny_bot then
         tiny_kills = tiny_kills + 1;
         Players[0]:print('タイニーの得点！');
      elseif owner == marcel_bot then
         marcel_kills = marcel_kills + 1;
         Players[0]:print('マーセルの得点！');
      elseif owner == p then
         player_kills = player_kills + 1;
         Players[0]:print('プレーヤーの得点！');
      else
         Players[0]:print('未知の加害者！ ('..owner..')');
      end
   end
   if (mtype == "tiny bot") and (clones_on) then
      tiny_bot = Monsters.new(tiny_bot_poly.x, tiny_bot_poly.y, 0, tiny_bot_poly, "tiny bot");
      tiny_bot.yaw = 90;
   end
   if (mtype == "marcel bot") and (clones_on) then
      marcel_bot = Monsters.new(marcel_bot_poly.x, marcel_bot_poly.y, 0, marcel_bot_poly, "marvel bot");
      marcel_bot.yaw = 90;
   end
end

function level_projectile_detonated(type, owner, polygon, x, y, z)
   p = Players[0].monster;
   if (type == "snyper bullet") and (owner ~= nil and owner.index == p.index) and gallery_on then
      gallery_shots = gallery_shots + 1;
   end
end

function level_got_item(item, player)
   if (item == "sword") then
      player.items["water vial"] = player.items["water vial"] + 200;
   end
end

