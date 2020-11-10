commands = {}

function commands.init()
  commands.all = {}
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
  -- if class == "ARPEGGIO" then
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



-- ASCEND
-- 1 ascend
-- ascend
self:register{
  invocations = { "ascend", "asc" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return (
      Validator:new(branch[1], invocations):ok()
    ) or (
      fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
    )
  end,
  payload = function(branch)
    local out = {
      class = "ASCEND"
    }
    if #branch == 2 then
      out["x"] = branch[1].leaves[1]
    end
    return out
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:get_track(payload.x):set_descend(false)
    else
      tracker:ascend()
    end
  end
}



-- ANCHOR
-- 1 5 #1
self:register{
  invocations = { "#" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1]) 
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):validate_prefix_invocation()
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
-- 1 append;3
-- 1 append;3 shadow
-- 1 append;3 sha
self:register{
  invocations = { "append", "ap" },
  signature = function(branch, invocations)
    if #branch ~= 2 and #branch ~= 3 then return false end
    return (
      fn.is_int(branch[1].leaves[1]) 
      and Validator:new(branch[2], invocations):ok()
      and fn.is_int(branch[2].leaves[3])
    ) or (
      fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and fn.is_int(branch[2].leaves[3])
      and fn.table_contains({"shadow", "sha"}, branch[3].leaves[1])
    )
  end,
  payload = function(branch)
    return {
      class = "APPEND",
      shadow = #branch == 3,
      value = branch[2].leaves[3],
      x = branch[1].leaves[1]
    }
  end,
  action = function(payload)
    for i = 1, payload.value do
      local position = i - 1
      tracker:append_track_after(payload.x + position, payload.shadow)
    end
  end
}



-- ARPEGGIO
-- 1 arp 60
-- 2 arp;3 60;61
-- 1 3 arp 60
-- 1 3 arp 60;63;65
-- 1 3 arp;2 60;63;65
-- 1 1 arp;2 bmin
-- 1 arp bmin
self:register{
  invocations = { "arpeggio", "arp", "a" },
  signature = function(branch, invocations)
    if #branch == 3 then
      return fn.is_int(branch[1].leaves[1]) 
        and Validator:new(branch[2], invocations):ok()
        and ( 
          fn.is_int(branch[3].leaves[1])
          or music:chord_to_midi(branch[3].leaves[1])
        )
    elseif #branch == 4 then
      return fn.is_int(branch[1].leaves[1]) 
        and fn.is_int(branch[2].leaves[1])
        and Validator:new(branch[3], invocations):ok()
        and ( 
          fn.is_int(branch[4].leaves[1])
          or music:chord_to_midi(branch[4].leaves[1])
        )
    end
  end,
  payload = function(branch)
    local value = 0
    local midi_notes = {}
    local y = 1
    if #branch == 3 then
      if music:chord_to_midi(branch[3].leaves[1]) then
        valid, midi_notes = music:chord_to_midi(branch[3].leaves[1])
      else
        midi_notes = fn.table_remove_semicolons(branch[3].leaves)
      end
      value = branch[2].leaves[3] ~= nil and branch[2].leaves[3] or 0
    elseif #branch == 4 then
      if music:chord_to_midi(branch[4].leaves[1]) then
        valid, midi_notes = music:chord_to_midi(branch[4].leaves[1])
      else
        midi_notes = fn.table_remove_semicolons(branch[4].leaves)
      end
      y = branch[2].leaves[1]
      value = branch[3].leaves[3] ~= nil and branch[3].leaves[3] or 0
      midi_notes = midi_notes
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
    tracker:select_track(payload.x)
  end
}



