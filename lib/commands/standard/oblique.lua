-- OBLIQUE
commands:register{
  invocations = { "oblique" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "OBLIQUE"
    }
  end,
  action = function(payload)
    fn.draw_oblique()
  end
}