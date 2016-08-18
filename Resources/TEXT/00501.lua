--[[ This is primarily for Jurassic, and supports bananas, powerups, spear, and
      crossbow.  --]]

function common_init(rs) 
	ItemTypes["vial"].mnemonic = "bananas"
	full_health = 150;
    if (Game.difficulty.index == 0) then
        banana_power = 50;
    elseif (Game.difficulty.index == 1) then
        banana_power = 25;
    else
        banana_power = 10;
    end
end
powerups = { "invisible", "invincible", "nightvision" };
energies = { "2x powerup", "3x powerup" };
function common_got_item(item, player)
   got_item_sound(item, player, powerups, 228);
   got_item_sound(item, player, energies, 227);
   if (item == "bananas") then
      player:play_sound(229,1);
      local life = player.life;
      local new_life;
      if (life >= full_health) then
         new_life = life + 3 + Game.global_random(5)
      else
         new_life = life + banana_power + Game.global_random(25)
      end
      if (new_life > full_health) and (life < full_health) then
         new_life = full_health;
      end
      player.life = new_life;
      player.items["bananas"] = 0;
   end
end

