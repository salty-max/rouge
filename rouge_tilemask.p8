pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function _init()
  sig = {}
  msk = {}

  input_data()

  local stxt = "wall_sig={"
  local mtxt = "wall_msk={"
  for i = 0, 45 do
    local cma = i == 45 and "" or ","
    stxt = stxt .. sig[i] .. cma
    mtxt = mtxt .. msk[i] .. cma
  end
  stxt = stxt .. "}"
  mtxt = mtxt .. "}"

  printh(stxt, "tilemask.txt", true)
  printh(mtxt, "tilemask.txt")
end

function input_data()
  -- simple walls
  sig[16] = 0b10110011
  msk[16] = 0b00001100

  sig[1] = 0b11101001
  msk[1] = 0b00000110

  sig[18] = 0b01111100
  msk[18] = 0b00000011

  sig[33] = 0b11010110
  msk[33] = 0b00001001

  -- inside corners
  sig[2] = 0b11111101
  msk[2] = 0b00000000

  sig[34] = 0b11111110
  msk[34] = 0b00000000

  sig[32] = 0b11110111
  msk[32] = 0b00000000

  sig[0] = 0b11111011
  msk[0] = 0b00000000

  -- outside corners
  sig[3] = 0b01010100
  msk[3] = 0b00001011

  sig[4] = 0b10010010
  msk[4] = 0b00001101

  sig[20] = 0b10100001
  msk[20] = 0b00001110

  sig[19] = 0b01101000
  msk[19] = 0b00000111

  -- singletons
  sig[17] = 0b00000000
  msk[17] = 0b00001111

  sig[22] = 0b11110000
  msk[22] = 0b00000000

  -- thin straights
  sig[35] = 0b11000000
  msk[35] = 0b00001111

  sig[36] = 0b00110000
  msk[36] = 0b00001111

  -- thin corners
  sig[5] = 0b01010000
  msk[5] = 0b00001011

  sig[7] = 0b10010000
  msk[7] = 0b00001101

  sig[39] = 0b10100000
  msk[39] = 0b00001110

  sig[37] = 0b01100000
  msk[37] = 0b00000111

  -- thin ends
  sig[6] = 0b00010000
  msk[6] = 0b00001111

  sig[23] = 0b10000000
  msk[23] = 0b00001111

  sig[38] = 0b00100000
  msk[38] = 0b00001111

  sig[21] = 0b01000000
  msk[21] = 0b00001111

  -- "underpants" aka t-bones
  sig[8] = 0b01110000
  msk[8] = 0b00000011

  sig[9] = 0b11010000
  msk[9] = 0b00001001

  sig[24] = 0b11100000
  msk[24] = 0b00000110

  sig[25] = 0b10110000
  msk[25] = 0b00001100

  -- three corners
  sig[10] = 0b11110001
  msk[10] = 0b00000000

  sig[11] = 0b11111000
  msk[11] = 0b00000000

  sig[26] = 0b11110010
  msk[26] = 0b00000000

  sig[27] = 0b11110100
  msk[27] = 0b00000000

  -- thin-into-wall
  sig[42] = 0b11110011
  msk[42] = 0b00000000

  sig[43] = 0b11111001
  msk[43] = 0b00000000

  sig[44] = 0b11110110
  msk[44] = 0b00000000

  sig[45] = 0b11111100
  msk[45] = 0b00000000

  -- unloved ones
  sig[40] = 0b11110101
  msk[40] = 0b00000000

  sig[41] = 0b11111010
  msk[41] = 0b00000000

  sig[12] = 0b11010010
  msk[12] = 0b00001001

  sig[13] = 0b10110001
  msk[13] = 0b00001100

  sig[29] = 0b11101000
  msk[29] = 0b00000110

  sig[28] = 0b01110100
  msk[28] = 0b00000011

  sig[14] = 0b11100001
  msk[14] = 0b00000110

  sig[15] = 0b01111000
  msk[15] = 0b00000011

  sig[30] = 0b10110010
  msk[30] = 0b00001100

  sig[31] = 0b11010100
  msk[31] = 0b00001001
end
