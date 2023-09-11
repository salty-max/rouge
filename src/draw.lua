function draw_game()
  cls(0)
  if fade_perc == 1 then return end
  map()

  ani_map()

  for m in all(d_mobs) do
    m.die -= 1

    if sin(time() * 8) > 0 then
      draw_mob(m)
    end

    if m.die <= 0 then
      del(d_mobs, m)
    end
  end

  for i = #mobs, 1, -1 do
    draw_mob(mobs[i])
  end

  if _upd == update_throw then
    local tx, ty = throw_tile()
    local lx1, ly1 = player.x * 8 + 3 + thr_dx * 4, player.y * 8 + 3 + thr_dy * 4
    local lx2, ly2 = mid(0, tx * 8 + 3, 127), mid(0, ty * 8 + 3, 127)
  
    rectfill(lx1 + thr_dy, ly1 + thr_dx, lx2 - thr_dy, ly2 - thr_dx, 0)
    
    local thr_anim, mob = flr(t / 7) % 2 == 0, get_mob_at(tx, ty)

    fillp(thr_anim and 0b1010010110100101 or ~0b1010010110100101)
    line(lx1, ly1, lx2, ly2, 7)
    fillp()
    o_print_8("+", lx2 - 1, ly2 - 2, 7, 0)

    if mob and thr_anim  then
      mob.flash = 1
    end
  end

  for x = 0, 15 do
    for y = 0, 15 do
      if fog[x][y] == 1 then
        rect_fill(x * 8, y * 8, 8, 8, 0)
      end
    end
  end

  for f in all(float) do
    o_print_8(f.s, f.x, f.y, f.c, 0)
  end
end

function draw_gover()
  cls(0)
  palt(12, true)
  spr(gover_spr, gover_x, 30, gover_w, 2)
  palt()

  local txt = ""
  if win then
    txt = "you are now a master chef!"
  else
    txt = "killed by a " .. st_killed
  end

  print_center(txt, 44, 6)
  
  color(5)
  cursor(45, 58)
  if not win then
    print("floor: 0".. floor)
  end
  print("steps: ".. st_steps)
  print("kills: ".. st_kills)
  print("meals: ".. st_meals)

  print("press ❎", 48, 90, 5 + min(abs(sin(time() / 2) * 2), 1))
end

function draw_mob(m)
  local c = m.c
  if m.flash > 0 then
    m.flash -= 1
    c = 7
  end
  draw_spr(get_frame(m.anim), m.x * 8 + m.ox, m.y * 8 + m.oy, c, m.flp)
end

function draw_logo()
  if logo_y > -24 then
    logo_t -= 1

    if logo_t <= 0 then
      logo_y += logo_t / 20
    end
    palt(0, false)
    palt(12, true)
    spr(144, 22, logo_y, 14, 3)
    palt()
    o_print_8("etchebest's quest", 30, logo_y + 20, 7, 0)
  end
end

function ani_map()
  t_ani += 1
  if (t_ani < 15) return
  t_ani = 0

  for x = 0, 15 do
    for y = 0, 15 do
      local tle = mget(x, y)
      if tle == 74 or tle == 90 then
        tle += 1
      elseif tle == 75 or tle == 91 then
        tle -= 1
      end

      mset(x, y, tle)
    end
  end
  
end