mixer = {}

function mixer.init()

end

function mixer:render()
  graphics:text(64, 32, "MIXER", 15)
  view:refresh()
  -- mute
  -- solo
  -- enable
  -- shadow
  -- clade
    -- midi
      -- device
      -- channel
    -- synth
      -- voice
    -- sampler
      -- bank
    -- crow
      -- pair
  -- direction
  graphics:draw_terminal()
  graphics:draw_command_processing()
  graphics:draw_y_mode()
end

return mixer