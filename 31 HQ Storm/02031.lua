exit_level = false;
destruct_enabled = false;
security_disabled = false;
destruct_active = false;
master_gat_dead = false;
lobby = 690;

bounds_polys = { 25, 626, 628, 627, 27 };


function level_init (rs)
exit_light = Lights[63];
destruct_light = Lights[27];
security_light = Lights[31];
basement_door = find_platform(170);
captain_door = find_platform(238);
garage_door = find_platform(782);
MonsterTypes["trex"].mnemonic = "gat captain";
   restoring_saved = rs;
   captain_unlocked = captain_door.player_controllable;
   Players[0]:play_sound(251, 1);
end

function find_monster(mtype)
   for g in Monsters() do 
      if g.type == mtype then
	 return g;
      end
   end
   return nil;
end

function find_item(itype)
   for g in Items() do 
      if g.type  == itype then
	 return g;
      end
   end
   return nil;
end

function out_of_bounds()
   local p = Players[0].polygon.index;
   for i, n in ipairs(bounds_polys) do
      if p == n then
         return true;
      end
   end
   return false;
end

function level_idle ()
   if out_of_bounds() then  --[[ in case the player is blasted outside the force shields ]]
      Players[0]:teleport(lobby);
   end
   if ((not destruct_active) and destruct_light.active) then
      Players[0]:print('自爆は起動されました。後ろのドアを見つけて外へ出てください！');
      destruct_enabled = true;  --[[ in case we have loaded a saved game ]]
      security_disabled = true;
      destruct_active = true;
   end
   if ((not destruct_enabled) and (basement_door.ceiling_height > 1)) then
      Players[0]:print('自爆は起動されました！');
      Players[0]:play_sound(15, 1);
      destruct_enabled = true;
   end
   if ((not security_disabled) and security_light.active ) then 
      Players[0]:print('セキュリティ・ロックアウトは無効化されました！');
      Players[0]:play_sound(131, 1);
      security_disabled = true;
   end
   --[[ If for some reason, the Master GAT failed to drop an SAP card, then give the player the card automatically.  Likewise, if the Master GAT is dead, but the basement door is still locked, then automatically unlock it.  Make that the card has not already been used in case the player is restoring a saved game.
   --]]
   if destruct_enabled and (not master_gat_dead) then
      master_gat = find_monster("gat captain");
      master_gat_dead = (master_gat == nil);
      gat_card = find_item("sap card");
      have_card = Players[0].items["sap card"] > 0;
      if master_gat_dead and (gat_card == nil) and (not have_card) then
         Players[0]:print('GATの船長は倒れました。あなたは今彼のアクセスカードを持っています！');
         Players[0].items["sap card"] = Players[0].items["sap card"] + 1;
      end
   end
   if exit_light.active and (not exit_level) then
      exit_level = true;
      Players[0]:teleport_to_level(40);
      Players[0]:play_sound(0, 1);
   end
end

function level_monster_killed(victim, victor, projectile)

   mtype = victim.type;
   if (mtype == "gat captain") then
      captain_door.player_controllable = true;
      captain_door.active = true;
      Players[0]:play_sound(17, 1);
      if Players[0].items["sap card"] <= 0 then
         Players[0]:print('GATの船長は倒れました。アクセスカードのために彼の死体を探してください！');
      else
         Players[0]:print('GATの船長は倒れました。');
      end
   end
end
