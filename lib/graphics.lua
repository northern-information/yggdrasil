graphics = {}

function graphics.init()
  -- frames and animation state
  graphics.fps = 30
  graphics.frame = 0
  graphics.quarter_frame = 0
  graphics.cursor_frame = 0
  graphics.run_command_frame = 0
  graphics.glow = 0
  graphics.glow_up = true
  graphics.transition_frame = 0
  graphics.command_icon = {}
  -- splash screen
  graphics.ni_splash_lines_open = {}
  graphics.ni_splash_lines_close = {}
  graphics.ni_splash_lines_close_available = {}
  for i = 1, 45 do graphics.ni_splash_lines_open[i] = i end
  for i = 1, 64 do graphics.ni_splash_lines_close_available[i] = i end
  graphics.ni_splash_done = false
  graphics.yggdrasil_splash_scale = 6
  graphics.yggdrasil_splash_segments = graphics:get_yggdrasil_segments(0, 35, graphics.yggdrasil_splash_scale)
  graphics.yggdrasil_splash_done = false
  graphics.yggdrasil_gui_scale = 3
  graphics.yggdrasil_gui_segments = graphics:get_yggdrasil_segments(0, 40, graphics.yggdrasil_gui_scale)
  -- slots
  graphics.slot_triggers = {}
end

function graphics.redraw_clock()
  while true do
    if view:is_tracker_dirty() then
      view:refresh()
      view:set_tracker_dirty(false)
      fn.dirty_screen(true)
    end
    if fn.dirty_screen() then
      redraw()
      fn.dirty_screen(false)
    end
    graphics:decrement_slot_triggers()
    clock.sleep(1 / graphics.fps)
  end
end

function graphics:render_page(page)
  self:setup()
  view:refresh()
  if self.transition_frame > self.frame then
    self:draw_transition()
  else
    if page == "splash" then
      self:splash()
    elseif page == "tracker" then
      if view:is_hud() then
        self:draw_hud_background()
      end
      self:draw_focus()
      self:draw_tracks()
      if view:is_hud() then
        self:draw_hud_foreground()
      end
      if editor:is_open() then
        self:draw_editor()
      else
        self:draw_terminal()
        self:draw_command_processing()
        self:draw_y_mode()
      end
    elseif page == "mixer" then
      self:draw_mixer()
      self:draw_terminal()
      self:draw_command_processing()
      self:draw_y_mode()
    elseif page == "clades" then
      self:draw_clades()
      self:draw_terminal()
      self:draw_command_processing()
      self:draw_y_mode()
    end
  end
  fn.dirty_screen(true)
  self:teardown()
end



-- editor


function graphics:draw_editor()
  local sw = view:get_slot_width()
  local x = ((view:get_x() - 1) * sw) - (view:get_x_offset() * sw) + sw
  local w = 128 - x
  -- background
  self:rect(x, 0, w, 64, 0)
  self:mls(x, 0, x, 64, 15)
  -- title
  -- self:rect(x, 0, w, 7, 17)
  -- self:draw_mixer_glyph(106, 0, editor:get_track():get_clade(), false)
  -- self:text_right(128, 15, editor:get_title(), 15)
  -- validator
  self:draw_validator_cube(editor:is_valid())
end

function graphics:draw_validator_cube(valid)
  local x = 116
  local y = 0
  if valid then
    -- horizontals
    self:mlrs(x + 4, y + 1, 7, 0)
    self:mlrs(x, y + 5, 8, 0)
    self:mlrs(x + 4, y + 8, 8, 0)
    self:mlrs(x + 1, y + 12, 7, 0)
    -- verticals
    self:mlrs(x + 1, y + 5, 0, 6)
    self:mlrs(x + 5, y, 0, 3)
    self:mlrs(x + 5, y + 6, 0, 2)
    self:mlrs(x + 8, y + 4, 0, 2)
    self:mlrs(x + 8, y + 9, 0, 2)
    self:mlrs(x + 12, y + 2, 0, 6)
    -- angles (from top to bottom)
    self:mlrs(x + 3, y + 2, 1, 0)
    self:mlrs(x + 10, y + 2, 1, 0)
    self:mlrs(x + 2, y + 3, 1, 0)
    self:mlrs(x + 9, y + 3, 1, 0)
    self:mlrs(x + 1, y + 4, 1, 0)
    self:mlrs(x + 8, y + 4, 1, 0)
    self:mlrs(x + 3, y + 9, 1, 0)
    self:mlrs(x + 10, y + 9, 1, 0)
    self:mlrs(x + 2, y + 10, 1, 0)
    self:mlrs(x + 9, y + 10, 1, 0)
    self:mlrs(x + 1, y + 11, 1, 0)
    self:mlrs(x + 8, y + 11, 1, 0)
  else
    self:mlrs(x + 1, y + 1, 10, 10)
    self:mlrs(x + 11, y + 1, -10, 10)
  end
end

