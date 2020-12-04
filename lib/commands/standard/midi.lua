-- MIDI
-- 1 midi;d;2
-- 1 midi;c;10
commands:register{
  invocations = { "midi" },
  signature = function(branch, invocations)
    if #branch ~= 2 then return false end
    return Validator:new(branch[2], invocations):ok()
        and branch[2].leaves[3] == "d" 
            or branch[2].leaves[3] == "device" 
            or branch[2].leaves[3] == "c"
            or branch[2].leaves[3] == "channel"
        and fn.is_int(branch[2].leaves[5])
  end,
  payload = function(branch)
    local out = {
        class = "MIDI",
        x = branch[1].leaves[1]
    }
    if branch[2].leaves[3] == "d" or branch[2].leaves[3] == "device" then
      out["device"] = branch[2].leaves[5]
    elseif branch[2].leaves[3] == "c" or branch[2].leaves[3] == "channel" then
      out["channel"] = branch[2].leaves[5]
    end
    return out
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
}