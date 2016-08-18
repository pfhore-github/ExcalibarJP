function level_init (rs)
   Players[0]:play_sound(105, 1);
   if rs then
      return;
   end
   remove_items("phaser", "wand", "rocks");
end

