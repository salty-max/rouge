-- bestiary indexes
-- 1: player, 240, 1 ,5, 4
-- 2: slime, 192, 1, 2, 4

items={name=split("butter knife,cheese knife,paring knife,utility knife,chef's knife,meat cleaver,paper apron,cotton apron,rubber apron,leather apron,chef's apron,butcher's apron,spoon,salad fork,fish fork,granny's fork,food_1,food_2,food_3,food_4,food_5,food_6"),kind=split("wep,wep,wep,wep,wep,wep,arm,arm,arm,arm,arm,arm,thr,thr,thr,thr,fud,fud,fud,fud,fud,fud"),stat1=split("1,2,3,4,5,6,0,0,0,0,1,2,1,2,3,4,1,2,3,4,5,6"),stat2=split("0,0,0,0,0,0,1,2,3,4,3,3,0,0,0,0,0,0,0,0,0,0"),min_f=split("1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,1,1,1,1,1,1"),max_f=split("3,4,5,6,7,8,3,4,5,6,7,8,4,6,7,8,8,8,8,8,8,8"),desc=split(",,,,,,,,,,,,,,,,heals,heals a lot,increases hp,stuns,is cursed,is blessed")}
bestiary={name=split("player,slime,melt,shoggoth,mantis-man,giant scorpion,ghost,golem,drake"),hp=split("5,1,2,3,3,4,5,14,5"),atk=split("1,1,2,1,2,3,3,5,8"),def=split("0,0,0,0,0,0,0,0,0"),los=split("4,4,4,4,4,4,4,4,4"),sp=split("240,192,196,200,204,208,212,216,220"),min_f=split("0,1,2,3,4,5,6,7,8"),max_f=split("0,3,4,5,6,7,8,8,8"),spec=split(",,,spawn?,fast?,stun,ghost,slow,")}

function _init()
  t = 0
  d_pal = split("0, 1, 1, 2, 1, 13, 6, 4, 4, 9, 3, 13, 1, 13, 14")
  -- fade palette
  dir_x = split("-1, 1, 0, 0, 1, 1, -1, -1")
  dir_y = split("0, 0, -1, 1, -1, 1, 1, -1")

  crv_sig = split("255, 214, 124, 179, 233")
  crv_msk = split("0, 9, 3, 12, 6")
  free_sig = split("0, 0, 0, 0, 16, 64, 32, 128, 160, 104, 84, 146")
  free_msk = split("8, 4, 2, 1, 6, 12, 9, 3, 10, 5, 10, 5")

  wall_sig=split("251,233,253,84,146,80,16,144,112,208,241,248,210,177,225,120,179,0,124,104,161,64,240,128,224,176,242,244,116,232,178,212,247,214,254,192,48,96,32,160,245,250,243,249,246,252")
  wall_msk=split("0,6,0,11,13,11,15,13,3,9,0,0,9,12,6,3,12,15,3,7,14,15,0,15,6,12,0,0,3,6,12,9,0,9,0,15,15,7,15,14,0,0,0,0,0,0")



  debug = {}

  is_dyn_gen = false

  start_game()
end

function start_game()
  -- activate music bass loop
  poke(0x3101, 194)
  music(0)

  shake = 0
  -- timer for map animation
  t_ani = 0
  -- fade percentage (1 ==  fully opaque)
  fade_perc = 1
  -- buffer for inputs
  butt_buff = -1

  logo_show = true
  logo_t = 240
  logo_y = 35

  -- flag for skipping AI
  skip_ai = false
  -- array for living mobs
  -- this includes player
  mobs = {}
  -- array for dead mobs
  d_mobs = {}
  d_map = {}
  -- reference for the player mob
  player = add_mob(1, 1, 1)
  a_t = 0
  thr_dx, thr_dy = 1, 0
  inv, eqp = {}, {}
  
  windows = {}
  float = {}
  dialog_box = nil
  
  hp_box = add_window(5, 5, 28, 13, {})
  
  _upd = update_game
  _drw = draw_game

  win = false
  win_flr = 9

  st_steps, st_kills, st_meals, st_killed = 0, 0, 0, ""

  make_item_pools()
  handle_food_names()
  gen_floor(0)
end

function _update60()
  t += 1
  _upd()
  do_floats()
  handle_hp_box()
end

function _draw()
  do_shake()
  _drw()
  draw_windows()
  draw_logo()
  if is_dyn_gen then
    fade_perc = 0
  else
    check_fade()
  end

  cursor(4, 4)
  color(12)
  for d in all(debug) do
    print(d)
  end
end