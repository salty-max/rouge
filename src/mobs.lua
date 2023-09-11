function add_mob(type, mx, my)
  local m = {
    name = bestiary.name[type],
    x = mx,
    y = my,
    ox = 0,
    oy = 0,
    c = 10,
    flp = false,
    anim = {},
    flash = 0,
    base_atk = bestiary.atk[type],
    atk = bestiary.atk[type],
    def_min = 0,
    def_max = 0,
    hp = bestiary.hp[type],
    hp_max = bestiary.hp[type],
    stun = false,
    bless = 0,
    charge = 1,
    last_moved = false,
    spec = bestiary.spec[type],
    los = bestiary.los[type],
    task = ai_wait
  }

  for i = 0, 3 do
    add(m.anim, bestiary.sp[type] + i)
  end

  add(mobs, m)
  return m
end

function get_mob_at(x, y)
  for m in all(mobs) do
    if m.x == x and m.y == y then
      return m
    end
  end
  return false
end

function is_walkable(x, y, mode)
  mode = mode or ""
  if is_in_bounds(x, y) then
    local tile = mget(x, y)
    if mode == "sight" then
      return not fget(tile, 2)
    else
      if not fget(tile, 0) then
        if mode == "check_mobs" then
          return not get_mob_at(x, y)
        end
        return true
      end
    end
  end

  return false
end

function is_in_bounds(x, y)
  local check = x < 0 or x > 15 or y < 0 or y > 15
  return not check
end

function mob_walk(m, dx, dy)
  m.x += dx
  m.y += dy

  mob_flip(m, dx)

  m.sox, m.soy = -dx * 8, -dy * 8
  m.ox, m.oy = m.sox, m.soy
  m.mov = move_walk
end

function mob_bump(m, dx, dy)
  mob_flip(m, dx)
  m.sox, m.soy = dx * 8, dy * 8
  m.ox, m.oy = 0, 0
  m.mov = move_bump
end

function mob_flip(m, dx)
  m.flp = dx == 0 and m.flp or dx < 0
end

function move_walk(self)
  local time = 1 - a_t
  self.ox = self.sox * time
  self.oy = self.soy * time
end

function move_bump(self)
  local time = a_t > 0.5 and 1 - a_t or a_t
  self.ox = self.sox * time
  self.oy = self.soy * time
end

function hit_mob(am, dm, raw)
  local dmg = am and am.atk or raw

  -- add curse/bless
  if dm.bless < 0 then
    dmg *= 2
  elseif dm.bless > 0 then
    dmg = flr(dmg / 2)
  end

  dm.bless = 0

  local def = dm.def_min + flr(rnd(dm.def_max - dm.def_min + 1))
  dmg -= min(def, dmg)

  dm.hp -= dmg
  dm.flash = 10

  add_float("-" .. dmg, dm.x * 8, dm.y * 8, 9)

  shake = dm == player and 0.07 or 0.05

  if dm.hp <= 0 then
    if dm == player then
      st_killed = am.name
    else
      st_kills += 1
    end
    add(d_mobs, dm)
    del(mobs, dm)
    dm.die = 20
  end
end

function do_ai()
  local moving
  for m in all(mobs) do
    if m != player then
      m.mov = nil
      if m.stun then
        m.stun = false
      else
        m.last_moved = m:task()
        moving = m.last_moved or moving
      end
    end
  end

  if moving then
    _upd = update_ai_turn
    a_t = 0
  else
    player.stun = false
  end
end

function ai_wait(self)
  if can_see(self, player) then
    -- aggro
    self.task = ai_chase
    self.tx, self.ty = player.x, player.y
    add_float("!", self.x * 8 + 2, self.y * 8, 10)
  end
  return false
end

function ai_chase(self)
  if dist(self.x, self.y, player.x, player.y) == 1 then
    -- attack player
    local dx, dy = player.x - self.x, player.y - self.y
    mob_bump(self, dx, dy)
    if self.spec == "stun" and self.charge > 0 then
      stun_mob(player)
      self.charge -= 1
    elseif self.spec == "ghost" and self.charge > 0 then
      hit_mob(self, player)
      bless_mob(player, -1)
      self.charge -= 1
    else
      hit_mob(self, player)
    end
    sfx(57)
    return true
  else
    -- move towards player
    if can_see(self, player) then
      self.tx, self.ty = player.x, player.y
    end

    if self.x == self.tx and self.y == self.ty then
      --de aggro
      self.task = ai_wait
      add_float("?", self.x * 8 + 2, self.y * 8, 10)
    else
      if self.spec == "slow" and self.last_moved then
        return false
      end
      local bdst, cand = 999, {}
      calc_dist(self.tx, self.ty)
      for i = 1, 4 do
        local dx, dy = dir_x[i], dir_y[i]
        local tx, ty = self.x + dx, self.y + dy
        if is_walkable(tx, ty, "check_mobs") then
          local dst = d_map[tx][ty]
          if dst < bdst then
            cand = {}
            bdst = dst
          end

          if dst == bdst then
            add(cand, i)
          end
        end
      end
      if #cand > 0 then
        local c = rnd(cand)
        mob_walk(self, dir_x[c], dir_y[c])
        return true
      end
    end
  end
  return false
end

