runner = {}

function runner.init() end

function runner:run(raw_input)
  local semiotic = Interpreter:new(raw_input)
  debug_semiotic(semiotic)
  if not semiotic:is_valid() then
    tracker:set_message("Unfound: " .. tostring(semiotic))
  else
    graphics:run_command()
    tracker:clear_message()
    semiotic:execute()
  end
end

return runner