function graphics:return_arrow(x, y)
  self:mlrs(x + 15, y + 6, 10, 0)
  self:mlrs(x + 25, y + 2, 0, 4)
  self:mlrs(x + 16, y + 5, 2, 0)
  self:mlrs(x + 16, y + 7, 2, 0)
  self:mlrs(x + 17, y + 4, 2, 0)
  self:mlrs(x + 17, y + 8, 2, 0)
  self:mlrs(x + 18, y + 3, 2, 0)
  self:mlrs(x + 18, y + 9, 2, 0)
end



-- tracker



function graphics:draw_focus()
  local sw, sh = view:get_slot_width(), view:get_slot_height()
  local w = view:get_x_offset() * sw
  local h = view:get_y_offset() * sh
  self:rect(
    ((view:get_x() - 1) * sw) - w,
    ((view:get_y() - 1) * sh + 1) - h,
    sw, sh, 1
  )
end

function graphics:draw_hud_background()
  self:draw_cols()
end

function graphics:draw_hud_foreground()
  local swm, sw, sh =  view:get_slot_width_min(), view:get_slot_width(), view:get_slot_height()
  self:rect(0, 0, swm, 64, 0)
  self:rect(0, 0, 128, sh, 0)
  -- vertical indicator to scroll up
  if view:get_rows_above()then
    for i = 1, 16 do
      self:mls(swm, sh - 1 + i, swm, sh + i, 16 - i)
    end
  end
  -- horizontal rule under the top numbers
  if view:get_rows_above() then
    self:mls(swm - 1, sh, 128, sh, 15)
  end
  -- vertical indicator to scroll down
  if view:get_rows_below() then
    local adjust_y = tracker:has_message() and -9 or 0
    for i = 1, 16 do 
      self:mls(swm, 56 - i + adjust_y, swm, 55 - i + adjust_y, 16 - i)
    end
  end
  -- col numbers, start at 2 because of the column HUD
  local start = 2
  if view:get_slot_extents() > swm then
    start = 1
  end
  for i = start, view:get_cols_per_view() do
    local value = i + view:get_x_offset()
    self:text_right(
      (i * sw - 2),
      (sh - 2),
      ((value < 1 or value > tracker:get_cols()) and "" or value),
      15
    )
  end
  -- row numbers, start at 2 because of the row HUD
  for i = 2, view:get_rows_per_view() + 2 do
    local value = i + view:get_y_offset()
    local adjust_a_single_pixel_for_number_1_because_typography = value == 1 and 1 or 0
    self:text_right(
      (swm - 3 - adjust_a_single_pixel_for_number_1_because_typography),
      (i * sh),
      ((value < 1 or value > tracker:get_rows()) and "" or value),
      15
    )
  end
end

function graphics:draw_y_mode()
  if keys:is_y_mode() then
    local l = page:is("CLADES") and 15 - self.cursor_frame or self.cursor_frame
    self:mls(6, 0, 3, 3, l)
    self:mls(9, 0, 0, 9, l)   
  end
end

function graphics:draw_tracks()
  for k, track in pairs(tracker:get_tracks()) do
    self:draw_slots(track)
  end
end

function graphics:draw_slots(track)
  local slots = track:get_slots()
  local slot_triggers = self:get_slot_triggers()
  local sw, sh = view:get_slot_width(), view:get_slot_height()
  local w = view:get_x_offset() * sw
  local h = view:get_y_offset() * sh
  for k, slot in pairs(slots) do
    if slot:get_y() <= track:get_depth() then
      local triggered = slot_triggers[slot:get_id()]
      if slot:is_selected() or triggered ~= nil then
        local background = 15
        local foreground = 0
        if ((view:get_x() == slot:get_x()) and (view:get_y() == slot:get_y()))
          and #tracker:get_track(slot:get_x()):get_selected_slots() > 1 then
            background = 1
            foreground = 15
        end
        if editor:is_open() and editor:get_slot():get_y() == slot:get_y() then
          background = self.cursor_frame
        end
        if triggered ~= nil then
          local l = slot_triggers[slot:get_id()].level
          foreground = math.abs(15 - l)
          background = l
        end
        self:rect(
          ((slot:get_x() - 1) * sw) - w,
          ((slot:get_y() - 1) * sh + 1) - h,
          sw, sh, background
        )
        self:text_right(
          (slot:get_x() * sw - 2) - w,
          (slot:get_y() * sh) - h,
          tostring(slot), foreground
        )
      else
        self:text_right(
          (slot:get_x() * sw - 2) - w,
          (slot:get_y() * sh) - h,
          tostring(slot), 15
        )
      end
    end
  end
end

