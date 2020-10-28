config.settings.dev_mode = true
config.settings.dev_scene = 1
config.settings.load_file = "shift.txt"

if config.settings.dev_mode then
  table.insert(config.page_titles, "DEV")
end