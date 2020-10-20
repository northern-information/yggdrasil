fn = {}

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

function fn.table_contains(t, check)
  for k, v in pairs(t) do
    if v == check then
      return true
    end
  end
  return false
end

function rerun()
  norns.script.load(norns.state.script)
end

return fn