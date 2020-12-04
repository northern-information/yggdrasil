-- $
-- $1 = 2 mute
commands:register{
  invocations = { "$" },
  signature = function(branch, invocations)
    if #branch < 3 then return false end
    return
      Validator:new(branch[1], invocations):validate_prefix_invocation()
      and branch[2].leaves[1] == "=" -- :)
      and branch[3] ~= nil
  end,
  payload = function(branch)
    return { class = "$" }
  end,
  action = function(payload)
    -- handled in Interpreter
  end
}