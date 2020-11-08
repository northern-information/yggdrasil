config = {}

config["settings"] = {
  ["version_major"] = 1,
  ["version_minor"] = 0,
  ["version_patch"] = 0,
  ["root"] = 0,
  ["scale"] = 47,
  ["octaves"] = 11,
  ["save_path"] =  _path.data .. "yggdrasil/",
  ["sample_path"] = _path.audio .. "yggdrasil/samples/",
  ["factory_path"] = _path.code .. "yggdrasil/samples/",
  ["runs_path"] = _path.data .. "yggdrasil/runs/",
  ["tracks_path"] = _path.data .. "yggdrasil/tracks/",
  ["default_tracks"] = 8,
  ["default_depth"] = 8,
  ["default_clade"] = "SYNTH",
  ["max_tracks"] = 50
}

config["page_titles"] = {
  "TRACKER",
  "MIXER",
  "CLADES"
}

return config