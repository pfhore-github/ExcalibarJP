-- 汎用スクリプト
Triggers = {};


monsters_name = {
["spewie"]="SPEWIE",
["barrel"]="樽",
["exploding barrel"]="爆発してる樽",
["novice sorcerer"]="マイナー魔法使い",
["magus sorcerer"]="メジャー魔法使い",
["shadow sorcerer"]="霊体魔法使い",
["master wizard"]="モーベア",
["future bob"]="連合軍戦士",
["soldier"]="悪の兵士",
["minor archer"]="射手",
["major archer"]="金髪の射手",
["cave bob"]="グロッグ",
["white knight"]="白馬の騎士",
["ranger"]="レンジャー",
["clone"]="フォラジェ・クローン",
["minor dinobug"]="ダイノバグ",
["major dinobug"]="吐くダイノバク",
["minor raptor"]="ラプトル",
["major raptor"]="メスのラプトル",
["dimorph"]="ダイモルフォドン",
["skull snake"]="骸骨蛇",
["fire beast"]="翼のある火炎獣",
["hover gat"]="空飛ぶ騎兵",
["bike cop"]="バイク警官",
["trex"]="ティラノサウルス",
["cleric"]="悪の牧師",
["lesser knight"]="闇の騎士",
["black knight"]="黒い騎士",
["minor gat"]="GAT",
["major gat"]="メジャーGAT",
["morgana"]="モルガナ",
["mordred"]="モードレッド",
["spider"]="モルガナの偵察兵",
["piranha"]="ピラニア",
["evil tree"]="襲う木",
["throne"]="王座（破壊者！）",
["wooden table"]="テーブル（破壊者！）",
["minor spam"]="スパムメカ",
["major spam"]="ミサイルスパムメカ",
["wooden chair"]="椅子（破壊者！）",
["maint bob"]="整備士",
["metal bar"]="破壊可能な棒",
["raptor eggs"]="ラプトルの卵",
["torch"]="燃えているたいまつ",
["fire"]="地獄の炎",
["laser turret"]="守護者のやぐら"
}

projectiles = {
["missile"]="ハイテクミサイル",
["grenade"]="グレネード",
["snyper bullet"]="スナイパー",
["dachron bullet"]="ダクロン",
["white eye bolt"]="目の電光",
["sword melee"]="剣",
["green eye bolt"]="目の電光",
["fireblast"]="炎",
["fireball"]="火の玉",
["freeze"]="冷たい冷気",
["healing"]="バンドエイド",
["excalibur"]="魔法の剣",
["lightning"]="雷光",
["plasma"]="プラズマ",
["blades"]="削除",
["bone"]="骨",
["rock"]="岩",
["guided micromissile"]="誘導マイクロミサイル",
["evil arrow"]="矢",
["crossbow bolt"]="石弓",
["knife"]="ナイフ",
["venom bite"]="有毒な噛み",
["venom spit"]="有毒な汚物",
["claw rip"]="剃刀のようなかぎづめ",
["laser turret"]="レーザービーム",
["micromissile"]="マイクロミサイル",
["drain"]="エネルギー吸収",
["photon"]="光子グレネード",
["trex chomp"]="大きな噛み付き",
["spear"]="やり",
["sting"]="突き刺し",
["ball"]="ボール",
["electrical short"]="短い電撃",
["electrical blast"]="電撃の爆発",
["overload"]="詰め過ぎ",
["raptor bite"]="攻撃的な噛み",
["phaser"]="フェーザー",
["morgana spell"]="悪の呪文",
["special"]="謎の呪文"
}




yuk_icon = [[
3
*0000FF
#000000
 FFFFFF
################
##    ####    ##
#####  ##  #####
################
################
#####  ##  #####
#####  ##  #####
################
################
#######  #######
#####      #####
###    ##    ###
###    ##    ###
##   # ## #   ##
## ###    ### ##
#######  #######
]];
skull_icon = [[
3
*0000FF
#000000
 FFFFFF
#####      #####
###          ###
###          ###
###  ##  ##  ###
###  ##  ##  ###
###          ###
###    ##    ###
######    ######
###### ## ######
# ####    #### #
#    ######    #
###          ###
######    ######
#      ##      #
# ############ #
################
]];

