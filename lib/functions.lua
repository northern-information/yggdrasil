fn = {}



-- global yggdrasil functions



function fn.init()
  fn.id_prefix = "ygg-"
  fn.id_counter = 1000
end

function fn.id(prefix)
  fn.id_counter = fn.id_counter + 1
  return fn.id_prefix .. prefix .. "-".. os.time(os.date("!*t")) .. "-" .. fn.id_counter
end

function fn.get_display_bpm()
  return "BPM: " .. params:get("clock_tempo")
end

function fn.get_semver_string()
  return "v" .. config.settings.version_major .. "." .. config.settings.version_minor .. "." .. config.settings.version_patch
end

function fn.dirty_screen(bool)
  if bool == nil then return y.screen_dirty end
  y.screen_dirty = bool
  return y.screen_dirty
end

function fn.break_splash(bool)
  if bool == nil then return y.splash_break end
  y.splash_break = bool
  return y.splash_break
end

function fn.dismiss_messages()
  if not synth:is_encoder_override() then
    tracker:clear_message()
    tracker:set_info(false)
  end
  fn.break_splash(true)
end

function fn.string_split(input_string, split_character)
  local s = split_character ~= nil and split_character or "%s"
  local t = {}
  if split_character == "" then
    for str in string.gmatch(input_string, ".") do
      table.insert(t, str)
    end
  else
    for str in string.gmatch(input_string, "([^" .. s .. "]+)") do
      table.insert(t, str)
    end
  end
  return t
end

local screenshot_counter = 1
function fn.screenshot()
  local which_screen = string.match(string.match(string.match(norns.state.script,"/home/we/dust/code/(.*)"),"/(.*)"),"(.+).lua")
  _norns.screen_export_png("/home/we/dust/" .. screenshot_counter .. "-" .. which_screen .. "-" .. os.time() .. ".png")
  screenshot_counter = screenshot_counter + 1
end

function fn.rerun()
  norns.script.load(norns.state.script)
end

function fn.print_matron_message(message)
  print("") print("") print("")      
  print(message)
  print("") print("") print("")
end

function fn.new()
  for x = 1, tracker:get_cols() do tracker:remove(1) end
  tracker:set_cols(config.settings.default_tracks)
  tracker:set_rows(config.settings.default_depth)
  for x = 1, tracker:get_cols() do tracker:append_track_after(x - 1) end
end

function fn.run_routine(filename)
  local r = filesystem:get_routines_path() .. filename
  if filesystem:file_or_directory_exists(r) then
    local lines = filesystem:file_read(r)
    for k, line in pairs(lines) do
      fn.cmd(line)
    end
  end
end

function fn.cmd(s)
  local t = fn.string_split(s, "")
  for k, v in pairs(t) do
    terminal:add(v)
  end
  terminal:execute()
end

function fn.toggle_enc_override()
  synth:toggle_encoder_override()
  if synth:is_encoder_override() then
    synth:scroll_m1(0) -- trigger the message box open
  else
    tracker:clear_message()
  end
end



--- value checking and manipulation



function fn.get_largest_extents_from_zero_to(i)
  local extents = 0
  for e = 1, i do
    local this_extents = screen.text_extents(e)
    extents = this_extents > extents and this_extents or extents
  end
  return extents
end

function fn.cycle(value, min, max)
  if value > max then
    return min
  elseif value < min then
    return max
  else
    return value
  end
end

function fn.over_cycle(value, min, max)
  if value > max then
    return fn.over_cycle(value - max, min, max)
  elseif value < min then
    return fn.over_cycle(max - value, min, max)
  else
    return value
  end
end

function fn.is_int(test)
  if test == nil then return false end
  if not tonumber(test) then return false end
  return test == math.floor(test)
end

function fn.is_number(test)
  if test == nil then return false end
  return type(tonumber(test)) == "number"
end

function fn.is_space(test)
  if test == nil then return false end
  return test == " "
end

function fn.is_variable(s)
  local check, count = string.gsub(s, "%$", "")
  if fn.is_int(tonumber(check)) and count > 0 then
    return tonumber(check)
  else
    return false
  end
