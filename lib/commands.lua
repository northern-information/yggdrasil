commands = {}

function commands.init()
  commands.all = {}
  commands.prefixes = { "#" }
  commands:register_all()
end

function commands:get_all()
  return self.all
end

function commands:get_prefixes()
  return self.prefixes
end

function commands:register(class, t)
  for k, command in pairs(self.all) do
    for kk, existing_invocation in pairs(command.invocations) do
      for kkk, new_invocation in pairs(t.invocations) do
        if existing_invocation == new_invocation then
          print_matron_message("Error: Invocation " .. new_invocation .. " on " .. class .. " is already registered to " .. k .. "! Overwriting...")
        end
      end
    end
  end
  self.all[class] = t
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
  invocations = { "#" },
  signature = function(branch, invocations)
    return #branch == 3
      and fn.is_int(branch[1].leaves[1]) 
      and fn.is_int(branch[2].leaves[1])
      and fn.is_invocation_match(branch[3], invocations)
      and fn.is_int(branch[3].leaves[2])
  end,
  payload = function(branch)
    return {
      class = "ANCHOR",
      phenomenon = true,
      prefix = "#",
      value = branch[3].leaves[2],
      x = branch[1].leaves[1], 
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
     tracker:update_slot(payload)
  end
})



-- bpm 127.3
self:register("BPM", {
  invocations = { "bpm" },
  signature = function(branch, invocations)
    return #branch == 2
      and fn.is_invocation_match(branch[1], invocations)
      and fn.is_number(branch[2].leaves[1])
  end,
  payload = function(branch)
    return {
      bpm = branch[2].leaves[1]
    }
  end,
  action = function(payload)
    params:set("clock_tempo", payload.bpm)
  end
})


-- 1 cp 2
self:register("COPY", {
  invocations = { "copy", "cp" },
  signature = function(branch, invocations)
    return #branch == 3
      and fn.is_int(branch[1].leaves[1]) 
      and fn.is_invocation_match(branch[2], invocations)
      and fn.is_int(branch[3].leaves[1])
  end,
  payload = function(branch)
    return {
      target = branch[1].leaves[1],
      destination = branch[3].leaves[1],
    }
  end,
  action = function(payload)
     tracker:copy_track(payload.target, payload.destination)
  end
})



