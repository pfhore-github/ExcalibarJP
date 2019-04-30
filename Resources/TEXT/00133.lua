--[[
--CTF/Lua v3.0
--By Darren Watts (W'rkncacnter)
--Updates by Jon Irons, changes by Bill Catambay to integrate into EMR
--]]
function local_player()
  for p in Players() do
    if p.local_ then
      return p
    end
  end
  return nil
end

to={ pdeg = 360/512, wu = 1/1024 };
HORIZ = 10;
VERT = 45;
facerName = "";
team1_flag = nil --Polygon of team 1's flag
team2_flag = nil --Polygon of team 2's flag
team1_bases = {} --Polygons for team1
team2_bases = {} --Polygons for team2
teams = {}
team1_flag_in_base = true
team2_flag_in_base = true
count1 = 0
count2 = 0
wait = 1
finish_off = false
has_ended = false
current_captures = {}
distance = {}
flag_position = {} -- first 3 elements are team 1's x, y, z. Next three are coords for team 2's flag.
reset_timer = {}
RESET_AMOUNT = 1350
err = "これは正当なCTFマップじゃない。readmeはCTFゲームをホストするときの情報を提供する。"
   
--[[ ----------------  Icons ---------------------]]
   
icons = {};
colors = {};
   
colors.team1 = [[
3
#5e2605
&ff0000
%111111
]]
colors.team2 = [[
3
#5E2605
&0000FF
%111111
]]
   
icons.carrying = [[
%##&%%%%%%%&&&&%
%##&&&%%%&&&&&&%
%##&&&&&&&&&&&&%
%##&&&&&&&&&&&&%
###&&&&&&&&&&&&%
##&&&&&&&&&&&&&%
##&&&&&&&&&&&&&%
##%%&&&&&&&%%%%%
##%%%%&&&%%%%%%%
##%%%%%%%%%%%%%%
##%%%%%%%%%%%%%%
##%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%
#%%%%%%%%%%%%%%%
]]

icons.dropped = [[
&&%%%%%%%%%%%%&&
&&&%%%%%%%%%%&&&
%&&&%%%%%%%%&&&%
%%&&&%%%%%%&&&%%
%%%&&&%%%%&&&%%%
%%%%&&&%%&&&%%%%
%%%%%&&&&&&%%%%%
%%%%%%&&&&%%%%%%
%%%%%%&&&&%%%%%%
%%%%%&&&&&&%%%%%
%%%%&&&%%&&&%%%%
%%%&&&%%%%&&&%%%
%%&&&%%%%%%&&&%%
%&&&%%%%%%%%&&&%
&&&%%%%%%%%%%&&&
&&%%%%%%%%%%%%&&
]]

icons.notcarrying = [[
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&
&&&&&&&&&&&&&&&&
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%
]]

function ctf_init(rs)
   if Game.type ~= "capture the flag" then
      return;
   end
   
   theFaced = local_player();  
   initialize_vars()
   set_base_polys()
   check_teams()
   place_flags()
end

function initialize_vars()
  for p in Players() do
     p._has_flag = false;
     p._distance = 0 ;
     p._holder_death_checked = true;
  end
  for i = 1, 6, 1 do
    flag_position[i] = 0
  end
  current_captures[1] = 0
  current_captures[2] = 0
  reset_timer[1] = 0
  reset_timer[2] = 0
end

function set_base_polys()
  for anon in Annotations() do
    if(string.lower(anon.text) == "rf") then
      team1_flag = anon.polygon
    end
    if(string.lower(anon.text) == "bf") then
      team2_flag = anon.polygon
    end
    if(string.lower(anon.text) == "rb") then
      table.insert(team1_bases, anon.polygon)
    end
    if(string.lower(anon.text) == "bb") then
      table.insert(team2_bases, anon.polygon)
    end
  end
  if(team1_flag == nil) or (team2_flag == nil) or (# team1_bases == 0) or
	  (# team1_bases == 0) then
    set_base_polys2()
  end
end

function set_base_polys2()
  if (team1_flag == nil) then
    for p in Polygons() do
      if(p.type == "visible monster trigger") then
        team1_flag = p
      end
    end
  end
  if (team2_flag == nil) then
    for p in Polygons() do
      if(p.type == "invisible monster trigger") then
        team2_flag = p
      end
    end
  end
  if (# team1_bases == 0) then
    for p in Polygons() do
      if(p.type == "dual monster trigger") then
        table.insert(team1_bases, p)
      end
    end
  end
  if (# team2_bases == 0) then
    for p in Polygons() do
      if(p.type == "must be explored") then
        table.insert(team2_bases, p)
      end
    end
  end
end

function check_teams()
  local red_team_exists = false
  local blue_team_exists = false
  for p in Players() do
    if p.team == "red" then
      red_team_exists = true
    elseif p.team == "blue" then
      blue_team_exists = true
    end
  end
  if (red_team_exists == false and blue_team_exists == false) then
    assign_teams(0)
  elseif (red_team_exists == true and blue_team_exists == false) then
    assign_teams(1)
  elseif (red_team_exists == false and blue_team_exists == true) then
    assign_teams(2)
  else
    assign_teams(3)
  end
end

function assign_teams(num)
  if (num == 0) then
    num = Game.random (# Players)
    teams[1] = Players[num].team
    for p in Players() do --Split into teams.
      if p.team ~= teams[1] then
        table.insert(teams, p.team)
      end
    end
    for p in Players() do 
      p._original_team = p.team
      p._original_color = p.color
      if (p.team == teams[1]) then
        p.team = "red"
        p.color = "red"
      else
        p.team = "blue"
        p.color = "blue"
      end
    end
  end
  if (num == 1 or num == 3) then
    for p in Players() do
      p._original_team = p.team
      p._original_color = p.color
      if (p.team == "red") then
        p.color = "red"
      else
        p.team = "blue"
        p.color = "blue"
      end
    end
  end
  if (num == 2) then
    for p in Players() do
      p._original_team = p.team
      p._original_color = p.color
      if(p.team == "blue") then
        p.color = "blue"
      else
        p.team = "red"
        p.color = "red"
      end
    end
  end
  teams[1] = "red"
  teams[2] = "blue"
end

function players_to_bases()
  for p in Players() do
    to_base(p, 0)
  end
end

function place_flags()
  Items.new(team1_flag.x, team1_flag.y, 0, team1_flag, "key")
  Items.new(team2_flag.x, team2_flag.y, 0, team2_flag, "sap card")
end

function ctf_idle()
  if Game.type ~= "capture the flag" then
    return;
  end
  if (team1_flag == nil) or (team2_flag == nil) or 
    (# team1_bases == 0) or (# team2_bases == 0) then 
    Players.print(err) 
    for i = 0, 5, 1 do 
      Players.print(" ") 
    end
    return
  end
  if(wait == 0) then
    players_to_bases()
  end
  remove_skulls()  [[-- If they exist --]]
  get_local_facing()
  check_reset()
  use_oxygen()
  use_overlay()
  check_player_land_location()
  captured_flag()
  update_count()
  make_sure_flag_exists()
  carrier_flash()
  compass_on()
end

function remove_skulls()
  for i in Items() do
    if (i.type == "ball") or (i.type == "blue ball") then
      i:delete()
    end
  end
end

function check_reset()
  local team1_player = nil
  local team2_player = nil
  for p in Players() do
    if (p1._original_team == teams[1]) then
      team1_player = p
      break
    end
  end
  for p in Players() do
    if (p1._original_team == teams[2]) then
      team2_player = p
      break
    end
  end
  if (reset_timer[1] == 1) then
    for i in Items() do
      if (i.type == "key") then
        i:delete()
      end
    end
    save_flag(team1_player)
  end
  if (reset_timer[2] == 1) then
    for i in Items() do
      if (i.type == "sap card") then
        i:delete()
      end
    end
    save_flag(team2_player)
  end
end

function distance_from_player(player, ix, iy, iz)
  local px = player.x;
  local py = player.y;
  local pz = player.z; 
  theDistance = math.sqrt((ix - px)^2 + (iy - py)^2 + (iz - pz)^2);
  return theDistance;
end

function use_oxygen()
  if (team1_flag_in_base) then
    flag_position[1] = team1_flag.x / 1024
    flag_position[2] = team1_flag.y / 1024
    flag_position[3] = team1_flag.z / 1024
  end
  for p in Players() do --If team 2 has flag.
    if (p._has_flag and p._original_team == teams[2]) then
      flag_position[1] = p.x
      flag_position[2] = p.y
      flag_position[3] = p.z
    end
  end
  if (team2_flag_in_base) then
    flag_position[4] = team2_flag.x / 1024
    flag_position[5] = team2_flag.y / 1024
    flag_position[6] = team1_flag.z / 1024
  end
  for p in Players() do --If team 1 has flag.
    if (p._has_flag and p._original_team == teams[1]) then
      flag_position[4] = p.x
      flag_position[5] = p.y
      flag_position[6] = p.z
    end
  end
  for p in Players() do
    if (p._original_team == teams[1]) then
      p._distance = distance_from_player(
				p, flag_position[4], flag_position[5], flag_position[6])
    else
      p._distance = distance_from_player(
				p, flag_position[1], flag_position[2], flag_position[3])
    end
  end
  local temp
  for p in Players() do
    temp = 40 - p._distance
    if (temp < 0) then 
      p.oxygen = 0
    else
      p.oxygen =  ( temp / 40 ) * 10800
    end
  end
end

function use_overlay()
  local team1_has_flag = false
  local team2_has_flag = false
  for p in Players() do
    if (p._original_team == teams[1] and p._has_flag) then
      team1_has_flag = true
    elseif (p._original_team == teams[2] and p._has_flag) then
      team2_has_flag = true
    end
    p.overlays[0].color = 2
    p.overlays[0].text = current_captures[1] .. " / " .. Game.kill_limit
    p.overlays[1].color = 7
    p.overlays[1].text = current_captures[2] .. " / " .. Game.kill_limit
    p.overlays[2].color = 0
    if (theFaced._has_flag) then
      p.overlays[2].color = 5
    end
    local theOverlay = facerName;
    local fPercent = math.floor(100 * (theFaced.life/150));
    if (theFaced ~= local_player()) then
      theOverlay = theOverlay.." ("..fPercent.."%)";
    end
    p.overlays[2].text = "      "..theOverlay
  end

  if (team1_has_flag) then
    icon0 = colors.team2 .. icons.carrying;
  elseif (team1_has_flag == false and team2_flag_in_base == false) then
    icon0 = colors.team2 .. icons.dropped;
  elseif (team2_flag_in_base) then
    icon0 = colors.team2 .. icons.notcarrying;
  end

  if (team2_has_flag) then
    icon1 = colors.team1 .. icons.carrying;
  elseif (team2_has_flag == false and team1_flag_in_base == false) then
    icon1 = colors.team1 .. icons.dropped;
  elseif (team1_flag_in_base) then
    icon1 = colors.team1 .. icons.notcarrying;
  end
  for p in Players() do
    p.overlats[0].icon = icon0;
    p.overlats[1].icon = icon1;
  end
end

function check_player_land_location()
  for p in Players() do
    if (p._has_flag and p._original_team == teams[1]) then
      local ev = p.external_velocity
      local x1 = p.x;
      local y1 = p.y;
      local z1 = p.z
      if (p.dead and ec.k == 0 and p.holder_death_checked) then
        for p2 in Players() do
          if (p2._original_team == teams[2]) then
            p2.compass.x = x1
            p2.compass.y = y1
            p2.compass.beacon = true
            p2.compass.lua = true
            flag_position[4] = x1
            flag_position[5] = y1
            flag_position[6] = z1
          end
        end
        p._holder_death_checked = false
        p._has_flag[i+1] = false
        p.color = p._original_color;
      end
    end
    if (p._has_flag and p._original_team == teams[2]) then
      local ev = p.external_velocity
      local x2 = p.x;
      local y2 = p.y;
      local z2 = p.z;
      if (p.dead and p.k == 0 and p._holder_death_checked) then
        for p2 in Players() do
          if (p2._original_team == teams[1]) then
            p2.compass.x = x2
            p2.compass.y = y2
            p2.compass.beacon = true
            p2.compass.lua = true
            flag_position[1] = x2
            flag_position[2] = y2
            flag_position[3] = z2
          end
        end
        p._holder_death_checked = false
        p._has_flag[i+1] = false
        p._color = p._original_color
      end
    end
  end
end

function captured_flag()
  for p in Players() do
    if (p._original_team == teams[1]) then
      if (p._has_flag == true) and (p.polygon == team1_flag) and
			   (team1_flag_in_base) and (not p.dead) then
        p.color = p._original_color
        p._has_flag = false
        team2_flag_in_base = true
        current_captures[1] = current_captures[1] + 1
        p.items["sap card"] = 0
        p.points = p.points + 1
        alert_captured(i, 1)
      end
    else
      if (p._has_flag == true) and (p.polygon == team2_flag) and
			   (team2_flag_in_base) and (not p.dead) then
        p.color = p._original_color
        p._has_flag = false
        team1_flag_in_base = true
        current_captures[2] = current_captures[2] + 1
        p.items["key"] = 0
        p.points = p.points + 1
        alert_captured(i, 2)
      end
    end
  end
end

function alert_captured(player, num)
  if (num == 1) then
    for p in Players() do
      if (p._original_team == teams[1] and p == player) then
        p:print("君は敵の旗をとった！")
      elseif (p._original_team == teams[1] and p ~= player) then
        p:print("君のチームは敵の旗をとった！")
      elseif (p._original_team == teams[2]) then
        p:print("敵は君の旗をとった！")
      end
    end
  else
    for p in Players() do
      if (p._original_team == teams[2] and p == player) then
        p:print("君は敵の旗をとった！")
      elseif (p._original_team == teams[2] and p ~= player) then
        p:print("君のチームは敵の旗をとった！")
      elseif (p._original_team == teams[1]) then
        p:print("敵は君の旗をとった！")
      end
    end
  end
end

function update_count()
  if (count1 > 0) then
    count1 = count1 - 1
  end
  if (count2 > 0) then
    count2 = count2 - 1
  end
  if (wait >= -1) then
    wait = wait - 1
  end
  if (reset_timer[1] > 0) then
    reset_timer[1] = reset_timer[1] - 1
  end
  if (reset_timer[2] > 0) then
    reset_timer[2] = reset_timer[2] - 1
  end
end

function make_sure_flag_exists()
  local flag1exists = false
  local flag2exists = false
  for i in Items() do
    if (i.type == "key") then
      flag1exists = true
    elseif (i.type == "sap card") then
      flag2exists = true
    end
  end
  if (flag1exists == false and team1_flag_in_base == true and count1 <= 0) then
    Items.new(team1_flag.x, team1_flag.y, team1_flag.z, team1_flag, "key")
    count1 = 10
  end
  if (flag2exists == false and team2_flag_in_base == true and count2 <= 0) then
    Items.new(team2_flag.x, team2_flag.y, team2_flag.z, team2_flag, "sap card")
    count2 = 10
  end
end

function carrier_flash()
  for p in Players() do
    if p._has_flag == true then
      p.color = "white"
    end
  end
end

function compass_on()
  local team1_has_flag = false
  local team2_has_flag = false
  local carrier_team1 = nil
  local carrier_team2 = nil
  for p in Players() do
    if (p._has_flag == true) then
      if (p._original_team== teams[1]) then
        carrier_team1 = p
        team1_has_flag = true
      else
        carrier_team2 = p
        team2_has_flag = true
      end
    end
  end
  for p in Players() do
    if (p._original_team == teams[1]) then
      if (team2_has_flag == true) then
	p.compass.x = carrier_team2.x
        p.compass.y = carrier_team2.y
        p.compass.beacon = true
        p.compass.lua = true
      end
    end
    if (p._original_team == teams[2]) then
      if (team1_has_flag == true) then
        p.compass.x = carrier_team1.x
        p.compass.y = carrier_team1.y
        p.compass.beacon = true
        p.compass.lua = true
      end
    end
    if (p._has_flag == false and p._original_team == teams[2]) then
      if (team1_has_flag == true) then
        p.compass.x = carrier_team1.x
        p.compass.y = carrier_team1.y
        p.compass.beacon = true
        p.compass.lua = true
      end
    end
    if (team1_flag_in_base == true) then
      if (p._original_team == teams[1] and not p._has_flag) then
        p.compass.lua = false
      end
    end
    if (team2_flag_in_base == true) then
      if (p._original_team == teams[2] and not p._has_flag) then 
        p.compass.lua = false
      end
    end
    if (p._has_flag and p._original_team == teams[1] and team1_flag_in_base) then
      p.compass.x = team1_flag.x / 1024
      p.compass.y = team1_flag.y / 1024
      p.compass.beacon = true
      p.compass.lua = true
    end
    if (p._has_flag and p._original_team == teams[2] and team2_flag_in_base) then
      p.compass.x = team2_flag.x / 1024
      p.compass.y = team2_flag.y / 1024
      p.compass.beacon = true
      p.compass.lua = true
    end
  end
end

function Triggers.got_item(type, player)
  if Game.type ~= "capture the flag" then
      return;
  end
  if (player._original_team == teams[1]) then
    if (type == "sap card") then
      player._has_flag = true
      alert_teams(1)
      team2_flag_in_base = false
      player._holder_death_checked = true
      reset_timer[2] = 0
    end
    if (type == "key" and team1_flag_in_base == true) then
      deny_pickup(player)
    end
    if (type == "key" and team1_flag_in_base == false) then
      save_flag(player)
      reset_timer[1] = 0
    end
  elseif (player._original_team == teams[2]) then
    if (type == "key") then
      player._has_flag = true
      alert_teams(2)
      team1_flag_in_base = false
      player._holder_death_checked = true
      reset_timer[1] = 0
    end
    if (type == "sap card" and team2_flag_in_base == true) then
      deny_pickup(player)
    end
    if (type == "sap card" and team2_flag_in_base == false) then
      save_flag(player)
      reset_timer[2] = 0
    end
  end
end

function alert_teams(num)
  if (num == 1) then
    for p in Players() do
      if (p._original_team == teams[1] and p._has_flag == true) then
        p:print("君は敵の旗を持っている！")
      elseif (p._original_team == teams[1] and p._has_flag == false) then
        p:print( "君のチームは敵の旗を持っている！")
      elseif (p._original_team == teams[2]) then
        p:print("君の旗はとられた！")
        p:play_sound("alarm", 1)
      end
    end
  else
    for p in Players() do
      if (p._original_team == teams[2] and p._has_flag == true) then
        p:print("君は敵の旗を持っている！")
      elseif (p._original_team == teams[2] and p._has_flag == false) then
        p:print( "君のチームは敵の旗を持っている！")
      elseif (p._original_team == teams[1]) then
        p:print("君の旗はとられた！")
        p:play_sound("alarm", 1)
      end
    end
  end
end

function to_base(player, num_tried)
  if (num_tried < 11) then
    if player._original_teams == teams[1] then
      local poly_has_player = false
      local poly = Game.random (# team1_bases)
      if (num_tried >= 10) then
        player:teleport(team1_bases[poly+1])
      end
      for p in Players() do
        if (p.polygon == team1_bases[poly+1]) then
          poly_has_player = true
          break
        end
      end
      if (poly_has_player == false) then
        player:teleport(team1_bases[poly+1])
      else
        to_base(player, num_tried + 1)
      end
    else
      local poly_has_player = false
      local poly = Game.random(# team2_bases)
      if (num_tried >= 10) then
        player:teleport(team2_bases[poly+1])
      end
      for p in Players() do
        if (p.polygon == team2_bases[poly+1]) then
          poly_has_player = true
          break
        end
      end
      if (poly_has_player == false) then
	player:teleport(team2_bases[poly+1])
      else
        to_base(player, num_tried + 1)
      end
    end
  end
end

function Triggers.player_killed(player, aggressor_player, action, projectile)
  if (player._original_team == teams[1] and player._has_flag)then
    reset_timer[2] = RESET_AMOUNT
  end
  if (player._original_team == teams[2] and player._has_flag)then
    reset_timer[1] = RESET_AMOUNT
  end
end


function Triggers.player_revived(player)
  if (player.color == "white" and player._has_flag) then
    player.color = player._original_team
    player._has_flag = false
  end
  to_base(player, 0)
end

function deny_pickup(player)
  if (player._original_team == teams[1]) then
    player.items["key"] = 0
  else
    player.items["sap card"] = 0
  end
end

function save_flag(player)
  if (player._original_team == teams[1]) then
    Items.new(team1_flag.x, team1_flag.y, team1_flag.z, team1_flag, "key")
    team1_flag_in_base = true
    player.items["key"] = 0
    save_flag_message(1)
  else
    Items.new(team2_flag.x, team2_flag.y, team2_flag.z, team2_flag, "sap card")
    team2_flag_in_base = true
    player.items["sap card"] = 0
    save_flag_message(2)
  end
end

function save_flag_message(num)
  if (num == 1) then
    for p in Players() do
      if (p._original_team == teams[1]) then
        p:print("君の旗は戻ってきた！")
      elseif(p._original_team == teams[2]) then
        p:print( "敵の旗は戻った！")
      end
    end
  else
    for p in Players() do
      if (p._original_team == teams[2]) then
        p:print("君の旗は戻ってきた！")
      elseif(p._original_team == teams[1]) then
        p:print( "敵の旗は戻った！")
      end
    end
  end
end

function ctf_cleanup()
  for p in Players() do
    p.color = p._original_color
    p.team = p._original_team
  end
end

--[[Begin code by Jon Irons for determining which player one is facing --]]

function get_local_facing()
  local a = local_player().monster;
  if (a.valid) then
    if (a.player) then
      local facing_table = {};
      for b in Monsters() do
        if (a ~= b and b.valid) then
          local monster_player = b.player;
          if is_monster_facing(a, b) and monster_player and 
					   (not player_is_dead(monster_player)) then
            table.insert(facing_table, b);
          end
        end
      end
      if (facing_table[1]) then
        local most_close = closest_monster_to(a, facing_table);
        local mc_pl = most_close.player;
        if most_close and mc_pl.team == local_player().team then
          theFaced = mc_pl;
          facerName = theFaced.name;
        end
      else
        facerName = "";
        theFaced = local_player();
      end
    end
  end
end

function is_monster_facing(m1, m2)
  local x1 = m1.x;
  local y1 = m1.y;
  local z1 = m1.z;
  local yaw1 = m1.player.yaw;
  local pitch1 = m1.player.pitch;
  local x2 = m2.x;
  local y2 = m2.y;
  local z2 = m2.z;
  local yaw2 = m2.player.yaw;
  local pitch2 = m2.player.pitch;

  local distance = to.wu * math.sqrt((x1 - x2)^2 + (y1 - y2)^2);
  local x = -1 * to.wu * (x2 - x1);
  local y = to.wu * (y2 - y1);
  local m1angle = yaw1;
  local m2angle =  math.deg(math.atan2(y, x));
  m2angle = math.abs(m2angle - 180);
  if (angle_distance(m1angle, m2angle) <= HORIZ) then
    return true;
  else
    return false;
  end
end

function closest_monster_to(monster, monster_list)
  local ggg;
  local dist1;
  local cdist = 999999999;
  local cindex = nil;
  local mindex = nil;
  for ggg = 1, # monster_list, 1 do
    local dude = monster_list[ggg];
    local dudePl = dude.player;
    local plLive;
    if (dudePl) then
      plDead = dudePl.dead;
    end
    if (dude.valid and dude ~= monster and dudePl and not plDead) then
      local x1 = monster.x;
      local y1 = monster.y;
      local z1 = monster.z;
      local x2 = dude.x;
      local y2 = dude.y;
      local z2 = dude.z;
      dist1 = math.sqrt((x1 - x2)^2 + (y1 - y2)^2);
      if (dist1 < cdist) then
        cdist = dist1;
        cindex = dude;
      end
    end
  end
  return cindex;
end



--[[end Irons code --]]

function angle_distance(angle1, angle2) --[[code by Solra Bizna --]]
--[[ Normalize the angles.--]]
  while angle1 < 0 do 
    angle1 = angle1 + 360 
  end
  while angle1 >= 360 do 
    angle1 = angle1 - 360 
  end
  while angle2 < 0 do 
    angle2 = angle2 + 360 
  end
  while angle2 >= 360 do 
    angle2 = angle2 - 360 
  end
  --[[ Subtract the angles. --]]
  return math.abs(angle1 - angle2)
end
