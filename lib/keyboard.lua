keyboard = hid.connect()

function keyboard.event(type, code, val)
  screen.ping()
  graphics:ping_cursor_frame()

  if keys:is_shift(code) then keys:handle_shift(val) end
  if keys:is_ctrl(code) then keys:handle_ctrl(val) end

  if not fn.break_splash() then fn.dismiss_messages() end

  if val == 0 then return end -- ignore other keyups


  print(code)
  print("")

  if keys:is_return(code) then
    if terminal:is_empty() then
      if not tracker:is_selected() then
        tracker:select_slot(view:get_x(), view:get_y())
      elseif not editor:is_open() and #tracker:get_selected_slots() == 1 then
        editor:activate(view:get_x(), view:get_y())
      elseif editor:is_open() then
        editor:commit_and_close()
      end
    elseif not terminal:is_empty() then
      terminal:execute()
    end
  end

  if keys:is_esc(code) then
        if tracker:has_message() then tracker:clear_message()
    elseif tracker:is_info()     then tracker:set_info(false)
    elseif editor:is_open()      then editor:close()
    else tracker:deselect()
    end
  end

  if editor:is_open() then
  
    if keys:is_arrow(code) then
          if keys:get_keycode_value(code) == "RIGHT" then view:pan_x(1)
      elseif keys:get_keycode_value(code) == "LEFT"  then view:pan_x(-1)
      elseif keys:get_keycode_value(code) == "UP"    then view:pan_y(-1)
      elseif keys:get_keycode_value(code) == "DOWN"  then view:pan_y(1)
      end
      tracker:select_slot(view:get_x(), view:get_y())
      editor:clear()
      editor:activate(view:get_x(), view:get_y())
    end
    




  else

    if keys:is_ctrled() then
      if keys:is_backspace_or_delete(code) and terminal:is_empty() then
          tracker:clear_selected_slots()
      elseif keys:get_keycode_value(code) == "RIGHT" then 
        fn.decrement_increment(keys:is_shifted() and 12 or 1)
      elseif keys:get_keycode_value(code) == "LEFT" then 
        fn.decrement_increment(keys:is_shifted() and -12 or -1)
      end
    end


    if keys:is_y_mode() then
      if keys:is_shifted() then
            if keys:is_number_code(code) then tracker:select_range_of_tracks(tonumber(keys:get_keycode_value(code)))
        elseif keys:equals(code, "[") then tracker:adjust_level(-0.1)
        elseif keys:equals(code, "]") then tracker:adjust_level(0.1)
        end
      else
        if keys:is_number_code(code) then 
            tracker:deselect()
            tracker:select_track(tonumber(keys:get_keycode_value(code)))
        elseif keys:equals(code, "q") then tracker:unmute()
        elseif keys:equals(code, "w") then tracker:unsolo()
        elseif keys:equals(code, "e") then tracker:enable()
        elseif keys:equals(code, "y") then keys:toggle_y_mode()
        elseif keys:equals(code, "a") then tracker:mute()
        elseif keys:equals(code, "s") then tracker:solo()
        elseif keys:equals(code, "d") then tracker:disable()
        elseif keys:equals(code, "f") then fn.decrement_increment(keys:is_shifted() and -12 or -1)
        elseif keys:equals(code, "g") then fn.decrement_increment(keys:is_shifted() and 12 or 1)
        elseif keys:equals(code, "h") then view:handle_pan(keys:get_keycode_value(code))
        elseif keys:equals(code, "j") then view:handle_pan(keys:get_keycode_value(code))
        elseif keys:equals(code, "k") then view:handle_pan(keys:get_keycode_value(code))
        elseif keys:equals(code, "l") then view:handle_pan(keys:get_keycode_value(code))
        elseif keys:equals(code, "[") then tracker:adjust_level(-0.01)
        elseif keys:equals(code, "]") then tracker:adjust_level(0.01)
        end
      end
    else
      if keys:is_letter_code(code) or keys:is_number_code(code) or keys:is_symbol(code) then
        if keys:is_shifted() and (keys:is_number_code(code) or keys:is_symbol(code)) then
          terminal:add(keys:get_shifted_keycode(code))
        else
          terminal:add(keys:get_keycode_value(code))
        end
      end
    end

    if keys:is_spacebar(code) then
      if terminal:is_empty() then
        tracker:toggle_playback()
      else
        terminal:add(" ")
      end
    end

    if keys:is_backspace_or_delete(code) then
      terminal:backspace()
    end

    if keys:is_arrow(code) then
          if keys:get_keycode_value(code) == "RIGHT" then terminal:move_cursor_index(1)
      elseif keys:get_keycode_value(code) == "LEFT"  then terminal:move_cursor_index(-1)
      elseif keys:get_keycode_value(code) == "UP"    then terminal:up_history()
      elseif keys:get_keycode_value(code) == "DOWN"  then terminal:down_history()
      end
    end


    if keys:is_tab(code) then page:cycle() end

    if keys:is_caps(code) then keys:toggle_y_mode() end

  end

  if keys ~= nil then
    fn.dirty_screen(true)
  end

end

return keyboard