function remove_items(item, ...)
   for p in Players() do
      p.items[item] = 0;
   end
   if( ... ) then
      remove_items(...)
   end
end

function remove_monsters(monster_type)
   for g in Monsters() do
      if (g.type == monster_type) then
	 g:damage(g.vitality+1, "suffocation");
      end
   end
end

function enemies_left(player, buffer)
   local cnt = 0;
   for g in Monsters() do
      if (g ~= player.monster) then
	 local mtype = g.type;
	 if (mtype ~= "fire") and (mtype ~= "torch") then
	    if mtype.enemies["player"] then
	       cnt = cnt + 1;
	    end
	 end
      end
   end
   if buffer then
      cnt = cnt - buffer;
      if cnt < 0 then
	 cnt = 0;
      end
   end
   return cnt;
end


function random_select(num, base)
   local ret, reg = {}, {};
   if num > base then
      Players:print('RANDOM_SELECT();への間違った呼び出し: '..num..' > '..base);
      num = base;
   end
   while (# ret < num) do
      local n = 1 + Game.global_random (base);
      if (not reg[n]) then
	 table.insert(ret, n);
	 reg[n] = true;
      end
   end
   return ret;
end

function find_polygon(search_text)
  for anno in Annotations() do
    if (search_text == anno.text) then 
      return anno.polygon 
    end
  end
  return nil
end

function find_platform(index)
    for plat in Platforms() do
        if( plat.polygon.index == index ) then
            return plat;
        end
    end
    return nil
end

function get_monster_name(monster)
  for p in Players() do
    if ( p.monster == monster) then
      return p.name;
    end
  end
  return monsters_name[monster.type];
end

function Triggers.cleanup()
    if ctf_cleanup ~= nil then
        ctf_cleanup();
    end
    if level_cleanup ~= nil then
        level_cleanup();
    end
  Level.fog.present = false;
  for p in Players() do 
    if p.local_ then
      p.crosshairs.active = false;
      p.overlays[0]:clear();
      p.overlays[1]:clear();
      p:print("");
      p:print("");
      p:print("");
      p:print("");
      p:print("");
      p:print("");
      p:print("");
      p:print("");
    end
  end
end
--[[
This script was written for EMR by Solra Bizna. Players and monsters with 
class player will not show up on the threat indicator. Any monster with the 
"enemy" flag set for the player will show up.  Inspired by Ghost Recon.

Updated by Bill Catambay to make it its own function, establish a radar
range using 3D measurement, and supports arguments for danger distance
and range distance.   Also added an argument for ignore_poly (ignore all monsters
on this poly) and an argument for dividing the grid into hemispheres via an x-point.
When player is in one hemisphere, it ignores the other.
]]

dangers = { tick_count = 20, tick = 0 };
danger_compass = false;
function dist2(v1, v2)
   local d = (v1.x-v2.x)*(v1.x-v2.x);
   d = d + ( v1.y-v2.y)*(v1.y-v2.y);   
   return math.sqrt(d);
end

function dist3(v1, v2)
   local d = (v1.x-v2.x)*(v1.x-v2.x);
   d = d + ( v1.y-v2.y)*(v1.y-v2.y);   
   d = d + ( v1.z-v2.z)*(v1.z-v2.z);   
   return math.sqrt(d);
end

function idle_danger(dangerdist, range, ignore_poly, x_divide, display_stat)
   if not ignore_poly then
      ignore_poly = nil;
   end
   if x_divide then
      divide_plane = x_divide / 1024;
      hemis_check = true;
   else
      divide_plane = 1000;
      hemis_check = false;
   end
   dangers.tick = dangers.tick + 1;
   if (dangers.tick >= dangers.tick_count) then 
      dangers.tick = 0 ;
   end
   for p in Players() do
      if (p.dead) then
	 p.compass.lua = false; --[[ no compass if dead --]]
      else
	 p.compass.lua = true;--[[ enable compass if alive, then set it up: --]]
	 local face = p.yaw;  --[[ angle offset --]]
	 local mindist = 128;    --[[ well above the maximum possible distance in an A1 map --]]
	 local mcnt = 0;
	 for m in Monsters() do
	    --[[ 
	    NOTE: ignore friendlies and monsters on the opposite side of 
	    x = divide_plane also ignore monsters that are not visible
	    ]]
	    if (m.visible and (m.type.class ~= "player") and 
	     (m.type.class ~= "environment") and 
	  (m.type.enemies["player"])) then
	       mcnt = mcnt + 1;
	       local d = dist3(m,p);
	       local dd = dist2(m,p);
	       in_hemisphere = ((not hemis_check) 
			     or ((m.x < divide_plane) and (p.x < divide_plane)) or
			  ((m.x > divide_plane) and (p.x > divide_plane)));
	       in_range = ((d < range) and (m.polygon ~= ignore_poly) 
		     and in_hemisphere);
	       if (d < mindist) and (in_range) then 
		  mindist = d;
	       end
	       --[[
	       NOTE: if we have one monster close enough to trigger danger
	       mode, we early-out as further information won`t change it 
	       --]]
	       if (mindist <= dangerdist) then 
		  break;
	       end
	       --         NOTE: Mis-ordering is intentional 
	       local ang = math.atan2(m.y-p.y,m.x-p.x) * 180 / math.pi - face;
	       --         NOTE: normalize the angle 
	       while (ang < 0) do 
		  ang = ang + 360;
	       end
	       while (ang >= 360) do 
		  ang = ang - 360;
	       end
	       if ((ang < 100) or (ang > 350)) and in_range then 
		  p.compass.ne = true;
	       end
	       if (ang < 190) and (ang > 80) and in_range then 
		  p.compass.se = true;
	       end
	       if (ang < 280) and (ang > 170) and in_range then 
		  p.compass.sw = true;
	       end
	       if ((ang < 10) or (ang > 260)) and in_range then
		  p.compass.nw = true;
	       end
	    end
	 end
	 if display_stat then
	    local msg;
	    if (mindist <= dangerdist) and in_range then
	       msg = '危険';
	       if (dangers.tick < dangers.tick_count / 2) then
		  p.overlays[0].color = "red";
	       else
		  p.overlays[0].color = "dark red";
	       end
	    elseif (mindist <= range/2) and in_range then
	       msg = '接近';
	       p.overlays[0].color = "yellow";
	    elseif in_range then
	       msg = '範囲内';
	       p.overlays[0].color = "white";
	    elseif mcnt > 0 then
	       msg = '範囲外';
	       p.overlays[0].color = "cyan";
	    else
	       msg = '敵無し';
	       p.overlays[0].color = "green";
	    end
	    p.overlays[0].text = '敵センサー: '.. msg;
	    p.overlays[1].text = math.floor(mindist*100)/100;
	 end
	 if (mindist <= dangerdist) then  --[[ danger mode, flashing indicator--]]
	    if (dangers.tick < dangers.tick_count / 2) then
	       p.compass:all_off();
	    else
	       p.compass:all_on();
	    end
	 end
      end
   end
end

function new_monster_at(t, poly, face)
   local realpoly;
   local m;
   if( type(poly) == "number") then
      realpoly = Polygons[poly];
   else
      realpoly = poly;
   end
   m = Monsters.new(realpoly.x, realpoly.y, 0, realpoly, t);
   if( face ) then
      m.yaw = face;
   end
end

function new_item_at(t, poly)
   local realpoly;
   if( type(poly) == "number") then
      realpoly = Polygons[poly];
   else
      realpoly = poly;
   end
   return Items.new(realpoly.x, realpoly.y, 0, realpoly, t);
end

function Triggers.init(rs)
	
	WeaponTypes["fist"].mnemonic = "kunckles";
	WeaponTypes["pistol"].mnemonic = "snyper";
	WeaponTypes["fusion pistol"].mnemonic = "crossbow";
	WeaponTypes["assault rifle"].mnemonic = "dachron";
	WeaponTypes["missile launcher"].mnemonic = "hightech";
	WeaponTypes["flamethrower"].mnemonic = "phaser";
	WeaponTypes["alien weapon"].mnemonic = "excalibur";
	WeaponTypes["shotgun"].mnemonic = "spear";
	WeaponTypes["smg"].mnemonic = "wand";

	ItemTypes["knife"].mnemonic = "knuckles";
	ItemTypes["pistol"].mnemonic = "snyper";
	ItemTypes["pistol ammo"].mnemonic = "snyper ammo";
	ItemTypes["fusion pistol"].mnemonic = "crossbow";
	ItemTypes["fusion pistol ammo"].mnemonic = "crossbow bolts";
	ItemTypes["assault rifle"].mnemonic = "dachron";
	ItemTypes["assault rifle ammo"].mnemonic = "dachron ammo";
	ItemTypes["assault rifle grenades"].mnemonic = "plasma pak";
	ItemTypes["missile launcher"].mnemonic = "hightech";
	ItemTypes["missile launcher ammo"].mnemonic = "missiles";
	ItemTypes["invisibility"].mnemonic = "invisible";
	ItemTypes["invincibility"].mnemonic = "invincible";
	ItemTypes["infravision"].mnemonic = "nightvision";
	ItemTypes["alien weapon"].mnemonic = "sword";
	ItemTypes["alien weapon ammo"].mnemonic = "magic scroll";
	ItemTypes["flamethrower"].mnemonic = "phaser";
	ItemTypes["flamethrower ammo"].mnemonic = "phaser pak";
	ItemTypes["extravision"].mnemonic = "antidote";
	ItemTypes["oxygen"].mnemonic = "epotion";
	ItemTypes["single health"].mnemonic = "health";
	ItemTypes["double health"].mnemonic = "2x powerup";
	ItemTypes["triple health"].mnemonic = "3x powerup";
	ItemTypes["shotgun"].mnemonic = "spear";
	ItemTypes["shotgun ammo"].mnemonic = "vial";
	ItemTypes["key"].mnemonic = "sap card";
	ItemTypes["uplink chip"].mnemonic = "key";
	ItemTypes["smg"].mnemonic = "wand";
	ItemTypes["smg ammo"].mnemonic = "rocks";


	MonsterTypes["minor tick"].mnemonic = "spewie";
	MonsterTypes["major tick"].mnemonic = "barrel";
	MonsterTypes["kamikaze tick"].mnemonic = "exploding barrel";
	MonsterTypes["minor compiler"].mnemonic = "novice sorcerer";
	MonsterTypes["major compiler"].mnemonic = "magus sorcerer";
	MonsterTypes["minor invisible compiler"].mnemonic = "shadow sorcerer";
	MonsterTypes["major invisible compiler"].mnemonic = "master wizard";
	MonsterTypes["minor fighter"].mnemonic = "future bob";
	MonsterTypes["major fighter"].mnemonic = "soldier";
	MonsterTypes["minor projectile fighter"].mnemonic = "minor archer";
	MonsterTypes["major projectile fighter"].mnemonic = "major archer";
	MonsterTypes["green bob"].mnemonic = "cave bob";
	MonsterTypes["blue bob"].mnemonic = "white knight";
	MonsterTypes["security bob"].mnemonic = "ranger";
	MonsterTypes["explodabob"].mnemonic = "clone";
	MonsterTypes["minor drone"].mnemonic = "minor dinobug";
	MonsterTypes["major drone"].mnemonic = "major dinobug";
	MonsterTypes["big minor drone"].mnemonic = "minor raptor";
	MonsterTypes["big major drone"].mnemonic = "major raptor";
	MonsterTypes["possessed drone"].mnemonic = "dimorph";
	MonsterTypes["minor cyborg"].mnemonic = "skull snake";
	MonsterTypes["major cyborg"].mnemonic = "fire beast";
	MonsterTypes["minor flame cyborg"].mnemonic = "hover gat";
	MonsterTypes["major flame cyborg"].mnemonic = "bike cop";
	MonsterTypes["minor enforcer"].mnemonic = "trex";
	MonsterTypes["major enforcer"].mnemonic = "cleric";
	MonsterTypes["minor hunter"].mnemonic = "lesser knight";
	MonsterTypes["major hunter"].mnemonic = "black knight";
	MonsterTypes["minor trooper"].mnemonic = "minor gat";
	MonsterTypes["major trooper"].mnemonic = "major gat";
	MonsterTypes["mother of all cyborgs"].mnemonic = "morgana";
	MonsterTypes["mother of all hunters"].mnemonic = "mordred";
	MonsterTypes["sewage yeti"].mnemonic = "spider";
	MonsterTypes["water yeti"].mnemonic = "piranha";
	MonsterTypes["lava yeti"].mnemonic = "evil tree";
	MonsterTypes["minor defender"].mnemonic = "throne";
	MonsterTypes["major defender"].mnemonic = "wooden table";
	MonsterTypes["minor juggernaut"].mnemonic = "minor spam";
	MonsterTypes["major juggernaut"].mnemonic = "major spam";
	MonsterTypes["tiny pfhor"].mnemonic = "wooden chair";
	MonsterTypes["tiny bob"].mnemonic = "maint bob";
	MonsterTypes["tiny yeti"].mnemonic = "metal bar";
	MonsterTypes["green vacbob"].mnemonic = "raptor eggs";
	MonsterTypes["blue vacbob"].mnemonic = "torch";
	MonsterTypes["security vacbob"].mnemonic = "fire";
	MonsterTypes["explodavacbob"].mnemonic = "laser turret";

	MonsterClasses["player"].mnemonic = "player";
	MonsterClasses["bob"].mnemonic = "friend";
	MonsterClasses["madd"].mnemonic = "raptor";
	MonsterClasses["possessed drone"].mnemonic = "dimorphodon";
	MonsterClasses["defender"].mnemonic = "trex";
	MonsterClasses["fighter"].mnemonic = "archer";
	MonsterClasses["trooper"].mnemonic = "sorcerer";
	MonsterClasses["hunter"].mnemonic = "knight";
	MonsterClasses["enforcer"].mnemonic = "beast";
	MonsterClasses["juggernaut"].mnemonic = "spam";
	MonsterClasses["compiler"].mnemonic = "futurebob";
	MonsterClasses["drone"].mnemonic = "spewie";
	MonsterClasses["cyborg"].mnemonic = "gat";
	MonsterClasses["explodabob"].mnemonic = "clone";
	MonsterClasses["tick"].mnemonic = "bosses";
	MonsterClasses["yeti"].mnemonic = "environment";

	ProjectileTypes["missile"].mnemonic = "missile";
	ProjectileTypes["grenade"].mnemonic = "grenade";
	ProjectileTypes["pistol bullet"].mnemonic = "snyper bullet";
	ProjectileTypes["rifle bullet"].mnemonic = "dachron bullet";
	ProjectileTypes["shotgun bullet"].mnemonic = "white eye bolt";
	ProjectileTypes["staff"].mnemonic = "sword melee";
	ProjectileTypes["staff bolt"].mnemonic = "green eye bolt";
	ProjectileTypes["flamethrower burst"].mnemonic = "fireblast";
	ProjectileTypes["compiler bolt minor"].mnemonic = "fireball";
	ProjectileTypes["compiler bolt major"].mnemonic = "freeze";
	ProjectileTypes["alien weapon"].mnemonic = "healing";
	ProjectileTypes["fusion bolt minor"].mnemonic = "excalibur";
	ProjectileTypes["fusion bolt major"].mnemonic = "lightning";
	ProjectileTypes["hunter"].mnemonic = "plasma";
	ProjectileTypes["fist"].mnemonic = "blades";
	ProjectileTypes["armageddon sphere"].mnemonic = "bone";
	ProjectileTypes["armageddon electricity"].mnemonic = "rock";
	ProjectileTypes["juggernaut rocket"].mnemonic = "guided micromissile";
	ProjectileTypes["trooper bullet"].mnemonic = "evil arrow";
	ProjectileTypes["trooper grenade"].mnemonic = "crossbow bolt";
	ProjectileTypes["minor defender"].mnemonic = "knife";
	ProjectileTypes["major defender"].mnemonic = "venom bite";
	ProjectileTypes["juggernaut missile"].mnemonic = "venom spit";
	ProjectileTypes["minor energy drain"].mnemonic = "claw rip";
	ProjectileTypes["major energy drain"].mnemonic = "laser turret";
	ProjectileTypes["oxygen drain"].mnemonic = "micromissile";
	ProjectileTypes["minor hummer"].mnemonic = "drain";
	ProjectileTypes["major hummer"].mnemonic = "photon";
	ProjectileTypes["durandal hummer"].mnemonic = "trex chomp";
	ProjectileTypes["minor cyborg ball"].mnemonic = "spear";
	ProjectileTypes["major cyborg ball"].mnemonic = "sting";
	ProjectileTypes["ball"].mnemonic = "ball";
	ProjectileTypes["minor fusion dispersal"].mnemonic = "electrical short";
	ProjectileTypes["major fusion dispersal"].mnemonic = "electrical blast";
	ProjectileTypes["overloaded fusion dispersal"].mnemonic = "overload";
	ProjectileTypes["yeti"].mnemonic = "raptor bite";
	ProjectileTypes["sewage yeti"].mnemonic = "phaser";
	ProjectileTypes["lava yeti"].mnemonic = "morgana spell";
	ProjectileTypes["smg bullet"].mnemonic = "special";

	DamageTypes["explosion"].mnemonic = "explosion";
	DamageTypes["staff"].mnemonic = "zap";
	DamageTypes["projectile"].mnemonic = "projectile";
	DamageTypes["absorbed"].mnemonic = "absorbed";
	DamageTypes["flame"].mnemonic = "fire";
	DamageTypes["claws"].mnemonic = "rip";
	DamageTypes["alien weapon"].mnemonic = "healing";
	DamageTypes["hulk slap"].mnemonic = "trex";
	DamageTypes["compiler"].mnemonic = "spell";
	DamageTypes["fusion"].mnemonic = "excalibur";
	DamageTypes["hunter"].mnemonic = "plasma";
	DamageTypes["fists"].mnemonic = "swing";
	DamageTypes["teleporter"].mnemonic = "teleporter";
	DamageTypes["defender"].mnemonic = "cold";
	DamageTypes["yeti claws"].mnemonic = "poison";
	DamageTypes["yeti projectile"].mnemonic = "laser";
	DamageTypes["crushing"].mnemonic = "crushing";
	DamageTypes["lava"].mnemonic = "lava";
	DamageTypes["suffocation"].mnemonic = "suffocation";
	DamageTypes["goo"].mnemonic = "electrocute";
	DamageTypes["energy drain"].mnemonic = "drain"; 
	DamageTypes["oxygen drain"].mnemonic = "oxygen drain";
	DamageTypes["drone"].mnemonic = "micromissile";
	DamageTypes["shotgun"].mnemonic = "arrows";
    if master_init ~= nil then
        master_init(rs);
    end
    if common_init ~= nil then
        common_init(rs);
    end
    if ctf_init ~= nil then
        ctf_init(rs);
    end
    if level_init ~= nil then
        level_init(rs);
    end
end

function Triggers.idle()
    if master_idle ~= nil then
        master_idle();
    end
    if common_idle ~= nil then
    	common_idle()
    end
    if ctf_idle ~= nil then
    	ctf_idle();
    end
    if level_idle ~= nil then
        level_idle();
    end
end


