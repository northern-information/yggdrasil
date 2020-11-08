parameters = {}

function parameters.init()

  params:add_separator("")
  params:add_separator("- Y G G D R A S I L -")

  parameters.is_splash_screen_on = true
  params:add_option("splash_screen", "SPLASH SCREEN", {"ENABLED", "DISABLED"})
  params:set_action("splash_screen", function(index) parameters.is_splash_screen_on = index == 1 and true or false end)

  params:add_option("jf_i2c_mode", "JF I2C MODE", {"1", "0"})
  params:set_action("jf_i2c_mode", function(index) crow.ii.jf.mode(index == 1 and 1 or 0) end)

  params:add_option("jf_i2c_tuning", "JF I2C TUNING", {"440 Hz", "432 Hz"})
  params:set_action("jf_i2c_tuning", function(index) crow.ii.jf.god_mode(index == 2 and 1 or 0) end)

  params:add_control("default_depth", "DEFAULT DEPTH", controlspec.new(1,64,"lin",8,1,"rows"))
  params:set_action("default_depth", function(depth) 
    config.settings.default_depth == depth
  	parameters.update()
  end)

  if util.file_exists(config.settings.save_path.."yggdrasil.pset") then 
	params:read(config.settings.save_path.."yggdrasil.pset")
  else  	
    params:default()
  end
  params:bang()
end


function parameters.update()
  params:write(config.settings.save_path.."yggdrasil.pset")
end

return parameters