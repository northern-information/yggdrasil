-- yggdrasil

include("lib/includes")

function init()
  parameters.init()
  page.init()
  graphics.init()
  keys.init()
  buffer.init()
  commands.init()
  tracker.init()
  y = {
    screen_dirty = true,
    splash_break = false,
    init_done = true,
  }
  y.redraw_clock_id = clock.run(graphics.redraw_clock)
  y.frame_clock_id = clock.run(graphics.frame_clock)
  y.tracker_clock_id = clock.run(tracker.tracker_clock)
  page:select(parameters.is_splash_screen_on and 0 or 1)
  redraw()
end

function enc(e, d)
  if e == 1 then
    print("e1", d)
  elseif e == 2 then
    tracker:scroll_x(d)
  elseif e == 3 then
    tracker:scroll_y(d)
  end
  fn.dismiss_messages()
  fn.dirty_screen(true)
end

function key(k, z)
  if z == 0 then return end
  if k == 1 then
    print("k1")
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