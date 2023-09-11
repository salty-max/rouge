function maze_worm()
  local cand
  repeat
    cand = {}
    for mx = 0, 15 do
      for my = 0, 15 do
        if can_carve(mx, my, false) and not is_next_to_room(mx, my) then
          add(cand, {x = mx, y = my})
        end
      end
    end

    if #cand > 0 then
      local c = rnd(cand)
      dig_worm(c.x, c.y)
    end
  until #cand <= 1
end

function dig_worm(x, y)
  local dir, stp = 1 + flr(rnd(4)), 0

  repeat
    local cand = {}
    mset(x, y, 1)
    snapshot()
    if not can_carve(x + dir_x[dir], y + dir_y[dir], false) or (rnd() < 0.5 and stp > 2) then
      stp = 0
      for i = 1, 4 do
        if can_carve(x + dir_x[i], y + dir_y[i], false) then
          add(cand, i)
        end
      end

      if #cand == 0 then
        dir = 8
      else
        dir = rnd(cand)
      end
    end

    x += dir_x[dir]
    y += dir_y[dir]
    stp += 1
  until dir == 8
end

function can_carve(x, y, walk)
  if not is_in_bounds(x, y) then return false end
  local walk = walk == nil and is_walkable(x, y) or walk
  if is_walkable(x, y) == walk then
    return pull_sig(get_sig(x, y), crv_sig, crv_msk) ~= 0
  end

  return false
end

function fill_ends()
  local filled, tle

  repeat
    filled = false
    for mx = 0, 15 do
      for my = 0, 15 do
        tle = mget(mx, my)
        if  can_carve(mx ,my, true) and tle != 72 and tle != 73 then
          filled = true
          mset(mx, my, 2)
          snapshot()
        end
      end
    end
  until not filled
end

function is_next_to_room(x, y, dirs)
  local dirs = dirs or 4
  for i = 1, dirs do
    if is_in_bounds(x + dir_x[i], y + dir_y[i]) and roomap[x + dir_x[i]][y + dir_y[i]] != 0 then
      return true
    end
  end
  return false
end