synth = {}

function synth.init()

end

function synth:play(voice, note, velocity, macro1, macro2)
  if not fn.is_int(note) then return end
  local v = velocity ~= nil and velocity or 127
  print("engine.voice(" .. voice .. ") VOICE!!11!!1!")
  engine.amp(v / 127)
  engine.hz(
    musicutil.note_num_to_freq(music:snap_note(music:transpose_note(note))), 
    macro1, macro2)
end

return synth