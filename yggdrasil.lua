-- yggdrasil

include("lib/includes")

function init()
  y = {}
  y.playing = false
  y.bpm = 120
  parameters.init()
  page.init()
  graphics.init()
  keys.init()
  buffer.init()
  commands.init()
  tracker.init()
  y.redraw_clock_id = clock.run(graphics.redraw_clock)
  y.frame_clock_id = clock.run(graphics.frame_clock)
  y.screen_dirty = true
  y.splash_break = false
  y.init_done = true
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
end