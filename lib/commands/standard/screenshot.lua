-- SCREENSHOT
commands:register{
  invocations = { "screenshot" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "SCREENSHOT"
    }
  end,
  action = function(payload)
    fn.screenshot()
  end
}