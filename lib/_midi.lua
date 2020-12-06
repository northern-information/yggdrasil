_midi = {}

function _midi.init()
  _midi.devices = {}
  _midi.devices[1] = midi.connect(1)
  _midi.devices[2] = midi.connect(2)
  _midi.devices[3] = midi.connect(3)
  _midi.devices[4] = midi.connect(4)
  _midi.notes = {}
end

function _midi:play(note, velocity, channel, device, origin_track)
  if not fn.is_int(note) then return end
  self:kill_notes_on_track(origin_track) -- kill all notes before registering new one
  self:register_note(note, velocity, channel, device, origin_track)
  self.devices[device]:note_on(note, velocity, channel)
end

function _midi:register_note(note, velocity, channel, device, origin_track)
  local new = {
    note = note,
    velocity = velocity,
    channel = channel,
    device = device,
    origin_track = origin_track,
    birthday = _clock:get_the_arrow_of_time()
  }
  for k, registered_note in pairs(self.notes) do
    if registered_note.note == new.note
    and registered_note.channel == new.channel
    and registered_note.device == new.device then
      table.remove(self.notes, k)
    end
  end
  table.insert(self.notes, new)
end

function _midi:kill_notes_on_track(track)
  for k, registered_note in pairs(self.notes) do
    if registered_note.origin_track == track then
      self.devices[registered_note.device]:note_off(registered_note.note, registered_note.velocity, registered_note.channel)
      table.remove(self.notes, k)
    end
  end
end

function _midi:all_off()
  for note = 1, 127 do
    for channel = 1, 16 do
      for device = 1, 4 do
        _midi.devices[device]:note_off(note, 0, channel)
      end
    end
  end
end

return _midi
