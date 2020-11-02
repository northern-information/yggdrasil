keyboard = hid.connect()

function keyboard.event(type, code, val)

  screen.ping()
  graphics:ping_cursor_frame()

  if keys:is_shift(code) then keys:handle_shift(val) end

  if not fn.break_splash() then fn.dismiss_messages() end

  if val == 0 then return end -- ignore other keyups

  keys:set_last_space(false)

  print(code)
  print("")

  if keys:is_y_mode() then
    if keys:is_hjkl(code) then
      view:handle_pan(keys:get_keycode(code))
    end
  else
    if keys:is_letter_code(code) or keys:is_number_code(code) or keys:is_symbol(code) then
      if keys:is_shifted() and (keys:is_number_code(code) or keys:is_symbol(code)) then
        buffer:add(keys:get_shifted_keycode(code))
      else
        buffer:add(keys:get_keycode(code))
      end
    end
  end

  if keys:is_spacebar(code) then
    if buffer:is_empty() then
      tracker:toggle_playback()
    else
      keys:set_last_space(true)
      buffer:add(" ")
    end
  end

  if keys:is_return(code) then
    if buffer:is_empty() then
      tracker:select_slot(view:get_x(), view:get_y())
    elseif not buffer:is_empty() then
      buffer:execute()
    end
  end

  if keys:is_backspace_or_delete(code) then
    if buffer:is_empty() and tracker:is_selected() then
      tracker:clear_selected_slots()
    else
      buffer:backspace()
    end
  end

  if keys:is_arrow(code) then
    local i = keys:is_shifted() and 12 or 1
        if keys:get_keycode(code) == "RIGHT" then fn.decrement_increment(i)
    elseif keys:get_keycode(code) == "LEFT"  then fn.decrement_increment(-i)
    elseif keys:get_keycode(code) == "UP"    then buffer:up_history()
    elseif keys:get_keycode(code) == "DOWN"  then buffer:down_history()
    end
  end

  if keys:is_esc(code) then
        if tracker:has_message() then tracker:clear_message()
    elseif tracker:is_selected() then tracker:deselect()
    end
  end

  if keys:is_tab(code) then view:toggle_hud() end

  if keys:is_caps(code) then keys:toggle_y_mode() end

  fn.dirty_screen(true)

end

return keyboard