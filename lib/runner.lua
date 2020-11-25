runner = {}

function runner.init()
  runner.current_run = "yggdrasil-run-" .. os.date("%Y-%m-%d-%H-%M-%S")
end

function runner:start()
  filesystem:file_new(self:get_current_run_file())
end

function runner:run(raw_input)
  local commands = fn.string_split(raw_input, "&&")
  for k, raw_input in pairs(commands) do
    local expanded_input = variables:expand(raw_input)
    local interpreter = Interpreter:new(expanded_input)
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