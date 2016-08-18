hole_poly = 541;
pool_poly = 534;
last_poly = nil;

function level_init (rs)
   restoring_saved = rs;
   Players[0]:play_sound(104, 1);
   if rs then
      return;
   end
   remove_items("spear", "rocks");
end

function level_idle ()

   loc = Players[0].polygon;
   if (loc.index == hole_poly) then
      if Players[0].z <= -2 then
         Players[0]:position(-16.75, 7.75, 6.0, pool_poly);
      end
   end
   if (loc.index ~= last_poly) then
      last_poly = loc.index;
      poly_type = loc.type;
      if (poly_type == "automatic exit") then
         Players[0]:teleport_to_level (11);
      end
   end
end
