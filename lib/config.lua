local config = {}

config["settings"] = {
  version_major = 1,
  version_minor = 0,
  version_patch = 16,
  ppqn = 96,
  root = 0,
  scale = 41,
  octaves = 11,
  commands_path = "yggdrasil/lib/commands/standard/",
  phenomenon_path = "yggdrasil/lib/commands/phenomenon/",
  factory_path = _path.code .. "yggdrasil/samples/",
  routines_path = _path.data .. "yggdrasil/routines/",
  runs_path = _path.data .. "yggdrasil/runs/",
  sample_path = _path.audio .. "yggdrasil/samples/",
  save_path =  _path.data .. "yggdrasil/",
  tracks_path = _path.data .. "yggdrasil/tracks/",
  default_tracks = 8,
  default_depth = 8,
  default_clade = "SYNTH",
  max_tracks = 50,
  default_hud = false
}

config["page_titles"] = {
  "TRACKER",
  "MIXER",
  "CLADES"
}

return config