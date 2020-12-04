-- DESCEND
-- 1 descend
-- descend
commands:register{
  invocations = { "descend", "des" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return (
      Validator:new(branch[1], invocations):ok()
    ) or (
      fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
    )
  end,
  payload = function(branch)
    local out = {
      class = "DESCEND"
    }
    if #branch == 2 then
      out["x"] = branch[1].leaves[1]
    end
    return out
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:get_track(payload.x):set_descend(true)
    else
      tracker:descend()
    end
  end
}