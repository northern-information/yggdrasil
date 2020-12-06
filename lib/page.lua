local page = {}

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
  view:set_x(1)
  view:set_y(1)
  if y.init_done and (i < 1 or i > #page.titles) then return end
  graphics:trigger_transition()
  self.active_page = i
  if i == 1 then
    terminal:set_focus(true)
  end
  view:refresh()
  fn.dirty_screen(true)
end

function page:render()
      if page.error            then self:error_message()
  elseif self.active_page == 0 then graphics:render_page("splash")
  elseif self.active_page == 1 then graphics:render_page("tracker")
  elseif self.active_page == 2 then graphics:render_page("mixer")
  elseif self.active_page == 3 then graphics:render_page("clades")
  end
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