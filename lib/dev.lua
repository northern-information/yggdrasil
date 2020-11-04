screen.ping()

dev = {}

function dev:scene(i)
  if i == 1 then
    filesystem:set_load_file(config.settings.load_file)
    filesystem:load()
    page:select(1)
    local clades = {}
    clades[1] = "SYNTH"
    clades[2] = "MIDI"
    clades[3] = "SAMPLER"
    clades[4] = "CROW"
    local tracks = tracker:get_tracks()
    for k, track in pairs(tracks) do
      track:set_clade(clades[math.random(1, 4)])
      track:set_muted(math.random(1, 2) == 1)
      track:set_soloed(math.random(1, 2) == 1)
      track:set_enabled(math.random(1, 2) == 1)
      track:set_descend(math.random(1, 2) == 1)
      track:set_clock_sync(math.random(1, 10) * .1)
      track:set_shadow(math.random(1, 2) == 1 and math.random(1, 8) or 0)
      track:set_level(math.random(0, 100) * .01)
    end
    
  elseif i == 3 then
    -- clade testing
    filesystem:set_load_file(config.settings.load_file)
    filesystem:load()
    page:select(4)
    local clades = {}
    table.insert(clades, "MIDI")
    table.insert(clades, "CROW")
    table.insert(clades, "SYNTH")
    table.insert(clades, "SAMPLER")
    local tracks = tracker:get_tracks()
    for k, track in pairs(tracks) do
      track:set_clade(clades[math.random(1, 4)])
    end
    t(1):midi()
  end
end

function rerun()
  fn.rerun()
end

function cmd(s)
  local t = fn.string_split(s, "")
  for k, v in pairs(t) do
    buffer:add(v)
  end
  buffer:execute()
end

function s(x, y)
  return tracker:get_track(x):get_slot(y)
end

function t(x)
  return tracker:get_track(x)
end

function debug_interpreter(interpreter)
  if config.settings.debug_interpreter then
    print("") print("") print("")
    print("### START interpreter debug ")
    tabutil.print(interpreter)
    print("split --- ")
    tabutil.print(interpreter.split)
    print("#branches --- ")
    print(#interpreter.branches)
    print("branches --- ")
    for k, v in pairs(interpreter.branches) do
      print("branch", k)
      for kk, vv in pairs(v.leaves) do
        print("leaf", kk, vv)
      end
    end
    print("payload --- ")
    tabutil.print(interpreter.payload)
    print("### END interpretor debug ")
  end
end

return dev