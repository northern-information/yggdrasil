screen.ping()

local dev = {}

function dev:scene(i)
  local debug_interpreter_cache = config.settings.debug_interpreter
  local debug_music_cache = config.settings.debug_music
  config.settings.debug_interpreter = false
  -- config.settings.debug_music = false
  if i == 1 then
    -- tracker:load_track(1, "love-lead.txt")
    -- tracker:load_track(2, "love-saw.txt")
    fn.dismiss_messages()
    cmd("1 clade;ypc")
    cmd("v;ypc")
    cmd("1 1 60")
    cmd("1 1 ypc;l;bd3.wav")
    cmd("ymode")
    tracker:select_slot(1, 1)
    -- editor:activate(1, 1)
    page:select(1)
  elseif i == 2 then
    for i = 1, 5 do
      t(i):set_clade("YPC")
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
    cmd("ypc;bank;factory")
    for x = 1, 3 do
      cmd(x .. " ypc;load;piano1_uiowa_440hz.wav")
    end
    cmd("4 ypc;load;wineglass_halffull_513hz.wav")
    page:select(1)
  elseif i == 3 then 
    page:select(1)   
    cmd("1 4 @2")
    cmd("2 1 @1")
    cmd("2 ascend")
    cmd("2 disable")
  end
  config.settings.debug_interpreter = debug_interpreter_cache
  config.settings.debug_music = debug_music_cache
end

function rerun()
  fn.rerun()
end

function cmd(s)
  local t = fn.string_split(s, "")
  for k, v in pairs(t) do
    terminal:add(v)
  end
  terminal:execute()
end

function slot(x, y)
  return tracker:get_track(x):get_slot(y)
end

function s(x, y)
  return tracker:get_track(x):get_slot(y)
end


function track(x)
  return tracker:get_track(x)
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

function dv()
  print("view.tracker", view.tracker)
  print("view.velocity", view.velocity)
  print("view.phenomenon", view.phenomenon)
  print("view.m1", view.m1)
  print("view.m2", view.m2)
  print("view.ypc", view.ypc)
  print("view.hud", view.hud)
  print("view.clades", view.clades)
  print("view.mixer", view.mixer)
  print("view.x", view.x)
  print("view.x_offset", view.x_offset)
  print("view.y", view.y)
  print("view.y_offset", view.y_offset)
  print("view.mixer_multiple", view.mixer_multiple)
  print("view.m.tracks", view.m.tracks)
  print("view.m.track_width", view.m.track_width)
  print("view.m.track_height", view.m.track_height)
end

return dev