-- BPM
-- bpm;127.3
self:register{
  invocations = { "bpm" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
      and fn.is_number(branch[1].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "BPM",
      bpm = branch[1].leaves[3]
    }
  end,
  action = function(payload)
    params:set("clock_tempo", payload.bpm)
  end
}



-- CHORD
-- 1 1 chord;60;63;67
-- 1 1 chord;bmin
self:register{
  invocations = { "chord", "c" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
      and (#branch[3].leaves >= 3 and fn.is_int(branch[3].leaves[3]))
          or (#branch[3].leaves >= 3 and music:chord_to_midi(branch[3].leaves[3]))
  end,
  payload = function(branch)
    local c = branch[3].leaves[3]
    if #branch[3].leaves > 3 then 
      -- include the octave information like `cm;3`
      c = branch[3].leaves[3]..branch[3].leaves[4]..branch[3].leaves[5]
    end
    local is_chord, midi_notes, note_names = music:chord_to_midi(c)
    if not is_chord then
      -- clear the invocation and semicolon
      -- we're doing it this way because we don't know how many
      -- notes are in this chord. could be 3, could be 10.
      table.remove(branch[3].leaves, 1)
      table.remove(branch[3].leaves, 1)
      midi_notes = fn.table_remove_semicolons(branch[3].leaves)
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
    tracker:select_slot(payload.x, payload.y)
  end
}



-- CLADE
-- 1 clade;midi
self:register{
  invocations = { "clade" },
  signature = function(branch, invocations)
    if #branch ~= 2 then return false end
    return fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and fn.table_contains({ "synth", "midi", "ypc", "crow" }, branch[2].leaves[3])
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
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
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
  invocations = { "crow" },
  signature = function(branch, invocations)
    if #branch ~= 2 then return false end
    return Validator:new(branch[2], invocations):ok()
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



-- DESCEND
-- 1 descend
-- descend
self:register{
  invocations = { "descend", "des" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return (
      Validator:new(branch[1], invocations):ok()
    ) or (
      fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
    )
  end,
  payload = function(branch)
    local out = {
      class = "DESCEND"
    }
    if #branch == 2 then
      out["x"] = branch[1].leaves[1]
    end
    return out
  end,
  action = function(payload) tabutil.print(payload)
    if payload.x ~= nil then
      tracker:get_track(payload.x):set_descend(true)
    else
      tracker:descend()
    end
  end
}



-- DEPTH
-- depth;16
-- 1 depth;16
self:register{
  invocations = { "depth", "d" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return
      (
        fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
        and fn.is_int(branch[2].leaves[3])
      ) or (
        Validator:new(branch[1], invocations):ok()
        and fn.is_int(branch[1].leaves[3])
      )
  end,
  payload = function(branch)
    local out = {
      class = "DEPTH"
    }
    if #branch == 1 then
      out.depth = branch[1].leaves[3]
      out.x = "all"
    elseif #branch == 2 then
      out.depth = branch[2].leaves[3]
      out.x = branch[1].leaves[1]
    end
    return out
  end,
  action = function(payload)
    if payload.x == "all" then
      for k, track in pairs(tracker:get_tracks()) do
        print(track:get_x())
        tracker:set_track_depth(track:get_x(), payload.depth)
      end
    else
      tracker:update_track(payload)
    end
  end
}



-- DISABLE
-- disable
-- 1 disable
self:register{
  invocations = { "disable" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return end
    return 
      (
        Validator:new(branch[1], invocations):ok()
      ) or (
        fn.is_int(branch[1].leaves[1])
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
    if #branch ~= 1 and #branch ~= 2 then return end
    return 
      (
        Validator:new(branch[1], invocations):ok()
      ) or (
        fn.is_int(branch[1].leaves[1])
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
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1]) 
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
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
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



-- SELECT
-- 1 2
-- 1;5
self:register{
  invocations = {},
  signature = function(branch, invocations)
    if #branch == 1 then
      return (
        fn.is_int(branch[1].leaves[1])
      ) or (
        fn.is_int(branch[1].leaves[1])
        and branch[1].leaves[2] == ";"
        and fn.is_int(branch[1].leaves[3])
        and fn.is_int(branch[1].leaves[1]) < fn.is_int(branch[1].leaves[3])
      )
    elseif #branch == 2 then
      return fn.is_int(branch[1].leaves[1]) 
      and fn.is_int(branch[2].leaves[1])
    end
  end,
  payload = function(branch)
    local out = {
      class = "SELECT",
      range = false,
      x1 = branch[1].leaves[1]
    }
    if branch[2] ~= nil then
      out["y"] = branch[2].leaves[1]
    end
    if branch[1].leaves[2] == ";" then
      out.range = true
      out["x2"] = branch[1].leaves[3]
    end
    return out
  end,
  action = function(payload)
    if payload.y ~= nil then
      tracker:select_slot(payload.x1, payload.y)
    else
      if payload.x2 ~= nil then
        tracker:select_range_of_tracks(payload.x1, payload.x2)
      else
        tracker:deselect()
        tracker:select_track(payload.x1)
      end
    end
  end
}



-- FOLLOW
self:register{
  invocations = { "follow" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
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
  invocations = { "info", "version" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
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
    if #branch < 3 then return false end
    return Validator:new(branch[1], invocations):ok()
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
    if #branch ~= 2 then return false end
    return fn.is_int(branch[1].leaves[1])
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
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
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
    if #branch ~= 2 then return false end
    return Validator:new(branch[2], invocations):ok()
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
    if #branch ~= 1 and #branch ~= 2 then return false end
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
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
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



-- OFF
-- 3 4 off
self:register{
  invocations = { "off", "o" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
       and fn.is_int(branch[2].leaves[1])
       and Validator:new(branch[3], invocations):ok()
  end,
  payload = function(branch)
    return {
        class = "OFF",
        phenomenon = true,
        prefix = "o",
        value = nil,
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
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
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



-- PANIC
self:register{
  invocations = { "panic" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "PANIC"
    }
  end,
  action = function(payload)
    _midi:all_off()
    synth:panic()
  end
}



-- PLAY
-- 1 play
-- play
self:register{
  invocations = { "play", "start" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return (
      Validator:new(branch[1], invocations):ok()
    ) or (
      fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
    )
  end,
  payload = function(branch)
    return {
      class = "PLAY",
      x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:get_track(payload.x):start()
    else
      tracker:start()
    end
  end
}



-- RANDOM
-- 3 4 ?
self:register{
  invocations = { "random", "?" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
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
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
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
    if #branch ~=2 and #branch ~= 3 then return false end
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
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
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
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
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



-- SYNC
-- sync
-- sync;3
self:register{
  invocations = { "sync" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return (
      Validator:new(branch[1], invocations):ok()
    ) or ( 
      Validator:new(branch[1], invocations):ok()
      and fn.is_int(branch[1].leaves[3])
    )
  end,
  payload = function(branch)
    return {
      class = "SYNC",
      y = branch[1].leaves[3] or nil
    }
  end,
  action = function(payload)
    tracker:sync(payload.y)
  end
}



-- NOTE
-- 1 1 72
-- 1 1 c5
self:register{
  invocations = {},
  signature = function(branch, invocations)
    if #branch ~= 3 then return faslse end
    return (
      fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and fn.is_int(branch[3].leaves[1])
    ) or (
      fn.is_int(branch[1].leaves[1])
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
      class = "NOTE",
      midi_note = midi_note,
      x = branch[1].leaves[1],
      y = branch[2].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_slot(payload)
    tracker:select_slot(payload.x, payload.y)
  end
}



-- load
-- 2 load what-is-love.txt
self:register{
  invocations = { "load" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
       and Validator:new(branch[2], invocations):ok()
       and #branch[3].leaves == 1
  end,
  payload = function(branch)
    return {
      class = "LOAD",
      filename = branch[3].leaves[1],
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
    tracker:load_track(payload.x, payload.filename)
  end
}



-- VELOCITY
-- 1 1 velocity;100
-- 1 1 vel;100
-- 1 vel;100
self:register{
  invocations = { "velocity", "vel" },
  signature = function(branch, invocations)
    if #branch == 2 then
      return fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
    elseif #branch == 3 then
      return fn.is_int(branch[1].leaves[1])
        and fn.is_int(branch[2].leaves[1])
        and Validator:new(branch[3], invocations):ok()
    end
  end,
  payload = function(branch)
    local out = {
      class = "VELOCITY",
      x = branch[1].leaves[1],
    }
    if #branch == 3 then
      out["velocity"] = branch[3].leaves[3]
      out["y"] = branch[2].leaves[1]
    elseif #branch == 2 then
      out["velocity"] = branch[2].leaves[3]
    end
    return out
  end,
  action = function(payload)
    if payload.y ~= nil then
      tracker:update_slot(payload)
    else
      for i = 1, tracker:get_track(payload.x):get_depth() do
        payload["y"] = i
        tracker:update_slot(payload)
      end
    end
  end
}



-- RUIN PHENOMENON
-- 1 5 r
self:register{
  invocations = { "ruin" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1]) 
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):validate_prefix_invocation()
  end,
  payload = function(branch)
    local out = {
      class = "RUIN",
      phenomenon = true,
      prefix = "ruin",
      x = branch[1].leaves[1], 
      y = branch[2].leaves[1]
    }
    return out
  end,
  action = function(payload)
     tracker:update_slot(payload)
  end
}



-- SHADOW
-- 1 shadow;2
-- 1 sha;5
self:register{
  invocations = { "shadow", "sha" },
  signature = function(branch, invocations)
    if #branch ~= 2 then return false end
    return fn.is_int(branch[1].leaves[1]) 
      and Validator:new(branch[2], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "SHADOW",
      shadow = branch[2].leaves[3],
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
     tracker:update_track(payload)
  end
}



-- SHIFT
-- 1 shift;5
self:register{
  invocations = { "shift", "s" },
  signature = function(branch, invocations)
    if #branch ~= 2 then return false end
    return fn.is_int(branch[1].leaves[1])
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



-- SHIFT PHENOMENON
-- 1 5 >1
-- 1 5 <1
self:register{
  invocations = { "<", ">" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1]) 
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):validate_prefix_invocation()
      and fn.is_int(branch[3].leaves[2])
  end,
  payload = function(branch)
    local out = {
      class = "SHIFT_PHENOMENON",
      phenomenon = true,
      value = branch[3].leaves[2],
      x = branch[1].leaves[1], 
      y = branch[2].leaves[1]
    }
    if branch[3].leaves[1] == "<" then
      out["class"] = "SHIFT_PHENOMENON_UP"
      out["prefix"] = "<"
    elseif branch[3].leaves[1] == ">" then
      out["class"] = "SHIFT_PHENOMENON_DOWN"
      out["prefix"] = ">"
    end
    return out
  end,
  action = function(payload)
     tracker:update_slot(payload)
  end
}



-- SOLO
-- solo
-- 1 solo
self:register{
  invocations = { "solo" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return 
      (
        Validator:new(branch[1], invocations):ok()
      ) or (
        fn.is_int(branch[1].leaves[1])
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
-- 1 stop
-- stop
self:register{
  invocations = { "stop" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return (
      Validator:new(branch[1], invocations):ok()
    ) or (
      fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
    )
  end,
  payload = function(branch)
    return {
      class = "STOP",
      x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:get_track(payload.x):stop()
    else
      tracker:stop()
    end
  end
}



-- CLOCK
-- 1 clock;5
self:register{
  invocations = { "clock" },
  signature = function(branch, invocations)
    if #branch ~= 2 then return false end
    return fn.is_int(branch[1].leaves[1])
       and Validator:new(branch[2], invocations):ok()
       and fn.is_number(branch[2].leaves[3])
  end,
  payload = function(branch)
    return {
      class = "CLOCK",
      clock = branch[2].leaves[3],
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
    tracker:update_track(payload)
  end
}



-- SAVE
-- 1 save what-is-love.txt
self:register{
  invocations = { "save" },
  signature = function(branch, invocations)
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
       and Validator:new(branch[2], invocations):ok()
       and #branch[3].leaves == 1
  end,
  payload = function(branch)
    return {
      class = "SAVE",
      filename = branch[3].leaves[1],
      x = branch[1].leaves[1],
    }
  end,
  action = function(payload)
    tracker:save_track(payload.x, payload.filename)
  end
}


-- SYNTH
-- 1 synth;voice;2
-- 1 synth;v;2
-- 1 synth;c1;99
-- 1 2 synth;c2;8
-- synth;enc
self:register{
  invocations = { "synth" },
  signature = function(branch, invocations)
    if #branch == 1 then
      return Validator:new(branch[1], invocations):ok()
        and branch[1].leaves[3] == "enc"
    elseif #branch == 2 then
    return (
      Validator:new(branch[2], invocations):ok()
      and fn.table_contains( {"voice", "v" }, branch[2].leaves[3])
      and fn.is_int(branch[2].leaves[5])
    ) or (
      fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and fn.table_contains( {"c1", "c2" }, branch[2].leaves[3])
      and fn.is_number(branch[2].leaves[5])
    )
    elseif #branch == 3 then
      return fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
      and fn.table_contains( {"c1", "c2" }, branch[3].leaves[3])
      and fn.is_number(branch[3].leaves[5])
    end
  end,
  payload = function(branch)
    local out = {
        class = "SYNTH",
        x = branch[1].leaves[1],
    }
    if #branch == 1 then
      synth:toggle_encoder_override()
    elseif #branch == 2 and fn.table_contains( {"voice", "v" }, branch[2].leaves[3]) then
      out["voice"] = branch[2].leaves[5]
    elseif #branch == 2 and fn.table_contains( {"c1", "c2" }, branch[2].leaves[3]) then
      out[branch[2].leaves[3]] = branch[2].leaves[5]
    elseif #branch == 3 then
      out["y"] = branch[2].leaves[1]
      out[branch[3].leaves[3]] = branch[3].leaves[5]
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
    if #branch ~= 3 then return false end
    return fn.is_int(branch[1].leaves[1])
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
    if #branch ~= 1 and #branch ~= 2 then return false end
    return 
      (
        Validator:new(branch[1], invocations):ok()
      ) or (
        fn.is_int(branch[1].leaves[1])
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



-- UNSHADOW
-- 1 unshadow
-- 1 unsha
-- unshadow
-- unsha
self:register{
  invocations = { "unshadow", "unsha" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return 
      (
        Validator:new(branch[1], invocations):ok()
      ) or (
        fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
      )
  end,
  payload = function(branch)
    return {
        class = "UNSHADOW",
        x = #branch == 2 and branch[1].leaves[1] or nil
    }
  end,
  action = function(payload)
    if payload.x ~= nil then
      tracker:unshadow(payload.x)
    else
      tracker:unshadow_all()
    end
  end
}



-- UNSOLO
-- unsolo
-- 1 unsolo
self:register{
  invocations = { "unsolo" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return 
      (
        Validator:new(branch[1], invocations):ok()
      ) or (
        fn.is_int(branch[1].leaves[1])
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
-- view;midi
-- v;tracker
-- v;ygg
self:register{
  invocations = { "view", "v" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
      and fn.table_contains({ 
      "midi", "ipn", "ygg", "freq", 
      "velocity", "vel", "v",
      "macros",
      "index",
      "phenomenon", "p",
      "tracker", "t",
      "hud", "h",
      "mixer", "m",
      "clades", "c",
      "bank", "b",
      "ypc",
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
    elseif v == "macros" then
        view:toggle_macros()
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
    elseif v == "ypc" then 
      view:toggle_ypc()
    elseif v == "bpm" then 
      tracker:set_message(fn.get_display_bpm())
    else
      tracker:set_track_view(v)
    end
    tracker:refresh()
  end
}


-- YPC
-- 1 1 ypc;load;piano_440.wav
-- 1 1 ypc;l;piano_440.wav
-- 1 ypc;llaod;piano_440.wav
-- 1 ypc;l;piano_440.wav
-- ypc;bank;909
-- ypc;b;909
self:register{
  invocations = { "ypc" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 and #branch ~= 3 then return false end
    return (
      #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
      and branch[3].leaves[1] == "ypc"
      and branch[3].leaves[5] ~= nil
    ) or (
      #branch == 2
      and fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and branch[2].leaves[1] == "ypc"
      and branch[2].leaves[5] ~= nil
    ) or (
      #branch == 1
      and Validator:new(branch[1], invocations):ok()
    )
  end,
  payload = function(branch)
    local out = {
        class = "YPC"
    }
    if #branch == 1 then
      if branch[1].leaves[3] == "bank" or branch[1].leaves[3] == "b" then
        out["action"] = "bank"
        out["directory"] = branch[1].leaves[5]
      end
    elseif #branch == 2 then
      if branch[2].leaves[3] == "load" or branch[2].leaves[3] == "l" then
        out["action"] = "load"
        out["filename"] = branch[2].leaves[5]
        out["x"] = branch[1].leaves[1]
      end
    elseif #branch == 3 then
      if branch[3].leaves[3] == "load" or branch[3].leaves[3] == "l" then
        out["action"] = "load"
        out["filename"] = branch[3].leaves[5]
        out["x"] = branch[1].leaves[1]
        out["y"] = branch[2].leaves[1]
      end
    end
    return out
  end,
  action = function(payload)
    if payload.action == "bank" then
      tracker:clear_all_samples()
      ypc:load_bank(payload.directory)
    elseif payload.action == "load" then
      tracker:deselect()
      tracker:select_track(payload.x)
      tracker:update_track(payload)
    end
  end
}



end -- register all




return commands