end



--- table utilities



function fn.shift_table(t, shift_amount)
  if shift_amount == 0 then return t end
  for i = 1, shift_amount do
    local last_value = t[#t]
    table.insert(t, 1, last_value)
    table.remove(t, #t)
  end
  return t
end

function fn.reverse_shift_table(t, shift_amount)
  if shift_amount == 0 then return t end
  for i = 1, shift_amount do
    local first_value = t[1]
    table.remove(t, 1)
    table.insert(t, #t + 1, first_value)
  end
  return t
end

function fn.deep_copy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
        copy[fn.deep_copy(orig_key)] = fn.deep_copy(orig_value)
    end
    setmetatable(copy, fn.deep_copy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function fn.table_contains(t, check)
  for k, v in pairs(t) do
    if v == check then
      return true
    end
  end
  return false
end

function fn.table_contains_key(t, check)
  local keys = {}
  for k, v in pairs(t) do
    table.insert(keys, k)
  end
  return fn.table_contains(keys, check)
end

function fn.pairs_by_keys(t)
  local a = {}
  for n in pairs(t) do
    table.insert(a, n)
  end
  table.sort(a)
  local i = 0
  local iterator = function()
    i = i + 1
    if a[i] == nil then
      return nil
    else 
      return a[i], t[a[i]]
    end
  end
  return iterator
end

function fn.table_remove_semicolons(t)
  for k, v in pairs(t) do
    if string.find(v, ";") then
      table.remove(t, k)
    end
  end
  return t
end

function fn.draw_oblique()
  local strategies = {
    "(Organic) machinery",
    "A line has two sides",
    "A very small object; its center",
    "Abandon desire",
    "Abandon normal instructions",
    "Abandon normal instruments",
    "Accept advice",
    "Accretion",
    "Adding on",
    "Allow an easement (an easement is the abandonment of a stricture)",
    "Always first steps",
    "Always give yourself credit for having more than personality (given by Arto Lindsay)",
    "Always the first steps",
    "Are there sections?  Consider transitions",
    "Ask people to work against their better judgement",
    "Ask your body",
    "Assemble some of the elements in a group and treat the group",
    "Balance the consistency principle with the inconsistency principle",
    "Be dirty",
    "Be extravagant",
    "Be less critical",
    "Breathe more deeply",
    "Bridges -build -burn",
    "Cascades",
    "Change ambiguities to specifics",
    "Change instrument roles",
    "Change nothing and continue consistently",
    "Change nothing and continue with immaculate consistency",
    "Change specifics to ambiguities",
    "Children -speaking -singing",
    "Cluster analysis",
    "Consider different fading systems",
    "Consider transitions",
    "Consult other sources -promising -unpromising",
    "Convert a melodic element into a rhythmic element",
    "Courage!",
    "Cut a vital conenction",
    "Decorate, decorate",
    "Define an area as 'safe' and use it as an anchor",
    "Destroy -nothing -the most important thing",
    "Destroy nothing; Destroy the most important thing",
    "Discard an axiom",
    "Disciplined self-indulgence",
    "Disconnect from desire",
    "Discover the recipes you are using and abandon them",
    "Discover your formulas and abandon them",
    "Display your talent",
    "Distort time",
    "Distorting time",
    "Do nothing for as long as possible",
    "Do something boring",
    "Do something sudden, destructive and unpredictable",
    "Do the last thing first",
    "Do the washing up",
    "Do the words need changing?",
    "Do we need holes?",
    "Don't avoid what is easy",
    "Don't be frightened of cliches",
    "Don't break the silence",
    "Don't stress on thing more than another [sic]",
    "Don't stress one thing more than another",
    "Dont be afraid of things because they're easy to do",
    "Dont be frightened to display your talents",
    "Emphasize differences",
    "Emphasize repetitions",
    "Emphasize the flaws",
    "Faced with a choice, do both (from Dieter Rot)",
    "Feed the recording back out of the medium",
    "Fill every beat with something",
    "Find a safe part and use it as an anchor",
    "Get your neck massaged",
    "Ghost echoes",
    "Give the game away",
    "Give the name away",
    "Give way to your worst impulse",
    "Go outside. Shut the door.",
    "Go slowly all the way round the outside",
    "Go to an extreme, come part way back",
    "Honor thy error as a hidden intention",
    "Honor thy mistake as a hidden intention",
    "How would someone else do it?",
    "How would you have done it?",
    "Humanize something free of error",
    "Idiot glee (?)",
    "Imagine the piece as a set of disconnected events",
    "In total darkness, or in a very large room, very quietly",
    "Infinitesimal gradations",
    "Intentions -nobility of -humility of -credibility of",
    "Into the impossible",
    "Is it finished?",
    "Is something missing?",
    "Is the information correct?",
    "Is the style right?",
    "Is there something missing",
    "It is quite possible (after all)",
    "It is simply a matter or work",
    "Just carry on",
    "Left channel, right channel, center channel",
    "Listen to the quiet voice",
    "Look at the order in which you do things",
    "Look closely at the most embarrassing details & amplify them",
    "Lost in useless territory",
    "Lowest common denominator",
    "Magnify the most difficult details",
    "Make a blank valuable by putting it in an exquisite frame",
    "Make a sudden, destructive unpredictable action; incorporate",
    "Make an exhaustive list of everything you might do & do the last thing on the list",
    "Make it more sensual",
    "Make what's perfect more human",
    "Mechanicalize something idiosyncratic",
    "Move towards the unimportant",
    "Mute and continue",
    "Not building a wall; making a brick",
    "Once the search has begun, something will be found",
    "Only a part, not the whole",
    "Only one element of each kind",
    "Openly resist change",
    "Pae White's non-blank graphic metacard",
    "Put in earplugs",
    "Question the heroic",
    "Reevaluation (a warm feeling)",
    "Remember quiet evenings",
    "Remember those quiet evenings",
    "Remove a restriction",
    "Remove ambiguities and convert to specifics",
    "Remove specifics and convert to ambiguities",
    "Repetition is a form of change",
    "Retrace your steps",
    "Reverse",
    "Short circuit (example; a man eating peas with the idea that they will improve his virility shovels them straight into his lap)",
    "Simple subtraction",
    "Simply a matter of work",
    "Slow preparation, fast execution",
    "Spectrum analysis",
    "State the problem as clearly as possible",
    "Take a break",
    "Take away the elements in order of apparent non-importance",
    "Take away the important parts",
    "Tape your mouth (given by Ritva Saarikko)",
    "The inconsistency principle",
    "The most easily forgotten thing is the most important",
    "The most important thing is the thing most easily forgotten",
    "The tape is now the music",
    "Think - inside the work -outside the work",
    "Think of the radio",
    "Tidy up",
    "Towards the insignificant",
    "Trust in the you of now",
    "Try faking it (from Stewart Brand)",
    "Turn it upside down",
    "Twist the spine",
    "Use 'unqualified' people",
    "Use an old idea",
    "Use an unacceptable color",
    "Use cliches",
    "Use fewer notes",
    "Use filters",
    "Use something nearby as a model",
    "Use your own ideas",
    "Voice your suspicions",
    "Water",
    "What are the sections sections of? Imagine a caterpillar moving",
    "What are you really thinking about just now?",
    "What context would look right?",
    "What is the reality of the situation?",
    "What is the simplest solution?",
    "What mistakes did you make last time?",
    "What to increase? What to reduce? What to maintain?",
    "What were you really thinking about just now?",
    "What would your closest friend do?",
    "What wouldn't you do?",
    "When is it for?",
    "Where is the edge?",
    "Which parts can be grouped?",
    "Work at a different speed",
    "Would anyone want it?",
    "You are an engineer",
    "You can only make one dot at a time",
    "You don't have to be ashamed of using your own ideas",
    "[blank white card]"
  }
  tracker:set_message(strategies[math.random(1, #strategies)])
end

return fn