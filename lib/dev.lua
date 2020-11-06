screen.ping()

dev = {}

function dev:scene(i)
  if i == 1 then
    filesystem:set_load_file(config.settings.load_file)
    filesystem:load()
    local clades = {}
    clades[1] = "SYNTH"
    clades[2] = "MIDI"
    clades[3] = "SAMPLER"
    clades[4] = "CROW"
    local tracks = tracker:get_tracks()
    for k, track in pairs(tracks) do
      track:set_clade(clades[math.random(1, 4)])
      track:set_muted(math.random(1, 2) == 1)
      -- track:set_soloed(math.random(1, 2) == 1)
      track:set_enabled(math.random(1, 2) == 1)
      track:set_descend(math.random(1, 2) == 1)
      track:set_clock_sync(math.random(1, 10) * .1)
      track:set_shadow(math.random(1, 2) == 1 and math.random(1, 8) or 0)
      track:set_level(math.random(0, 100) * .01)
    end
    t(1):set_clade("SYNTH")
    t(1):unshadow()
    t(1):unsolo()
    t(1):unmute()
    t(1):enable()
    t(1):set_level(1)
    t(1):refresh()
    page:select(1)
  elseif i == 2 then
    for i=1,5 do
      t(i):set_clade("SAMPLER")
      t(i):unshadow()
      t(i):unsolo()
      t(i):unmute()
      t(i):enable()
      t(i):set_level(1)
      t(i):refresh()
    end
    cmd("1 1 c;c/e;3")
    cmd("1 3 c;em;3")
    cmd("1 5 c;am/e;3")
    cmd("1 7 c;f;3")
    cmd("4 2 76")
    cmd("4 4 72")
    cmd("1 depth;8")
    cmd("2 depth;8")
    cmd("3 depth;8")
    page:select(1)
    sampler:load_sample("/home/we/dust/code/yggdrasil/samples/piano1_uiowa_440hz.wav")
    sampler:load_sample("/home/we/dust/code/yggdrasil/samples/wineglass_halffull_526hz.wav")
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
