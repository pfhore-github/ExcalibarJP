scroll = false;

function level_init (rs)
	nightvision_poly = Polygons[507];
	spider_poly = Polygons[506];
   Players[0]:play_sound(105, 1);
   if rs then
      return;
   end
   Players[0].items["sword"] = 0;
end

function level_idle ()
  if (not scroll) and Tags[2].active then
    scroll = true;
    Items.new(nightvision_poly.x, nightvision_poly.y, 0, nightvision_poly, "nightvision");
    Players[0].items["nightvision"] = Players[0].items["nightvision"] + 1
    m = Monsters.new(18.2, -10.83, 0, spider_poly, "spider");
  end
end