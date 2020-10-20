-- yggdrasil

include("lib/includes")

function init()
  y = {}
  y.buffer = ""
  y.playing = false
  y.bpm = 120
  parameters.init()
  page.init()
  graphics.init()
  keys.init()
  y.redraw_clock_id = clock.run(graphics.redraw_clock)
  y.frame_clock_id = clock.run(graphics.frame_clock)
  page:select(parameters.is_splash_screen_on and 0 or 1)
  y.screen_dirty = true
  y.splash_break = false
  y.init_done = true
  redraw()
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