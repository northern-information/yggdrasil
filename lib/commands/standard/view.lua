-- VIEW
-- view;midi
-- v;tracker
-- v;ygg
commands:register{
  invocations = { "view", "v" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
      and fn.table_contains({ 
      "midi", "ipn", "ygg", "freq", 
      "velocity", "vel", "v",
      "m1","m2",
      "index",
      "phenomenon", "p",
      "tracker", "t",
      "hud", "h",
      "mixer", "m",
      "clades", "c",
      "bank", "b",
      "ypc", "y",
      "bpm"
      }, branch[1].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "VIEW",
      view = branch[1].leaves[3]
    }
  end,
  action = function(payload)
    local v = payload.view
    if v == "tracker" 
      or v == "t" then
        page:select(1)
        tracker:set_track_view("midi")
    elseif v == "velocity" 
      or v == "vel"
      or v == "v" then
        view:toggle_velocity()
    elseif v == "m1" then
        view:toggle_m1()
    elseif v == "m2" then
        view:toggle_m2()
    elseif v == "hud" 
      or v == "h" then
        view:toggle_hud()
    elseif v == "phenomenon"
      or v == "phen"
      or v == "p" then
        view:toggle_phenomenon()
    elseif v == "mixer" 
      or v == "m" then
        page:select(2)
    elseif v == "clades" 
      or v == "c" then
        page:select(3)
    elseif v == "bank" 
      or v == "b" then
      ypc:show_bank()
    elseif v == "ypc" 
        or v == "y" then 
      view:toggle_ypc()
    elseif v == "bpm" then 
      tracker:set_message(fn.get_display_bpm())
    else
      tracker:set_track_view(v)
    end
    tracker:refresh()
  end
}