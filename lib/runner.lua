runner = {}

function runner.init() end

function runner:run(raw_input)
  local interpreter = Interpreter:new(raw_input)
  debug_interpreter(interpreter)
  if not interpreter:is_valid() then
    tracker:set_message("Unfound: " .. tostring(interpreter))
  else
    graphics:draw_run_command()
    tracker:clear_message()
    interpreter:execute()
  end
end

return runner