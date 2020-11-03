page = {}

function page.init()
  page.titles = config.page_titles
  page.active_page = 0
  page.error = false
  page.error_code = 0
end

function page:get_page_title()
  return self.titles[self.active_page]
end

function page:cycle()
  self:select(fn.cycle(page.active_page + 1, 1, #page.titles))
end

function page:select(i)
  -- reset the view x and y for everything but moving from tracker to tracker + hud
  if not (self.active_page == 1 and i == 2) and not (self.active_page == 2 and i == 1) then
    view:set_x(1)
    view:set_y(1)
  end
  if y.init_done and (i < 1 or i > #page.titles) then return end
  self.active_page = i
  view:refresh()
  fn.dirty_screen(true)
end

function page:render()
  graphics:setup()
  view:refresh()
      if page.error            then self:error_message()
  elseif self.active_page == 0 then graphics:splash()
  elseif self.active_page == 1 then self:render_tracker()
  elseif self.active_page == 2 then self:render_tracker("with_hud")
  elseif self.active_page == 3 then self:render_mixer()
  elseif self.active_page == 4 then self:render_clades()
  end
  fn.dirty_screen(true)
  graphics:teardown()
end

function page:render_tracker(hud)
  if hud ~= nil then
    graphics:draw_hud_background()
  end
  graphics:draw_focus()
  graphics:draw_tracks()
  if hud ~= nil then
    graphics:draw_hud_foreground()
  end
  graphics:draw_terminal()
  graphics:draw_command_processing()
  graphics:draw_y_mode()
end

function page:render_mixer()
  graphics:draw_mixer()
  graphics:draw_terminal()
  graphics:draw_command_processing()
  graphics:draw_y_mode()
end

function page:render_clades()
  graphics:draw_clades()
  graphics:draw_terminal()
  graphics:draw_command_processing()
  graphics:draw_y_mode()
end

function page:error_message()
  local e = "Error:", self.error_code
  tracker:set_message(e)
  print(e)
end

function page:set_error(i)
  self.error = true
  self.error_code = i
end

function page:clear_error()
  self.error = false
  self.error_code = 0
end

function page:get_page_count()
  return #self.titles
end

function page:get_active_page()
  return self.active_page
end

function page:is(s)
  return self:get_page_title() == s
end

return page