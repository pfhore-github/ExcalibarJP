-- シナリオ編の共通スクリプト、二番目に実行される
interval_poison_damage = 4;
tolerance_coeff = .5;
max_poison_time = 30;    
poison_interval = 60;
poison_active = false;
last_weapon = -1;
underwater_timer = 0;
underwater_breath = 110;
underwater_death = false;
underwater_active = true;
railgun_in_action = false;
fog_save = {};
-- Fogデータの退避と復帰
function save_fog()
   local attributes = { 
      OGL_Fog_AboveLiquid = { 
	 Depth = Level.fog.depth, 
	 Color = { 
	    red = Level.fog.color.r, 
	    blue = Level.fog.color.b, 
	    green = Level.fog.color.g }, 
	 IsPresent = Level.fog.present, 
	 AffectsLandscapes = Level.fog.affects_landscapes }, 
      OGL_Fog_BelowLiquid = { 
	 Depth = Level.underwater_fog.depth, 
	 Color = { 
	    red = Level.underwater_fog.color.r, 
	    green = Level.underwater_fog.color.g, 
	    blue = Level.underwater_fog.color.b, }, 
	 IsPresent = Level.underwater_fog.present, 
	 AffectsLandscapes = Level.underwater_fog.affects_landscapes } } 
   return attributes 
end
function load_fog(t) 
   Level.fog.depth = t.OGL_Fog_AboveLiquid.Depth 
   Level.fog.present = t.OGL_Fog_AboveLiquid.IsPresent 
   Level.fog.affects_landscapes = t.OGL_Fog_AboveLiquid.AffectsLandscapes 
   Level.fog.color.r = t.OGL_Fog_AboveLiquid.Color.red 
   Level.fog.color.g = t.OGL_Fog_AboveLiquid.Color.green 
   Level.fog.color.b = t.OGL_Fog_AboveLiquid.Color.blue 
   Level.underwater_fog.depth = t.OGL_Fog_BelowLiquid.Depth 
   Level.underwater_fog.present = t.OGL_Fog_BelowLiquid.IsPresent 
   Level.underwater_fog.affects_landscapes = t.OGL_Fog_BelowLiquid.AffectsLandscapes 
   Level.underwater_fog.color.r = t.OGL_Fog_BelowLiquid.Color.red 
   Level.underwater_fog.color.g = t.OGL_Fog_BelowLiquid.Color.green 
   Level.underwater_fog.color.b = t.OGL_Fog_BelowLiquid.Color.blue 
end
function master_init(rs)
   for p in Players()  do
      p._poisoned = -1;
      p._poison_ticker = 1;
      p._poison_hits = 0;
      p._tolerance = 0;
   end
   crosshairs_prefs = Players[0].crosshairs.active;
end


function master_idle()
   -- 水面下の処理
   local life = Players[0].life;
   local under_media = Players[0].head_below_media
   if ( under_media and (underwater_timer == 0) and underwater_active ) then
      if (life > 0) then
	 Players[0]:play_sound(232, 1);
	 underwater_timer = underwater_breath;
      end
      if ( (life <= 0) and (not underwater_death) ) then
	 Players[0]:play_sound(224, 1);
	 underwater_death = true;
      end
   end
   if (underwater_timer > 0) then
      underwater_timer = underwater_timer - 1
   end

   -- フェーザーの照準表示
   
   cur_weapon = Players[0].weapons.current;
   if (cur_weapon ~= nil and cur_weapon.index ~= last_weapon) then
      if (last_weapon == WeaponTypes["phaser"].index ) then
	 Players[0].crosshairs.active = crosshairs_prefs;
      elseif (WeaponTypes["phaser"].index ) then
	 Players[0].crosshairs.active = true;
      end
      last_weapon = cur_weapon;
   end 

   --フェーザー以外の照準設定を保持する
   
   if cur_weapon ~= WeaponTypes["phaser"].index  then
      crosshairs_prefs = Players[0].crosshairs.active;
   end
   
   --毒の処理
   for p in Players() do
      if p.dead then
	 p._poisoned = -1;
      end
      if ( p._poisoned >= 0) then
	 p._poison_ticker = p._poison_ticker - 1
	 p._poisoned = p._poisoned - 1
	 if (p._poison_ticker <= 0) then
	    dmg = interval_poison_damage - (tolerance_coeff * p._tolerance);
	    p:damage(dmg,  "suffocation");
	    pt = p._poisoned/30;
	    p:play_sound(221, pt/max_poison_time);
	    level = math.floor(100*pt/max_poison_time + 0.5);
	    p.overlays[4].text = '毒性: '..level..'%';
	    p.overlays[4].color = "red";
	    p.overlays[4].icon = yuk_icon;
	    p._poison_ticker = poison_interval;
	 end
      end
      if ( p._poisoned <= 0) and poison_active then
	 load_fog(fog_save);
	 poison_active = false;
	 p._poisoned = -1;
	 p._poison_hits = 0;
	 if (p._tolerance < 9) then
	    p._tolerance = p._tolerance + 1
	    p:print('毒性は取り除かれた。毒への耐性が増えた。');
	 else
	    p:print('毒性は取り除かれた。');
	 end
	 p.overlays[4]:clear();
      end
   end
