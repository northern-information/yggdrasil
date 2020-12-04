-- NOTE
-- 1 1 72
-- 1 1 c5
commands:register{
  invocations = {},
  signature = function(branch, invocations)
    if #branch ~= 3 then return faslse end
    return (
      fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_int(branch[3].leaves[1])
    ) or (
      fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and music:is_valid_ygg(branch[3].leaves[1])
    )
  end,
  payload = function(branch)
    local midi_note = 0
    if fn.is_int(branch[3].leaves[1]) then
      midi_note = branch[3].leaves[1]
    else
      midi_note = music:convert("ygg_to_midi", branch[3].leaves[1])
    end
    return {
      class = "NOTE",
      midi_note = midi_note,
      x = branch[1].leaves[1],
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
    tracker:select_slot(payload.x, payload.y)
  end
}