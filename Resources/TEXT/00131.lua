-- Lua for net game, second(or 3rd) execute
local degrees = {
	[3]={msg="任務中", adj="３人殺し"},
	[5]={msg="殺人鬼", adj="殺人鬼"},
	[10]={msg="凶暴\的", adj="凶暴\性"},
	[15]={msg="威圧的", adj="支配"},
	[20]={msg="停止不能\のよう", adj="停止不能\性"},
	[25]={msg="神のよう", adj="神のような状態"}
};
function master_init(rs)
	for p in Players() do
		p._kills = 0;
	end
end
local damages = {
["explosion"]={"外に吹き飛ばした", "外に吹き飛ばされた"},
["zap"]={"衝撃を与えた", "衝撃を受けた"},
["projectile"]={"撃った", "撃たれた"},
["absorbed"]={"無敵なのに殺した?!", "無敵なのに死んだ?!"},
["fire"]={"融かした", "融けた"},
["rip"]={"から剥がした", "剥がれた"},
["healing"]={"魔法をかけた", "魔法がかかった"},
["trex"]={"噛み付いた", "噛みつかれた"},
["spell"]={"呪った", "呪われた"},
["excalibur"]={"破壊した", "破壊された"},
["plasma"]={"殺した", "殺された"},
["swing"]={"溺れさせた", "溺れた"},
["teleporter"]={"テレポートさせた", "テレポートした"},
["cold"]={"凍らせた", "凍った"},
["poison"]={"毒を飲ませた", "毒を飲んだ"},
["laser"]={"焼いた", "焼かれた"},
["crushing"]={"ぶつけた", "ぶつけられた"},
["lava"]={"焼いた","焼かれた"},
["suffocation"]={"窒息死させた", "窒息した"},
["electrocute"]={"感電させた", "感電した"},
["drain"]={"吸収した", "吸収された"},
["oxygen drain"]={"吸収した", "吸収された"},
["micromissile"]={"外に吹き飛ばした", "外に吹き飛ばされた"},
["arrows"]={"撃った", "撃たれた"}
}
local function verb(noun, verb)
	verb = damages[verb] or {"殺した", "殺された"}
	local verb1 = verb[1]
	if (noun == "" or noun == nil) then
		if (verb1 == "吹き飛ばした") then
			verb1 = "吹き飛んだ"
		elseif (verb1 == "殺した") then
			verb1 = "死んだ"
		else
			verb1 = verb[2]
		end
		return verb1;
	end
	return noun .. "を" .. verb1
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
		 		by = proj .."によって"
			end
		end
		--[[ suicide --]]
		if (victor ~= nil and victim == victor) then
	 		Players.print(victor.name .. "が" .. by .. verb("自分", type))
		elseif (victor ~= nil) then
	 		--[[ PK --]]
	 		Players.print(victor.name .. "が" .. by .. verb(victim.name, type))
	 	elseif (monster  ~= nil) then
			 --[[ monster --]]
		 	Players.print(monsters_name[monster.type.mnemonic] .. "が" .. by .. verb(victim.name, type))
	 	else
			 --[[ environment --]]
		 	Players.print(victor.name .. "は" .. by .. verb(nil, type))
	 end
	 --[[ give victor a kill and output a message? --]]
	 if (victim ~= victor and victor) then
		 victor._kills = victor._kills + 1
		 if(victim._kills > 0) then
	  for n=25,5,-5 do
		  if (n <= victim._kills) then
		Players.print(victim.name .. "の" .. degrees[n].adj .. 
					"は" .. victor.name .. "によってとめられた")
		break
		  end
	  end
		 end
		 local deg = degrees[victor._kills]
		 if (deg) then 
	  deg = deg.msg 
		 end
		 if (deg) then
	  Players.print(victor.name .. "は" .. deg .. "だ!")
		 end
	 elseif (victim ~= victor and monster) then
		 if(victim._kills > 0) then
	  for n=25,5,-5 do
		  if(n <= victim._kills) then
		Players.print(victim.name .. "の" .. degrees[n].adj .. 
					"は" .. monsters_name[monster.type] .. victor.name .. "によってとめられた")
		break
		  end
	  end
		 end
	 else
		 if (victim._kills > 0) then
	  for n=25,5,-5 do
		  if(n <= victim._kills) then
		Players.print(victim.name .. "の" .. degrees[n].adj .. 
					"は早くも終わった。")
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
			by =  proj .. "によって" 
		end
	end
	
	--[[ PK --]]
	if (victor) then
		Players.print(victor.name .. "は" .. by .. verb(monsters_name[victim.type.mnemonic], type))
	elseif (monstah ~= nil and monstah) then
		local victor = monstah
		--[[ suicide --]]
		if (victim == victor) then
			Players.print(monsters_name[victor.type.mnemonic] .. "は" .. by .. verb("自分", type))
		--[[ monster --]]
		else
			Players.print(verb(monsters_name[victim.type.mnemonic], type))
			Players.print(monsters_name[victor.type.mnemonic] .. "は" .. by .. verb(monsters_name[victim.type.mnemonic], type))
		end
	else
		Players.print(monsters_name[victim.type] .. "は" .. by .. verb(nil, type))
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
			Players.print(victor.name .. "は" .. deg .. "だ!")
			victor:play_sound(233, 1);
		end
	end
end
