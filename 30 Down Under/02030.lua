fans_on = false;
next_level = false;
	exit_poly = 480;

function level_init (rs)
   Players[0]:play_sound(251, 1);
   if rs then
      return;
   end
   remove_items("wand");
end

function level_idle ()
   if Lights[25].active and (not fans_on) then
      Polygons[531].ceiling.height = 3.5;
      Polygons[533].ceiling.height = 3.5;
      fans_on = true;
   end
   poly = Players[0].polygon.index;
   z = Players[0].z;
   if (poly == exit_poly) and (z < 0) and (not next_level) then
      Players[0]:teleport_to_level(31);
      next_level = true;
   end
end

