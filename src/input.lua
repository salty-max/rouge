function get_butt()
  for i = 0, 5 do
    if btnp(i) then
      return i
    end
  end

  return -1
end

function buffer_butt()
  if butt_buff == -1 then
    butt_buff = get_butt()
  end
end

function handle_butt(b)
  if b < 0 then return end
  if logo_t > 0 then logo_t = 0 end
  if b < 4 then
    move_player(dir_x[b + 1], dir_y[b + 1])
  elseif b == 4 then
    sfx(54)
    show_inv()
  elseif b == 5 then
  --  player.hp = 0
  --  st_killed = "slime"
    gen_floor(floor + 1)
  end
end