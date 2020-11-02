view = {}

function view.init()
  -- page
  view.index = 1
  view.tracker = false
  view.hud = false
  view.mixer = false
  view.total_views = 4
  -- tracker
  view.slot_width_min = 16
  view.slot_width = view.slot_width_min
  view.slot_height = 7
  view.tracker_dirty = true
  view.x = 1
  view.x_offset = 0
  view.y = 1
  view.y_offset = 0
  view.rows_above = nil
  view.rows_below = nil
  view.rows_per_view = 7
  view.cols_per_view = 8
  view.slot_extents = view.slot_width_min
  view.slot_left_padding = 4
  view.transposed = false
end

function view:refresh()
  local index = self:get_index()
  if index == 1 then
    self:set_tracker(true)
    self:set_hud(false)
    self:set_mixer(false)
    self:set_clades(false)
    self:set_transposed(false)
    page:select(1)
  elseif index == 2 then
    self:set_tracker(true)
    self:set_hud(true)
    self:set_mixer(false)
    self:set_clades(false)
    self:set_transposed(false)
    page:select(1)
  elseif index == 3 then
    self:set_tracker(false)
    self:set_hud(false)
    self:set_mixer(true)
    self:set_clades(false)
    self:set_transposed(false)
    page:select(2)
  elseif index == 4 then
    self:set_tracker(false)
    self:set_hud(false)
    self:set_mixer(false)
    self:set_clades(true)
    self:set_transposed(true)
    page:select(3)
  end
  local y = self:get_y()
  local x = self:get_x()
  if tracker:is_follow() then
    local deepest = tracker:get_deepest_not_empty_position()
    x = deepest.x
    y = deepest.y
  end
  self:set_slot_extents(tracker:get_extents())
  self:set_rows_above(y > 2)
  self:set_rows_below(y <= tracker:get_rows() - 5) -- todo what is this magic number
  self:set_cols_per_view(math.floor(128 / self:get_slot_width()))
  self:set_x_offset(x - math.ceil(self:get_cols_per_view() / 2))
  if not self:is_clades() then
    self:set_y_offset(y - math.ceil(self:get_rows_per_view() / 2))
  else
    self:set_y_offset(x - 1) -- clades are transposed
  end
end

function view:handle_pan(direction)
  tracker:set_follow(false)
  if not self:is_transposed() then
        if direction == "k" then self:pan_y(-1)
    elseif direction == "h" then self:pan_x(-1)
    elseif direction == "j" then self:pan_y(1)
    elseif direction == "l" then self:pan_x(1)
    end
  else
        if direction == "k" then self:pan_x(-1)
    elseif direction == "h" then self:pan_y(-1)
    elseif direction == "j" then self:pan_x(1)
    elseif direction == "l" then self:pan_y(1)
    end
  end
end

function view:pan_x(d)
  tracker:set_follow(false)
  self:set_x(util.clamp(self:get_x() + d, 1, tracker:get_cols()))
  self:set_tracker_dirty(true)
end

function view:pan_y(d)
  tracker:set_follow(false)
  self:set_y(util.clamp(self:get_y() + d, 1, tracker:get_rows()))
  self:set_tracker_dirty(true)
end

function view:pan_to_y(y)
  tracker:set_follow(false)
  self:set_y(util.clamp(y, 1, tracker:get_rows()))
  self:set_tracker_dirty(true)
end

function view:cycle()
  self:set_index(fn.cycle(self:get_index() + 1, 1, self.total_views))
  self:refresh()
end

-- getters & setters

function view:set_index(i)
  self.index = i
end

function view:get_index()
  return self.index
end

function view:set_tracker_dirty(bool)
  self.tracker_dirty = bool
end

function view:is_tracker_dirty(bool)
  return self.tracker_dirty
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

function view:get_x()
  return self.x
end

function view:set_x(i)
  self.x = i
end

function view:get_y()
  return self.y
end

function view:set_y(i)
  self.y = i
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

function view:get_x_offset()
  return self.x_offset
end

function view:set_x_offset(i)
  self.x_offset = i
end

function view:get_y_offset()
  return self.y_offset
end

function view:set_y_offset(i)
  self.y_offset = i
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

function view:get_slot_left_padding()
  return self.slot_left_padding
end

function view:set_hud(bool)
  self.hud = bool
end

function view:is_hud()
  return self.hud
end

function view:set_tracker(bool)
  self.tracker = bool
end

function view:is_tracker()
  return self.tracker
end

function view:set_mixer(bool)
  self.mixer = bool
end

function view:is_mixer()
  return self.mixer
end

function view:set_clades(bool)
  self.clades = bool
end

function view:is_clades()
  return self.clades
end

function view:set_transposed(bool)
  self.transposed = bool
end

function view:is_transposed()
  return self.transposed
end

return view