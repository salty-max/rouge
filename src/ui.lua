function add_window(wx, wy, ww, wh, txt)
  local w = {
    x = wx,
    y = wy,
    w = ww,
    h = wh,
    txt = txt
  }

  add(windows, w)
  return w
end

function draw_windows()
  for w in all(windows) do
    local wx, wy, ww, wh = w.x, w.y, w.w, w.h

    rect_fill(wx, wy, ww, wh, 0)
    rect(wx + 1, wy + 1, wx + ww - 2, wy + wh - 2, 6)

    wx += 4
    wy += 4

    clip(wx, wy, ww - 8, wh - 8)
    if w.cur then
      wx += 6
    end
    for i = 1, #w.txt do
      local txt, c = w.txt[i], 6
      if w.col and w.col[i] then
        c = w.col[i]
      end
      print(txt, wx, wy, c)

      if i == w.cur then
        spr(255, wx - 5 + min(sin(time())), wy)
      end

      wy += 6
    end
    clip()

    if w.dur then
      w.dur -= 1
      if w.dur <= 0 then
        local dif = wh / 4
        w.y += dif / 2
        w.h -= dif

        if wh < 3 then
          del(windows, w)
        end
      end
    else
      if w.butt then
        o_print_8("❎", wx + ww - 15, wy - 1 - max(sin(time())), 6, 0)
      end
    end
  end
end

function show_msg(txt, dur)
  local width = (#txt + 2) * 4 + 7
  local w = add_window(63 - width / 2, 50, width, 13, { " " .. txt })
  w.dur = dur
end

function show_dialog(txt)
  local dialog_h = #txt * 6 + 7
  local start_y = (128 - dialog_h) / 2
  dialog_box = add_window(16, start_y, 94, dialog_h, txt)
  dialog_box.butt = true
end

function add_float(txt, fx, fy, col)
  add(
    float, {
      s = txt,
      x = fx,
      y = fy,
      end_y = fy - 10,
      c = col,
      t = 0
    }
  )
end

function do_floats()
  for f in all(float) do
    f.y += (f.end_y - f.y) / 10
    f.t += 1
    if f.t > 70 then
      del(float, f)
    end
  end
end

function handle_hp_box()
  hp_box.txt[1] = "♥" .. player.hp .. "/" .. player.hp_max
  local hpy = 5
  if player.y < 8 then
    hpy = 110
  end

  hp_box.y += (hpy - hp_box.y) / 5
end

function show_inv()
  local txt, col, itm, eqt = {}, {}
  _upd = update_inv
  for i = 1, 2 do
    itm = eqp[i]
    if eqp[i] then
      eqt = items.name[itm]
      add(col, 6)
    else
      eqt = i == 1 and "[weapon]" or "[armor]"
      add(col, 5)
    end
    add(txt, eqt)
  end
  add(txt, "……………………………………")
  add(col, 6)
  for i = 1, 6 do
    itm = inv[i]
    if inv[i] then
      add(txt, items.name[itm])
      add(col, 6)
    else
      add(txt, "...")
      add(col, 5)
    end
  end
  inv_box = add_window(5, 17, 84, 62, txt)
  inv_box.cur = 1
  inv_box.col = col
  curr_box = inv_box

  local status = "ok"
  if player.bless > 0 then
    status = "bless"
  elseif player.bless < 0 then
    status = "curse"
  end

  stat_box = add_window(5, 5, 84, 13, {"atk:"..player.atk.." def:"..player.def_min.."-"..player.def_max.. " "..status})

  show_hint()
end

function move_menu(w)
  local moved = false
  if btnp(2) then
    sfx(56)
    w.cur -= 1
    w.cur = (curr_box == inv_box and w.cur == 3) and 2 or w.cur
    moved = true
  elseif btnp(3) then
    sfx(56)
    w.cur += 1
    w.cur = (curr_box == inv_box and w.cur == 3) and 4 or w.cur
    moved = true
  end
  w.cur = (w.cur - 1) % #w.txt + 1

  return moved
end

function show_use_menu()
  local idx = inv_box.cur
  local itm = idx < 3 and eqp[idx] or inv[idx - 3]
  if itm == nil then return end

  local knd, txt = items.kind[itm], {}

  if idx > 3 and (knd == "wep" or knd == "arm") then
    add(txt, "equip")
  elseif knd == "fud" then
    add(txt, "eat")
  elseif knd == "drk" then
    add(txt, "drink")
  end

  if knd == "thr" or knd == "fud" then
    add(txt, "throw")
  end

  add(txt, "drop")

  itm_menu_box = add_window(84, idx * 6 + 11, 36, 7 + #txt * 6, txt)
  itm_menu_box.cur = 1
  curr_box = itm_menu_box
end

function use_item()
  local idx, back = inv_box.cur, true
  local itm = idx < 3 and eqp[idx] or inv[idx - 3]
  local verb = itm_menu_box.txt[itm_menu_box.cur]

  if verb == "drop" then
    if idx < 3 then
      eqp[idx] = nil
      update_stats()
    else
      inv[idx - 3] = nil
    end
  elseif verb == "equip" then
    local slot = items.kind[itm] == "wep" and 1 or 2
    inv[idx - 3] = eqp[slot]
    eqp[slot] = itm
    update_stats()
  elseif verb == "eat" or verb == "drink" then
    consume(player, itm)
    inv[idx - 3] = nil
    player.mov = nil
    back = false
    a_t = 0
    _upd = update_pturn
  elseif verb == "throw" then
    thr_slot = idx - 3
    back = false
    _upd = update_throw
  end

  itm_menu_box.dur = 0

  if back then
    del(windows, inv_box)
    del(windows, stat_box)
    show_inv()
    inv_box.cur = idx
  else
    inv_box.dur = 0
    stat_box.dur = 0
    hint_box.dur = 0
  end
end

function show_flr_msg()
  show_msg("floor " .. floor, 60)
end

function show_hint()
  if hint_box then
    hint_box.dur = 0
    hint_box = nil
  end

  if inv_box.cur > 3 then
    local itm = inv[inv_box.cur - 3]
    if itm and items.kind[itm] == "fud" then
      local txt = itm_known[itm] and items.desc[itm] or "???"
      hint_box = add_window(5, 78, #txt * 4 + 7, 13, { txt })
    end
  end
end