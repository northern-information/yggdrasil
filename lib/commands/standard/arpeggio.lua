-- ARPEGGIO
-- 1 arp 60
-- 2 arp;3 60;61
-- 1 3 arp 60
-- 1 3 arp 60;63;65
-- 1 3 arp;2 60;63;65
-- 1 1 arp;2 bmin
-- 1 arp bmin
commands:register{
  invocations = { "arpeggio", "arp", "a" },
  signature = function(branch, invocations)
    if #branch == 3 then
      return fn.is_int(branch[1].leaves[1]) 
        and Validator:new(branch[2], invocations):ok()
        and ( 
          fn.is_int(branch[3].leaves[1])
          or music:chord_to_midi(branch[3].leaves[1])
        )
    elseif #branch == 4 then
      tabutil.print(branch)
      return fn.is_int(branch[1].leaves[1]) 
        and fn.is_int(branch[2].leaves[1])
        and Validator:new(branch[3], invocations):ok()
        and ( 
          fn.is_int(branch[4].leaves[1])
          or music:chord_to_midi(branch[4].leaves[1])
        )
    end
  end,
  payload = function(branch)
    local value = 0
    local midi_notes = {}
    local y = 1
    if #branch == 3 then
      if music:chord_to_midi(branch[3].leaves[1]) then
        valid, midi_notes = music:chord_to_midi(branch[3].leaves[1])
      else
        midi_notes = fn.table_remove_semicolons(branch[3].leaves)
      end
      value = branch[2].leaves[3] ~= nil and branch[2].leaves[3] or 0
    elseif #branch == 4 then
      if music:chord_to_midi(branch[4].leaves[1]) then
        valid, midi_notes = music:chord_to_midi(branch[4].leaves[1])
      else
        midi_notes = fn.table_remove_semicolons(branch[4].leaves)
      end
      y = branch[2].leaves[1]
      value = branch[3].leaves[3] ~= nil and branch[3].leaves[3] or 0
      midi_notes = midi_notes
    end
    return {
      class = "ARPEGGIO",
      value = value,
      midi_notes = midi_notes,
      x = branch[1].leaves[1],
      y = y,
    }
  end,
  action = function(payload)
    tracker:update_every_other(payload)
    tracker:select_track(payload.x)
    tracker:refresh()
  end
}