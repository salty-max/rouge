function get_frame(a)
  return a[flr(t / 12) % #a + 1]
end

function draw_spr(s, x, y, c, flp)
  palt(0, false)
  pal(6, c)
  spr(s, x, y, 1, 1, flp)
  pal()
end

function rect_fill(x, y, w, h, c)
  rectfill(x, y, x + max(w - 1, 0), y + max(h - 1, 0), c)
end

function o_print_8(s, x, y, c, oc)
  for i = 1, 8 do
    print(s, x + dir_x[i], y + dir_y[i], oc)
  end
  print(s, x, y, c)
end

function print_center(s, y, c)
  print(s, 64 - #s * 2, y, c)
end

function dist(fx, fy, tx, ty)
  local dx, dy = fx - tx, fy - ty
  return sqrt(dx * dx + dy * dy)
end

function do_fade()
  local p, kmax, col, k = flr(mid(0, fade_perc, 1) * 100)
  for j = 1, 15 do
    col = j
    kmax = flr((p + j * 1.46) / 22)
    for k = 1, kmax do
      col = d_pal[col]
    end
    pal(j, col, 1)
  end
end

function fade_out(spd, dur)
  if (spd == nil) spd = 0.04
  if (dur == nil) dur = 0
  repeat
    fade_perc = min(fade_perc + spd, 1)
    do_fade()
    flip()until fade_perc == 1
  wait(dur)
end

function check_fade()
  if fade_perc > 0 then
    fade_perc = max(fade_perc - 0.04, 0)
    do_fade()
  end
end

function wait(dur)
  repeat
    dur -= 1
    flip()until dur < 0
end

function blank_map(dflt)
  local m = {}
  if dflt == nil then dflt = 0 end

  for x = 0, 15 do
    m[x] = {}
    for y = 0, 15 do
      m[x][y] = dflt
    end
  end

  return m
end

function calc_dist(tx, ty)
  local cand, step, cand_new = {}, 0
  d_map = blank_map(-1)
  add(cand, { x = tx, y = ty })
  d_map[tx][ty] = step

  repeat
    step += 1

    cand_new = {}
    for c in all(cand) do
      for d = 1, 4 do
        local dx, dy = c.x + dir_x[d], c.y + dir_y[d]
        if is_in_bounds(dx, dy) and d_map[dx][dy] == -1 then
          d_map[dx][dy] = step
          if is_walkable(dx, dy) then
            add(cand_new, { x = dx, y = dy })
          end
        end
      end
    end

    cand = cand_new
  until #cand == 0
end

function copy_map(mx, my)
  local tle
  for x = 0, 15 do
    for y = 0, 15 do
      tle = mget(mx + x, my + y)
      mset(x, y, tle)

      if tle == 73 then
        player.x, player.y = x, y
      end
    end
  end
end

function do_shake()
  local sx, sy = 16 - rnd(32), 16 - rnd(32)
  camera(sx * shake, sy * shake)
  shake *= 0.95
  if (shake < 0.05) shake = 0
end