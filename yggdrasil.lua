-- k1: exit   e1: select
--
--
--      e2: pan x     e3: pan y
--
--   k2: play      k3: ???

include("lib/includes")

function init()
  y = {}
  parameters.init()
  filesystem.init()
  fn.init()
  _midi.init()
  _crow.init()
  ypc.init()
  music.init()
  terminal.init()
  runner.init()
  commands.init()
  variables.init()
  view.init()
  graphics.init()
  keys.init()
  page.init()
  synth.init()
  editor.init()
  tracker.init()
  clipboard.init()
  selector.init()
  tracker:refresh()
  runner:start()
  y.screen_dirty = true
  y.splash_break = false
  y.init_done = true
  y.redraw_clock_id = clock.run(graphics.redraw_clock)
  y.frame_clock_id = clock.run(graphics.frame_clock)
  y.tracker_clock_id = clock.run(tracker.tracker_clock)
  page:select(parameters.is_splash_screen_on and 0 or 1)
  runner:startup_routine()
  if config.settings.dev_mode then dev:scene(config.settings.dev_scene) end
  redraw()
end

function enc(e, d)
  if e == 1 then
    tracker:cycle_select(d)
  elseif e == 2 then
    if synth:is_encoder_override() then
      synth:scroll_m1(d)
    else
      if not view:is_transposed() then
        view:pan_x(d)
      else
        view:pan_y(d)
      end
    end
  elseif e == 3 then
    if synth:is_encoder_override() then
      synth:scroll_m2(d)
    else
      if not view:is_transposed() then
        view:pan_y(d)
      else
        view:pan_x(d)
      end
    end
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
    fn.dismiss_messages()
  elseif k == 3 then
    commands:fire_k3()
  end
  fn.dirty_screen(true)
end

function redraw()
  if not fn.dirty_screen() then return end
  page:render()
  fn.dirty_screen(false)
end

function cleanup()
  _midi:all_off()
  clock.cancel(y.redraw_clock_id)
  clock.cancel(y.frame_clock_id)
  clock.cancel(y.tracker_clock_id)
end
