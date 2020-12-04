-- CROW
-- 1 crow;pair;1
-- 1 crow;p;2
-- 1 crow;jf;on
commands:register{
  invocations = { "crow" },
  signature = function(branch, invocations)
    if #branch ~= 2 then return false end
    return (
        Validator:new(branch[2], invocations):ok()
        and (branch[2].leaves[3] == "pair" 
            or branch[2].leaves[3] == "p")
        and fn.is_int(branch[2].leaves[5])
    ) or (
        Validator:new(branch[2], invocations):ok()
        and branch[2].leaves[3] == "jf" 
        and (branch[2].leaves[5] == "on"
            or branch[2].leaves[5] == "off")
    )
  end,
  payload = function(branch)
    local out = {
      class = "CROW",
      x = branch[1].leaves[1]
    }
    if branch[2].leaves[3] == "jf" then
      out["jf"] = (branch[2].leaves[5] == "on")
    else
      out["pair"] = branch[2].leaves[5]
    end
    return out
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
}