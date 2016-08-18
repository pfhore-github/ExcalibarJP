--[[ This is for later Camelot levels, and supports potions, Flamer, Excalibur and
      crossbow.  --]]

full_health = 150;

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
  got_item_sound(item, player, powerup, 19);
  got_item_sound(item, player, energies, 19);
   if (item == "epotion") then
    life = player.life;
    if (life < 50) then
      player:play_sound(19,1);
      player.life = life + 2*full_health;
      player.items[item] = 0;
    end
  end
end

