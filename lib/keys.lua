keys = {}

function keys.init()
  keys.y_mode  = false
  keys.alt   = false
  keys.ctrl  = false
  keys.opt   = false
  keys.shift = false
  keys.caps  = false
  keys.codes = {
    { k = 1,   v = "ESC" },
    { k = 10,  v = "9" },
    { k = 103, v = "UP" },
    { k = 105, v = "LEFT" },
    { k = 106, v = "RIGHT" },
    { k = 108, v = "DOWN" },
    { k = 111, v = "DELETE" },
    { k = 125, v = "OPT" },
    { k = 11,  v = "0" },
    { k = 14,  v = "BACKSPACE" },
    { k = 15,  v = "TAB" },
    { k = 16,  v = "q" },
    { k = 17,  v = "w" },
    { k = 18,  v = "e" },
    { k = 19,  v = "r" },
    { k = 2,   v = "1" },
    { k = 20,  v = "t" },
    { k = 21,  v = "y" },
    { k = 22,  v = "u" },
    { k = 23,  v = "i" },
    { k = 24,  v = "o" },
    { k = 25,  v = "p" },
    { k = 26,  v = "["},
    { k = 27,  v = "]"},
    { k = 28,  v = "RETURN" },
    { k = 29,  v = "CTRL" },
    { k = 3,   v = "2" },
    { k = 30,  v = "a" },
    { k = 31,  v = "s" },
    { k = 32,  v = "d" },
    { k = 33,  v = "f" },
    { k = 34,  v = "g" },
    { k = 35,  v = "h" },
    { k = 36,  v = "j" },
    { k = 37,  v = "k" },
    { k = 38,  v = "l" },
    { k = 39,  v = ";" },
    { k = 4,   v = "3" },
    { k = 42,  v = "SHIFT" },
    { k = 44,  v = "z" },
    { k = 45,  v = "x" },
    { k = 46,  v = "c" },
    { k = 47,  v = "v" },
    { k = 48,  v = "b" },
    { k = 49,  v = "n" },
    { k = 5,   v = "4" },
    { k = 50,  v = "m" },
    { k = 51,  v = "," },
    { k = 52,  v = "." },
    { k = 53,  v = "/" },
    { k = 54,  v = "SHIFT" },
    { k = 56,  v = "ALT" },
    { k = 57,  v = "SPACEBAR" },
    { k = 58,  v = "CAPS" },
    { k = 6,   v = "5" },
    { k = 7,   v = "6" },
    { k = 8,   v = "7" },
    { k = 9,   v = "8" },
    -- { k = 41,  v = "`" },
    { k = 13,  v = "=" },
    { k = 12,  v = "-" },
    { k = 97,  v = "CTRL" },
  }
  keys.shift_codes = {
    -- { k = 10,  v = "(" },
    -- { k = 11,  v = ")" },
    { k = 12,  v = "_" },
    { k = 13,  v = "+" },
    { k = 2,   v = "!" },
    -- { k = 3,   v = "@" },
    { k = 4,   v = "#" },
    -- { k = 41,  v = "~" },
    -- { k = 5,   v = "$" },
    -- { k = 6,   v = "%" },
    -- { k = 7,   v = "^" },
    -- { k = 8,   v = "&" },
    -- { k = 9,   v = "*" },
    { k = 39,  v = ":" },
    { k = 51,  v = "<" },
    { k = 52,  v = ">" },
    { k = 53,  v = "?" },
  }
end

function keys:equals(code, check)
  return self:get_keycode_value(code) == check
end

function keys:get_keycode_value(code)
  for foo, bar in pairs(self.codes) do
    if bar.k == code then
      return bar.v
    end
  end
end

function keys:get_shifted_keycode(code)
  for foo, bar in pairs(self.shift_codes) do
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

function keys:is_symbol(code)
  local check = {
    2, 4, 12, 13, 39, 51, 52, 53
  }
  return fn.table_contains(check, code)
end

function is_left_bracket(code)
  return 26 == code
end

function is_right_bracket(code)
  return 27 == code
end

function keys:is_return(code)
  return 28 == code
end

function keys:is_backspace_or_delete(code)
  return (14 == code) or (111 == code)
end

function keys:is_spacebar(code)
  return 57 == code
end

function keys:is_tab(code)
  return 15 == code
end

function keys:is_arrow(code)
  return (103 == code) or (106 == code) or (108 == code) or (105 == code)
end

function keys:is_esc(code)
  return 1 == code
end

function keys:is_caps(code)
  return 58 == code
end

function keys:handle_caps(val)
  if not self.caps and val == 1 then
    self.caps = true
  elseif val == 0 then
    self.caps = false
  end
end
    
function keys:is_capsed()
  return self.caps
end

function keys:is_ctrl(code)
  return (29 == code) or (97 == code)
end

function keys:handle_ctrl(val)
  if not self.ctrl and val == 1 then
    self.ctrl = true
  elseif val == 0 then
    self.ctrl = false
  end
end

function keys:is_ctrled()
  return self.ctrl
end

function keys:is_opt(code)
  return 125 == code
end

function keys:handle_opt(val)
  if not self.opt and val == 1 then
    self.opt = true
  elseif val == 0 then
    self.opt = false
  end
end

function keys:is_opted()
  return self.opt
end

function keys:is_alt(code)
  return 56 == code
end

function keys:handle_alt(val)
  if not self.alt and val == 1 then
    self.alt = true
  elseif val == 0 then
    self.alt = false
  end
end

function keys:is_alted()
  return self.alt
end

function keys:is_shift(code)
  return (42 == code) or (54 == code)
end

function keys:handle_shift(val)
  if not self.shift and val == 1 then
    self.shift = true
  elseif val == 0 then
    self.shift = false
  end
end

function keys:is_shifted()
  return self.shift
end

function keys:is_y_mode()
  return self.y_mode
end

function keys:toggle_y_mode()
  self.y_mode = not self.y_mode
end

return keys