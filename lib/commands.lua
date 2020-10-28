commands = {}

--[[

# command definitions

 - signature defines what string from the buffer fits with this command
 - payload defines how to format the string for execution
 - action combines the payload with the final executable method

]]

commands["BPM"] = {
  signature = function(branch)
    return #branch == 2
       and branch[1].leaves[1] == "bpm"
       and fn.is_number(branch[2].leaves[1])
  end,
  payload = function(branch)
    return {
      bpm = tonumber(branch[2].leaves[1])
    }
  end,
  action = function(payload)
    params:set("clock_tempo", payload.bpm)
  end
}



commands["FOCUS_SLOT"] = {
  signature = function(branch)
    return #branch == 2 
       and fn.is_int(branch[1].leaves[1]) 
       and fn.is_int(branch[2].leaves[1])
  end,
  payload = function(branch)
    return {
      x = tonumber(branch[1].leaves[1]), 
      y = tonumber(branch[2].leaves[1])
    }
  end,
  action = function(payload)
    tracker:focus_slot(payload.x, payload.y)
  end
}



commands["FOCUS_TRACK"] = {
  signature = function(branch)
    return #branch == 1
       and fn.is_int(branch[1].leaves[1])
  end,
  payload = function(branch)
    return {
      x = tonumber(branch[1].leaves[1])
    }
  end,
  action = function(payload)
    tracker:focus_track(payload.x)
  end
}



commands["FOLLOW"] = {
  signature = function(branch)
    return #branch == 1
       and branch[1].leaves[1] == "follow"
  end,
  payload = function(branch)
    return {}
  end,
  action = function(payload)
    tracker:toggle_follow()
  end
}



commands["OBLIQUE"] = {
  signature = function(branch)
    return #branch == 1
       and branch[1].leaves[1] == "oblique"
  end,
  payload = function(branch)
    return {}
  end,
  action = function(payload)
    fn.draw_oblique()
  end
}



commands["PLAY"] = {
  signature = function(branch)
    return #branch == 1
       and branch[1].leaves[1] == "play"
  end,
  payload = function(branch)
    return {}
  end,
  action = function(payload)
    tracker:set_playback(true)
  end
}



commands["RERUN"] = {
  signature = function(branch)
    return #branch == 1
       and branch[1].leaves[1] == "rerun"
  end,
  payload = function(branch)
    return {}
  end,
  action = function(payload)
    fn.rerun()
  end
}



commands["SCREENSHOT"] = {
  signature = function(branch)
    return #branch == 1
       and branch[1].leaves[1] == "screenshot"
  end,
  payload = function(branch)
    return {}
  end,
  action = function(payload)
    fn.screenshot()
  end
}



commands["STOP"] = {
  signature = function(branch)
    return #branch == 1
       and branch[1].leaves[1] == "stop"
  end,
  payload = function(branch)
    return {}
  end,
  action = function(payload)
    tracker:set_playback(false)
  end
}


-- view {midi,ipn,ygg,freq,index}
commands["VIEW"] = {
  signature = function(branch)
    return #branch == 2
       and branch[1].leaves[1] == "view"
  end,
  payload = function(branch)
    return {
      view = branch[2].leaves[1]
    }
  end,
  action = function(payload)
    tracker:set_slot_view(payload.view)
  end
}

  -- "DEPTH"                       tracker:set_track_depth(self.payload.x, self.payload.depth)
  -- "END"                         tracker:update_slot(self.payload)
  -- "ANCHOR"                      tracker:update_slot(self.payload)
  -- "LUCK"                        tracker:update_slot(self.payload)
  -- "RANDOM"                      tracker:update_slot(self.payload)
  -- "SET_MIDI_NOTE"               tracker:update_slot(self.payload)
  -- "SET_MIDI_NOTE_AND_VELOCITY"  tracker:update_slot(self.payload)
  -- "SHIFT"                       tracker:update_track(self.payload)




