-- FOLLOW
commands:register{
  invocations = { "follow" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "FOLLOW"
    }
  end,
  action = function(payload)
    tracker:toggle_follow()
  end
}