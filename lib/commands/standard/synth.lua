-- SYNTH
-- 1 synth;voice;2
-- 1 synth;v;2
-- 1 synth;m1;99
-- 1 2 synth;m2;8
-- synth;enc
commands:register{
  invocations = { "synth" },
  signature = function(branch, invocations)
    if #branch == 1 then
      return Validator:new(branch[1], invocations):ok()
        and branch[1].leaves[3] == "enc"
    elseif #branch == 2 then
    return (
      Validator:new(branch[2], invocations):ok()
      and fn.table_contains( {"voice", "v" }, branch[2].leaves[3])
      and #branch[2].leaves == 5
    ) or (
      fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and fn.table_contains( {"m1", "m2" }, branch[2].leaves[3])
      and fn.is_number(branch[2].leaves[5])
    )
    elseif #branch == 3 then
      return fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
      and fn.table_contains( {"m1", "m2" }, branch[3].leaves[3])
      and fn.is_number(branch[3].leaves[5])
    end
  end,
  payload = function(branch)
    local out = {
        class = "SYNTH",
        x = branch[1].leaves[1],
    }
    if #branch == 1 then
      synth:toggle_encoder_override()
    elseif #branch == 2 and fn.table_contains( {"voice", "v" }, branch[2].leaves[3]) then
      local v = branch[2].leaves[5]
      if fn.is_int(v) then
        out["voice"] = v
      elseif v == "ppm" then
        out["voice"] = 1
      elseif v == "rikki" then
        out["voice"] = 2
      elseif v == "toast" then
        out["voice"] = 3
      end
    elseif #branch == 2 and fn.table_contains( {"m1", "m2" }, branch[2].leaves[3]) then
      out[branch[2].leaves[3]] = branch[2].leaves[5]
    elseif #branch == 3 then
      out["y"] = branch[2].leaves[1]
      out[branch[3].leaves[3]] = branch[3].leaves[5]
    end
    return out
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
}