function place_flags()
  local curf = 1
  flags, flag_lib = blank_map(0), {}
  for x = 0, 15 do
    for y = 0, 15 do
      if is_walkable(x, y) and flags[x][y] == 0 then
        grow_flag(x, y, curf)
        add(flag_lib, curf)
        curf += 1
      end
    end
  end
end

function grow_flag(mx, my, f)
  local cand, new_cand = {{ x = mx, y = my }}
  flags[mx][my] = f

  repeat
    new_cand = {}

    for c in all(cand) do
      for d = 1, 4 do
        local dx, dy = c.x + dir_x[d], c.y + dir_y[d]
        if is_walkable(dx, dy) and flags[dx][dy] != f then
           flags[dx][dy] = f
          add(new_cand, {x = dx, y = dy})
        end
      end
    end

    cand = new_cand
  until #cand == 0
end

function carve_doors()
  local x1, y1, x2, y2, drs, found, f1, f2 = 1, 1, 1, 1

  repeat
    drs = {}

    for mx = 0, 15 do
      for my = 0, 15 do
        if not is_walkable(mx, my) then
          local sig = get_sig(mx, my)
          found = false
          if sig_comp(sig, 0b11000000, 0b00001111) then
            x1, y1, x2, y2, found = mx, my - 1, mx, my + 1, true
          elseif sig_comp(sig, 0b00110000, 0b00001111) then
            x1, y1, x2, y2, found = mx + 1, my, mx - 1, my, true
          end
          f1, f2 = flags[x1][y1], flags[x2][y2]
          if found and f1 != f2 then
            add(drs, {x = mx, y = my, f1 = f1, f2 = f2})
          end
        end
      end
    end

    if #drs > 0 then
      local d = rnd(drs)

      add(doors, d)
      mset(d.x, d.y, 1)
      snapshot()
      grow_flag(d.x, d.y, d.f1)
      del(flag_lib, d.f2)
    end
  until #drs == 0
end

function carve_scuts()
  local x1, y1, x2, y2, cut, drs, found = 1, 1, 1, 1, 0

  repeat
    drs = {}

    for mx = 0, 15 do
      for my = 0, 15 do
        if not is_walkable(mx, my) then
          local sig = get_sig(mx, my)
          found = false
          if sig_comp(sig, 0b11000000, 0b00001111) then
            x1, y1, x2, y2, found = mx, my - 1, mx, my + 1, true
          elseif sig_comp(sig, 0b00110000, 0b00001111) then
            x1, y1, x2, y2, found = mx + 1, my, mx - 1, my, true
          end
          if found then
            calc_dist(x1, y1)
            if d_map[x2][y2] > 20 then
              add(drs, {x = mx, y = my})
            end
          end
        end
      end
    end

    if #drs > 0 then
      local d = rnd(drs)
      add(doors, d)
      mset(d.x, d.y, 1)
      snapshot()
      cut += 1
    end
  until #drs == 0 or cut >= 3
end

function is_door(x, y)
  local sig = get_sig(x, y)
  if sig_comp(sig, 0b11000000, 0b00001111) or sig_comp(sig, 0b00110000, 0b00001111) then
    for i = 1, 4 do
      if is_in_bounds(x + dir_x[i], y + dir_y[i]) and roomap[x + dir_x[i]][y + dir_y[i]] != 0 then
        return true
      end
    end
  end

  return false
end