runner = {}

function runner.init() end

function runner:run(raw_input)
  local command = Command:new(raw_input)
  print("command ### ")
  tabutil.print(command)
  print("split --- ")
  tabutil.print(command.split)
  print("branches --- ")
  tabutil.print(command.branches[1])
  print("payload --- ")
  tabutil.print(command.payload)
  if not command:is_valid() then
    tracker:set_message("Unfound: " .. tostring(command))
  else
    graphics:run_command()
    tracker:clear_message()
    command:execute()
  end
end

return runner