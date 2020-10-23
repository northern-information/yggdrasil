music = {}

function music.init()
  music.root = config.settings.root
  music.scale = config.settings.scale
  music.octaves = config.settings.octaves
  music.transpose = 0
  music.scale_name = ""
  music.scale_names = {}
  for k, v in pairs(musicutil.SCALES) do
    music.scale_names[k] = musicutil.SCALES[k].name
  end
  music.scale_notes = {}
  music:set_scale(music.scale)
end

function music:transpose_note(note)
  return note + (self.transpose * 12)
end

function music:set_scale(i)
  self.scale = util.clamp(i, 1, #self.scale_names)
  self.scale_name = self.scale_names[self.scale]
  self:build_scale()
end

function music:build_scale()
  self.scale_notes =  musicutil.generate_scale(self.root, self.scale_name, self.octaves)
end

function music:snap_note(note)
  return musicutil.snap_note_to_array(note, self.scale_notes)
end

function music:convert(direction, value)
  local conversion = {
    { m = 0,    y = "c-1" },
    { m = 1,    y = "cs-1" },
    { m = 2,    y = "d-1" },
    { m = 3,    y = "ds-1" },
    { m = 4,    y = "e-1" },
    { m = 5,    y = "f-1" },
    { m = 6,    y = "fs-1" },
    { m = 7,    y = "g-1" },
    { m = 8,    y = "gs-1" },
    { m = 9,    y = "a-1" },
    { m = 10,   y = "as-1" },
    { m = 11,   y = "b-1" },
    { m = 12,   y = "c0" },
    { m = 13,   y = "cs0" },
    { m = 14,   y = "d0" },
    { m = 15,   y = "ds0" },
    { m = 16,   y = "e0" },
    { m = 17,   y = "f0" },
    { m = 18,   y = "fs0" },
    { m = 19,   y = "g0" },
    { m = 20,   y = "gs0" },
    { m = 21,   y = "a0" },
    { m = 22,   y = "as0" },
    { m = 23,   y = "b0" },
    { m = 24,   y = "c1" },
    { m = 25,   y = "cs1" },
    { m = 26,   y = "d1" },
    { m = 27,   y = "ds1" },
    { m = 28,   y = "e1" },
    { m = 29,   y = "f1" },
    { m = 30,   y = "fs1" },
    { m = 31,   y = "g1" },
    { m = 32,   y = "gs1" },
    { m = 33,   y = "a1" },
    { m = 34,   y = "as1" },
    { m = 35,   y = "b1" },
    { m = 36,   y = "c2" },
    { m = 37,   y = "cs2" },
    { m = 38,   y = "d2" },
    { m = 39,   y = "ds2" },
    { m = 40,   y = "e2" },
    { m = 41,   y = "f2" },
    { m = 42,   y = "fs2" },
    { m = 43,   y = "g2" },
    { m = 44,   y = "gs2" },
    { m = 45,   y = "a2" },
    { m = 46,   y = "as2" },
    { m = 47,   y = "b2" },
    { m = 48,   y = "c3" },
    { m = 49,   y = "cs3" },
    { m = 50,   y = "d3" },
    { m = 51,   y = "ds3" },
    { m = 52,   y = "e3" },
    { m = 53,   y = "f3" },
    { m = 54,   y = "fs3" },
    { m = 55,   y = "g3" },
    { m = 56,   y = "gs3" },
    { m = 57,   y = "a3" },
    { m = 58,   y = "as3" },
    { m = 59,   y = "b3" },
    { m = 60,   y = "c4" },
    { m = 61,   y = "cs4" },
    { m = 62,   y = "d4" },
    { m = 63,   y = "ds4" },
    { m = 64,   y = "e4" },
    { m = 65,   y = "f4" },
    { m = 66,   y = "fs4" },
    { m = 67,   y = "g4" },
    { m = 68,   y = "gs4" },
    { m = 69,   y = "a4" },
    { m = 70,   y = "as4" },
    { m = 71,   y = "b4" },
    { m = 72,   y = "c5" },
    { m = 73,   y = "cs5" },
    { m = 74,   y = "d5" },
    { m = 75,   y = "ds5" },
    { m = 76,   y = "e5" },
    { m = 77,   y = "f5" },
    { m = 78,   y = "fs5" },
    { m = 79,   y = "g5" },
    { m = 80,   y = "gs5" },
    { m = 81,   y = "a5" },
    { m = 82,   y = "as5" },
    { m = 83,   y = "b5" },
    { m = 84,   y = "c6" },
    { m = 85,   y = "cs6" },
    { m = 86,   y = "d6" },
    { m = 87,   y = "ds6" },
    { m = 88,   y = "e6" },
    { m = 89,   y = "f6" },
    { m = 90,   y = "fs6" },
    { m = 91,   y = "g6" },
    { m = 92,   y = "gs6" },
    { m = 93,   y = "a6" },
    { m = 94,   y = "as6" },
    { m = 95,   y = "b6" },
    { m = 96,   y = "c7" },
    { m = 97,   y = "cs7" },
    { m = 98,   y = "d7" },
    { m = 99,   y = "ds7" },
    { m = 100, y = "e7" },
    { m = 101, y = "f7" },
    { m = 102, y = "fs7" },
    { m = 103, y = "g7" },
    { m = 104, y = "gs7" },
    { m = 105, y = "a7" },
    { m = 106, y = "as7" },
    { m = 107, y = "b7" },
    { m = 108, y = "c8" },
    { m = 109, y = "cs8" },
    { m = 110, y = "d8" },
    { m = 111, y = "ds8" },
    { m = 112, y = "e8" },
    { m = 113, y = "f8" },
    { m = 114, y = "fs8" },
    { m = 115, y = "g8" },
    { m = 116, y = "gs8" },
    { m = 117, y = "a8" },
    { m = 118, y = "as8" },
    { m = 119, y = "b8" },
    { m = 120, y = "c9" },
    { m = 121, y = "cs9" },
    { m = 122, y = "d9" },
    { m = 123, y = "ds9" },
    { m = 124, y = "e9" },
    { m = 125, y = "f9" },
    { m = 126, y = "fs9" },
    { m = 127, y = "g9" },
  }
  if direction == "ygg_to_midi" then
    for k, v in pairs(conversion) do
      if v.y == value then
        print(v.y, value, v.m)
        return v.m
      end
    end
  end
  if direction == "midi_to_ygg" then
    for k, v in pairs(conversion) do
      if v.m == value then
        return v.y
      end
    end
  end
end

return music