function graphics:draw_cols()
  for i = 1, view:get_cols_per_view() do
    local x = (i - 1) * view:get_slot_width()
    local value = i + view:get_x_offset()
    if value > 1 and value <= tracker:get_cols() + 1 then
      for ii = 1, (view:get_rows_per_view() * 2) do
        if view:get_rows_above() and (
            (view:get_y_offset() > 0  and not view:is_hud()) or
            (view:get_y_offset() > -1 and     view:is_hud())
          ) then
          local adjust_y = view:is_hud() and view:get_slot_height() or -1
          self:mls(x, ii - 1 + adjust_y, x, ii + adjust_y, 16 - ii)
        end
        if view:get_rows_below() then
          local adjust_y = tracker:has_message() and -9 or 0
          self:mls(x, 56 - ii + adjust_y, x, 55 - ii + adjust_y, 16 - ii)
        end
      end
    end
  end
end



-- mixer



function graphics:draw_mixer()
  local fg = 15
  local bg = 0
  local v = view:get_m()
  for i = 1, v.tracks do
    local track = tracker:get_track(i)
    local x = 2 + ((i - 1) * v.track_width) - view:get_x()
    local y = -view:get_y()
    local track_title_width = 11
    if i == 1 then
      -- bpm
      self:text(x - 1, y - 18, "BPM", 1)
      self:text(x - 1, v.track_height + y + 10, "BPM", 1)
      screen.font_size(16)
      self:text(x - 1, y - 6, params:get("clock_tempo"), 1)
      self:text(x - 1, v.track_height + y + 22, params:get("clock_tempo"), 1)
      self:reset_font()
    end
    -- cover any overflow from previous tracks
    self:rect(x - 1, y, v.track_width, v.track_height, bg)
    -- upper boundary, left line, & terminator
    self:rect(x - 1, y - 3, v.track_width - 2, 3, fg)
    self:mlrs(x, y - 3, 0, v.track_height + 3, fg)
    self:rect(x - 2, y + v.track_height, 3, 3, fg)
    -- track number
    local selected_fg = track:is_selected() and fg or bg
    local selected_bg = track:is_selected() and bg or fg
    self:rect(x, y + 1, track_title_width, 7, selected_fg)
    self:text_center(x + 5, y + 7, i, selected_bg)
    -- mute, solo, enabled
    self:draw_mixer_glyph(x + 1, y + 9, "m", track:is_muted())
    self:draw_mixer_glyph(x + 1, y + 19, "s", track:is_soloed())
    self:draw_mixer_glyph(x + 1, y + 29, "e", track:is_enabled())
    -- level
    self:draw_level_gauge(x + track_title_width, y + 1, track:get_level())
    -- direction
    self:draw_mixer_glyph(x + track_title_width + 3, y + 29, track:is_descending() and "down" or "up")
    -- clade
    self:draw_mixer_glyph(x, y + 39, track:get_clade(), true)
    -- attributes
    local attributes = {}
    -- shadow
    local shadow_adjust = 0
    if track:is_shadow() then
      self:draw_mixer_glyph(x, y + 47, "shadow", true)
      attributes[1] = { name = "sd.",  value = tracker:get_track_by_id(track:get_shadow()):get_x() }
      shadow_adjust = 8
    end
    if track:is_synth() then
      attributes[#attributes + 1] = { name = "vo.",  value = track:get_voice() }
    elseif track:is_midi() then
      attributes[#attributes + 1] = { name = "dv.", value = track:get_device() }
      attributes[#attributes + 1] = { name = "ch.", value = track:get_channel() }
    elseif track:is_ypc() then

    elseif track:is_crow() then
      attributes[#attributes + 1] = { name = "", value = track:get_pair() == 1 and "1/2" or "3/4" }
      attributes[#attributes + 1] = { name = "jf.", value = track:is_jf() and "on" or "x"}
    end
    local i = 0
    local attribute_start = 53
    if #attributes > 0 then
      for k, attribute in pairs(attributes) do
        self:text(x + 1, y + shadow_adjust + attribute_start + i, attribute.name .. attribute.value, fg)
        i = i + 8
      end
    end
    -- clock
    local clock_y = y + attribute_start + 32
    self:rect(x, clock_y - 5, 22, 7, fg)
    self:text(x + 1, clock_y + 1, "SYNC", bg)
    self:text(x + 2, clock_y + 9, track:get_clock(), fg)
  end
end


function graphics:draw_level_gauge(x, y, level)
  self:rect(x, y, 11, 27, 15)
  self:rect(x + 1, y + 1, 9, 25, 0)  
  local max_height = 23
  local height = math.floor(util.linlin(0.0, 1.0, 1, 23, level))
  self:rect(x + 2, ((y + 2) + (max_height - height)), 7, height)
  if height > 2 then
    self:mlrs(x + 2, ((y + 4) + (max_height - height)), 8, 0, 0)
  end
end



-- clades



function graphics:draw_clades()
  local clade_x = 77
  local track_x = 40
  local track_x_start = 10
  local bg = 0
  local fg = 15
  local is_any_soloed = tracker:is_any_soloed()
  self:rect(0, 0, 128, 64, 15)
  -- rightmost column
  local clades = {}
  clades[1] = { name = "SYNTH", wired = false, y = 0 }
  clades[2] = { name = "MIDI", wired = false, y = 0 }
  clades[3] = { name = "YPC", wired = false, y = 0 }
  clades[4] = { name = "CROW", wired = false, y = 0 }
  local tracks = tracker:get_tracks()
  for k, track in pairs(tracks) do
    for kk, clade in pairs(clades) do
      -- things get confusing because x and y are transposed
      if track:is_enabled()
        and not track:is_muted()
        and (track:is_soloed() or not is_any_soloed)
        and track:get_clade() == clade.name
        and track:get_x() > view:get_y_offset() - 2
        and track:get_x() < view:get_y_offset() + view:get_rows_per_view() + 1 then
          clades[kk].wired = true
      end
    end
  end
  for k, clade in pairs(clades) do
    local y = (k * 13) - 5
    clades[k]["y"] = y
    self:rect(87, y - 5, 38, 9, bg)
    self:mlrs(125, y, 3, 0, bg)
    if clade.wired then
      self:mlrs(clade_x, y, 23, 0, bg)
    end
    self:draw_mixer_glyph(89, y - 4, clade.name, false)
  end
  -- tracks
  local track_extents = fn.get_largest_extents_from_zero_to(tracker:get_cols())
  for i = 1, view:get_rows_per_view() + 2 do
    -- leftmost column
    local value = i + view:get_y_offset() - 2
    local track = tracker:get_track(value)
    local track_y = (i * 8) - 3
    if track ~= nil then
      -- track background
      self:mlrs(0, track_y, track_x_start, 0, bg)
      self:rect(track_x_start, track_y - 4, track_extents + 4, 7, bg)
      if track:is_enabled() 
        and not track:is_muted()
        and (track:is_soloed() or not is_any_soloed) then
          self:mlrs(track_x - 21, track_y, 21, 0, bg)
      else
          self:mlrs(track_x - 21, track_y, 7, 0, bg)
      end
      if not track:is_enabled() then
          self:rect(track_x - 13, track_y - 2, 3, 3, bg)
      end
      if track:is_muted() then
          self:mlrs(track_x - 14, track_y - 3, 0, 5, bg)
      end
      if track:is_soloed() then
          self:mlrs(track_x - 17, track_y - 2, 3, 0, bg)
          self:mlrs(track_x - 17, track_y + 2, 3, 0, bg)
      end
      -- type
      local adjust_a_single_pixel_for_number_1_because_typography = value == 1 and 1 or 0
      self:text_right(
        (12 + track_extents - adjust_a_single_pixel_for_number_1_because_typography),
        (i * 8) - 1,
        ((value < 1 or value > tracker:get_cols()) and "" or value),
        fg
      )
      -- the web
      for k, clade in pairs(clades) do
        if track:is_enabled() 
          and not track:is_muted() 
          and (track:is_soloed() or not is_any_soloed)
          and track:get_clade() == clade.name then
            self:mls(track_x, track_y, clade_x, clade.y, bg)
        end
      end
    end
  end
end




-- terminal



function graphics:draw_terminal()
  local height = 9
  if tracker:has_message() then
    height = 18
  elseif tracker:is_info() then
    height = 40
  end
  self:mls(0, 64 - height, 128, 64 - height - 1, 15)
  self:rect(0, 64 - height, 128, height, 0)
  if tracker:has_message() then
    self:text(5, 54, tracker:get_message_value(), 1)
  elseif tracker:is_info() then
    self:draw_yggdrasil_gui_logo()
    self:text(64, 40, fn.get_semver_string(), 1)
  end
  local total = 0
  local y = 64 - height - 4
  local tb = terminal:get_field():get_text_buffer()
  local eb = terminal:get_field():get_extents_buffer()
  if #tb > 0 then
    for k, character in pairs(tb) do
      if k == 1 then
        self:text(0, 62, character, 15)
      else
        self:text(total, 62, character, 15)
      end
      total = eb[k] + total + 1
      if k == terminal:get_field():get_cursor_index() then
        if terminal:get_field():get_cursor_index() < #eb then
          self:draw_cursor(total)
        else
          self:draw_cursor(total + 1)
        end
      end
    end
  else
    self:draw_cursor(1)
  end
  if terminal:get_field():get_cursor_index() == 0 and #tb > 0 then
    self:draw_cursor(1)
  end
end

function graphics:draw_cursor(x)
  if not keys:is_y_mode() then
    self:mlrs(x, 56, 0, 7, self.cursor_frame)
  end
end

function graphics:draw_command_processing()
  if self.run_command_frame < self.frame then return end  
  local x = 123
  local y = 55
  local l = self.frame < self.run_command_frame - 15 and 15 or (self.run_command_frame - self.frame)
  self:rect(x, y, 5, 9, 0)
  local this = math.random(1, 5)
  self.command_icon[this] = util.clamp(self.command_icon[this] - math.random(1, 2), -7, 0)
  for i = 1, #self.command_icon do
    self:mlrs(x - 1 + i, y + 9, 0, self.command_icon[i], l)
  end
  for i = 1, #self.command_icon do
    local l = math.abs(self.command_icon[i])
    self:mlrs(x - 1 + i, y + 9, 0, -math.floor(l / 2), 0)
  end
end

function graphics:draw_run_command()
  self.command_icon = {0, 0, 0, 0, 0}
  self.run_command_frame = self.frame + 30
end



-- housekeeping



function graphics:frame_clock()
  while true do
    graphics:handle_frames()
    fn.dirty_screen(true)
    clock.sleep(1 / graphics.fps)
  end
end

function graphics:handle_frames()
  self.frame = self.frame + 1
  self.quarter_frame = self.frame % 16 == 0 and self.quarter_frame + 1 or self.quarter_frame
  if self.frame % 16 == 0 then
    self.glow_up =  not self.glow_up
  end
  self.glow = self.glow_up and self.frame % 16 or math.abs((self.frame % 16) - 16)
  self.cursor_frame = fn.cycle(self.cursor_frame - 1, 0, 16)
end

function graphics:ping_cursor_frame()
  self.cursor_frame = 16
end

function graphics:setup()
  screen.clear()
  screen.aa(0)
  self:reset_font()
end

function graphics:reset_font()
  screen.font_face(0)
  screen.font_size(8)
end

function graphics:teardown()
  screen.update()
end



-- slots



function graphics:get_slot_triggers()
  return self.slot_triggers
end

function graphics:register_slot_trigger(id)
  self.slot_triggers[id] = { id = id, level = 15 }
end

function graphics:decrement_slot_triggers()
  for id, st in pairs(self:get_slot_triggers()) do
    self.slot_triggers[id].level = st.level - 3
    if self.slot_triggers[id].level < 0 then
      self.slot_triggers[id] = nil
    end
  end
end



-- northern information graphics abstractions



function graphics:mlrs(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line_rel(x2, y2)
  screen.stroke()
end

function graphics:mls(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line(x2, y2)
  screen.stroke()
end

function graphics:rect(x, y, w, h, l)
  screen.level(l or 15)
  screen.rect(x, y, w, h)
  screen.fill()
end

function graphics:circle(x, y, r, l)
  screen.level(l or 15)
  screen.circle(x, y, r)
  screen.fill()
end

function graphics:text(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text(s)
end

function graphics:text_right(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_right(s)
end

function graphics:text_center(x, y, s, l)
  screen.level(l or 15)
  screen.move(x, y)
  screen.text_center(s)
end



-- glyphs



function graphics:draw_mixer_glyph(x, y, glyph, inverted)
  local inverted = inverted ~= nil and inverted or false
  local fg = 15
  local bg = 0
  if inverted then
    fg = 0
    bg = 15
  end

  if glyph == "m" or glyph == "s" or glyph == "e" then
    self:rect(x, y, 9, 9, bg)
  elseif glyph == "SYNTH" or glyph == "MIDI" or glyph == "YPC" or glyph == "CROW"  or glyph == "shadow"then
    self:rect(x, y, 22, 7, bg)
  end

  if glyph == "m" then
    self:mlrs(x + 2, y + 3, 5, 0, fg)
    self:mlrs(x + 3, y + 2, 0, 5, fg)
    self:mlrs(x + 5, y + 2, 0, 5, fg)
    self:mlrs(x + 7, y + 2, 0, 5, fg)
  elseif glyph == "s" then
    self:mlrs(x + 2, y + 3, 5, 0, fg)
    self:mlrs(x + 3, y + 2, 0, 3, fg)
    self:mlrs(x + 2, y + 5, 5, 0, fg)
    self:mlrs(x + 7, y + 4, 0, 3, fg)
    self:mlrs(x + 2, y + 7, 5, 0, fg)
  elseif glyph == "e" then
    if inverted then
      -- e for enabled
      self:mlrs(x + 3, y + 2, 0, 5, fg)
      self:mlrs(x + 2, y + 3, 5, 0, fg)
      self:mlrs(x + 2, y + 5, 5, 0, fg)
      self:mlrs(x + 2, y + 7, 5, 0, fg)
    else
      -- d for disabled
      self:mlrs(x + 3, y + 2, 0, 5, fg)
      self:mlrs(x + 2, y + 3, 4, 0, fg)
      self:mlrs(x + 7, y + 3, 0, 3, fg)
      self:mlrs(x + 2, y + 7, 4, 0, fg)
    end
  elseif glyph == "up" then
    self:mlrs(x + 0, y + 3, 0, 2, fg)
    self:mlrs(x + 1, y + 2, 0, 2, fg)
    self:mlrs(x + 2, y + 1, 0, 2, fg)
    self:mlrs(x + 3, y + 0, 0, 8, fg)
    self:mlrs(x + 4, y + 1, 0, 2, fg)
    self:mlrs(x + 5, y + 2, 0, 2, fg)
    self:mlrs(x + 6, y + 3, 0, 2, fg)
  elseif glyph == "down" then
    self:mlrs(x + 0, y + 3, 0, 2, fg)
    self:mlrs(x + 1, y + 4, 0, 2, fg)
    self:mlrs(x + 2, y + 5, 0, 2, fg)
    self:mlrs(x + 3, y + 0, 0, 8, fg)
    self:mlrs(x + 4, y + 5, 0, 2, fg)
    self:mlrs(x + 5, y + 4, 0, 2, fg)
    self:mlrs(x + 6, y + 3, 0, 2, fg)
elseif glyph == "SYNTH" then
    local wave = 0
    for i = 1, 3 do
      self:mlrs(x + 1 + wave, y + 4, 2, 0, fg)
      self:mlrs(x + 3 + wave, y + 4, 0, 2, fg)
      self:mlrs(x + 3 + wave, y + 6, 2, 0, fg)
      self:mlrs(x + 5 + wave, y + 1, 0, 5, fg)
      self:mlrs(x + 5 + wave, y + 2, 2, 0, fg)
      self:mlrs(x + 7 + wave, y + 1, 0, 3, fg)
      self:mlrs(x + 7 + wave, y + 4, 1, 0, fg)
      wave = i * 6
    end
 elseif glyph == "MIDI" then
    self:mlrs(x + 1, y + 2, 4, 0, fg)
    self:mlrs(x + 2, y + 1, 0, 5, fg)
    self:mlrs(x + 4, y + 1, 0, 4, fg)
    self:mlrs(x + 6, y + 2, 0, 4, fg)
    self:mlrs(x + 8, y + 1, 0, 5, fg)
    self:mlrs(x + 10, y + 3, 0, 3, fg)
    self:mlrs(x + 9, y + 2, 3, 0, fg)
    self:mlrs(x + 13, y + 2, 0, 4, fg)
    self:mlrs(x + 9, y + 6, 4, 0, fg)
    self:mlrs(x + 15, y + 1, 0, 5, fg)
  elseif glyph == "YPC" then
    self:mlrs(x + 1, y + 4, 20, 0, fg)
    self:mlrs(x + 3, y + 1, 0, 5, fg)
    self:mlrs(x + 4, y + 2, 0, 3, fg)
    self:mlrs(x + 6, y + 2, 0, 3, fg)
    self:mlrs(x + 8, y + 4, 0, 2, fg)
    self:mlrs(x + 10, y + 1, 0, 5, fg)
    self:mlrs(x + 11, y + 2, 0, 3, fg)
    self:mlrs(x + 14, y + 2, 0, 2, fg)
    self:mlrs(x + 16, y + 1, 0, 4, fg)
    self:mlrs(x + 18, y + 2, 0, 2, fg)
    self:mlrs(x + 19, y + 4, 0, 1, fg)
  elseif glyph == "CROW" then
    self:mlrs(x + 3, y + 5, 0, 1, fg)
    self:mlrs(x + 4, y + 3, 0, 2, fg)
    self:mlrs(x + 5, y + 2, 0, 2, fg)
    self:rect(x + 5, y + 1, 2, 2, fg)
    self:mlrs(x + 8, y + 2, 0, 2, fg)
    self:mlrs(x + 9, y + 3, 0, 2, fg)
    self:rect(x + 9, y + 4, 3, 2, fg)
    self:mlrs(x + 13, y + 3, 0, 2, fg)
    self:mlrs(x + 14, y + 2, 0, 2, fg)
    self:rect(x + 14, y + 1, 2, 2, fg)
    self:mlrs(x + 17, y + 2, 0, 2, fg)
    self:mlrs(x + 18, y + 3, 0, 2, fg)
    self:mlrs(x + 19, y + 5, 0, 1, fg)
  elseif glyph == "shadow" then
    -- s
    self:mlrs(x + 1, y + 2, 3, 0, fg)
    self:mlrs(x + 2, y + 1, 0, 3, fg)
    self:mlrs(x + 1, y + 4, 7, 0, fg)
    self:mlrs(x + 4, y + 3, 0, 3, fg)
    self:mlrs(x + 1, y + 6, 3, 0, fg)
    -- h
    self:mlrs(x + 6, y + 1, 0, 5, fg)
    self:mlrs(x + 8, y + 2, 0, 4, fg)
    -- a
    self:mlrs(x + 10, y + 2, 0, 1, fg)
    self:mlrs(x + 10, y + 4, 0, 1, fg)
    self:mlrs(x + 7, y + 6, 7, 0, fg)
    -- d
    self:mlrs(x + 12, y + 2, 0, 4, fg)
    self:mlrs(x + 14, y + 1, 0, 5, fg)
    self:mlrs(x + 11, y + 3, 3, 0, fg)
    -- o
    self:mlrs(x + 13, y + 2, 3, 0, fg)
    -- w
    self:mlrs(x + 16, y + 1, 0, 5, fg)
    self:mlrs(x + 18, y + 3, 0, 3, fg)
    self:mlrs(x + 20, y + 4, 0, 2, fg)
    self:mlrs(x + 15, y + 6, 5, 0, fg)
    self:mlrs(x + 17, y + 2, 3, 0, fg)
    self:mlrs(x + 20, y + 1, 0, 2, fg)
  end
end



-- northern information, yggdrasil splash screen, & transition

function graphics:trigger_transition()
  self.transition_frame = self.frame + 10
end

function graphics:draw_transition()
  -- dust
  for i = 1, 16 do
    self:mlrs(math.random(1, 128), math.random(28, 36), 1, 1, 15)
  end
  for i = 1, 32 do
    self:mlrs(math.random(1, 128), math.random(16, 48), 1, 1, 1)
  end
  -- lines
  local lines = {}
  lines[1] = { y_baseline = 30, level = 5}
  lines[2] = { y_baseline = 32, level = 15}
  lines[3] = { y_baseline = 34, level = 5}
  for kl, line in pairs(lines) do
    local points = {}
    points[1] = { x = 0, y = 0 }
    points[2] = { x = 16, y = 0 }
    points[3] = { x = 32, y = 0 + math.random(-8, 8)}
    points[4] = { x = 64, y = 0 + math.random(-16, 16)}
    points[5] = { x = 80, y = 0 + math.random(-16, 16)}
    points[6] = { x = 96, y = 0 + math.random(-8, 8)}
    points[7] = { x = 112, y = 0 }
    points[8] = { x = 128, y = 0 }
    local last_x, last_y = 0, 0
    for kp, point in pairs(points) do
      self:mls(last_x, last_y + line.y_baseline, point.x, point.y + line.y_baseline, line.level)
      last_x = point.x
      last_y = point.y
    end
  end
end

function graphics:splash()
  if fn.break_splash() then
    self.ni_splash_done = true
    self.yggdrasil_splash_done = true
  end
  local col_x = 34
  local row_x = 34
  local y = 45
  local l = self.frame >= 49 and 0 or 15
  if self.frame >= 49 and self.frame < 168 then
    self:rect(0, 0, 128, 50, 15)
  end
  self:ni(col_x, row_x, y, l)
  if #self.ni_splash_lines_open > 1 then 
    local delete = math.random(1, #self.ni_splash_lines_open)
    table.remove(self.ni_splash_lines_open, delete)
    for i = 1, #self.ni_splash_lines_open do
      self:mlrs(1, self.ni_splash_lines_open[i] + 4, 128, 1, 0)
    end
  end
  if self.frame >= 49 then
    self:text_center(64, 60, "NORTHERN INFORMATION")
  end
  if self.frame > 100 then
    if #self.ni_splash_lines_close_available > 0 then 
      local add = math.random(1, #self.ni_splash_lines_close_available)
      table.insert(self.ni_splash_lines_close, self.ni_splash_lines_close_available[add])
      table.remove(self.ni_splash_lines_close_available, add)
    end
    for i = 1, #self.ni_splash_lines_close do
      self:mlrs(1, self.ni_splash_lines_close[i], 128, 1, 0)
    end
  end
  if #self.ni_splash_lines_close_available == 0 then
    self.ni_splash_done = true
  end
  if self.frame >= 168 then
    if self.frame <= 300 then
      self:yggdrasil_random_on()
    end
    if (self.frame >= 168 and self.frame <= 250) or (self.frame >= 340) then
      for i = 1, #self.yggdrasil_splash_segments do
        self.yggdrasil_splash_segments[i].l = util.clamp(self.yggdrasil_splash_segments[i].l - 1, 0, 15)
      end
    elseif self.frame > 250 then
      for i = 1, #self.yggdrasil_splash_segments do
        self.yggdrasil_splash_segments[i].l = util.clamp(self.yggdrasil_splash_segments[i].l + 1, 0, 15)
      end
    end
  end
  if self.frame >= 168 then
    for k, segment in pairs(self.yggdrasil_splash_segments) do
      screen.level(segment.l)
      screen.move(segment.x - self.yggdrasil_splash_scale, segment.y)
      screen.line_rel(-self.yggdrasil_splash_scale, self.yggdrasil_splash_scale)
      screen.stroke()
    end
  end
  if self.frame >= 370 then
    self.yggdrasil_splash_done = true
  end
  if self.ni_splash_done and self.yggdrasil_splash_done then
    fn.break_splash(true)
    page:select(1)
  end
  fn.dirty_screen(true)
end

function graphics:yggdrasil_random_on()
  local on = math.random(1, #self.yggdrasil_splash_segments)
  if self.yggdrasil_splash_segments[on].l == 0 then
    self.yggdrasil_splash_segments[on].l = 15
  end
end

function graphics:get_yggdrasil_segments(x, y, scale)
  local s           = scale
  local x           = x
  local baseline    = y
  local asc_line    = baseline - s
  local asc_2_line  = baseline - (s * 2)
  local asc_3_line  = baseline - (s * 3)
  local asc_4_line  = baseline - (s * 4)
  local desc_line   = baseline + s
  local desc_2_line = baseline + (s * 2)
  return {
    -- y
    { l = 0, x = x + (s * 5), y = asc_2_line },
    { l = 0, x = x + (s * 4), y = asc_line },
    { l = 0, x = x + (s * 6), y = asc_2_line },
    { l = 0, x = x + (s * 5), y = asc_line },
    { l = 0, x = x + (s * 4), y = baseline },
    { l = 0, x = x + (s * 3), y = desc_line },
    { l = 0, x = x + (s * 2), y = desc_2_line },
    -- g
    { l = 0, x = x + (s * 7), y = asc_2_line },
    { l = 0, x = x + (s * 6), y = asc_line },
    { l = 0, x = x + (s * 8), y = asc_2_line },
    { l = 0, x = x + (s * 7), y = asc_line },
    { l = 0, x = x + (s * 6), y = baseline} ,
    { l = 0, x = x + (s * 5), y = desc_line },
    { l = 0, x = x + (s * 4), y = desc_2_line },
    -- g
    { l = 0, x = x + (s * 9),  y = asc_2_line },
    { l = 0, x = x + (s * 8),  y = asc_line },
    { l = 0, x = x + (s * 10), y = asc_2_line },
    { l = 0, x = x + (s * 9),  y = asc_line },
    { l = 0, x = x + (s * 8),  y = baseline },
    { l = 0, x = x + (s * 7),  y = desc_line },
    { l = 0, x = x + (s * 6),  y = desc_2_line },
    -- d
    { l = 0, x = x + (s * 11), y = asc_2_line },
    { l = 0, x = x + (s * 10), y = asc_line },
    { l = 0, x = x + (s * 14), y = asc_4_line },
    { l = 0, x = x + (s * 13), y = asc_3_line },
    { l = 0, x = x + (s * 12), y = asc_2_line },
    { l = 0, x = x + (s * 11), y = asc_line },
    -- r
    { l = 0, x = x + (s * 13), y = asc_2_line },
    { l = 0, x = x + (s * 12), y = asc_line },
    { l = 0, x = x + (s * 14), y = asc_2_line },
    -- a
    { l = 0, x = x + (s * 15), y = asc_2_line },
    { l = 0, x = x + (s * 14), y = asc_line },
    { l = 0, x = x + (s * 16), y = asc_2_line },
    { l = 0, x = x + (s * 15), y = asc_line },
    -- s
    { l = 0, x = x + (s * 17), y = asc_2_line },
    { l = 0, x = x + (s * 17), y = asc_line },
    -- i
    { l = 0, x = x + (s * 21), y = asc_4_line },
    { l = 0, x = x + (s * 19), y = asc_2_line },
    { l = 0, x = x + (s * 18), y = asc_line },
    -- l
    { l = 0, x = x + (s * 22), y = asc_4_line },
    { l = 0, x = x + (s * 21), y = asc_3_line },
    { l = 0, x = x + (s * 20), y = asc_2_line },
    { l = 0, x = x + (s * 19), y = asc_line }
  }
end

function graphics:draw_yggdrasil_gui_logo()
  for k, segment in pairs(self.yggdrasil_gui_segments) do
    screen.level(5)
    screen.move(segment.x - self.yggdrasil_gui_scale, segment.y)
    screen.line_rel(-self.yggdrasil_gui_scale, self.yggdrasil_gui_scale)
    screen.stroke()
  end
end

function graphics:ni(col_x, row_x, y, l)
  self:n_col(col_x, y, l)
  self:n_col(col_x+20, y, l)
  self:n_col(col_x+40, y, l)
  self:n_row_top(row_x, y, l)
  self:n_row_top(row_x+20, y, l)
  self:n_row_top(row_x+40, y, l)
  self:n_row_bottom(row_x+9, y+37, l)
  self:n_row_bottom(row_x+29, y+37, l)
end

function graphics:n_col(x, y, l)
  self:mls(x, y, x+12, y-40, l)
  self:mls(x+1, y, x+13, y-40, l)
  self:mls(x+2, y, x+14, y-40, l)
  self:mls(x+3, y, x+15, y-40, l)
  self:mls(x+4, y, x+16, y-40, l)
  self:mls(x+5, y, x+17, y-40, l)
end

function graphics:n_row_top(x, y, l)
  self:mls(x+20, y-39, x+28, y-39, l)
  self:mls(x+20, y-38, x+28, y-38, l)
  self:mls(x+19, y-37, x+27, y-37, l)
  self:mls(x+19, y-36, x+27, y-36, l)
end

function graphics:n_row_bottom(x, y, l)
  self:mls(x+21, y-40, x+29, y-40, l)
  self:mls(x+21, y-39, x+29, y-39, l)
  self:mls(x+20, y-38, x+28, y-38, l)
  self:mls(x+20, y-37, x+28, y-37, l)
end

return graphics