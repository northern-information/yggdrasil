-- yggdrasill

include("lib/includes")

function init()
  globals = {}
  globals.buffer = ""
  globals.playing = false
  globals.bpm = 120
  graphics.init()
  keys.init()
  globals.redraw_clock_id = clock.run(graphics.redraw_clock)
  globals.frame_clock_id = clock.run(graphics.frame_clock)
  globals.screen_dirty = true
  redraw()
end

function redraw()
  if not fn.dirty_screen() then return end
  graphics:render()
  fn.dirty_screen(false)
end

function cleanup()
  clock.cancel(globals.redraw_clock_id)
  clock.cancel(globals.frame_clock_id)
end