-- SHADOW
-- 1 shadow;2
-- 1 sha;5
commands:register{
  invocations = { "shadow", "sha" },
  signature = function(branch, invocations)
    if #branch ~= 2 then return false end
    return fn.is_int(branch[1].leaves[1]) 
      and Validator:new(branch[2], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "SHADOW",
      shadow = branch[2].leaves[3],
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
     tracker:update_track(payload)
  end
}