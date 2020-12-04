-- PANIC
commands:register{
  invocations = { "panic" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "PANIC"
    }
  end,
  action = function(payload)
    _midi:all_off()
    synth:panic()
  end
}