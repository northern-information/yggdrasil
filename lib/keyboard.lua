keyboard = hid.connect()

function keyboard.event(type, code, val)

  screen.ping()
  graphics:ping_cursor_frame()
  if keys:is_shift(code) then keys:handle_shift(val) end
  if keys:is_ctrl(code) then keys:handle_ctrl(val) end
  if keys:is_opt(code) then keys:handle_opt(val) end
  if keys:is_alt(code) then keys:handle_alt(val) end
  if not fn.break_splash() then fn.dismiss_messages() end
  if val == 0 then return end -- ignore other keyups
  if config.settings.dev_mode then print(code) print("") end



  -- eternal return



  if keys:is_return(code) and terminal:is_empty() then
    if not tracker:is_selected() then
      tracker:select_slot(view:get_x(), view:get_y())
    elseif #tracker:get_selected_slots() == 1 then
      local slot = tracker:get_selected_slots()[1]
      if tracker:is_selected() and (view:get_x() ~= slot:get_x() or view:get_y() ~= slot:get_y()) then
        tracker:select_slot(view:get_x(), view:get_y())
      elseif not editor:is_open() then
        editor:activate(view:get_x(), view:get_y())
        editor:select_field(1)
      elseif editor:is_open() and editor:is_unsaved_changes() and editor:is_valid() then
        editor:commit()
      elseif editor:is_open() and editor:is_valid() then
        editor:clear()
        editor:close()
      end
    end
  elseif keys:is_return(code) and not terminal:is_empty() then
    terminal:execute()
    terminal:set_focus(true)
  end



  -- eternal escape



  if keys:is_esc(code) then
        if tracker:has_message() then tracker:clear_message()
    elseif tracker:is_info()     then tracker:set_info(false)
    elseif editor:is_open()      then editor:clear() editor:close()
    else   tracker:deselect()
    end
  end



  -- eternal tab & caps



  if keys:is_tab(code) then page:cycle() end

  if keys:is_caps(code) then keys:toggle_y_mode() end



  -- editor



  if editor:is_open() then

    if keys:is_arrow(code) and keys:is_mod() then
      local pan = keys:is_shifted() and 10 or 1
          if keys:equals(code, "RIGHT") then view:pan_x(1 * pan)
      elseif keys:equals(code, "LEFT")  then view:pan_x(-1 * pan)
      elseif keys:equals(code, "UP")    then view:pan_y(-1 * pan)
      elseif keys:equals(code, "DOWN")  then view:pan_y(1 * pan)
      end
      tracker:select_slot(view:get_x(), view:get_y())
      editor:clear()
      editor:activate(view:get_x(), view:get_y())

    elseif keys:is_arrow(code) then
          if keys:equals(code, "RIGHT") then editor:get_focused_field().input_field:move_cursor_index(1)
      elseif keys:equals(code, "LEFT")  then editor:get_focused_field().input_field:move_cursor_index(-1)
      elseif keys:equals(code, "UP")    then editor:increment_fields(-1)
      elseif keys:equals(code, "DOWN")  then editor:increment_fields(1)
      end
    
    elseif keys:is_tab(code) then
      if keys:is_shifted() then
        editor:cycle_fields(-1)
      else
        editor:cycle_fields(1)
      end

    elseif keys:is_letter_code(code) or keys:is_number_code(code) or keys:is_symbol(code) and not keys:is_mod() then
      if keys:is_shifted() and (keys:is_number_code(code) or keys:is_symbol(code)) then
        editor:add(keys:get_shifted_keycode(code))
      else
        editor:add(keys:get_keycode_value(code))
      end

    elseif keys:is_backspace_or_delete(code) then
      editor:backspace()

    end



  -- not editor



  else

    if keys:is_mod() then
      if keys:is_backspace_or_delete(code) and terminal:is_empty() then
        tracker:clear_selected_slots()
      elseif keys:equals(code, "x") then 
        clipboard:cut_items()
      elseif keys:equals(code, "c") then 
        clipboard:copy_items()
      elseif keys:equals(code, "v") then 
        clipboard:paste_items()
      end
    elseif keys:is_y_mode() then
      if keys:is_shifted() then
            if keys:is_number_code(code) and tracker:is_selected() then tracker:select_range_of_tracks(tonumber(keys:get_keycode_value(code)))
        elseif keys:equals(code, "[") then tracker:adjust_level(-0.1)
        elseif keys:equals(code, "]") then tracker:adjust_level(0.1)
        elseif keys:equals(code, "h") then view:handle_pan(keys:get_keycode_value(code), 10)
        elseif keys:equals(code, "j") then view:handle_pan(keys:get_keycode_value(code), 10)
        elseif keys:equals(code, "k") then view:handle_pan(keys:get_keycode_value(code), 10)
        elseif keys:equals(code, "l") then view:handle_pan(keys:get_keycode_value(code), 10)
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
      if keys:is_mod() and terminal:is_empty() then
        local pan = keys:is_shifted() and 10 or 1
        view:handle_pan(keys:get_keycode_value(code), pan)
      elseif keys:is_mod() and not terminal:is_empty() then
            if keys:equals(code, "RIGHT") then terminal:space_move_cursor_index(1)
        elseif keys:equals(code, "LEFT")  then terminal:space_move_cursor_index(-1)
        end
      else
            if keys:equals(code, "RIGHT") then terminal:move_cursor_index(1)
        elseif keys:equals(code, "LEFT")  then terminal:move_cursor_index(-1)
        elseif keys:equals(code, "UP")    then terminal:up_history()
        elseif keys:equals(code, "DOWN")  then terminal:down_history()
        end
      end
    end
  end

  if keys ~= nil then
    fn.dirty_screen(true)
  end

end

return keyboard