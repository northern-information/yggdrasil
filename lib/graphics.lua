graphics = {}

function graphics.init()
  graphics.fps = 30
  graphics.glow = 0
  graphics.glow_up = true
  graphics.frame = 0
end

function graphics.redraw_clock()
  while true do
    if fn.dirty_screen() then
      redraw()
      fn.dirty_screen(false)
    end
    clock.sleep(1 / 30)
  end
end

function graphics:frame_clock()
  while true do
    graphics:handle_frames()
    fn.dirty_screen(true)
    clock.sleep(1 / graphics.fps)
  end
end

function graphics:handle_frames()
  self.frame = self.frame + 1
  if self.frame % 16 == 0 then
    self.glow_up =  not self.glow_up
  end
  self.glow = self.glow_up and self.frame % 16 or math.abs((self.frame % 16) - 16)
end

function graphics:render()
  self:setup()
  self:draw_slots()
  self:draw_terminal()  
  self:teardown()
end

function graphics:draw_slots()
  for i = 1, 8 do
    self:rect(100, (i - 1) * 8, 28, 6, 15)
  end
end

function graphics:draw_terminal()
  self:text(screen.text_extents(globals.buffer), 62, " >", graphics.glow)
  self:text(0, 62, globals.buffer, 15)
end

function graphics:setup()
  screen.clear()
  screen.aa(0)
  self:reset_font()
end

function graphics:reset_font()
  screen.font_face(0)
  screen.font_size(8)
end

function graphics:teardown()
  screen.update()
end

function graphics:mlrs(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line_rel(x2, y2)
  screen.stroke()
end

function graphics:mls(x1, y1, x2, y2, l)
  screen.level(l or 15)
  screen.move(x1, y1)
  screen.line(x2, y2)
  screen.stroke()
end

function graphics:rect(x, y, w, h, l)
  screen.level(l or 15)
  screen.rect(x, y, w, h)
  screen.fill()
end

function graphics:circle(x, y, r, l)
  screen.level(l or 15)
  screen.circle(x, y, r)
  screen.fill()
end

function graphics:text(x, y, s, l)
  if s == nil then return end
  screen.level(l or 15)
  screen.move(x, y)
  screen.text(s)
end

return graphics