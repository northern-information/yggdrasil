parameters = {}

function parameters.init()
  parameters.startup = true -- prevents writing parameters on startup

  params:add_separator("")
  params:add_separator("- Y G G D R A S I L -")

  params:add_option("default_hud", "DEFAULT HUD", {"ON", "OFF"})
  params:set_action("default_hud", function(index)
    config.settings.default_hud = (index == 1) and true or false
    view:set_hud(config.settings.default_hud)
    parameters.update()
  end)


  params:add_control("default_depth", "DEFAULT DEPTH", controlspec.new(1,64,"lin",1,8))
  params:set_action("default_depth", function(depth) 
    config.settings.default_depth = depth
    parameters.update()
  end)

  params:add_control("default_tracks", "DEFAULT TRACKS", controlspec.new(1,64,"lin",1,8))
  params:set_action("default_tracks", function(tracks) 
    config.settings.default_tracks = tracks
    parameters.update()
  end)

  local clades = {"SYNTH","MIDI","CROW","YPC"}
  params:add_option("default_clade", "DEFAULT CLADE", clades)
  params:set_action("default_clade", function(i) 
    config.settings.default_clade = clades[i]
    parameters.update()
  end)

  parameters.is_splash_screen_on = true
  params:add_option("splash_screen", "SPLASH SCREEN", {"ENABLED", "DISABLED"})
  params:set_action("splash_screen", function(index) parameters.is_splash_screen_on = index == 1 and true or false end)

  params:add_option("jf_i2c_mode", "JF I2C MODE", {"1", "0"})
  params:set_action("jf_i2c_mode", function(index) crow.ii.jf.mode(index == 1 and 1 or 0) end)

  params:add_option("jf_i2c_tuning", "JF I2C TUNING", {"440 Hz", "432 Hz"})
  params:set_action("jf_i2c_tuning", function(index) crow.ii.jf.god_mode(index == 2 and 1 or 0) end)

  parameters.default_pset = "yggdrasil.pset"
  if util.file_exists(config.settings.save_path .. parameters.default_pset) then 
  	params:read(config.settings.save_path .. parameters.default_pset)
  else  	
    params:default()
  end
  params:bang()
  parameters.startup = false
end


function parameters.update()
  if not parameters.startup then 
    params:write(config.settings.save_path .. parameters.default_pset)
  end
end

return parameters