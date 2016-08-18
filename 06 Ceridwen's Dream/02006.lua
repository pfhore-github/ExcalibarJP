glass_broken = false;
music_on = true;
ceridwen_theme = "Cavern/M06.mp3";

function level_init (rs)
   Players[0]:play_sound(252, 1);
end

function level_idle ()
   if (not Lights[31].active) and (not glass_broken) then
      Players[0]:play_sound(186, 1);
      glass_broken = true;
   end
   player_poly = Players[0].polygon.index;
   if (player_poly ~= last_poly) then
      last_poly = player_poly;
      if (player_poly == 564) and music_on then
         Music.fade(60/1000);
         music_on = false;
      end
      if (player_poly == 536) and (not music_on) then
         Music.play(ceridwen_theme);
         music_on = true;
      end
   end
end

