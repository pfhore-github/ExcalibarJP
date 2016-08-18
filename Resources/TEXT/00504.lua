--[[ This is for later Kronos levels, and supports powerups, Flamer, Excalibur and
      crossbow.  --]]

sword_play = true;
mixed_bag = false;
powerup = { "invisible", "invincible", "nightvision" };
energies = { "2x powerup", "3x powerup" };

function common_got_item(item, player)
  if (item == "swrod") and sword_play then
    player:play_sound(62,1);
  end
  if (item == "invisible") and mixed_bag then
     player:play_sound(19,1);
  else
     got_item_sound(item, player, powerup, 228);
  end
  if (item == "2x powerup") and mixed_bag then
     player:play_sound(19,1);
  else
     got_item_sound(item, player, energies, 227);
  end
end

