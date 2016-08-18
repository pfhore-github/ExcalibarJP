
function level_init(rs)
   for p in Players() do 
      p._last_poly = nil;
   end
end

function level_idle ()

   for p in Players() do 
      loc = p.polygon.index;
      if (loc ~= p._last_poly) then
         p._last_poly = loc;
         if (loc == 66) then
            p:play_sound(235, 1);
            p:position(-2, 25.9, 0, 140);
         elseif (loc == 32) then
            p:play_sound(235, 1);
            p:position(-26.4, 1.5, 0, 100);
         elseif (loc == 142) then
            p:play_sound(235, 1);
            p:position(-2, -22.8, 0, 61);
         elseif (loc == 103) then
            p:play_sound(235, 1);
            p:position(22.4, 1.5, 0, 31);
	 end
      end
   end
end
