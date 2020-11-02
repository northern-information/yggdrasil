clades = {}

function clades.init()

end

function clades:render()
  view:refresh()
  graphics:draw_clades()
  graphics:draw_terminal()
  graphics:draw_command_processing()
  graphics:draw_y_mode()
end

return clades