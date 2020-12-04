-- EXIT
commands:register{
  invocations = { "exit", "ragequit" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "exit"
    }
  end,
  action = function(payload)
    _menu.set_mode(true)
    fn.print_matron_message("FAREWELL YGGDRASIL PILOT!")
    norns.script.clear()
  end
}