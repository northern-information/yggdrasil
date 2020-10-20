fn = {}

function fn.dirty_screen(bool)
  if bool == nil then return globals.screen_dirty end
  globals.screen_dirty = bool
  return globals.screen_dirty
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