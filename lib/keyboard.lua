keyboard = hid.connect()

function keyboard.event(type, code, val)

  if keys:is_shift(code) then
    if not keys.shift and val == 1 then
      keys.shift = true
    elseif val == 0 then
      keys.shift = false
    end
  end

  if val == 0 then return end -- ignore other keyups

  print(code)
  print(keys.shift)
  -- print(keys:get_keycode(code))
  -- print("is letter:", keys:is_letter_code(code))
  -- print("is number:", keys:is_number_code(code))
  -- print("is backspace:", keys:is_backspace(code))

  -- if keys.shift then ... end
  
  if keys:is_letter_code(code) or keys:is_number_code(code) then
    y.buffer = y.buffer .. keys:get_keycode(code)
  end

  if keys:is_spacebar(code) then
    y.buffer = y.buffer .. " "
  end

  if keys:is_return(code) then
    fn.run_command()
    y.buffer =  ""
  end

  if keys:is_backspace(code) then
    y.buffer = y.buffer:sub(1, -2)
  end

  fn.dirty_screen(true)

end

return keyboard