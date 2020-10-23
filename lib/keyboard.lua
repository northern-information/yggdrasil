keyboard = hid.connect()

function keyboard.event(type, code, val)

  screen.ping()

  if keys:is_shift(code) then
    keys:handle_shift(val)
  end

  if not fn.break_splash() then
    fn.dismiss_messages()
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
    buffer:add(keys:get_keycode(code))
  end

  if keys:is_spacebar(code) then
    if buffer:is_empty() then
      tracker:toggle_playback()
    else
      buffer:add(" ")
    end
  end

  if keys:is_return(code) then
    buffer:execute()
  end

  if keys:is_backspace(code) then
    if buffer:is_empty() and tracker:is_focused() then
      tracker:clear_focused_slots()
    else
      buffer:backspace()
    end
  end

  if keys:is_arrow(code) then
    if keys:shifted() then
      tracker:handle_arrow(keys:get_keycode(code))
    else
      if keys:get_keycode(code) == "UP" then
        buffer:up_history()
      elseif keys:get_keycode(code) == "DOWN" then
        buffer:down_history()
      end
      local history = buffer:get_history()
      if history ~= nil then
        buffer:clear()
        buffer:set(history.history_string, history.history_table)
      else
        buffer:clear()
      end
    end
  end

  if keys:is_esc(code) then
    if tracker:has_message() then
      tracker:clear_message()
    elseif tracker:is_focused() then
      tracker:unfocus()
    end
  end

  if keys:is_caps(code) then
    graphics:toggle_hud()
  end

  fn.dirty_screen(true)

end

return keyboard