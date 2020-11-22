synth = {}

function synth.init()
  synth.encoder_override = false
  synth.m1_override = 50
  synth.m2_override = 50
end

function synth:play(voice, note, velocity, macro1, macro2)
  if not fn.is_int(note) then return end
  local v = velocity ~= nil and velocity or 127
  if self:is_encoder_override() then
    macro1 = self:get_m1_override() * .01
    macro2 = self:get_m2_override() * .01
  end
  local freq = musicutil.note_num_to_freq(music:snap_note(music:transpose_note(note)))
  local voice_name = ({
    "MikaPerc", 
    "PolyPercMacrod",
    "YggyToast"
  })[voice] or "PolyPercMacrod"
  engine.amp(v / 127)
  engine.hz(voice_name, freq, macro1, macro2)
end

function synth:panic()
  engine.panic()
end

function synth:get_c_shift_message()
  return "MANUAL OVERRIDE [" .. self:get_m1_override() .. "] [" .. self:get_m2_override() .. "]"
end

function synth:scroll_m1(d)
  self:set_m1_override(self:get_m1_override() + d)
  tracker:set_message(self:get_c_shift_message())
end

function synth:set_m1_override(i)
  self.m1_override = util.clamp(i, 0, 99)
end

function synth:get_m1_override()
  return self.m1_override
end

function synth:scroll_m2(d)
  self:set_m2_override(self:get_m2_override() + d)
  tracker:set_message(self:get_c_shift_message())
end

function synth:set_m2_override(i)
  self.m2_override = util.clamp(i, 0, 99)
end

function synth:get_m2_override()
  return self.m2_override
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