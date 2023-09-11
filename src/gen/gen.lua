function gen_floor(f)
  floor = f
  mobs = {}
  add(mobs, player)
  fog = blank_map(0)
  
  if floor == 1 then
    -- remove music bass loop for smooth transition
    poke(0x3101, 66)
  end

  if floor == 0 then
    copy_map(16, 0)
  elseif floor == win_flr then
    copy_map(32, 0)
  else
    make_flr_i_pool()
    fog = blank_map(1)
    map_gen()
    unfog()
  end

end

function map_gen()
  repeat
    copy_map(48, 0)
    rooms = {}
    roomap = blank_map(0)
    doors = {}

    gen_rooms()
    maze_worm()
    place_flags()
    carve_doors()

    if #flag_lib > 1 then
      debug[1] = "reconnected area"
    end
  until #flag_lib == 1
  carve_scuts()
  start_end()
  fill_ends()
  prettify_walls()
  place_doors()
  place_chests()
  spawn_mobs()
  deco_rooms()
end

function snapshot()
  if not is_dyn_gen then return end
  cls()
  map()
  for i = 0, 5 do
    flip()
  end
end

