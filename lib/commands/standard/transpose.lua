-- TRANSPOSE_SLOT
-- TRANSPOSE
-- 1 1 transpose;12
-- 1 1 trp;12
-- 1 1 t;1
-- 1 t;1
commands:register{
  invocations = { "transpose", "trans", "t" },
  signature = function(branch, invocations)
    -- if #branch ~= 3 then return false end
    if #branch == 2 then 
      return fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
        and fn.is_int(branch[2].leaves[3])
    elseif #branch == 3 then 
      return fn.is_int(branch[1].leaves[1])
        and fn.is_int(branch[2].leaves[1])
        and Validator:new(branch[3], invocations):ok()
        and fn.is_int(branch[3].leaves[3])
    end
  end,
  payload = function(branch)
    local out = {
      x = branch[1].leaves[1]
    }

    if #branch == 2 then
      out.class = "TRANSPOSE"
      out.value = branch[2].leaves[3]
    elseif #branch == 3 then
      out.class = "TRANSPOSE_SLOT"
      out.value = branch[3].leaves[3]
      out.y = branch[2].leaves[1]
    else
      error("WATs"..#branch)
    end
    return out
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
}
