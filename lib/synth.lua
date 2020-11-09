synth = {}

function synth.init()
  synth.encoder_override = false
  synth.c1_override = 50
  synth.c2_override = 50
end

function synth:play(voice, note, velocity, macro1, macro2)
  if not fn.is_int(note) then return end
  local v = velocity ~= nil and velocity or 127
  if self:is_encoder_override() then
    macro1 = self:get_c1_override() * .01
    macro2 = self:get_c2_override() * .01
  end
  local freq = musicutil.note_num_to_freq(music:snap_note(music:transpose_note(note)))
  local voice_name = voice == 1 and "MikaPerc" or "PolyPercMacrod"
  -- print(voice_name, v, freq, macro1, macro2)
  engine.amp(v / 127)
  engine.hz(voice_name, freq, macro1, macro2)
end

function synth:panic()
  engine.panic()
end

function synth:get_c_shift_message()
  return "MANUAL OVERRIDE [" .. self:get_c1_override() .. "] [" .. self:get_c2_override() .. "]"
end

function synth:scroll_c1(d)
  self:set_c1_override(self:get_c1_override() + d)
  tracker:set_message(self:get_c_shift_message())
end

function synth:set_c1_override(i)
  self.c1_override = util.clamp(i, 0, 99)
end

function synth:get_c1_override()
  return self.c1_override
end

function synth:scroll_c2(d)
  self:set_c2_override(self:get_c2_override() + d)
  tracker:set_message(self:get_c_shift_message())
end

function synth:set_c2_override(i)
  self.c2_override = util.clamp(i, 0, 99)
end

function synth:get_c2_override()
  return self.c2_override
end

function synth:toggle_encoder_override()
  self:set_encoder_override(not self:is_encoder_override())
end

function synth:is_encoder_override()
  return self.encoder_override
end

function synth:set_encoder_override(bool)
  self.encoder_override = bool
end

return synth