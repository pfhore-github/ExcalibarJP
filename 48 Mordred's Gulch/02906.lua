last_poly = { };
red_zone = 357;
red_pad = 369;
red_river = 112;
blue_river = 203;
blue_zone = 79;
blue_pad = 374;
function level_init(rs) 
	monsters_name["dimorph"]="�G";
	monsters_name["hover gat"]="���b�h�E�f�r���i�Ԃ������j";
	monsters_name["bike cop"]="�L���m���E�t�H�_�[�i��C�����j";
	monsters_name["trex"]="�W���[�E�O���[��";
	monsters_name["cleric"]="�����[�N�E�t�F�[�U�[";
	monsters_name["lesser knight"]="�W�F�[�N�E�u���[";
	monsters_name["black knight"]="���[�U�[�E�f���[�h";
	monsters_name["minor gat"]="�}�X�^�[�E�u���X�^�[";
	monsters_name["major gat"]="�I�[�Y�E�W���[�X";
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
