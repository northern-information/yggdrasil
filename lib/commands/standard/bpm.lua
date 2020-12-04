-- BPM
-- bpm;127.3
commands:register{
  invocations = { "bpm" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
      and fn.is_number(branch[1].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "BPM",
      bpm = branch[1].leaves[3]
    }
  end,
  action = function(payload)
    params:set("clock_tempo", payload.bpm)
  end
}