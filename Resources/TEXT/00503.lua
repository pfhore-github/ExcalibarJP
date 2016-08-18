--[[ This is for early Camelot levels, and supports potions, axe, apples, Excalibur and
			crossbow.	--]]

full_health = 150;
triple_health = 450;

mixed_bag = false;
function common_init(rs)
	ItemTypes["rocks"].mnemonic = "apples"
	if (Game.difficulty.index == 0) then
		apple_power = 100;
	elseif (Game.difficulty.index == 1) then
		apple_power = 75;
	elseif (Game.difficulty.index == 2) then
		apple_power = 50;
	else
		apple_power = 25;
	end
end

function common_idle()
	life = Players[0].life;
	potions = Players[0].items["epotion"];
	if (life < 50) and (potions > 0) then
		Players[0]:play_sound(19,1);
		Players[0].life = life + 2*full_health;
		Players[0].items["epotion"] = potions - 1
	end
end
sword = { "sword" };
powerup = { "invisible", "invincible", "nightvision" };
energies = { "2x powerup", "3x powerup" };

function common_got_item(item, player)
	got_item_sound(item, player, sword, 62);
	if (item == "invincible") and mixed_bag then
		player:play_sound(228,1);
	else
		got_item_sound(item, player, powerup, 19);
	end
	if (item == "epotion") then
		life = player.life;
		if (life < 50) then
			player:play_sound(19,1);
			player.life = life + 2*full_health;
			player.items[item] = player.items[item] - 1
		end
	end
	if (item == "2x powerup") and mixed_bag then	
		player:play_sound(227,1);
	else
		got_item_sound(item, player, energies, 19);
	end
	if (item == "apples") then
		player:play_sound(229,1);
		life = player.life;
		if (life >= full_health) then
			new_life = life + 10 + Game.global_random(5)
		else
			new_life = life + apple_power + Game.global_random(25)
	end
	if (new_life > full_health) and (life < full_health) then
		new_life = full_health;
	end
		if new_life > triple_health then
			new_life = triple_health;
		end
		player.life = new_life;
		player.items[item] = 0;
	end
end

