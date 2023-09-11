function update_game()
  if dialog_box then
    if get_butt() == 5 then
      dialog_box.dur = 0
      dialog_box = nil
    end
  end
  buffer_butt()
  handle_butt(butt_buff)
  butt_buff = -1
end

function update_gover()
  if btnp(5) then
    sfx(54)
    fade_out()
    start_game()
  end
end

function update_pturn()
  buffer_butt()

  a_t = min(a_t + 0.128, 1)
  
  if player.mov then
    player:mov()
  end

  if a_t == 1 then    
    _upd = update_game

    if trigger_step() then return end

    if check_end() and not skip_ai then
      do_ai()
    end

    skip_ai = false
  end
end

function update_ai_turn()
  buffer_butt()
  a_t = min(a_t + 0.128, 1)

  for m in all(mobs) do
    if m != player and m.mov then
      m:mov()
    end
  end

  if a_t == 1 then
    _upd = update_game
    if check_end() then
      if player.stun then
        player.stun = false
        do_ai()
      end
    end
  end
end

function update_inv()
  if move_menu(curr_box) then
    show_hint()
  end

  if btnp(5) then
    sfx(53)
    if curr_box == inv_box then
      _upd = update_game
      inv_box.dur = 0
      stat_box.dur = 0
      if hint_box then
        hint_box.dur = 0
      end
    elseif curr_box == itm_menu_box then
      itm_menu_box.dur = 0
      curr_box = inv_box
    end
  end

  if btnp(4) then
    sfx(54)
    if curr_box == inv_box and inv_box.cur != 3 then
      show_use_menu()
    elseif curr_box == itm_menu_box then
      use_item()
    end
  end
end

function update_throw()
  local b = get_butt()
  if b >= 0 and b < 4 then
    thr_dx, thr_dy = dir_x[b + 1], dir_y[b + 1]
  end

  if b == 5 then
    a_t = 0
    _upd = update_pturn
  elseif b == 4 then
    throw()
  end
end