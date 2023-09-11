function take_item(itm)
  local idx = get_free_slot()
  if idx < 0 then return false end
  inv[idx] = itm
  return true
end

function get_free_slot()
  for i = 1, 6 do
    if not inv[i] then
      return i
    end
  end

  return -1
end

function make_item_pools()
  i_pool_rar = {}
  i_pool_com = {}

  for i = 1, #items.name do
    local knd = items.kind[i]
    if knd == "wep" or knd == "arm" then
      add(i_pool_rar, i)
    else
      add(i_pool_com, i)
    end
  end
end

function make_flr_i_pool()
  flr_i_pool_rar = {}
  flr_i_pool_com = {}

  for i in all(i_pool_rar) do
    if items.min_f[i] <= floor and items.max_f[i] >= floor then
      add(flr_i_pool_rar, i)
    end
  end

  for i in all(i_pool_com) do
    if items.min_f[i] <= floor and items.max_f[i] >= floor then
      add(flr_i_pool_com, i)
    end
  end
end

function get_rare_item()
  if #flr_i_pool_rar > 0 then
    local itm = rnd(flr_i_pool_rar)
    del(flr_i_pool_rar, itm)
    del(i_pool_rar, itm)
    return itm
  else
    return rnd(flr_i_pool_com)
  end
end

function handle_food_names()
  local fud_names, fud = split("jerky,shnitzel,steak,gyros,fricassee,haggis,mett,kebab,burger,meatball,pizza,calzone,pasticio,chops,ham,ribs,roast,meatloaf,chili,stew,pie,taco,burrito,rolls,filet,salami,sandwich,cassoulet,yakitori,poutine")
  local fud_adjs, adj = split("yellow,green,blue,purple,black,sweet,salty,spicy,strange,old,dry,wet,smooth,soft,crusty,pickled,sour,leftover,mom's,steamed,hairy,smoked,mini,stuffed,classic,marinated,bbq,savory,baked,juicy,sloppy,cheesy,hot,cold,zesty")

  itm_known = {}

  for i = 1,#items.name do
    if items.kind[i] == "fud" then
      fud, adj = rnd(fud_names), rnd(fud_adjs)
      items.name[i] = adj.." "..fud
      itm_known[i] = false
      del(fud_names, fud)
      del(fud_adjs, adj)
    end
  end
end