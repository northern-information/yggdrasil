-- SAVE
-- 1 save what-is-love.txt
commands:register{
  invocations = { "save" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
       and Validator:new(branch[2], invocations):ok()
       and #branch[3].leaves == 1
  end,
  payload = function(branch)
    return {
      class = "SAVE",
      filename = branch[3].leaves[1],
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
    tracker:save_track(payload.x, payload.filename)
  end
}