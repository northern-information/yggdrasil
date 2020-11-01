-- k1: exit   e1: focus
--
--
--      e2: pan x     e3: pan y
--
--   k2: play      k3: ???

include("lib/includes")

function init()
  y = {}
  buffer.init()
  runner.init()
  commands.init()
  docs.init()
  filesystem.init()
  fn.init()
  view.init()
  graphics.init()
  keys.init()
  music.init()
  page.init()
  parameters.init()
  synth.init()
  tracker.init()
  tracker:refresh()
  y.screen_dirty = true
  y.splash_break = false
  y.init_done = true
  y.redraw_clock_id = clock.run(graphics.redraw_clock)
  y.frame_clock_id = clock.run(graphics.frame_clock)
  y.tracker_clock_id = clock.run(tracker.tracker_clock)
  page:select(parameters.is_splash_screen_on and 0 or 1)
  if config.settings.dev_mode then dev:scene(config.settings.dev_scene) end
  redraw()
end

function enc(e, d)
  if e == 1 then
    tracker:cycle_focus(d)
  elseif e == 2 then
    view:pan_x(d)
  elseif e == 3 then
    view:pan_y(d)
  end
  fn.dismiss_messages()
  fn.dirty_screen(true)
end

function key(k, z)
  if z == 0 then return end
  if k == 1 then
    -- exit
  elseif k == 2 then
    tracker:toggle_playback()
  elseif k == 3 then
    print("k3")
  end
  fn.dismiss_messages()
  fn.dirty_screen(true)
end

function redraw()
  if not fn.dirty_screen() then return end
  page:render()
  fn.dirty_screen(false)
end

function cleanup()
  clock.cancel(y.redraw_clock_id)
  clock.cancel(y.frame_clock_id)
  clock.cancel(y.tracker_clock_id)
end