--   -- 1 1 #8
--   self:register_class({
--     name = "ANCHOR",
--     format_payload = function(c)
--       return {
--         class = "ANCHOR",
--         phenomenon = true,
--         prefix = "#",
--         value = tonumber(fn.split_symbol(c[3], "#").payload[2]),
--         x = tonumber(c[1]), 
--         y = tonumber(c[2]),
--       }
--     end,
--     signature = function(c)
--       return #c == 3 and fn.is_int(tonumber(c[1])) and fn.is_int(tonumber(c[2])) and fn.is_anchor_command(c[3])
--     end
--   })
  






--   self:register_class({
--     name = "DEPTH",
--     format_payload = function(c)
--       return {
--         class = "DEPTH",
--         x = tonumber(c[1]),
--         depth = fn.extract("depth", c[2]),
--         phenomenon = false
--       }
--     end,
--     signature = function(c)
--       return #c == 2 and fn.is_int(tonumber(c[1])) and fn.is_depth_command(c[2])
--     end
--   })



--   self:register_class({
--     name = "END",
--     format_payload = function(c)
--       return {
--         class = "END",
--         phenomenon = true,
--         prefix = "x",
--         value = nil,
--         x = tonumber(c[1]), 
--         y = tonumber(c[2]),
--       }
--     end,
--     signature = function(c)
--       return #c == 3 and fn.is_int(tonumber(c[1])) and fn.is_int(tonumber(c[2])) and c[3] == "x"
--     end
--   })





--   self:register_class({
--     name = "LUCK",
--     format_payload = function(c)
--       return {
--         class = "LUCK",
--         phenomenon = true,
--         prefix = "!",
--         value = nil,
--         x = tonumber(c[1]), 
--         y = tonumber(c[2]),
--       }
--     end,
--     signature = function(c)
--       return #c == 3 and fn.is_int(tonumber(c[1])) and fn.is_int(tonumber(c[2])) and c[3] == "!"
--     end
--   })



--   self:register_class({
--     name = "RANDOM",
--     format_payload = function(c)
--       return {
--         class = "RANDOM",
--         phenomenon = true,
--         prefix = "?",
--         value = nil,
--         x = tonumber(c[1]), 
--         y = tonumber(c[2]),
--       }
--     end,
--     signature = function(c)
--       return #c == 3 and fn.is_int(tonumber(c[1])) and fn.is_int(tonumber(c[2])) and c[3] == "?"
--     end
--   })



--   self:register_class({
--     name = "SET_MIDI_NOTE",
--     format_payload = function(c)
--       return {
--         class = "SET_MIDI_NOTE",
--         midi_note = tonumber(c[3]),
--         phenomenon = false,
--         x = tonumber(c[1]), 
--         y = tonumber(c[2]),
--       }
--     end,
--     signature = function(c)
--       return #c == 3 and fn.is_int(tonumber(c[1])) and fn.is_int(tonumber(c[2])) and fn.is_int(tonumber(c[3]))
--     end
--   })


--   -- 1 1 72 vel;100
--   self:register_class({
--     name = "SET_MIDI_NOTE_AND_VELOCITY",
--     format_payload = function(c)
--       return {
--         class = "SET_MIDI_NOTE_AND_VELOCITY",
--         x = tonumber(c[1]), 
--         y = tonumber(c[2]),
--         midi_note = tonumber(c[3]),
--         velocity = fn.extract("velocity", c[4]),
--         phenomenon = false
--       }
--     end,
--     signature = function(c)
--       return #c == 4 and fn.is_int(tonumber(c[1])) and fn.is_int(tonumber(c[2])) 
--             and fn.is_int(tonumber(c[3])) and fn.is_velocity_command(c[4])
--     end
--   })




--   -- 1 shift;5
--   self:register_class({
--     name = "SHIFT",
--     format_payload = function(c)
--       return {
--         class = "SHIFT",
--         x = tonumber(c[1]), 
--         shift = fn.extract("shift", c[2]),
--         phenomenon = false
--       }
--     end,
--     signature = function(c)
--       return #c == 2 and fn.is_int(tonumber(c[1])) and fn.is_shift_command(c[2]) 
--     end
--   })





return commands