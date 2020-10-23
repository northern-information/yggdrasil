filesystem = {}

function filesystem.init()
  filesystem.paths = {}
  filesystem.paths["save_path"] = config.settings.save_path
  filesystem.test_file = "what-is-love.txt"
end

function filesystem:load()
  local filename = self.paths.save_path .. self.test_file
  local file = assert(io.open(filename, "r"))
  local col = {}
  for line in file:lines() do
    col[#col + 1] = line:gsub("%s+", "")
  end
  file:close()
  tracker:load_column(1, col)
end

return filesystem