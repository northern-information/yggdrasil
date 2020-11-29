runner = {}

function runner.init()
  runner.current_run = "yggdrasil-run-" .. os.date("%Y-%m-%d-%H-%M-%S")
  runner.startup_routine_file = "startup.txt"
end

function runner:start()
  filesystem:file_new(self:get_current_run_file())
end

function runner:startup_routine()
  local startup = filesystem:get_routines_path() .. self.startup_routine_file
  if filesystem:file_or_directory_exists(startup) then
    local lines = filesystem:file_read(startup)
    for k, line in pairs(lines) do
      fn.cmd(line)
    end
  end
end

function runner:run(input)
  local commands = {input}
  -- if this is not an assignment, split the &&s
  if string.find(input, "=") == nil then
    commands = fn.string_split(input, "&&")
  end
  for k, command in pairs(commands) do
    local interpreter = Interpreter:new(command)
    debug_interpreter(interpreter)
    if not interpreter:is_valid() then
      tracker:set_message("Unfound: " .. tostring(interpreter))
    else
      graphics:draw_run_command()
      tracker:clear_message()
      interpreter:execute()
      if filesystem ~= nil then
        filesystem:file_append(self:get_current_run_file(), tostring(interpreter))
      end
    end
  end
end

function runner:get_current_run_file()
  return filesystem:get_runs_path() .. self.current_run .. ".txt"
end

return runner