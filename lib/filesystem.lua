filesystem = {}

function filesystem.init()
  filesystem.paths = {}
  filesystem:set_save_path(config.settings.save_path)
end


function filesystem:load()
  local filename = self.paths.save_path .. self:get_load_file()
  local file = assert(io.open(filename, "r"))
  local col = {}
  for line in file:lines() do
    col[#col + 1] = line:gsub("%s+", "")
  end
  file:close()
  tracker:load_track(1, col)
end

function filesystem:set_load_file(s)
  self.load_file = s
end

function filesystem:get_load_file()
  return self.load_file
end

function filesystem:set_save_path(s)
  self.paths.save_path = s
end

function filesystem:get_save_path()
  return self.paths.save_path
end

return filesystem
