--[[ This is for Future levels, and supports powerups, Flamer, Excalibur and
      rail gun.  --]]

railgun_in_action = true;

grenades = {};
grenade_wait = 2*30;
grenade_power = 400;
grenade_range = 2;
sword_play = true;
explosion_active = false;
increase_power = 0;
increase_radius = 0;
function common_init(rs)
	
	ProjectileTypes["rock"].mnemonic = "biggrenade";
	MonsterTypes["raptor eggs"].mnemonic = "grenade";
	if monsters_name ~= nil then
		monsters_name["grenade"]="グレネード";
	end
	if projectiles ~= nil then
		projectiles["biggrenade"]="爆発";
		projectiles["crossbow bolt"]="鋭い発射物";
	end
end
function common_idle()
   local i = 0;
   cnt = # grenades;
   i = 1;
   while (i <= cnt) do
      grenades[i].timer = grenades[i].timer - 1;
      if grenades[i].timer <= 0 then
	 if grenades[i].item and grenades[i].item.valid then
	    grenades[i].item:damage(10000, "suffocation");
	 end
	 table.remove(grenades,i);
	 i = i - 1;
	 cnt = cnt - 1;
      end
      i = i + 1;
   end
end

function common_monster_killed(monster, killer, shot)
   local type = monster.type;
   if (type ~= "grenade") then
      return;
   end
   local _mx = monster.x
   local _my = monster.y
   local _mp = monster.polygon;
   if explosion_active then
      increase_power = increase_power + 200;
      increase_radius = increase_radius + 1;
   else
      explode_grenade(monster, grenade_range, grenade_power, _mp, _mx, _my);
   end
end
sword = { "sword" };
powerup = { "invisible", "invincible", "nightvision" };
energies = { "2x powerup", "3x powerup" };

function common_got_item(item, player)
   if (item == "sword") and sword_play then
      player:play_sound(62,1);
   end
   got_item_sound(item, player, powerup, 228);
   got_item_sound(item, player, energies, 227);
end

function Triggers.projectile_detonated(type, owner, polygon, x, y, z)
	if level_projectile_detonated ~= nil then
		level_projectile_detonated(type, owner, polygon, x, y, z);
		end
  local grenade = {};
  if (type == "biggrenade") then
    grenade.item = Monsters.new(x, y, 0, polygon, "grenade");
    grenade.poly = polygon;
    grenade.x = x;
    grenade.y = y;
    grenade.timer = grenade_wait;
    table.insert(grenades, grenade);
  end
end

function explode_grenade(grenade, radius, power, poly, x, y)
   local r = 0;
   local p = 0;
   explosion_active = true;
   increase_power = 0;
   increase_radius = 0;
   for g in Monsters() do
      if (g ~= grenade) then
	 p = power + increase_power;
	 r = radius + increase_radius;
	 local mp = g.polygon;
	 local dist = (g.x - x)^2 + (g.y - y)^2;
	 local wu_dist = math.sqrt(dist);
	 local floor_delta = math.abs(mp.floor.height - poly.floor.height);
	 if (wu_dist <= r) and (floor_delta < 1.0) then
	    local damage = p - (p*wu_dist/r);
	    g:damage(damage, "explosion");
	 end
      end
   end
   explosion_active = false;
end


