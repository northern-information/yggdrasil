-- ROUTINE
-- routine;anything.txt
-- r;dreams.txt
commands:register{
  invocations = { "routine", "r" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
    and filesystem:file_or_directory_exists(filesystem:get_routines_path() .. branch[1].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "ROUTINE",
      filename = branch[1].leaves[3]
    }
  end,
  action = function(payload)
    fn.run_routine(payload.filename)
  end
}