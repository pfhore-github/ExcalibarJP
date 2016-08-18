--[[ this is for early Kronos levels, and supports powerups, spear, Excalibur and
      crossbow. --]]


sword = { "sword" };
powerup = { "invisible", "invincible", "nightvision" };
energies = { "2x powerup", "3x powerup" };
function common_got_item(item, player)   
   got_item_sound(item, player, sword, 62);
   got_item_sound(item, player, powerup, 228);
   got_item_sound(item, player, energies, 227);
end