end

function master_player_damaged(victim_player, aggressor_player,       
				aggressor_monster, damage_type, 
				damage_amount, projectile)
   local life;
   local potions;
   
   --[[ Process emergency kits (should be ignored if railgun is in action --]]
   
   life = victim_player.life;
   potions = victim_player.items["epotion"];
   if (life < 50) and (potions > 0) and (not railgun_in_action) then
      victim_player:play_sound(19,1);
      victim_player.life = life + 2*full_health;
      victim_player.items["epotion"] = potions - 1;
   end
   
   --[[ Process poison damage --]]
   
   if ( (damage_type == "poison") and 
     (victim_player) and (not victim_player.dead)) then
      victim_player._poison_hits = victim_player._poison_hits + 1;
      pct = 15 + Game.global_random(2)*10 + Game.global_random(5);
      victim_player._poisoned = victim_player._poisoned + 
	 (max_poison_time*30)*pct/100;
      if (victim_player._poisoned > max_poison_time*30) then
	 victim_player._poisoned = max_poison_time*30;
      end
      victim_player._poison_ticker = 1;
      if (not poison_active) then
	 fog_save = save_fog();
	 Level.fog.present = true;
	 Level.fog.depth = 6;
	 Level.fog.color.r = 1.0;
	 Level.fog.color.g = 0.0;
	 Level.fog.color.b = 1.0;
	 poison_active = true;
      end
   end
end

function Triggers.got_item(item, player)
    if level_got_item ~= nil then
        level_got_item(item, player)
    elseif common_got_item ~= nil then
        common_got_item(item, player)
    end
   if (item == "health") then
      player:play_sound(229,1);
   end
   if (item == "antidote") then
      player:play_sound(19,1);
      if poison_active then
	 player:play_sound(229,1);
	 player._poisoned = -1;
      end
      if (player._tolerance == nil or player._tolerance < 9) and (not poison_active) then
      if player._tolerance == nil then
      	player._tolerance = 1
      	else
		 player._tolerance = player._tolerance + 1
		 end
	 player:print('毒への耐性が増えた。')
      end
   end
end
-- ターミナルの変更
function set_terminal_text_number(poly, line, id) 
   if Lines[line].ccw_polygon ~= nil and Lines[line].ccw_polygon.index == poly then 
      s = Lines[line].ccw_side 
   elseif Lines[line].cw_polygon ~= nil and Lines[line].cw_polygon.index == poly then 
      s = Lines[line].cw_side 
   else 
      return 
   end 
   if s.control_panel and s.control_panel.type.class == 8 then 
      s.control_panel.permutation = id 
   end 
end
-- 取得音
function got_item_sound(item, player, table, sound)
   for i, v in ipairs(table) do
      if( item == v ) then
	 player:play_sound(sound,1);
      end
   end
end

function Triggers.player_damaged(victim_player, aggressor_player,       
				aggressor_monster, damage_type, 
				damage_amount, projectile)
	master_player_damaged(victim_player, aggressor_player,       
				aggressor_monster, damage_type, 
				damage_amount, projectile);
    if level_player_damaged ~= nil then
        level_player_damaged(victim_player, aggressor_player,       
				aggressor_monster, damage_type, 
				damage_amount, projectile)
	end
end

function Triggers.monster_killed(victim, victor, projectile)
	if common_monster_killed ~= nil then
		common_monster_killed(victim, victor, projectile);
	end
	if level_monster_killed ~= nil then
		level_monster_killed(victim, victor, projectile);
	end
end


