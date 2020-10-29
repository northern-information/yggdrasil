commands = {}

function commands.init()
  commands.all = {}
  commands:register_all()
end

function commands:get_all()
  return self.all
end

function commands:register(class, t)
  table.insert(self.all, t)
end

function commands:register_all()

--[[

# command definitions

this is the only place you need to configure / add / modify commands! :)

 - "signature" defines what string from the buffer fits with this command
 - "payload" defines how to format the string for execution
 - "action" combines the payload with the final executable method/function

]]


-- 1 5 #1
self:register("ANCHOR", {
  signature = function(branch)
    return #branch == 3
       and fn.is_int(branch[1].leaves[1]) 
       and fn.is_int(branch[2].leaves[1])
       and fn.is_anchor_command(branch[3].leaves[1])
  end,
  payload = function(branch)
    return {
      class = "ANCHOR",
      phenomenon = true,
      prefix = "#",
      value = tonumber(string.sub(branch[3].leaves[1], 2)),
      x = tonumber(branch[1].leaves[1]), 
      y = tonumber(branch[2].leaves[1]),
    }
  end,
  action = function(payload)
     tracker:update_slot(payload)
  end
})



-- bpm 127.3
self:register("BPM", {
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
})



-- 1 depth;16
self:register("DEPTH", {
  signature = function(branch)
    return #branch == 2
       and fn.is_int(branch[1].leaves[1])
       and fn.is_depth_command(branch[2].leaves[1])
  end,
  payload = function(branch)
    return {
      class = "DEPTH",
      depth = fn.extract("depth", branch[2].leaves[1]),
      x = tonumber(branch[1].leaves[1]),
    }
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
})



-- 1 5 x
self:register("END", {
  signature = function(branch)
    return #branch == 3
       and fn.is_int(branch[1].leaves[1]) 
       and fn.is_int(branch[2].leaves[1])
       and branch[3].leaves[1] == "x"
  end,
  payload = function(branch)
    return {
      class = "END",
      phenomenon = true,
      prefix = "x",
      value = nil,
      x = tonumber(branch[1].leaves[1]), 
      y = tonumber(branch[2].leaves[1]),
    }
  end,
  action = function(payload)
     tracker:update_slot(payload)
  end
})



-- 1 2
self:register("FOCUS_SLOT", {
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
})



-- 2
self:register("FOCUS_TRACK", {
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
})



-- follow
self:register("FOLLOW", {
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
})



-- 3 4 !
self:register("LUCK", {
  signature = function(branch)
    return #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and branch[3].leaves[1] == "!"
  end,
  payload = function(branch)
    return {
        class = "LUCK",
        phenomenon = true,
        prefix = "!",
        value = nil,
        x = tonumber(branch[1].leaves[1]), 
        y = tonumber(branch[2].leaves[1]),
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
})



-- 1 1 72
self:register("SET_MIDI_NOTE", {
  signature = function(branch)
    return #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_int(branch[3].leaves[1])
  end,
  payload = function(branch)
    return {
      class = "SET_MIDI_NOTE",
      midi_note = tonumber(branch[3].leaves[1]),
      x = tonumber(branch[1].leaves[1]),
      y = tonumber(branch[2].leaves[1]),
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
})



-- 1 1 72 vel;100
self:register("SET_MIDI_NOTE_AND_VELOCITY", {
  signature = function(branch)
    return #branch == 4
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_int(branch[3].leaves[1])
      and fn.is_velocity_command(branch[4].leaves[1])
  end,
  payload = function(branch)
    return {
      class = "SET_MIDI_NOTE_AND_VELOCITY",
      midi_note = tonumber(branch[3].leaves[1]),
      velocity = fn.extract("velocity", branch[4].leaves[1]),
      x = tonumber(branch[1].leaves[1]),
      y = tonumber(branch[2].leaves[1]),
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
})



-- oblique
self:register("OBLIQUE", {
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
})



-- play
self:register("PLAY", {
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
})



-- 3 4 ?
self:register("RANDOM", {
  signature = function(branch)
    return #branch == 3
       and fn.is_int(branch[1].leaves[1])
       and fn.is_int(branch[2].leaves[1])
       and branch[3].leaves[1] == "?"
  end,
  payload = function(branch)
    return {
        class = "RANDOM",
        phenomenon = true,
        prefix = "?",
        value = nil,
        x = tonumber(branch[1].leaves[1]), 
        y = tonumber(branch[2].leaves[1]),
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
})



-- rerun
self:register("RERUN", {
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
})



-- screenshot
self:register("SCREENSHOT", {
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
})



-- 1 shift;5
self:register("SHIFT", {
  signature = function(branch)
    return #branch == 2
       and fn.is_int(branch[1].leaves[1])
       and fn.is_shift_command(branch[2].leaves[1])
  end,
  payload = function(branch)
    return {
      class = "SHIFT",
      shift = fn.extract("shift", branch[2].leaves[1]),
      x = tonumber(branch[1].leaves[1]),
    }
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
})



-- stop
self:register("STOP", {
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
})



-- view {midi,ipn,ygg,freq,index}
self:register("VIEW", {
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
})



end -- register all




return commands