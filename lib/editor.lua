editor = {}

function editor.init()
  editor.open = false
  editor.editing_track = nil
  editor.editing_slot = nil
end

function editor:activate(x, y)
  self:set_open(true)
  local track = tracker:get_track(x)
  self:set_editing_track(track)
  self:set_editing_slot(track:get_slot(y))
end

function editor:commit_and_close()
  self:set_open(false)
end



-- getters & setters

function editor:get_title()
  if self:slot() == nil or self:track() == nil then return "No slot or track to edit." end
  local ipn = self:slot():get_ipn_note()
  return self:track():get_x() .. " " .. self:slot():get_y() .. (ipn ~= nil and (" " .. ipn) or "")
end


function editor:set_editing_track(track)
  self.editing_track = track
end

function editor:track()
  return self.editing_track
end

function editor:set_editing_slot(slot)
  self.editing_slot = slot
end

function editor:slot()
  return self.editing_slot
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


return editor