-- 1 depth;16
self:register("DEPTH", {
  invocations = { "depth", "d" },
  signature = function(branch, invocations)
    return #branch == 2
      and fn.is_int(branch[1].leaves[1])
      and fn.is_invocation_match(branch[2], invocations)
      and fn.is_int(branch[2].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "DEPTH",
      depth = branch[2].leaves[3],
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
})



-- 1 5 x
self:register("END", {
  invocations = { "end", "x" },
  signature = function(branch, invocations)
    return #branch == 3
       and fn.is_int(branch[1].leaves[1]) 
       and fn.is_int(branch[2].leaves[1])
      and fn.is_invocation_match(branch[3], invocations)
  end,
  payload = function(branch)
    return {
      class = "END",
      phenomenon = true,
      prefix = "x",
      value = nil,
      x = branch[1].leaves[1], 
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
     tracker:update_slot(payload)
  end
})



-- 1
-- 1 2
self:register("FOCUS", {
  invocations = {},
  signature = function(branch, invocations)
    return (
      #branch == 1
      and fn.is_int(branch[1].leaves[1])
      
    ) or (
     #branch == 2
      and fn.is_int(branch[1].leaves[1]) 
      and fn.is_int(branch[2].leaves[1])
    )
  end,
  payload = function(branch)
    local y = nil
    if branch[2] ~= nil then
      y = fn.is_int(branch[2].leaves[1]) and branch[2].leaves[1] or nil
    end
    return {
      x = branch[1].leaves[1], 
      y = y
    }
  end,
  action = function(payload)
    if payload.y ~= nil then
      tracker:focus_slot(payload.x, payload.y)
    else
      tracker:focus_track(payload.x)
    end
  end
})



-- follow
self:register("FOLLOW", {
  invocations = { "follow" },
  signature = function(branch, invocations)
    return #branch == 1
      and fn.is_invocation_match(branch[1], invocations)
  end,
  payload = function(branch)
    return {}
  end,
  action = function(payload)
    tracker:toggle_follow()
  end
})



-- 3 4 !
self:register("LUCKY", {
  invocations = { "lucky", "!" },
  signature = function(branch, invocations)
    return #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_invocation_match(branch[3], invocations)
  end,
  payload = function(branch)
    return {
        class = "LUCKY",
        phenomenon = true,
        prefix = "!",
        value = nil,
        x = branch[1].leaves[1], 
        y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
})



-- 1 1 72
self:register("SET_MIDI_NOTE", {
  invocations = {},
  signature = function(branch, invocations)
    return #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_int(branch[3].leaves[1])
  end,
  payload = function(branch)
    return {
      class = "SET_MIDI_NOTE",
      midi_note = branch[3].leaves[1],
      x = branch[1].leaves[1],
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
})



-- 1 1 72 vel;100
self:register("SET_MIDI_NOTE_AND_VELOCITY", { -- todo make midi note optional?
  invocations = { "velocity", "vel" },
  signature = function(branch, invocations)
    return #branch == 4
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_int(branch[3].leaves[1])
      and fn.is_invocation_match(branch[4], invocations)
  end,
  payload = function(branch)
    return {
      class = "SET_MIDI_NOTE_AND_VELOCITY",
      midi_note = branch[3].leaves[1],
      velocity = branch[4].leaves[3],
      x = branch[1].leaves[1],
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
})



-- oblique
self:register("OBLIQUE", {
  invocations = { "oblique" },
  signature = function(branch, invocations)
    return #branch == 1
      and fn.is_invocation_match(branch[1], invocations)
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
  invocations = { "play" },
  signature = function(branch, invocations)
    return #branch == 1
      and fn.is_invocation_match(branch[1], invocations)
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
  invocations = { "random", "?" },
  signature = function(branch, invocations)
    return #branch == 3
       and fn.is_int(branch[1].leaves[1])
       and fn.is_int(branch[2].leaves[1])
      and fn.is_invocation_match(branch[3], invocations)
  end,
  payload = function(branch)
    return {
        class = "RANDOM",
        phenomenon = true,
        prefix = "?",
        value = nil,
        x = branch[1].leaves[1], 
        y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
})



-- 1 rm
-- 1 2 rm
self:register("REMOVE", {
  invocations = { "remove", "rm" },
  signature = function(branch, invocations)
    return (
      #branch == 2
      and fn.is_int(branch[1].leaves[1])
      and fn.is_invocation_match(branch[2], invocations)
    ) or (
      #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_invocation_match(branch[3], invocations)
    )
  end,
  payload = function(branch)
    return {
        class = "REMOVE",
        x = branch[1].leaves[1], 
        y = fn.is_int(branch[2].leaves[1]) and branch[2].leaves[1] or nil,
    }
  end,
  action = function(payload)
    tracker:remove(payload.x, payload.y)
  end
})



-- rerun
self:register("RERUN", {
  invocations = { "rerun" },
  signature = function(branch, invocations)
    return #branch == 1
      and fn.is_invocation_match(branch[1], invocations)
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
  invocations = { "screenshot" },
  signature = function(branch, invocations)
    return #branch == 1
      and fn.is_invocation_match(branch[1], invocations)
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
  invocations = { "shift", "s" },
  signature = function(branch, invocations)
    return #branch == 2
       and fn.is_int(branch[1].leaves[1])
      and fn.is_invocation_match(branch[2], invocations)
  end,
  payload = function(branch)
    return {
      class = "SHIFT",
      shift = branch[2].leaves[3],
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
})



-- stop
self:register("STOP", {
  invocations = { "stop" },
  signature = function(branch, invocations)
    return #branch == 1
      and fn.is_invocation_match(branch[1], invocations)
  end,
  payload = function(branch)
    return {}
  end,
  action = function(payload)
    tracker:set_playback(false)
  end
})



-- 1 1 t;1
self:register("TRANSPOSE_SLOT", {
  invocations = { "transpose", "trans", "t" },
  signature = function(branch, invocations)
    return #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_invocation_match(branch[3], invocations)
      and fn.is_int(branch[3].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "TRANSPOSE_SLOT",
      value = branch[3].leaves[3],
      x = branch[1].leaves[1],
      y = branch[2].leaves[1]
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
})



-- view midi
self:register("VIEW", {
  invocations = { "view", "v" },
  signature = function(branch, invocations)
    return #branch == 2
      and fn.is_invocation_match(branch[1], invocations)
      and fn.table_contains({ "midi", "ipn", "ygg", "freq", "index" }, branch[2].leaves[1])
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