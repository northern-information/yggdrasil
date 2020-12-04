-- ASCEND
-- 1 ascend
-- ascend
commands:register{
  invocations = { "ascend", "asc" },
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
      class = "ASCEND"
    }
    if #branch == 2 then
      out["x"] = branch[1].leaves[1]
    end
    return out
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:get_track(payload.x):set_descend(false)
    else
      tracker:ascend()
    end
  end
}