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

function commands:register(t)
  local class = self:extract_class(t)
  --[[
  loop through all registered classes
  then all their invocations
  then all the incomping invocations
  and alert if there are duplicates
  ]]
  for k, command in pairs(self.all) do
    for kk, existing_invocation in pairs(command.invocations) do
      for kkk, new_invocation in pairs(t.invocations) do
        if existing_invocation == new_invocation then
          print_matron_message("Error: Invocation " .. new_invocation .. " on " .. class .. " is already registered to " .. k .. "! Overwriting...")
        end
      end
    end
  end
  -- if class == "APPEND" then
    self.all[class] = t
  -- end
end

--[[
to keep with DRY principals this allows
us to only type the class name once in a definition
it also serves as a mini-validation and
check against some of the structures of the
command composition. it is simply extracting
the classname from the payload.
]]
function commands:extract_class(t)
  local dummy_branches = {}
  local dummy_branch = Branch:new("stub;1;2;3;4")
  for i = 1, 4 do  dummy_branches[i] = dummy_branch end
  local result = t.payload(dummy_branches)
  return result.class
end

--[[
this is the only place you need to configure / add / modify commands! :)
 - "invocations" defines the valid aliases
 - "signature" defines what string from the buffer fits with this command
 - "payload" defines how to format the string for execution
 - "action" combines the payload with the final executable method/function
note, new "prefixes" are a special matching case and still need to be added in .init()
]]
function commands:register_all()

-- ANCHOR
-- 1 5 #1
self:register{
  invocations = { "#" },
  signature = function(branch, invocations)
    return #branch == 3
      and fn.is_int(branch[1].leaves[1]) 
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
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
}



-- APPEND
-- 1 append 3
self:register{
  invocations = { "append", "ap" },
  signature = function(branch, invocations)
    return #branch == 3
      and fn.is_int(branch[1].leaves[1]) 
      and Validator:new(branch[2], invocations):ok()
      and fn.is_int(branch[3].leaves[1])
  end,
  payload = function(branch)
    return {
      class = "APPEND",
      value = branch[3].leaves[1],
      x = branch[1].leaves[1]
    }
  end,
  action = function(payload)
    for i = 1, payload.value do
      local position = i - 1
      tracker:append_track_after(payload.x + position)
    end
  end
}



-- ARPEGGIO
-- 1 arp 60
-- 2 arp;3 60;61
-- 1 3 arp 60
-- 1 3 arp 60;63;65
-- 1 3 arp;2 60;63;65
self:register{
  invocations = { "arpeggio", "arp", "a" },
  signature = function(branch, invocations)
    return (
        #branch == 3
        and fn.is_int(branch[1].leaves[1]) 
        and Validator:new(branch[2], invocations):ok()
        and fn.is_int(branch[3].leaves[1])
      ) or (
        #branch == 4
        and fn.is_int(branch[1].leaves[1]) 
        and fn.is_int(branch[2].leaves[1])
        and Validator:new(branch[3], invocations):ok()
        and fn.is_int(branch[4].leaves[1])
      )
  end,
  payload = function(branch)
    local value = 0
    local midi_notes = {}
    local y = 1
    if #branch == 3 then
      value = branch[2].leaves[3] ~= nil and branch[2].leaves[3] or 0
      midi_notes = fn.table_remove_semicolons(branch[3].leaves)
    elseif #branch == 4 then
      y = branch[2].leaves[1]
      value = branch[3].leaves[3] ~= nil and branch[3].leaves[3] or 0
      midi_notes = fn.table_remove_semicolons(branch[4].leaves)
    end
    return {
      class = "ARPEGGIO",
      value = value,
      midi_notes = midi_notes,
      x = branch[1].leaves[1],
      y = y,
    }
  end,
  action = function(payload)
     tracker:update_every_other(payload)
  end
}



-- BPM
-- bpm 127.3
self:register{
  invocations = { "bpm" },
  signature = function(branch, invocations)
    return #branch == 2
      and Validator:new(branch[1], invocations):ok()
      and fn.is_number(branch[2].leaves[1])
  end,
  payload = function(branch)
    return {
      class = "BPM",
      bpm = branch[2].leaves[1]
    }
  end,
  action = function(payload)
    params:set("clock_tempo", payload.bpm)
  end
}

