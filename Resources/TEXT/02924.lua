red_score = 0;
blue_score = 0;
red_basket = Polygons[37];
blue_basket = Polygons[7];
red_rebound = Polygons[121];
blue_rebound = Polygons[32];

announced = false;
pre_idle = Triggers.idle;
pre_projectile_detonated = Triggers.projectile_detonated;
ItemTypes["epotion"].mnemonic = "grenade";
global_init = Triggers.init;
function local_player()
  for p in Players()
    if p.local_ then
      return p
    end
  end
  return nil
end

function Triggers.init(rs)
   global_init(rs);
   reds = 0;
   blues = 0;
   for p in Players() do 
      p._noteam = nil;
      c = p.color;
      if c == "red" then
         reds = reds + 1;
      elseif c == "blue" then
         blues = blues + 1;
      else
	 p._noteam = c;
      end
   end
   for p in Players() do 
      if p._noteam then 
         if reds > blues then
	    p.color = "blue";
            blues = blues + 1;
         else
	    p.color = "red";
            reds = reds + 1;
	 end
      end
   end
end

function Triggers.idle ()
   pre_idle();
   for p in Players() do 
      loc = p.polygon;
      if (loc ~= p._last_poly ) then
         p._last_poly = loc;
      end
   end
   lplayer = local_player();
   c = lplayer.color;
   if not announced then
      if c == "red" then
	 lplayer:print('君は紅組だ');
      elseif c == "blue" then
	 lplayer:print('君は青組だ');
      else
	 lplayer:print('君は紅組でも青組でもない');
      end
      announced = true;
   end
   lplayer.overlays[0].color = "red";
   lplayer.overlays[0].text = '得点: '..red_score;
   lplayer.overlays[1].color = "white";
   lplayer.overlays[1].text = "-";
   lplayer.overlays[2].color = "blue";
   lplayer.overlays[2].text = '得点: '..blue_score;
end


function Triggers.projectile_detonated(type, owner, polygon, x, y, z)
   pre_projectile_detonated(type, owner, polygon, x, y, z);
   if (type == "rock") and (polygon == red_basket) then
      red_score = red_score + 2;
      c = owner.color;
      if (c == "red") then  --[[ if on red team ]]
	 owner.points = owner.points + 2;
	 owner.kills[owner] = owner.kills[owner] + 2;
      elseif (c == "blue") then  --[[ if on blue team ]]
	 owner.points = owner.points - 2;
 	 owner.kills[owner] = owner.kills[owner] - 2;
      end

      Players[0]:print(get_monster_name(owner) .. 'は紅組に２点取った！');
      Players[0]:play_sound(233, 1);
      Items.new(red_rebound.x, red_rebound.y, 0, red_rebound, "grenade");
   end
   if (type == "rock") and (polygon == blue_basket) then
      blue_score = blue_score + 2;
      c = owner.color;
      if (c == "red") then  --[[ if on red team ]]
	 owner.points = owner.points - 2;
	 owner.kills[owner] = owner.kills[owner] - 2;
      elseif (c == "blue") then  --[[ if on blue team ]]
	 owner.points = owner.points + 2;
 	 owner.kills[owner] = owner.kills[owner] + 2;
      end
      Players[0]:print(get_monster_name(owner) .. 'は青組に２点取った！');
      Players[0]:play_sound(233, 1);
      Items.new(blue_rebound.x, blue_rebound.y, 0, blue_rebound, "grenade");
   end
end