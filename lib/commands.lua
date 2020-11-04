commands = {}

function commands.init()
  commands.all = {}
  commands.prefixes = { "#" }
  commands:register_all()
  commands.k3 = nil
end

function commands:set_k3(s)
  self.k3 = s
end

function commands:fire_k3()
  if self.k3 ~= nil then
    runner:run(self.k3)
  else
    tracker:set_message("Assign K3 with: k3 = ...")
  end
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
  -- if class == "SYNTH" then
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
-- 1 1 chord c4;ds4;g4
self:register{
  invocations = { "chord", "c" },
  signature = function(branch, invocations)
    return #branch == 4
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
      and (#branch[4].leaves >= 2 or music:chord_to_midi(branch[4].leaves[1])) -- weak
  end,
  payload = function(branch)
    local c = ""
    for _, v in pairs(branch[4].leaves) do
      c = c .. v
    end
    local is_chord, midi_notes, note_names = music:chord_to_midi(c)
    if not is_chord then
      midi_notes = fn.table_remove_semicolons(branch[4].leaves)
    end
    return {
      class = "CHORD",
      midi_notes = midi_notes,
      x = branch[1].leaves[1],
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
    tracker:chord(payload)
  end
}



-- CLADE
-- 1 clade;midi
self:register{
  invocations = { "clade" },
  signature = function(branch, invocations)
    return #branch == 2
      and fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and fn.table_contains({ "synth", "midi", "sampler", "crow" }, branch[2].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "CLADE",
      clade = string.upper(branch[2].leaves[3]),
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
}



-- CLEAR
self:register{
  invocations = { "clear" },
  signature = function(branch, invocations)
    return #branch == 1
      and Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "clear"
    }
  end,
  action = function(payload)
    tracker:clear_tracks()
  end
}


-- CROW
-- 1 crow;pair;1
-- 1 crow;p;2
self:register{
  invocations = { "crow"},
  signature = function(branch, invocations)
    return #branch == 2
        and Validator:new(branch[2], invocations):ok()
        and branch[2].leaves[3] == "pair" 
            or branch[2].leaves[3] == "p" 
        and fn.is_int(branch[2].leaves[5])
  end,
  payload = function(branch)
    return {
      class = "CROW",
      x = branch[1].leaves[1],
      pair = branch[2].leaves[5]
    }
  end,
  action = function(payload)
    tracker:update_track(payload)
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



-- DISABLE
-- disable
-- 1 disable
self:register{
  invocations = { "disable" },
  signature = function(branch, invocations)
    return 
      (
        #branch == 1
        and Validator:new(branch[1], invocations):ok()
      ) or (
        #branch == 2
        and fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
      )
  end,
  payload = function(branch)
    return {
        class = "DISABLE",
        x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:disable(payload.x)
    else
      tracker:disable_all()
    end
  end
}



-- ENABLE
-- enable
-- 1 enable
self:register{
  invocations = { "enable" },
  signature = function(branch, invocations)
    return 
      (
        #branch == 1
        and Validator:new(branch[1], invocations):ok()
      ) or (
        #branch == 2
        and fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
      )
  end,
  payload = function(branch)
    return {
        class = "ENABLE",
        x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:enable(payload.x)
    else
      tracker:enable_all()
    end
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




-- EXIT
self:register{
  invocations = { "exit", "ragequit" },
  signature = function(branch, invocations)
    return #branch == 1
      and Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "exit"
    }
  end,
  action = function(payload)
    _menu.set_mode(true)
    fn.print_matron_message("FAREWELL YGGDRASIL PILOT!")
    norns.script.clear()
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
    if page:is("MIXER") or page:is("CLADES") then
      page:select(1)
    end
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



-- INFO
self:register{
  invocations = { "info" },
  signature = function(branch, invocations)
    return #branch == 1
      and Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "INFO"
    }
  end,
  action = function(payload)
    tracker:toggle_info()
  end
}



-- K3
-- k3 = some amazing thing
self:register{
  invocations = { "k3" },
  signature = function(branch, invocations)
    return #branch > 2
        and Validator:new(branch[1], invocations):ok()
        and branch[2].leaves[1] == "="
  end,
  payload = function(branch)
    local command_string = ""
    -- remove the "k3" and the "="
    -- leaving us with just whatever is left afterwards
    table.remove(branch, 1)
    table.remove(branch, 1)
    for k, v in pairs(branch) do
      for kk, vv in pairs(v.leaves) do
        command_string = command_string .. vv
      end
      command_string = command_string .. " "
    end
    return {
      class = "K3",
      command_string = command_string
    }
  end,
  action = function(payload)
    self:set_k3(payload.command_string)
  end
}



-- LEVEL
-- 1 level;58
self:register{
  invocations = { "level", "l" },
  signature = function(branch, invocations)
    return #branch == 2
      and fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and fn.is_int(branch[2].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "LEVEL",
      level = branch[2].leaves[3] * .01,
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_track(payload)
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



-- MIDI
-- 1 midi;d;2
-- 1 midi;c;10
self:register{
  invocations = { "midi" },
  signature = function(branch, invocations)
    return #branch == 2
        and Validator:new(branch[2], invocations):ok()
        and branch[2].leaves[3] == "d" 
            or branch[2].leaves[3] == "device" 
            or branch[2].leaves[3] == "c"
            or branch[2].leaves[3] == "channel"
        and fn.is_int(branch[2].leaves[5])
  end,
  payload = function(branch)
    local out = {
        class = "MIDI",
        x = branch[1].leaves[1]
    }
    if branch[2].leaves[3] == "d" or branch[2].leaves[3] == "device" then
      out["device"] = branch[2].leaves[5]
    elseif branch[2].leaves[3] == "c" or branch[2].leaves[3] == "channel" then
      out["channel"] = branch[2].leaves[5]
    end
    return out
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
}



-- MUTE
-- mute
-- 1 mute
self:register{
  invocations = { "mute" },
  signature = function(branch, invocations)
    return 
      (
        #branch == 1
        and Validator:new(branch[1], invocations):ok()
      ) or (
        #branch == 2
        and fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
      )
  end,
  payload = function(branch)
    return {
        class = "MUTE",
        x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:mute(payload.x)
    else
      tracker:mute_all()
    end
  end
}



-- NEW
self:register{
  invocations = { "new" },
  signature = function(branch, invocations)
    return #branch == 1
      and Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "NEW"
    }
  end,
  action = function(payload)
    fn.new()
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



-- PLAY
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



-- REVERSE
-- 3 4 reverse
self:register{
  invocations = { "reverse", "rev"},
  signature = function(branch, invocations)
    return #branch == 3
       and fn.is_int(branch[1].leaves[1])
       and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
  end,
  payload = function(branch)
    return {
        class = "REVERSE",
        phenomenon = true,
        prefix = "rev",
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



-- SAMPLER
-- 1 sampler;TBD
-- self:register{
--   invocations = { "sampler", "sam" },
--   signature = function(branch, invocations)
--     return #branch == 2
--         and Validator:new(branch[2], invocations):ok()
--         and branch[2].leaves[3] == "tbd" 
--             or branch[2].leaves[3] == "tbd" 
--         and fn.is_int(branch[2].leaves[5])
--   end,
--   payload = function(branch)
--     local out = {
--         class = "SAMPLER",
--         x = branch[1].leaves[1]
--     }
--     if branch[2].leaves[3] == "tbd" or branch[2].leaves[3] == "tbd" then
--       out["TBD"] = branch[2].leaves[5]
--     elseif branch[2].leaves[3] == "tbd" or branch[2].leaves[3] == "tbd" then
--       out["TBD"] = branch[2].leaves[5]
--     end
--     return out
--   end,
--   action = function(payload)
--     tracker:update_track(payload)
--   end
-- }


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



-- SET_MIDI_NOTE
-- 1 1 72
-- 1 1 c5
self:register{
  invocations = {},
  signature = function(branch, invocations)
    return (
      #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_int(branch[3].leaves[1])
    ) or (
      #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and music:is_valid_ygg(branch[3].leaves[1])
    )
  end,
  payload = function(branch)
    local midi_note = 0
    if fn.is_int(branch[3].leaves[1]) then
      midi_note = branch[3].leaves[1]
    else
      midi_note = music:convert("ygg_to_midi", branch[3].leaves[1])
    end
    return {
      class = "SET_MIDI_NOTE",
      midi_note = midi_note,
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
-- 1 1 c4 vel;100
self:register{ -- todo make midi note optional?
  invocations = { "velocity", "vel" },
  signature = function(branch, invocations)
    return (
      #branch == 4
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_int(branch[3].leaves[1])
      and Validator:new(branch[4], invocations):ok()
    ) or (
      #branch == 4
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and music:is_valid_ygg(branch[3].leaves[1])
      and Validator:new(branch[4], invocations):ok()
    )
  end,
  payload = function(branch)
    local midi_note = 0
    if fn.is_int(branch[3].leaves[1]) then
      midi_note = branch[3].leaves[1]
    else
      midi_note = music:convert("ygg_to_midi", branch[3].leaves[1])
    end
    return {
      class = "SET_MIDI_NOTE_AND_VELOCITY",
      midi_note = midi_note,
      velocity = branch[4].leaves[3],
      x = branch[1].leaves[1],
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
  end
}



-- SHADOW
-- 1 shadow x
-- 1 sha x
self:register{
  invocations = { "shadow", "sha" },
  signature = function(branch, invocations)
    return #branch == 3
       and fn.is_int(branch[1].leaves[1]) 
       and fn.is_int(branch[3].leaves[1])
      and Validator:new(branch[2], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "SHADOW",
      value = branch[3].leaves[1],
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
     tracker:update_slot(payload)
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



-- SOLO
-- solo
-- 1 solo
self:register{
  invocations = { "solo" },
  signature = function(branch, invocations)
    return 
      (
        #branch == 1
        and Validator:new(branch[1], invocations):ok()
      ) or (
        #branch == 2
        and fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
      )
  end,
  payload = function(branch)
    return {
        class = "SOLO",
        x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:solo(payload.x)
    else
      tracker:solo_all()
    end
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



-- SYNTH
-- 1 synth;voice;2
-- 1 synth;v;2
-- 1 synth;c1;99
-- 1 synth;c2;8
self:register{
  invocations = { "synth" },
  signature = function(branch, invocations)
    return #branch == 2
        and Validator:new(branch[2], invocations):ok()
        and branch[2].leaves[3] == "voice" 
            or branch[2].leaves[3] == "v" 
            or branch[2].leaves[3] == "c1"
            or branch[2].leaves[3] == "c2"
        and fn.is_int(branch[2].leaves[5])
  end,
  payload = function(branch)
    local out = {
        class = "SYNTH",
        x = branch[1].leaves[1]
    }
    if branch[2].leaves[3] == "v" or branch[2].leaves[3] == "voice" then
      out["voice"] = branch[2].leaves[5]
    elseif branch[2].leaves[3] == "c1" then
      out["c1"] = branch[2].leaves[5]
    elseif branch[2].leaves[3] == "c2" then
      out["c2"] = branch[2].leaves[5]
    end
    return out
  end,
  action = function(payload)
    tracker:update_track(payload)
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



-- UNMUTE
-- unmute
-- 1 unmute
self:register{
  invocations = { "unmute" },
  signature = function(branch, invocations)
    return 
      (
        #branch == 1
        and Validator:new(branch[1], invocations):ok()
      ) or (
        #branch == 2
        and fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
      )
  end,
  payload = function(branch)
    return {
        class = "UNMUTE",
        x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:unmute(payload.x)
    else
      tracker:unmute_all()
    end
  end
}



-- UNSOLO
-- unsolo
-- 1 unsolo
self:register{
  invocations = { "unsolo" },
  signature = function(branch, invocations)
    return 
      (
        #branch == 1
        and Validator:new(branch[1], invocations):ok()
      ) or (
        #branch == 2
        and fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
      )
  end,
  payload = function(branch)
    return {
        class = "UNSOLO",
        x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:unsolo(payload.x)
    else
      tracker:unsolo_all()
    end
  end
}



-- VIEW
self:register{
  invocations = { "view", "v" },
  signature = function(branch, invocations)
    return #branch == 2
      and Validator:new(branch[1], invocations):ok()
      and fn.table_contains({ "midi", "ipn", "ygg", "freq", "vel", "index", "tracker", "hud", "mixer", "clades" }, branch[2].leaves[1])
  end,
  payload = function(branch)
    return {
      class = "VIEW",
      view = branch[2].leaves[1]
    }
  end,
  action = function(payload)
    if payload.view == "tracker" then
      page:select(1)
      tracker:set_track_view("midi")
    elseif payload.view == "hud" then
      page:select(2)
      tracker:set_track_view("midi")
    elseif payload.view == "mixer" then
      page:select(3)
    elseif payload.view == "clades" then
      page:select(4)
    else
      tracker:set_track_view(payload.view)
    end
  end
}


end -- register all




return commands