selector = {}

function selector.init()
  selector.open = false
  selector.items = {}
  selector.selected_item = nil
  selector.tab_index = 0
end

-- t must be a numeric index
function selector:activate(t, selected_item)
  self:set_open(true)
  self:set_items(t)
  self:set_selected_item(selected_item)
  self:set_tab_index(self:get_selected_item_index())
end

function selector:get_selected_item_index()
  for k, v in pairs(self:get_items()) do
    if self:get_selected_item() == v then
      return k
    end
  end
  return 1
end

function selector:move(i)
  self:set_tab_index(fn.cycle(self:get_tab_index() + i, 1, #self:get_items()))
  -- again this is hard coupled for now...
  local field = editor:get_fields()["ypc"].input_field
  field:clear()
  field:load_string(self:get_item(self:get_tab_index()))
end

function selector:is_unsaved_changes()
  return self:get_selected_item() ~= self:get_item(self:get_tab_index())
end

function selector:close()
  self:set_open(false)
  self:set_items({})
  self:set_tab_index(0)
  self:set_selected_item(nil)
end

function selector:is_open()
  return self.open
end

function selector:set_open(bool)
  self.open = bool
end

function selector:get_items()
  return self.items
end

function selector:get_item(i)
  return self.items[i]
end

function selector:set_items(t)
  self.items = t
end

function selector:set_tab_index(i)
  self.tab_index = i
end

function selector:get_tab_index()
  return self.tab_index
end

function selector:set_selected_item(i)
  self.selected_item = i
end

function selector:get_selected_item()
  return self.selected_item
end

return selector