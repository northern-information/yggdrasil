local clipboard = {}

function clipboard.init()
  clipboard.type = nil
  clipboard.contents = {}
  clipboard.cut = false
  clipboard.copy = false
end

function clipboard:cut_items()
  if tracker:is_selected() then
    self:get_data_from_tracker()
    self:set_cut(true)
    self:set_copy(false)
    self:send_message("Cut")
  end
end

function clipboard:copy_items()
  if tracker:is_selected() then
    self:get_data_from_tracker()
    self:set_copy(true)
    self:set_cut(false)
    self:send_message("Copied")
  end
end



function clipboard:paste_items()
  if not self:is_cut() and not self:is_copy() then
    tracker:set_message("Clipboard empty.")    
  else
    if self:is_slot() then
      tracker:paste_slot(view:get_x(), view:get_y(), self:get_contents()[1])
    elseif self:is_track() then
      tracker:paste_track(view:get_x(), view:get_y(), self:get_contents()[1])
    end
    self:send_message("Pasted")
    if self:is_cut() then
      self:get_contents()[1]:clear()
      self:set_type(nil)
      self:set_cut(false)
      self:set_contents({})
    end
  end
end

function clipboard:get_data_from_tracker()
  self:set_type(tracker:get_selected_type())
  if self:is_slot() or self:is_slots() then
    self:set_contents(tracker:get_selected_slots())
  elseif self:is_track() or self:is_tracks() then
    self:set_contents(tracker:get_selected_tracks())
  end
end

function clipboard:send_message(prefix)
    local message = self:get_type() .. "."
    if self:is_slot() then
      local slot = tracker:get_track(view:get_x()):get_slot(view:get_y())
      message = "slot X" .. slot:get_x() .. "Y" .. slot:get_y() .. "."
    else
      
    end
    tracker:set_message(prefix .. " " .. message)  
end

function clipboard:get_contents()
  return self.contents
end

function clipboard:set_contents(t)
  self.contents = t
end

function clipboard:get_type()
  return self.type
end

function clipboard:set_type(s)
  self.type = s
end

function clipboard:is_slot()
  return self.type == "slot"
end

function clipboard:is_slots()
  return self.type == "slots"
end

function clipboard:is_track()
  return self.type == "track"
end

function clipboard:is_tracks()
  return self.type == "tracks"
end

function clipboard:set_cut(bool)
  self.cut = bool
end

function clipboard:is_cut()
  return self.cut
end

function clipboard:set_copy(bool)
  self.copy = bool
end

function clipboard:is_copy()
  return self.copy
end

return clipboard