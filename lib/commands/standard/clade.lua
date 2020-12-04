-- CLADE
-- 1 clade;midi
commands:register{
  invocations = { "clade" },
  signature = function(branch, invocations)
    if #branch ~= 2 then return false end
    return fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and fn.table_contains({ "synth", "midi", "ypc", "crow" }, branch[2].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "CLADE",
      clade = string.upper(branch[2].leaves[3]),
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
}
