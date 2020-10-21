tracker = {}

function tracker.init()
  tracker.cols = 16
  tracker.rows = 16
  tracker.view = {
    x = 1,
    y = 1,
    rows_above = false,
    rows_below = true
  }
  tracker.slots = {}
  for x = 1, tracker.cols do
    for y = 1, tracker.rows do
      table.insert(tracker.slots, Slot:new(x, y))
    end
  end
end

function tracker:scroll_x(d)
  self.view.x = util.clamp(self.view.x + d, 1, self.cols)
end

function tracker:scroll_y(d)
  self.view.y = util.clamp(self.view.y + d, 1, self.rows)
  self.view.rows_above = self.view.y > 1
  self.view.rows_below = self.view.y <= self.rows - 7
end

function tracker:focus(x, y)
  self:unfocus()
  for k, slot in pairs(self.slots) do
    if slot.x == x and slot.y == y then
      slot:set_focus(true)
      self.view.x = x
      self.view.y = y
    end
  end
end

function tracker:unfocus()
  local focused_slot = self:get_focused_slot()
  if focused_slot ~= nil then
    focused_slot:set_focus(false)
  end
end

function tracker:get_focused_slot()
  for k, slot in pairs(self.slots) do
    if slot:is_focus() then
      return slot
    end
  end
end

function tracker:render()
  graphics:draw_cols(self.view)
  graphics:draw_slots(self.slots, self.view)
  graphics:draw_terminal()
end

return tracker