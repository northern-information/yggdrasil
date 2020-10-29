config.settings.dev_mode = true
config.settings.debug_semiotic = false
config.settings.dev_scene = 1
config.settings.load_file = "shift.txt"

if config.settings.dev_mode then
  table.insert(config.page_titles, "DEV")
end