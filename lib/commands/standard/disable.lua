-- DISABLE
-- disable
-- 1 disable
commands:register{
  invocations = { "disable" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return end
    return 
      (
        Validator:new(branch[1], invocations):ok()
      ) or (
        fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
      )
  end,
  payload = function(branch)
    return {
        class = "DISABLE",
        x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:disable(payload.x)
    else
      tracker:disable_all()
    end
  end
}