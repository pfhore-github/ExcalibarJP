-- Lua for net game, second(or 3rd) execute
local degrees = {
	[3]={msg="�C����", adj="�R�l�E��"},
	[5]={msg="�E�l�S", adj="�E�l�S"},
	[10]={msg="���\\�I", adj="���\\��"},
	[15]={msg="�Ј��I", adj="�x�z"},
	[20]={msg="��~�s�\\�̂悤", adj="��~�s�\\��"},
	[25]={msg="�_�̂悤", adj="�_�̂悤�ȏ��"}
};
function master_init(rs)
	for p in Players() do
		p._kills = 0;
	end
end
local damages = {
["explosion"]={"�O�ɐ�����΂���", "�O�ɐ�����΂��ꂽ"},
["zap"]={"�Ռ���^����", "�Ռ����󂯂�"},
["projectile"]={"������", "�����ꂽ"},
["absorbed"]={"���G�Ȃ̂ɎE����?!", "���G�Ȃ̂Ɏ���?!"},
["fire"]={"�Z������", "�Z����"},
["rip"]={"���甍������", "�����ꂽ"},
["healing"]={"���@��������", "���@����������"},
["trex"]={"���ݕt����", "���݂��ꂽ"},
["spell"]={"�����", "���ꂽ"},
["excalibur"]={"�j�󂵂�", "�j�󂳂ꂽ"},
["plasma"]={"�E����", "�E���ꂽ"},
["swing"]={"�M�ꂳ����", "�M�ꂽ"},
["teleporter"]={"�e���|�[�g������", "�e���|�[�g����"},
["cold"]={"���点��", "������"},
["poison"]={"�ł����܂���", "�ł�����"},
["laser"]={"�Ă���", "�Ă��ꂽ"},
["crushing"]={"�Ԃ���", "�Ԃ���ꂽ"},
["lava"]={"�Ă���","�Ă��ꂽ"},
["suffocation"]={"������������", "��������"},
["electrocute"]={"���d������", "���d����"},
["drain"]={"�z������", "�z�����ꂽ"},
["oxygen drain"]={"�z������", "�z�����ꂽ"},
["micromissile"]={"�O�ɐ�����΂���", "�O�ɐ�����΂��ꂽ"},
["arrows"]={"������", "�����ꂽ"}
}
local function verb(noun, verb)
	verb = damages[verb] or {"�E����", "�E���ꂽ"}
	local verb1 = verb[1]
	if (noun == "" or noun == nil) then
		if (verb1 == "������΂���") then
			verb1 = "�������"
		elseif (verb1 == "�E����") then
			verb1 = "����"
		else
			verb1 = verb[2]
		end
		return verb1;
	end
	return noun .. "��" .. verb1
end

function Triggers.player_damaged(victim, victor, monster, type, amount, projectile)
	if (victor) and (victim ~= victor) and (victim.team == victor.team) then
		victim.life = victim.life + amount
	end
	if (victim.life < 0) then
		local by = ""
		if (projectile) then
			local proj = projectiles[projectile.type];
	 		if(proj) then
		 		by = proj .."�ɂ����"
			end
		end
		--[[ suicide --]]
		if (victor ~= nil and victim == victor) then
	 		Players.print(victor.name .. "��" .. by .. verb("����", type))
		elseif (victor ~= nil) then
	 		--[[ PK --]]
	 		Players.print(victor.name .. "��" .. by .. verb(victim.name, type))
	 	elseif (monster  ~= nil) then
			 --[[ monster --]]
		 	Players.print(monsters_name[monster.type.mnemonic] .. "��" .. by .. verb(victim.name, type))
	 	else
			 --[[ environment --]]
		 	Players.print(victor.name .. "��" .. by .. verb(nil, type))
	 end
	 --[[ give victor a kill and output a message? --]]
	 if (victim ~= victor and victor) then
		 victor._kills = victor._kills + 1
		 if(victim._kills > 0) then
	  for n=25,5,-5 do
		  if (n <= victim._kills) then
		Players.print(victim.name .. "��" .. degrees[n].adj .. 
					"��" .. victor.name .. "�ɂ���ĂƂ߂�ꂽ")
		break
		  end
	  end
		 end
		 local deg = degrees[victor._kills]
		 if (deg) then 
	  deg = deg.msg 
		 end
		 if (deg) then
	  Players.print(victor.name .. "��" .. deg .. "��!")
		 end
	 elseif (victim ~= victor and monster) then
		 if(victim._kills > 0) then
	  for n=25,5,-5 do
		  if(n <= victim._kills) then
		Players.print(victim.name .. "��" .. degrees[n].adj .. 
					"��" .. monsters_name[monster.type] .. victor.name .. "�ɂ���ĂƂ߂�ꂽ")
		break
		  end
	  end
		 end
	 else
		 if (victim._kills > 0) then
	  for n=25,5,-5 do
		  if(n <= victim._kills) then
		Players.print(victim.name .. "��" .. degrees[n].adj .. 
					"�͑������I������B")
		break
		  end
	  end
		 end
	 end
	 victim._kills = 0
 end
end

function Triggers.monster_killed(victim, victor, projectile)
	if level_monster_killed ~= nil then
		level_monster_killed(victim, victor, projectile);
	end

	local msg = "";
	local monstah, type;
	if (projectile == nil) then
		type,monstah = nil
	else
		type = projectile.type
		monstah = projectile.owner
	end
	local by = ""
	if (projectile ) then
		local proj = projectiles[projectile.type]
		if(proj) then
			by =  proj .. "�ɂ����" 
		end
	end
	
	--[[ PK --]]
	if (victor) then
		Players.print(victor.name .. "��" .. by .. verb(monsters_name[victim.type.mnemonic], type))
	elseif (monstah ~= nil and monstah) then
		local victor = monstah
		--[[ suicide --]]
		if (victim == victor) then
			Players.print(monsters_name[victor.type.mnemonic] .. "��" .. by .. verb("����", type))
		--[[ monster --]]
		else
			Players.print(verb(monsters_name[victim.type.mnemonic], type))
			Players.print(monsters_name[victor.type.mnemonic] .. "��" .. by .. verb(monsters_name[victim.type.mnemonic], type))
		end
	else
		Players.print(monsters_name[victim.type] .. "��" .. by .. verb(nil, type))
	end
	--[[ give victor a kill and output a message --]]
	if(victor) then
		victor._kills = victor._kills + 1;
		victor.points = victor.points + 1;
		victor.kills[victor] = victor.kills[victor] + 1;
		local deg = degrees[victor._kills];
		if (deg) then 
			deg = deg.msg 
		end
		if (deg) then
			Players.print(victor.name .. "��" .. deg .. "��!")
			victor:play_sound(233, 1);
		end
	end
end
