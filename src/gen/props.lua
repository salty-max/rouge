function start_end()
  local high, low, px, py, ex, ey = 0, 999
  
  repeat
    px, py = flr(rnd(16)), flr(rnd(16))
  until is_walkable(px, py)

  calc_dist(px, py)
  
  for x = 0, 15 do
    for y = 0, 15 do
      local tmp = d_map[x][y]
      if is_walkable(x, y) and tmp > high then
        px, py = x, y
        high = tmp
      end
    end
  end

  calc_dist(px, py)
  high = 0
  for x = 0, 15 do
    for y = 0, 15 do
      local tmp = d_map[x][y]
      if tmp > high and can_carve(x, y) then
        ex, ey, high = x, y, tmp
      end
    end
  end

  mset(ex, ey, 72)
  snapshot()

  for x = 0, 15 do
    for y = 0, 15 do
      local tmp = d_map[x][y]
      if tmp > 0 then
        local score = start_score(x, y)
        tmp = tmp - score
        if tmp < low and score >= 0 then 
          px, py, low = x, y, tmp
        end
      end
    end
  end

  if roomap[px][py] > 0 then
    rooms[roomap[px][py]].no_spawn = true
  end
  
  mset(px, py, 73)
  player.x, player.y = px, py
  snapshot()
end

function start_score(x, y)
  if roomap[x][y] == 0 then
    if is_next_to_room(x, y, 8) then
      return -1
    end

    if is_freestanding(x, y) > 0 then
      return 5
    else
      if can_carve(x, y) then
        return 0
      end
    end
  else
    local scr = is_freestanding(x, y)
    if scr > 0 then
      return scr <= 8 and 3 or 0
    end
  end

  return -1
end

function place_doors()
  for d in all(doors) do
    local dx, dy = d.x, d.y
    local tle = mget(dx, dy)
    if is_floor_tile(dx, dy) and is_walkable(dx, dy) and is_door(dx, dy) and not is_next_to_tile(dx, dy, 71) then
      mset(dx, dy, 71)
      snapshot()
    end
  end
end

function prettify_walls()
  for x = 0, 15 do
    for y = 0, 15 do
      if mget(x, y) == 2 then
        local sig, tle = get_sig(x, y), 3
        local w_tle = pull_sig(sig, wall_sig, wall_msk)

        tle = w_tle == 0 and 3 or w_tle + 15
        mset(x, y, tle)
      elseif mget(x, y) == 1 then
        local tle = mget(x, y - 1)
        if not is_walkable(x, y - 1) then
          if tle == 35 or tle == 37 or tle == 53 then
            mset(x, y, 5)
          elseif tle == 36 or tle == 39 or tle == 55 then
            mset(x, y, 7)
          elseif tle == 54 then
            mset(x, y, 6)
          else
            mset(x, y, 4)
          end
        end
      end
    end
  end
end

function deco_rooms()
  farn_arr = split("1, 9, 10, 10, 10, 11, 11, 11, 12, 13")
  dirt_arr = split("1, 9, 14, 15")
  pots_arr = split("1, 1, 65, 66")
  
  local funcs, func, rpot = {deco_carpet, deco_dirt, deco_torch, deco_farn, deco_pots}, deco_pots, {}

  for r in all(rooms) do
    add(rpot, r)
  end

  repeat
    local r = rnd(rpot)
    del(rpot, r)
    for x = 0, r.w - 1 do
      for y = r.h - 1, 1, -1 do
        if mget(r.x + x, r.y + y) == 1 then
          func(r, r.x + x, r.y + y, x, y)
        end
      end
    end
    func = rnd(funcs)
  until #rpot == 0
end

function deco_carpet(r, tx, ty, x, y)
  deco_torch(r, tx, ty, x, y)
  if x > 0 and x < r.w - 1 and y < r.h - 1 then
    mset(tx, ty, 8)
  end
end

function deco_dirt(r, tx, ty)
  mset(tx, ty, rnd(dirt_arr))
end

function deco_torch(r, tx, ty, x ,y)
  if rnd(3) > 1 and y % 2 == 1 and not is_next_to_tile(tx, ty, 71) then
    if x == 0 then
      mset(tx, ty, 74)
    elseif x == r.w - 1 then
      mset(tx, ty, 90)
    end
  end
end

function deco_farn(r, tx, ty)
  mset(tx, ty, rnd(farn_arr))
end

function deco_pots(r, tx, ty)
  if is_walkable(tx, ty, "check_mobs") and not is_next_to_tile(tx ,ty, 71) and not sig_comp(get_sig(tx, ty), 0, 0b00001111) then
    mset(tx, ty, rnd(pots_arr))
  end
end

function is_next_to_tile(x, y, tle)
  for i = 1, 4 do
    local dx, dy = x + dir_x[i],  y + dir_y[i]
    if is_in_bounds(dx, dy) and mget(dx, dy) == tle then
      return true
    end
  end

  return false
end

function place_chests()
  local chest_dice, r_pot, rare = split("1, 1, 1, 1, 2, 3"), {}, true
  local n_to_place = rnd(chest_dice)
  for r in all(rooms) do
    add(r_pot, r)
  end

  while n_to_place > 0 and #r_pot > 0 do
    local r = rnd(r_pot)
    del(r_pot, r)
    place_chest(r, rare)
    rare = false
    n_to_place -= 1
  end
end

function place_chest(r, rare)
  local x, y
      
  repeat
    x, y = r.x + flr(rnd(r.w - 2)) + 1, r.y + flr(rnd(r.h - 2)) + 1
  until mget(x, y) == 1

  mset(x, y, rare and 70 or 68)
end

function is_freestanding(x, y)
  return pull_sig(get_sig(x, y), free_sig, free_msk)
end
