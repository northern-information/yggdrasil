runner = {}

function runner.init()
  runner.current_run = "yggdrasil-run-" .. os.date("%Y-%m-%d-%H-%M-%S")
end

function runner:start()
  filesystem:file_new(self:get_current_run_file())
end

function runner:run(raw_input)
  local interpreter = Interpreter:new(raw_input)
  debug_interpreter(interpreter)
  if not interpreter:is_valid() then
    tracker:set_message("Unfound: " .. tostring(interpreter))
  else
    graphics:draw_run_command()
    tracker:clear_message()
    interpreter:execute()
    filesystem:file_append(self:get_current_run_file(), tostring(interpreter))
  end
end

function runner:get_current_run_file()
  return filesystem:get_runs_path() .. self.current_run .. ".txt"
end

return runner