-- K3
-- k3 = some amazing thing
commands:register{
  invocations = { "k3" },
  signature = function(branch, invocations)
    if #branch < 3 then return false end
    return Validator:new(branch[1], invocations):ok()
        and branch[2].leaves[1] == "="
  end,
  payload = function(branch)
    local command_string = ""
    -- remove the "k3" and the "="
    -- leaving us with just whatever is left afterwards
    table.remove(branch, 1)
    table.remove(branch, 1)
    for k, v in pairs(branch) do
      for kk, vv in pairs(v.leaves) do
        command_string = command_string .. vv
      end
      command_string = command_string .. " "
    end
    return {
      class = "K3",
      command_string = command_string
    }
  end,
  action = function(payload)
    commands:set_k3(payload.command_string)
  end
}