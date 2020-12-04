-- CHORD
-- 1 1 chord;60;63;67
-- 1 1 chord;bmin
commands:register{
  invocations = { "chord", "c" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
      and (#branch[3].leaves >= 3 and fn.is_int(branch[3].leaves[3]))
          or (#branch[3].leaves >= 3 and music:chord_to_midi(branch[3].leaves[3]))
  end,
  payload = function(branch)
    local c = branch[3].leaves[3]
    if #branch[3].leaves > 3 then 
      -- include the octave information like `cm;3`
      c = branch[3].leaves[3]..branch[3].leaves[4]..branch[3].leaves[5]
    end
    local is_chord, midi_notes, note_names = music:chord_to_midi(c)
    if not is_chord then
      -- clear the invocation and semicolon
      -- we're doing it this way because we don't know how many
      -- notes are in this chord. could be 3, could be 10.
      table.remove(branch[3].leaves, 1)
      table.remove(branch[3].leaves, 1)
      midi_notes = fn.table_remove_semicolons(branch[3].leaves)
    end
    return {
      class = "CHORD",
      midi_notes = midi_notes,
      x = branch[1].leaves[1],
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
    tracker:chord(payload)
    tracker:select_slot(payload.x, payload.y)
    tracker:refresh()
  end
}