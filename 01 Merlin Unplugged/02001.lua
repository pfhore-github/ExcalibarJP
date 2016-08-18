camelot_visit = false;
jurassic_visit = false;
last_poly = nil;
door_locked = true;
bob_safe = false;
bob_timer = 0;
quake = 0;
quake_time = 256;
camelot_holodeck = 453;
camelot_program = 721;
camelot_exit = 826;
camelot_holodeck_return = 451;
holodeck_arrows1 = 452;
holodeck_arrows2 =  449;
jurassic_holodeck = 850;
jurassic_program = 180;
jurassic_exit = 256;
jurassic_holodeck_return = 310;
holodeck_raptor1 = 640;
holodeck_raptor2 = 642;
holodeck_spear = 851;
bob_rest = 80;
bob_start = 164;
bob_trigger = 124;
bob_safety = 905;
quake_poly = 240;

function find_monster(mtype)
	for g in Monsters() do
		if g.type == mtype then
			return g;
		end
	end
	return nil;
end

function level_init (rs)
	bob_door = find_platform(163);
	rock_poly = find_platform(242);

	camelot_light = Lights[45];
	jurassic_light = Lights[46];
	maintdoor_light = Lights[47];
	Players[0]:play_sound(99, 1);
	bob = find_monster("maint bob");
	if bob then
		bob_poly = bob.polygon;
		bob_safe = (poly == bob_safety);
	else
		bob_poly = nil;
		bob_safe = true;
	end
	door_locked = not bob_door.player_controllable;
	if rs then
		camelot_visit = camelot_light.active;
		jurassic_visit = jurassic_light.active;
	end

end


function level_idle ()
	if door_locked and (bob_door.active or bob_safe) then
		bob_door.player_controllable = true;
		door_locked = false;
		if not bob_safe then
			maintdoor_light.active = true;
			Players.print('ドアのロックは解除された');
		end
	end
	player_poly = Players[0].polygon.index;
	if (not door_locked) and bob and bob.valid then
		if bob_timer > -1 then
			bob_timer = bob_timer + 1;
		end
		dist = (bob.x - Players[0].x)^2 + (bob.y - Players[0].y)^2;
		wu_dist = math.sqrt(dist);
		if (wu_dist <= 2) and (bob_timer > 90) then
			bob:damage(201, "suffocation");
			bob_safe = true;
			bob_timer = -1;
		end
	end
	if camelot_visit and door_locked then
		 bob_door.active = true;
		door_locked = false;
	end
	if (last_poly ~= player_poly) then
		last_poly = player_poly;
		if (player_poly == bob_trigger) and (bob_poly.index == bob_rest) and bob then
			bob:position(-13.5, -12, 0, bob_start);
			Players[0]:play_sound(114, 1);
			Players[0]:play_sound(261, 1);
			bob_poly = Polygons[bob_start];
		end
		if (quake == 0) and (player_poly == quake_poly) then
			Players[0]:play_sound(226, 1);
			quake = 1;
		end
		if (not camelot_visit) and (player_poly == camelot_holodeck) then
			camelot_visit = true;
			camelot_light.active = true;
			Players.print('ホロデックプログラム起動：キャメロット');
			Players[0].yaw = 45;
			Players[0].pitch = 360;
			Players[0]:teleport(camelot_program);
		end
		if (player_poly == camelot_exit) then
			Players.print('ホロデックプログラム解除：キャメロット');
			new_item_at("crossbow bolts", holodeck_arrows1);
			new_item_at("crossbow bolts", holodeck_arrows2);
			Players[0].yaw = 270;
			Players[0].pitch = 360;
			Players[0]:teleport(camelot_holodeck_return);
		end
		if (not jurassic_visit) and (player_poly == jurassic_holodeck) then
			jurassic_visit = true;
			jurassic_light.active = true;
			Players.print('ホロデックプログラム起動：ジュラ紀');
			Players[0].yaw = 0;
			Players[0].pitch = 360;
			Players[0]:teleport(jurassic_program);
		end
		if (player_poly == jurassic_exit) then
			Players.print('ホロデックプログラム解除：ジュラ紀');
			new_item_at("spear", holodeck_spear);
			new_monster_at("minor raptor", holodeck_raptor1, 90);
			new_monster_at("minor raptor", holodeck_raptor2, 90);
			Players[0].yaw = 270;
			Players[0].pitch = 360;
		end
	end
	if (quake > 0) then
		quake = quake + 1;
	end
	if (quake == quake_time) then
		rock_poly.active = true;
		Players[0]:play_sound(226, 1);
		quake = 0;
	end
	if ((quake > 15) and (quake < quake_time)) then
		local theta;
		for p in Players() do
			theta = Game.global_random(360);
			vfactor = quake;
			if (vfactor > 240) then 
				vfactor = 240
			end
		local vel = (Game.global_random(100+vfactor*0.5))/10000;
		p:accelerate(theta, vel, 0);
		end
	end
end
