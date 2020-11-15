editor = {}

function editor.init()
  editor.open = false
  editor.track = nil
  editor.slot = nil
  editor.fields = {}
  editor.valid = true
end

function editor:activate(x, y)
  self:set_open(true)
  local track = tracker:get_track(x)
  self:set_track(track)
  self:set_slot(track:get_slot(y))
  print("get editable fields?")
end

function editor:clear()
  self:set_open(false)
  self:set_track(nil)
  self:set_slot(nil)
  self:set_fields({})
end

function editor:commit_and_close()
  -- commit...
  self:clear()
end



-- getters & setters

function editor:get_title()
  if self:get_slot() == nil or self:get_track() == nil then return "No slot or track to edit." end
  local ipn = self:get_slot():get_ipn_note()
  return self:get_track():get_x() .. " " .. self:get_slot():get_y() .. (ipn ~= nil and (" " .. ipn) or "")
end

function editor:set_track(track)
  self.track = track
end

function editor:get_track()
  return self.track
end

function editor:set_slot(slot)
  self.slot = slot
end

function editor:get_slot()
  return self.slot
end

function editor:close()
  self:set_open(false)
end

function editor:is_open()
  return self.open
end

function editor:set_open(bool)
  self.open = bool
end

function editor:set_fields(t)
  self.fields = t
end

function editor:get_fields()
  return self.fields
end

function editor:is_valid()
  return self.valid
end

function editor:set_valid(bool)
  self.valid = bool
end

return editor