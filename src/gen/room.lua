function gen_rooms()
  local fmax, rmax = 5, 4
  local max_w, max_h = 10, 10

  repeat
    local r = rnd_room(max_w, max_h)

    if place_room(r) then
      if #rooms == 1 then
        max_w /= 2
        max_h /= 2
      end
      rmax -= 1
      snapshot()
    else
      fmax -= 1
      max_w = max(max_w - 1, 3)
      max_h = max(max_h - 1, 3)
    end
  until fmax <= 0 or rmax <= 0

end

function rnd_room(max_rw, max_rh)
  -- clamp max area
  local rw = 3 + flr(rnd(max_rw - 2))
  local max_rh = mid(3, 35 / rw, max_rh)
  local rh = 3 + flr(rnd(max_rh - 2))

  return {
    x = 0,
    y = 0,
    w = rw,
    h = rh,
  }
end

function place_room(r)
  local cand, c = {}

  for mx = 0, 16 - r.w do
    for my = 0, 16 - r.h do
      if does_room_fit(r, mx, my) then
        add(cand, {x = mx, y = my})
      end
    end
  end

  if #cand == 0 then return false end

  c = rnd(cand)
  r.x, r.y = c.x, c.y
  add(rooms, r)

  for x = 0, r.w - 1 do
    for y = 0, r.h - 1 do
      mset(x + r.x, y + r.y, 1)
      roomap[x + r.x][y + r.y] = #rooms
    end
  end

  return true
end

function does_room_fit(r, mx, my)
  for x = -1, r.w do
    for y = -1, r.h do
      if is_walkable(mx + x, my + y) then
        return false
      end
    end
  end

  return true
end