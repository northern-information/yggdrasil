-- VELOCITY
-- 1 1 velocity;100
-- 1 1 vel;100
-- 1 vel;100
commands:register{
  invocations = { "velocity", "vel" },
  signature = function(branch, invocations)
    if #branch == 2 then
      return fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
    elseif #branch == 3 then
      return fn.is_int(branch[1].leaves[1])
        and fn.is_int(branch[2].leaves[1])
        and Validator:new(branch[3], invocations):ok()
    end
  end,
  payload = function(branch)
    local out = {
      class = "VELOCITY",
      x = branch[1].leaves[1],
    }
    if #branch == 3 then
      out["velocity"] = branch[3].leaves[3]
      out["y"] = branch[2].leaves[1]
    elseif #branch == 2 then
      out["velocity"] = branch[2].leaves[3]
    end
    return out
  end,
  action = function(payload)
    if payload.y ~= nil then
      tracker:update_slot(payload)
    else
      for i = 1, tracker:get_track(payload.x):get_depth() do
        payload["y"] = i
        tracker:update_slot(payload)
      end
    end
  end
}