function can_see(m1, m2)
  return los(m1.x, m1.y, m2.x, m2.y) and dist(m1.x, m1.y, m2.x, m2.y) <= m1.los
end

-- check Line of Sight (LoS) between two points using Bresenham's line algorithm.
function los(x1, y1, x2, y2)
  -- initial setting of `frst` to denote first point in line check.
  local frst, sx, sy, dx, dy = true

  -- if distance between the two points is 1, they have direct sight.
  if dist(x1, y1, x2, y2) == 1 then return true end

  -- determine the direction of movement on the x-axis.
  -- if starting x is less than ending x, move right. Otherwise, move left.
  if x1 < x2 then
    sx, dx = 1, x2 - x1
  else
    sx, dx = -1, x1 - x2
  end

  -- determine the direction of movement on the y-axis.
  -- if starting y is less than ending y, move down. Otherwise, move up.
  if y1 < y2 then
    sy, dy = 1, y2 - y1
  else
    sy, dy = -1, y1 - y2
  end

  -- starting error for Bresenham's algorithm.
  local err, e2 = dx - dy

  -- traverse from (x1, y1) to (x2, y2) one grid cell at a time.
  while (x1 == x2 and y1 == y2) == false do
    -- if the current cell isn't the first and isn't walkable, LoS is blocked.
    if not frst and not is_walkable(x1, y1, "sight") then return false end

    -- calculate error to determine next cell in path.
    e2, frst = err + err, false
    if e2 > -dy then
      err -= dy
      x1 += sx
    end
    if e2 < dx then
      err += dx
      y1 += sy
    end
  end

  -- if function reaches here, there's an unblocked line of sight.
  return true
end

function update_stats()
  local atk, def_min, def_max = player.base_atk, 0, 0

  if eqp[1] then
    atk += items.stat1[eqp[1]]
  end

  if eqp[2] then
    def_min += items.stat1[eqp[2]]
    def_max += items.stat2[eqp[2]]
  end

  player.atk = atk
  player.def_min = def_min
  player.def_max = def_max
end

function consume(mob, itm)
  local eft = items.stat1[itm]

  if not itm_known[itm] then
    show_msg(items.name[itm].. " " .. items.desc[itm] .. "!", 60)
    itm_known[itm] = true
  end

  if mob == player then st_meals += 1 end

  if eft == 1 then
    -- heal
    heal_mob(mob, 1)
  elseif eft == 2 then
    -- bug heal
    heal_mob(mob, 3)
  elseif eft == 3 then
    -- hp max ++
    mob.hp_max += 1
    heal_mob(mob, 1)
  elseif eft == 4 then
    -- stun
    stun_mob(mob)
  elseif eft == 5 then
    -- curse
    bless_mob(mob, -1)
  elseif eft == 6 then
    -- bless
    bless_mob(mob, 1)
  end
end

function heal_mob(mob, amt)
  sfx(51)
  amt = min(amt, mob.hp_max - mob.hp)
  mob.hp += amt
  mob.flash = 10
  add_float("+"..amt, mob.x * 8, mob.y * 8, 11)
end

function stun_mob(mob)
  mob.stun = true
  mob.flash = 10
  add_float("stun", mob.x * 8 - 3, mob.y * 8, 7)
  sfx(51)
end

function bless_mob(mob, val)
  mob.bless = mid(-1, 1, mob.bless + val)
  mob.flash = 10

  local txt = "bless"
  if val < 0 then
    txt = "curse"
  end

  add_float(txt, mob.x * 8 - 5, mob.y * 8, 7)

  if mob.spec == "ghost" and val > 0 then
    add(d_mobs, mob)
    del(mobs, mob)
    mob.die = 20
  end
  sfx(51)
end

function spawn_mobs()
  m_pool = {}
  for i = 2, #bestiary.name do
    if bestiary.min_f[i] <= floor and bestiary.max_f[i] >= floor then
      add(m_pool, i)
    end
  end

  if (#m_pool == 0) return
  
  local placed, min_mobs = 0, 3
  local min_mobs = split("3, 5, 7, 9, 10, 11, 12, 13")
  local max_mobs = split("6, 10, 14, 18, 20, 22, 24, 26")

  local r_pot = {}
  for r in all(rooms) do
    add(r_pot, r)
  end

  repeat
    local r = rnd(r_pot)
    placed += infest_room(r)
    del(r_pot, r)
  until #r_pot == 0 or placed > max_mobs[floor]

  if placed < min_mobs[floor] then
    repeat
      local x, y
      
      repeat
        x, y = flr(rnd(16)), flr(rnd(16))
      until is_walkable(x, y, "check_mobs") and is_floor_tile(x, y)

      add_mob(rnd(m_pool), x, y)
      placed += 1
    until placed >= min_mobs[floor]
  end
end

function infest_room(r)
  if r.no_spawn then return 0 end

  local target, x, y = 2 + flr(rnd(r.w * r.h / 6 - 1))
  target = min(5, target)

  for i = 1, target do
    repeat
      x = r.x + flr(rnd(r.w))
      y = r.y + flr(rnd(r.h))
    until is_walkable(x, y, "check_mobs") and is_floor_tile(x, y)
    local m_idx = rnd(m_pool)
    add_mob(m_idx, x, y)
  end

  return target
end