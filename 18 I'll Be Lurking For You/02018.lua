
dead_spells = {};
dead_timers = {};

master_queue = 0;
master_timer = 0;
function level_init (rs)
	ProjectileTypes["freeze"].mnemonic = "raise dead";
	MonsterTypes["white knight"].mnemonic = "the dead";
	if (Game.difficulty.index == 0) then
		dead_vitality = 150;
		dead_length = 300 * 30;
	elseif (Game.difficulty.index == 1) then
		dead_vitality = 120;
		dead_length = 240 * 30;
	elseif (Game.difficulty.index == 2) then
		dead_vitality = 100;
		dead_length = 180 * 30;
	else
		dead_vitality = 80;
		dead_length = 60 * 30;
	end
	Players[0]:play_sound(250, 1);
	if rs then
		for g in Monsters() do
			if  (g.type == "the dead") then
				table.insert(dead_spells, g);
				table.insert(dead_timers, dead_length/2);
				master_queue = master_queue + 1;
			end
		end
		return;
	end
	remove_items("wand", "rocks");
end

function level_idle ()
   if master_queue > 0 then
      master_timer = master_timer - 1;
      if master_timer <= 0 then
         master_timer = 60;
	 Players[0]:play_sound( 257, 1);
         master_queue = master_queue - 1;
         if master_queue == 0 then
            master_timer = 0;
	 end
      end
   end
   cnt = # dead_spells;
   i = 1;
   while (i <= cnt) do
      dead_timers[i] = dead_timers[i] - 1;
      if dead_timers[i] <= 0 then
	 if dead_spells[i] and dead_spells[i].valid then
	    dead_spells[i]:damage( dead_vitality + 10, "suffocation");
	 end
	 table.remove(dead_spells, i);
	 table.remove(dead_timers, i);
	 i = i - 1;
	 cnt = cnt - 1;
      end
      i = i + 1;
   end
end

function Triggers.projectile_detonated(type, owner, polygon, x, y, z)
   if (type == "raise dead") then
      floor = polygon.floor.height;
      height = polygon.ceiling.height - floor;
      if height < 0.8 then
	 Players[0]:print("呪文失敗：目的地はモンスターには狭すぎる");
	 Players[0]:play_sound(5, 1);
	 Players[0]:fade_screen("bright");
      else
	 spell = Monsters.new(x, y, 0, polygon, "the dead");
	 spell.yaw = Players[0].yaw;
	 spell.active = true;
	 spell.vitality = dead_vitality;
	 table.insert(dead_spells, spell);
	 table.insert(dead_timers, dead_length);
	 master_queue = master_queue + 1;
      end
   end
end