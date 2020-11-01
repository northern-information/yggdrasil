screen.ping()

dev = {}

function dev:scene(i)
  if i == 1 then
    filesystem:set_load_file(config.settings.load_file)
    filesystem:load()
    page:select(1)
  elseif i == 2 then
    page:select(2)
  else
    print("dev scene else")
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