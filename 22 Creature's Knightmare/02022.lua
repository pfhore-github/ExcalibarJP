mines = {};
mine_length_min = 2 * 30;
mine_radius = 3;
mine_max_damage = 100;
mine_damage_type = "explosion";
last_poly = nil;
exit_poly = 704;
function level_init (rs)
	ProjectileTypes["special"].mnemonic = "mine";
	MonsterTypes["clone"].mnemonic = "mine";
   Players[0]:play_sound(252, 1);
   if rs then
      for g in Monsters() do
	 if (g.type == "mine") then
            table.insert(mines, {spell=g, timer=mine_length_min, ignited=false});
	 end
      end
      return;
   end
   remove_items("wand", "epotion");
end

function level_idle ()
   poly = Players[0].polygon.index;
   if poly ~= last_poly then
      last_poly = poly;
      if poly == exit_poly then
        Players[0]:teleport_to_level(23);
     end
  end
  cnt = # mines;
  for i = 1, cnt do
     mines[i].timer = mines[i].timer - 1;
     if (mines[i].timer <= 0) and (not mines[i].ignited) then
	if mines[i].spell and mines[i].spell.valid then
	   mines[i].spell:damage( 500, mine_damage_type);
	end
     end
  end
end

function ignite_mine(mine_index)
   local g, is_mine, mine_damage;
   player = Players[0].monster;
   mine_poly = mines[mine_index].spell.polygon;
   mine_x = mines[mine_index].spell.x
   mine_y = mines[mine_index].spell.y
   mine_z =  mines[mine_index].spell.z
   for g in Monsters() do
      is_mine = g.type == "mine";
      if (g ~= mines[mine_index].spell) then
         mp = g.polygon
         mfloor = mp.floor.height;
         dist = (g.x - mine_x)^2 + (g.y - mine_y)^2
         wu_dist = math.sqrt(dist) / 1024
         floor_delta = math.abs(mfloor - mine_poly.floor.height);
         hover = g.z - mfloor;
         if (wu_dist <= mine_radius) and (hover <= .5) and (floor_delta < 1.0) then
            if is_mine then
               mine_damage = 500;
            else
               mine_damage = mine_max_damage - 
		  (mine_max_damage*wu_dist/mine_radius);
	    end
            g:damage_monster(mine_damage, mine_damage_type);
	 end
      end
   end
end

function level_monster_killed(victim, killer, projectile)
   cnt = # mines;
   for i = 1, cnt do
      if (mines[i].spell == victim) and (not mines[i].ignited) then
	 Players[0]:print("Mine #"..i.."‚Í”š”­‚µ‚½");
	 mines[i].ignited = true;
	 ignite_mine(i);
      end
   end
end

function Triggers.projectile_detonated(type, owner, polygon, x, y, z)
   if (type == "mine") then
      spell = Monsters.new(x, y, 0, polygon, "mine");
      spell.active = true;
      Players[0]:play_sound(34, 1);
      numticks = mine_length_min + Game.global_random (90);
      table.insert(mines, {spell=spell, timer=numticks, ignited=false});
      cnt = # mines;
   end
end

