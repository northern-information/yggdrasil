keyboard = hid.connect()

function keyboard.event(type, code, val)

  screen.ping()
  graphics:ping_cursor_frame()

  if keys:is_shift(code) then
    keys:handle_shift(val)
  end

  if not fn.break_splash() then
    fn.dismiss_messages()
  end

  if val == 0 then return end -- ignore other keyups

  print(code)
  print("")

  if keys:is_letter_code(code) or keys:is_number_code(code) or keys:is_symbol(code) then
    if keys:is_shifted() then
      if keys:is_hjkl(code) then
        graphics:handle_arrow(keys:get_keycode(code))
      elseif keys:is_number_code(code) or keys:is_symbol(code) then
        buffer:add(keys:get_shifted_keycode(code))
      end
    else
      buffer:add(keys:get_keycode(code)) 
    end
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
    if keys:is_shifted() then
      graphics:handle_arrow(keys:get_keycode(code))
    else
      if keys:get_keycode(code) == "RIGHT" then return end
      if keys:get_keycode(code) == "LEFT" then return end
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