-- SELECT
-- 1 2
-- 1;5
commands:register{
  invocations = {},
  signature = function(branch, invocations)
    if #branch == 1 then
      return (
        fn.is_int(branch[1].leaves[1])
      ) or (
        fn.is_int(branch[1].leaves[1])
        and branch[1].leaves[2] == ";"
        and fn.is_int(branch[1].leaves[3])
        and fn.is_int(branch[1].leaves[1]) < fn.is_int(branch[1].leaves[3])
      )
    elseif #branch == 2 then
      return fn.is_int(branch[1].leaves[1]) 
      and fn.is_int(branch[2].leaves[1])
    end
  end,
  payload = function(branch)
    local out = {
      class = "SELECT",
      range = false,
      x1 = branch[1].leaves[1]
    }
    if branch[2] ~= nil then
      out["y"] = branch[2].leaves[1]
    end
    if branch[1].leaves[2] == ";" then
      out.range = true
      out["x2"] = branch[1].leaves[3]
    end
    return out
  end,
  action = function(payload)
    if payload.y ~= nil then
      tracker:select_slot(payload.x1, payload.y)
    else
      if payload.x2 ~= nil then
        tracker:select_range_of_tracks(payload.x1, payload.x2)
      else
        tracker:deselect()
        tracker:select_track(payload.x1)
      end
    end
  end
}