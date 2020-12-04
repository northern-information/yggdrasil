-- INFO
commands:register{
  invocations = { "info", "version" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "INFO"
    }
  end,
  action = function(payload)
    tracker:toggle_info()
  end
}