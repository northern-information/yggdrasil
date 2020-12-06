local filesystem = {}

function filesystem.init()
  filesystem.paths = {
    save_path = config.settings.save_path,
    sample_path = config.settings.sample_path,
    factory_path = config.settings.factory_path,
    factory_bank = config.settings.sample_path .. "factory/",
    runs_path = config.settings.runs_path,
    routines_path = config.settings.routines_path,
    tracks_path = config.settings.tracks_path
  }
  for k, path in pairs(filesystem.paths) do
    if util.file_exists(path) == false then
      util.make_dir(path)
    end
  end
  filesystem:copy_factory_bank()
end

function filesystem:save(file_path, data)
  if file_path == nil or track == nil then return end
  self:file_new(file_path)  
  for k, line in pairs(data) do
    self:file_append(file_path, line)
  end
end

function filesystem:scandir(directory)
  local i, t, popen = 0, {}, io.popen
  local pfile = popen('ls -a "' .. directory .. '"')
  for filename in pfile:lines() do
    if filename ~= "." and filename ~= ".." then
      i = i + 1
      t[i] = filename
    end
  end
  pfile:close()
  return t
end

function filesystem:copy_factory_bank()
  for k, sample in pairs(self:scandir(config.settings.factory_path)) do
    util.os_capture("cp" .. " " .. self.paths.factory_path .. sample .. " " .. self.paths.factory_bank)
  end
end

function filesystem:file_new(file_path)
  local file = io.open(file_path, "w")
  io.output(file)
  io.close(file)
end

function filesystem:file_append(file_path, line)
  local file = io.open(file_path, "a")
  io.output(file)
  io.write(line)
  io.write("\n")
  io.close(file)
end

function filesystem:file_or_directory_exists(path)
   local ok, err, code = os.rename(path, path)
   if not ok then
      if code == 13 then
         -- permission denied, but it exists
         return true
      end
   end
   return ok, err
end

function filesystem:file_read(file_path)
  if not self:file_or_directory_exists(file_path) then return {} end
  lines = {}
  for line in io.lines(file_path) do 
    lines[#lines + 1] = line
  end
  return lines
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

function filesystem:set_tracks_path(s)
  self.paths.tracks_path = s
end

function filesystem:get_tracks_path()
  return self.paths.tracks_path
end

function filesystem:set_sample_path(s)
  self.paths.sample_path = s
end

function filesystem:get_sample_path()
  return self.paths.sample_path
end

function filesystem:get_runs_path()
  return self.paths.runs_path
end

function filesystem:get_routines_path()
  return self.paths.routines_path
end

return filesystem
