keys = {}

function keys.init()
  keys.shift = false
  keys.codes = {
    { k = 30, v = "a" },
    { k = 48, v = "b" },
    { k = 46, v = "c" },
    { k = 32, v = "d" },
    { k = 18, v = "e" },
    { k = 33, v = "f" },
    { k = 34, v = "g" },
    { k = 35, v = "h" },
    { k = 23, v = "i" },
    { k = 36, v = "j" },
    { k = 37, v = "k" },
    { k = 38, v = "l" },
    { k = 50, v = "m" },
    { k = 49, v = "n" },
    { k = 24, v = "o" },
    { k = 25, v = "p" },
    { k = 16, v = "q" },
    { k = 19, v = "r" },
    { k = 31, v = "s" },
    { k = 20, v = "t" },
    { k = 22, v = "u" },
    { k = 47, v = "v" },
    { k = 17, v = "w" },
    { k = 45, v = "x" },
    { k = 21, v = "y" },
    { k = 44, v = "z" },
    { k = 11, v = "0" },
    { k = 2,  v = "1" },
    { k = 3,  v = "2" },
    { k = 4,  v = "3" },
    { k = 5,  v = "4" },
    { k = 6,  v = "5" },
    { k = 7,  v = "6" },
    { k = 8,  v = "7" },
    { k = 9,  v = "8" },
    { k = 10, v = "9" },
    { k = 28, v = "RETURN" },
    { k = 14, v = "BACKSPACE" },
    { k = 57, v = "SPACEBAR" },
    { k = 42, v = "SHIFT" },
    { k = 39, v = ";" },
    { k = 15, v = "TAB" },
    { k = 103, v = "UP_ARROW" },
    { k = 106, v = "RIGHT_ARROW" },
    { k = 108, v = "DOWN_ARROW" },
    { k = 105, v = "LEFT_ARROW" },
  }
end

function keys:get_keycode(code)
  for foo, bar in pairs(self.codes) do
    if bar.k == code then
      return bar.v
    end
  end
end

function keys:is_letter_code(code)
  -- a thru z
  local check = {
    30, 48, 46, 32, 18, 33, 34, 35, 23, 36, 
    37, 38, 50, 49, 24, 25, 16, 19, 31, 20, 
    22, 47, 17, 45, 21, 44, 11
  }
  return fn.table_contains(check, code)
end

function keys:is_number_code(code)
  -- 0 thru 9
  local check = {
    11, 2, 3, 4, 5, 6, 7, 8, 9, 10
  }
  return fn.table_contains(check, code)
end

function keys:is_return(code)
  return 28 == code
end

function keys:is_backspace(code)
  return 14 == code
end

function keys:is_spacebar(code)
  return 57 == code
end

function keys:is_shift(code)
  return (42 == code) or (54 == code)
end

function keys:is_tab(code)
  return 15 == code
end

function keys:is_arrow(code)
  return (103 == code) or (106 == code) or (108 == code) or (105 == code)
end

return keys