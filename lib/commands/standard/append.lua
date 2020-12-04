-- APPEND
-- 1 append;3
-- 1 append;3 shadow
-- 1 append;3 sha
commands:register{
  invocations = { "append", "ap" },
  signature = function(branch, invocations)
    if #branch ~= 2 and #branch ~= 3 then return false end
    return (
      fn.is_int(branch[1].leaves[1]) 
      and Validator:new(branch[2], invocations):ok()
      and fn.is_int(branch[2].leaves[3])
    ) or (
      fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and fn.is_int(branch[2].leaves[3])
      and fn.table_contains({"shadow", "sha"}, branch[3].leaves[1])
    )
  end,
  payload = function(branch)
    return {
      class = "APPEND",
      shadow = #branch == 3,
      value = branch[2].leaves[3],
      x = branch[1].leaves[1]
    }
  end,
  action = function(payload)
    for i = 1, payload.value do
      local position = i - 1
      tracker:append_track_after(payload.x + position, payload.shadow)
    end
  end
}