view = {}

function view.init()
  -- hud
  view.hud = true
  -- tracker
  view.slot_width_min = 16
  view.slot_width = view.slot_width_min
  view.slot_height = 7
  view.tracker_view_dirty = true
  view.view_x = 1
  view.view_x_offset = 0
  view.view_y = 1
  view.view_y_offset = 0
  view.rows_above = nil
  view.rows_below = nil
  view.rows_per_view = 7
  view.cols_per_view = 8
  view.slot_extents = view.slot_width_min
end

function view:refresh()
  local y = self:get_view_y()
  local x = self:get_view_x()
  if tracker:is_follow() then
    local deepest = tracker:get_deepest_not_empty_position()
    x = deepest.x
    y = deepest.y
  end
  self:set_slot_extents(tracker:get_extents())
  self:set_rows_above(y > 2)
  self:set_rows_below(y <= tracker:get_rows() - 5) -- todo what is this magic number
  self:set_cols_per_view(math.floor(128 / self:get_slot_width()))
  self:set_view_x_offset(x - math.ceil(self:get_cols_per_view() / 2))
  self:set_view_y_offset(y - math.ceil(self:get_rows_per_view() / 2))
end

function view:handle_arrow(direction)
  tracker:set_follow(false)
      if direction == "UP"    or direction == "k" then self:pan_y(-1)
  elseif direction == "LEFT"  or direction == "h" then self:pan_x(-1)
  elseif direction == "DOWN"  or direction == "j" then self:pan_y(1)
  elseif direction == "RIGHT" or direction == "l" then self:pan_x(1)
  end
end

function view:pan_x(d)
  tracker:set_follow(false)
  self:set_view_x(util.clamp(self:get_view_x() + d, 1, tracker:get_cols()))
  self:set_tracker_view_dirty(true)
end

function view:pan_y(d)
  tracker:set_follow(false)
  self:set_view_y(util.clamp(self:get_view_y() + d, 1, tracker:get_rows()))
  self:set_tracker_view_dirty(true)
end

function view:pan_to_y(y)
  tracker:set_follow(false)
  self:set_view_y(util.clamp(y, 1, tracker:get_rows()))
  self:set_tracker_view_dirty(true)
end



-- getters & setters

function view:set_tracker_view_dirty(bool)
  self.tracker_view_dirty = bool
end

function view:is_tracker_dirty(bool)
  return self.tracker_view_dirty
end

function view:set_slot_width(i)
  self.slot_width = i
end

function view:get_slot_width()
  return self.slot_width
end

function view:set_slot_height(i)
  self.slot_height = i
end

function view:get_slot_height()
  return self.slot_height
end

function view:get_view_x()
  return self.view_x
end

function view:set_view_x(i)
  self.view_x = i
end

function view:get_view_y()
  return self.view_y
end

function view:set_view_y(i)
  self.view_y = i
end

function view:get_rows_above()
  return self.rows_above
end

function view:set_rows_above(i)
  self.rows_above = i
end

function view:get_rows_below()
  return self.rows_below
end

function view:set_rows_below(i)
  self.rows_below = i
end

function view:get_rows_per_view()
  return self.rows_per_view
end

function view:set_rows_per_view(i)
  self.rows_per_view = i
end

function view:get_cols_per_view()
  return self.cols_per_view
end

function view:set_cols_per_view(i)
  self.cols_per_view = i
end

function view:get_view_x_offset()
  return self.view_x_offset
end

function view:set_view_x_offset(i)
  self.view_x_offset = i
end

function view:get_view_y_offset()
  return self.view_y_offset
end

function view:set_view_y_offset(i)
  self.view_y_offset = i
end

function view:get_slot_extents()
  return self.slot_extents
end

function view:set_slot_extents(i)
  self.slot_extents = i
  if i > self:get_slot_width_min() then
    self.slot_width = i
  else
    self.slot_width = self:get_slot_width_min()
  end
end

function view:get_slot_width_min()
  return self.slot_width_min 
end

function view:set_slot_width_min(i)
  self.slot_width_min  = i
end

function view:toggle_hud()
  self.hud = not self.hud
end

function view:is_hud()
  return self.hud
end

return view