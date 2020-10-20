parameters = {}

function parameters.init()

  params:add_separator("")
  params:add_separator("- Y G G D R A S I L -")

  parameters.is_splash_screen_on = true
  params:add_option("splash_screen", "SPLASH SCREEN", {"ENABLED", "DISABLED"})
  params:set_action("splash_screen", function(index) parameters.is_splash_screen_on = index == 1 and true or false end)

  params:default()
  params:bang()
end

return parameters