-- CHORD
-- 1 1 chord 60;63;67
self:register{
  invocations = { "chord", "c" },
  signature = function(branch, invocations)
    return #branch == 4
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
      and #branch[4].leaves >= 2
  end,
  payload = function(branch)
    return {
      class = "CHORD",
      midi_notes = fn.table_remove_semicolons(branch[4].leaves),
      x = branch[1].leaves[1],
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
    tracker:chord(payload)
  end
}

-- DEPTH
-- 1 depth;16
self:register{
  invocations = { "depth", "d" },
  signature = function(branch, invocations)
    return #branch == 2
      and fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
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
}



-- END
-- 1 5 x
self:register{
  invocations = { "end", "x" },
  signature = function(branch, invocations)
    return #branch == 3
       and fn.is_int(branch[1].leaves[1]) 
       and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
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
}



-- FOCUS
-- 1 2
self:register{
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
      class = "FOCUS",
      x = branch[1].leaves[1], 
      y = y
    }
  end,
  action = function(payload)
    if payload.y ~= nil then
      tracker:select_slot(payload.x, payload.y)
    else
      tracker:select_track(payload.x)
    end
  end
}



-- FOLLOW
self:register{
  invocations = { "follow" },
  signature = function(branch, invocations)
    return #branch == 1
      and Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "FOLLOW"
    }
  end,
  action = function(payload)
    tracker:toggle_follow()
  end
}



-- LUCKY
-- 3 4 !
self:register{
  invocations = { "lucky", "!" },
  signature = function(branch, invocations)
    return #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
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
}



-- SET_MIDI_NOTE
-- 1 1 72
self:register{
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
}



-- SET_MIDI_NOTE_AND_VELOCITY
-- 1 1 72 vel;100
self:register{ -- todo make midi note optional?
  invocations = { "velocity", "vel" },
  signature = function(branch, invocations)
    return #branch == 4
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_int(branch[3].leaves[1])
      and Validator:new(branch[4], invocations):ok()
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
}



-- OBLIQUE
self:register{
  invocations = { "oblique" },
  signature = function(branch, invocations)
    return #branch == 1
      and Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "OBLIQUE"
    }
  end,
  action = function(payload)
    fn.draw_oblique()
  end
}



-- play
self:register{
  invocations = { "play" },
  signature = function(branch, invocations)
    return #branch == 1
      and Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "PLAY"
    }
  end,
  action = function(payload)
    tracker:set_playback(true)
  end
}



-- RANDOM
-- 3 4 ?
self:register{
  invocations = { "random", "?" },
  signature = function(branch, invocations)
    return #branch == 3
       and fn.is_int(branch[1].leaves[1])
       and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
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
}



-- REMOVE
-- 1 rm
-- 1 2 rm
self:register{
  invocations = { "remove", "rm" },
  signature = function(branch, invocations)
    return (
      #branch == 2
      and fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
    ) or (
      #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
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
}



-- RERUN
self:register{
  invocations = { "rerun" },
  signature = function(branch, invocations)
    return #branch == 1
      and Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "RERUN"
    }
  end,
  action = function(payload)
    fn.rerun()
  end
}



-- SCREENSHOT
self:register{
  invocations = { "screenshot" },
  signature = function(branch, invocations)
    return #branch == 1
      and Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "SCREENSHOT"
    }
  end,
  action = function(payload)
    fn.screenshot()
  end
}



-- SHIFT
-- 1 shift;5
self:register{
  invocations = { "shift", "s" },
  signature = function(branch, invocations)
    return #branch == 2
       and fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
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
}



-- STOP
self:register{
  invocations = { "stop" },
  signature = function(branch, invocations)
    return #branch == 1
      and Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "STOP"
    }
  end,
  action = function(payload)
    tracker:set_playback(false)
  end
}



-- TRANSPOSE_SLOT
-- 1 1 t;1
self:register{
  invocations = { "transpose", "trans", "t" },
  signature = function(branch, invocations)
    return #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
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
}



-- VIEW
self:register{
  invocations = { "view", "v" },
  signature = function(branch, invocations)
    return #branch == 2
      and Validator:new(branch[1], invocations):ok()
      and fn.table_contains({ "midi", "ipn", "ygg", "freq", "index" }, branch[2].leaves[1])
  end,
  payload = function(branch)
    return {
      class = "VIEW",
      view = branch[2].leaves[1]
    }
  end,
  action = function(payload)
    tracker:set_slot_view(payload.view)
  end
}



end -- register all




return commands