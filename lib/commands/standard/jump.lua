-- JUMP
-- :4
commands:register{
  invocations = { ":" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):validate_prefix_invocation()
      and fn.is_int(branch[1].leaves[2])
  end,
  payload = function(branch)
    return {
      class = "JUMP",
      y = branch[1].leaves[2]
    }
  end,
  action = function(payload)
    if page:get_active_page() == 1 then
      view:set_y(util.clamp(payload.y, 1, tracker:get_rows()))
    end
  end
}