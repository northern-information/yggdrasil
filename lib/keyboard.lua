keyboard = hid.connect()

function keyboard.event(type, code, val)
  screen.ping()
  graphics:ping_cursor_frame()

  if keys:is_shift(code) then keys:handle_shift(val) end
  if keys:is_ctrl(code) then keys:handle_ctrl(val) end

  if not fn.break_splash() then fn.dismiss_messages() end

  if val == 0 then return end -- ignore other keyups

  buffer:set_last_space(false)

  print(code)
  print("")

  if keys:is_y_mode() then
    if keys:is_shifted() and keys:is_number_code(code) and tracker:is_selected() then 
      tracker:select_tracks(tonumber(keys:get_keycode_value(code)))
    else
       if keys:is_number_code(code) then tracker:select_tracks(tonumber(keys:get_keycode_value(code)))
      elseif keys:equals(code, "q") then tracker:unmute()
      elseif keys:equals(code, "w") then tracker:unsolo()
      elseif keys:equals(code, "e") then tracker:enable()
      elseif keys:equals(code, "a") then tracker:mute()
      elseif keys:equals(code, "s") then tracker:solo()
      elseif keys:equals(code, "d") then tracker:disable()
      elseif keys:equals(code, "f") then fn.decrement_increment(keys:is_shifted() and -12 or -1)
      elseif keys:equals(code, "g") then fn.decrement_increment(keys:is_shifted() and 12 or 1)
      elseif keys:equals(code, "h") then view:handle_pan(keys:get_keycode_value(code))
      elseif keys:equals(code, "j") then view:handle_pan(keys:get_keycode_value(code))
      elseif keys:equals(code, "k") then view:handle_pan(keys:get_keycode_value(code))
      elseif keys:equals(code, "l") then view:handle_pan(keys:get_keycode_value(code))
      end
    end
  else
    if keys:is_letter_code(code) or keys:is_number_code(code) or keys:is_symbol(code) then
      if keys:is_shifted() and (keys:is_number_code(code) or keys:is_symbol(code)) then
        buffer:add(keys:get_shifted_keycode(code))
      else
        buffer:add(keys:get_keycode_value(code))
      end
    end
  end

  if keys:is_spacebar(code) then
    if buffer:is_empty() then
      tracker:toggle_playback()
    else
      if not buffer:is_last_space() then
        buffer:set_last_space(true)
        buffer:add(" ")
      end
    end
  end

  if keys:is_backspace_or_delete(code) then
    if buffer:is_last_space() then
      buffer:set_last_space(false)
    end
    buffer:backspace()
  end

  if keys:is_arrow(code) then
    local i = keys:is_shifted() and 12 or 1
        if keys:get_keycode_value(code) == "RIGHT" then print("move cursor right")
    elseif keys:get_keycode_value(code) == "LEFT"  then print("move cursor left")
    elseif keys:get_keycode_value(code) == "UP"    then buffer:up_history()
    elseif keys:get_keycode_value(code) == "DOWN"  then buffer:down_history()
    end
  end

  if keys:is_ctrled() then
    if keys:is_backspace_or_delete(code) and buffer:is_empty() and tracker:is_selected() then
        tracker:clear_selected_slots()
    elseif keys:get_keycode_value(code) == "RIGHT" then 
      fn.decrement_increment(keys:is_shifted() and 12 or 1)
    elseif keys:get_keycode_value(code) == "LEFT" then 
      fn.decrement_increment(keys:is_shifted() and -12 or -1)
    end
  end

  if keys:is_esc(code) then
        if tracker:has_message() then tracker:clear_message()
    elseif tracker:is_info() then tracker:set_info(false)
    elseif tracker:is_selected() then tracker:deselect()
    end
  end

  if keys:is_tab(code) then page:cycle() end

  if keys:is_caps(code) then keys:toggle_y_mode() end

  if keys:is_return(code) then
    if buffer:is_empty() then
      tracker:select_slot(view:get_x(), view:get_y())
    elseif not buffer:is_empty() then
      buffer:execute()
    end
  end

  if keys ~= nil then
    fn.dirty_screen(true)
  end

end

return keyboard