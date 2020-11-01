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

function page:scroll(d)
  self:select(util.clamp(page.active_page + d, 1, #page.titles))
end

function page:select(i)
  if y.init_done and (i < 1 or i > #page.titles) then return end
  self.active_page = i
  fn.dirty_screen(true)
end

function page:render()
  graphics:setup()
      if page.error            then self:error_message()
  elseif self.active_page == 0 then graphics:splash()
  elseif self.active_page == 1 then self:tracker()
  elseif self.active_page == 2 then self:dev()
  end
  fn.dirty_screen(true)
  graphics:teardown()
end

function page:tracker()
  tracker:render()
end

function page:dev()
  graphics:yggdrasil()
end

function page:error_message()
  print("Error:", self.error_code)
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

return page