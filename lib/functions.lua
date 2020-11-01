fn = {}



-- global yggdrasil functions



function fn.init()
  fn.id_prefix = "ygg-"
  fn.id_counter = 1000
end

function fn.id()
  fn.id_counter = fn.id_counter + 1
  return fn.id_prefix .. os.time(os.date("!*t")) .. "-" .. fn.id_counter
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
  tracker:clear_message()
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

function fn.draw_oblique()
  tracker:set_message(docs:draw_oblique())
end

function fn.screenshot()
  local which_screen = string.match(string.match(string.match(norns.state.script,"/home/we/dust/code/(.*)"),"/(.*)"),"(.+).lua")
  _norns.screen_export_png("/home/we/dust/" .. which_screen .. "-" .. os.time() .. ".png")
end

function fn.rerun()
  norns.script.load(norns.state.script)
end

function fn.print_matron_message(message)
  print("") print("") print("")      
  print(message)
  print("") print("") print("")
end


function fn.decrement_increment(i)
  local slots = tracker:get_selected_slots()
  if #slots > 0 then
    for k, slot in pairs(slots) do
      if slot:get_midi_note() ~= nil then
        tracker:update_slot({
          class = "TRANSPOSE_SLOT",
          x = slot:get_x(),
          y = slot:get_y(),
          value = i
        })
      end
    end    
  end
end



--- value checking and manipulation



function fn.cycle(value, min, max)
  if value > max then
    return min
  elseif value < min then
    return max
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

return fn