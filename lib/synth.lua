synth = {}

function synth.init()

end

function synth:play(note, velocity)
  local v = velocity ~= nil and velocity or 127
  engine.amp(v / 127)
  engine.hz(musicutil.note_num_to_freq(music:snap_note(music:transpose_note(note))))
end

return synth