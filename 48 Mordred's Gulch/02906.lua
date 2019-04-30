last_poly = { };
red_zone = 357;
red_pad = 369;
red_river = 112;
blue_river = 203;
blue_zone = 79;
blue_pad = 374;
function level_init(rs) 
	monsters_name["dimorph"]="烏";
	monsters_name["hover gat"]="レッド・デビル（赤い悪魔）";
	monsters_name["bike cop"]="キャノン・フォダー（大砲飼料）";
	monsters_name["trex"]="ジョー・グリーン";
	monsters_name["cleric"]="リューク・フェーザー";
	monsters_name["lesser knight"]="ジェーク・ブルー";
	monsters_name["black knight"]="レーザー・デュード";
	monsters_name["minor gat"]="マスター・ブラスター";
	monsters_name["major gat"]="オーズ・ジュース";
end
function find_platform(index)
    for plat in Platforms() do
        if( plat.polygon.index == index ) then
            return plat;
        end
    end
    return nil
end
function level_idle()
   for p in Players() do 
      loc = p.polygon.index;
      if (loc == red_river) then
         find_platform(red_river).active = true;
      elseif (loc == blue_river) then
		 find_platform(blue_river).active = true;
      end
      if (loc ~= last_poly[p.index]) then
         last_poly[p.index] = loc;
         if (loc == blue_zone) then
            p:play_sound(235, 1);
            p:position(-12.5, 12.13, 0.2, Polygons[blue_pad]);
         elseif (loc == red_zone) then
            p:play_sound(235, 1);
            p:position(12.63, -17.88, 0.2, Polygons[red_pad]);
	 end
      end
   end
end
