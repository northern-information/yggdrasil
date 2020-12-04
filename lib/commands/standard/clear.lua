-- CLEAR
commands:register{
  invocations = { "clear" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "clear"
    }
  end,
  action = function(payload)
    tracker:clear_tracks()
  end
}