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
  music.database = {
    { m = -12,        i = "C-2",      f = 4.0879,       y = "c-2" },
    { m = -11,        i = "C#-2",     f = 4.331,        y = "cs-2"},
    { m = -10,        i = "D-2",      f = 4.5885,       y = "d-2" },
    { m = -9,         i = "D#-2",     f = 4.8614,       y = "ds-2"},
    { m = -8,         i = "E-2",      f = 5.1504,       y = "e-2" },
    { m = -7,         i = "F-2",      f = 5.4567,       y = "f-2" },
    { m = -6,         i = "F#-2",     f = 5.7812,       y = "fs-2"},
    { m = -5,         i = "G-2",      f = 6.1249,       y = "g-2" },
    { m = -4,         i = "G#-2",     f = 6.4891,       y = "gs-2"},
    { m = -3,         i = "A-2",      f = 6.875,        y = "a-2" },
    { m = -2,         i = "A#-2",     f = 7.2838,       y = "as-2"},
    { m = -1,         i = "B-2",      f = 7.7169,       y = "b-2" },
    { m = 0,          i = "C-1",      f = 8.1758,       y = "c-1" },
    { m = 1,          i = "C#-1",     f = 8.662,        y = "cs-1"},
    { m = 2,          i = "D-1",      f = 9.177,        y = "d-1" },
    { m = 3,          i = "D#-1",     f = 9.7227,       y = "ds-1"},
    { m = 4,          i = "E-1",      f = 10.3009,      y = "e-1" },
    { m = 5,          i = "F-1",      f = 10.9134,      y = "f-1" },
    { m = 6,          i = "F#-1",     f = 11.5623,      y = "fs-1"},
    { m = 7,          i = "G-1",      f = 12.2499,      y = "g-1" },
    { m = 8,          i = "G#-1",     f = 12.9783,      y = "gs-1"},
    { m = 9,          i = "A-1",      f = 13.75,        y = "a-1" },
    { m = 10,         i = "A#-1",     f = 14.5676,      y = "as-1"},
    { m = 11,         i = "B-1",      f = 15.4339,      y = "b-1" },
    { m = 12,         i = "C0",       f = 16.351,       y = "c0"  },
    { m = 13,         i = "C#0",      f = 17.324,       y = "cs0" },
    { m = 14,         i = "D0",       f = 18.354,       y = "d0"  },
    { m = 15,         i = "D#0",      f = 19.445,       y = "ds0" },
    { m = 16,         i = "E0",       f = 20.601,       y = "e0"  },
    { m = 17,         i = "F0",       f = 21.827,       y = "f0"  },
    { m = 18,         i = "F#0",      f = 23.124,       y = "fs0" },
    { m = 19,         i = "G0",       f = 24.499,       y = "g0"  },
    { m = 20,         i = "G#0",      f = 25.956,       y = "gs0" },
    { m = 21,         i = "A0",       f = 27.5,         y = "a0"  },
    { m = 22,         i = "A#0",      f = 29.135,       y = "as0" },
    { m = 23,         i = "B0",       f = 30.868,       y = "b0"  },
    { m = 24,         i = "C1",       f = 32.703,       y = "c1"  },
    { m = 25,         i = "C#1",      f = 34.648,       y = "cs1" },
    { m = 26,         i = "D1",       f = 36.708,       y = "d1"  },
    { m = 27,         i = "D#1",      f = 38.891,       y = "ds1" },
    { m = 28,         i = "E1",       f = 41.203,       y = "e1"  },
    { m = 29,         i = "F1",       f = 43.654,       y = "f1"  },
    { m = 30,         i = "F#1",      f = 46.249,       y = "fs1" },
    { m = 31,         i = "G1",       f = 48.999,       y = "g1"  },
    { m = 32,         i = "G#1",      f = 51.913,       y = "gs1" },
    { m = 33,         i = "A1",       f = 55,           y = "a1", },
    { m = 34,         i = "A#1",      f = 58.27,        y = "as1" },
    { m = 35,         i = "B1",       f = 61.735,       y = "b1"  },
    { m = 36,         i = "C2",       f = 65.406,       y = "c2"  },
    { m = 37,         i = "C#2",      f = 69.296,       y = "cs2" },
    { m = 38,         i = "D2",       f = 73.416,       y = "d2"  },
    { m = 39,         i = "D#2",      f = 77.782,       y = "ds2" },
    { m = 40,         i = "E2",       f = 82.407,       y = "e2"  },
    { m = 41,         i = "F2",       f = 87.307,       y = "f2"  },
    { m = 42,         i = "F#2",      f = 92.499,       y = "fs2" },
    { m = 43,         i = "G2",       f = 97.999,       y = "g2"  },
    { m = 44,         i = "G#2",      f = 103.826,      y = "gs2" },
    { m = 45,         i = "A2",       f = 110,          y = "a2"  },
    { m = 46,         i = "A#2",      f = 116.541,      y = "as2" },
    { m = 47,         i = "B2",       f = 123.471,      y = "b2"  },
    { m = 48,         i = "C3",       f = 130.813,      y = "c3"  },
    { m = 49,         i = "C#3",      f = 138.591,      y = "cs3" },
    { m = 50,         i = "D3",       f = 146.832,      y = "d3"  },
    { m = 51,         i = "D#3",      f = 155.563,      y = "ds3" },
    { m = 52,         i = "E3",       f = 164.814,      y = "e3"  },
    { m = 53,         i = "F3",       f = 174.614,      y = "f3"  },
    { m = 54,         i = "F#3",      f = 184.997,      y = "fs3" },
    { m = 55,         i = "G3",       f = 195.998,      y = "g3"  },
    { m = 56,         i = "G#3",      f = 207.652,      y = "gs3" },
    { m = 57,         i = "A3",       f = 220,          y = "a3"  },
    { m = 58,         i = "A#3",      f = 233.082,      y = "as3" },
    { m = 59,         i = "B3",       f = 246.942,      y = "b3"  },
    { m = 60,         i = "C4",       f = 261.626,      y = "c4"  },
    { m = 61,         i = "C#4",      f = 277.183,      y = "cs4" },
    { m = 62,         i = "D4",       f = 293.665,      y = "d4"  },
    { m = 63,         i = "D#4",      f = 311.127,      y = "ds4" },
    { m = 64,         i = "E4",       f = 329.628,      y = "e4"  },
    { m = 65,         i = "F4",       f = 349.228,      y = "f4"  },
    { m = 66,         i = "F#4",      f = 369.994,      y = "fs4" },
    { m = 67,         i = "G4",       f = 391.995,      y = "g4"  },
    { m = 68,         i = "G#4",      f = 415.305,      y = "gs4" },
    { m = 69,         i = "A4",       f = 440,          y = "a4"  },
    { m = 70,         i = "A#4",      f = 466.164,      y = "as4" },
    { m = 71,         i = "B4",       f = 493.883,      y = "b4"  },
    { m = 72,         i = "C5",       f = 523.251,      y = "c5"  },
    { m = 73,         i = "C#5",      f = 554.365,      y = "cs5" },
    { m = 74,         i = "D5",       f = 587.33,       y = "d5"  },
    { m = 75,         i = "D#5",      f = 622.254,      y = "ds5" },
    { m = 76,         i = "E5",       f = 659.255,      y = "e5"  },
    { m = 77,         i = "F5",       f = 698.456,      y = "f5"  },
    { m = 78,         i = "F#5",      f = 739.989,      y = "fs5" },
    { m = 79,         i = "G5",       f = 783.991,      y = "g5"  },
    { m = 80,         i = "G#5",      f = 830.609,      y = "gs5" },
    { m = 81,         i = "A5",       f = 880,          y = "a5"  },
    { m = 82,         i = "A#5",      f = 932.328,      y = "as5" },
    { m = 83,         i = "B5",       f = 987.767,      y = "b5"  },
    { m = 84,         i = "C6",       f = 1046.502,     y = "c6"  },
    { m = 85,         i = "C#6",      f = 1108.731,     y = "cs6" },
    { m = 86,         i = "D6",       f = 1174.659,     y = "d6"  },
    { m = 87,         i = "D#6",      f = 1244.508,     y = "ds6" },
    { m = 88,         i = "E6",       f = 1318.51,      y = "e6"  },
    { m = 89,         i = "F6",       f = 1396.913,     y = "f6"  },
    { m = 90,         i = "F#6",      f = 1479.978,     y = "fs6" },
    { m = 91,         i = "G6",       f = 1567.982,     y = "g6"  },
    { m = 92,         i = "G#6",      f = 1661.219,     y = "gs6" },
    { m = 93,         i = "A6",       f = 1760,         y = "a6"  },
    { m = 94,         i = "A#6",      f = 1864.655,     y = "as6" },
    { m = 95,         i = "B6",       f = 1975.533,     y = "b6"  },
    { m = 96,         i = "C7",       f = 2093.005,     y = "c7"  },
    { m = 97,         i = "C#7",      f = 2217.461,     y = "cs7" },
    { m = 98,         i = "D7",       f = 2349.318,     y = "d7"  },
    { m = 99,         i = "D#7",      f = 2489.016,     y = "ds7" },
    { m = 100,        i = "E7",       f = 2637.021,     y = "e7"  },
    { m = 101,        i = "F7",       f = 2793.826,     y = "f7"  },
    { m = 102,        i = "F#7",      f = 2959.955,     y = "fs7" },
    { m = 103,        i = "G7",       f = 3135.964,     y = "g7"  },
    { m = 104,        i = "G#7",      f = 3322.438,     y = "gs7" },
    { m = 105,        i = "A7",       f = 3520,         y = "a7"  },
    { m = 106,        i = "A#7",      f = 3729.31,      y = "as7" },
    { m = 107,        i = "B7",       f = 3951.066,     y = "b7"  },
    { m = 108,        i = "C8",       f = 4186.009,     y = "c8"  },
    { m = 109,        i = "C#8",      f = 4434.922,     y = "cs8" },
    { m = 110,        i = "D8",       f = 4698.636,     y = "d8"  },
    { m = 111,        i = "D#8",      f = 4978.032,     y = "ds8" },
    { m = 112,        i = "E8",       f = 5274.042,     y = "e8"  },
    { m = 113,        i = "F8",       f = 5587.652,     y = "f8"  },
    { m = 114,        i = "F#8",      f = 5919.91,      y = "fs8" },
    { m = 115,        i = "G8",       f = 6271.928,     y = "g8"  },
    { m = 116,        i = "G#8",      f = 6644.876,     y = "gs8" },
    { m = 117,        i = "A8",       f = 7040,         y = "a8"  },
    { m = 118,        i = "A#8",      f = 7458.62,      y = "as8" },
    { m = 119,        i = "B8",       f = 7902.132,     y = "b8"  },
    { m = 120,        i = "C9",       f = 8372.018,     y = "c9"  },
    { m = 121,        i = "C#9",      f = 8869.844,     y = "cs9" },
    { m = 122,        i = "D9",       f = 9397.272,     y = "d9"  },
    { m = 123,        i = "D#9",      f = 9956.064,     y = "ds9" },
    { m = 124,        i = "E9",       f = 10548.084,    y = "e9"  },
    { m = 125,        i = "F9",       f = 11175.304,    y = "f9"  },
    { m = 126,        i = "F#9",      f = 11839.82,     y = "fs9" },
    { m = 127,        i = "G9",       f = 12543.856,    y = "g9"  },
    { m = 128,        i = "G#9",      f = 13289.752,    y = "gs9" },
    { m = 129,        i = "A9",       f = 14080,        y = "a9"  },
    { m = 130,        i = "A#9",      f = 14917.24,     y = "as9" },
    { m = 131,        i = "B9",       f = 15804.264,    y = "b9"  }
  }
end

function music:is_valid_ygg(s)
  local match = false
  for k, v in pairs(self:get_database()) do
    if v.y == s then
      match = true
    end 
  end
  return match
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

function music:get_database()
  return self.database
end

function music:convert(direction, value)
  local db = self:get_database()
  if direction == "midi_to_ygg"  then for k, v in pairs(db) do if v.m == value then return v.y end end end
  if direction == "midi_to_ipn"  then for k, v in pairs(db) do if v.m == value then return v.i end end end
  if direction == "midi_to_freq" then for k, v in pairs(db) do if v.m == value then return v.f end end end
  if direction == "ygg_to_midi"  then for k, v in pairs(db) do if v.y == value then return v.m end end end
end


function music:chord_to_midi(c,return_names)
  -- input: chord names with optional transposition/octaves
  --        in format <note><chordtype>[/<note>][;octave]
  --        (octave 4 is default)
  --        return_names is boolean to return names instead of midi
  -- returns: table of note names or midi notes in that chord 
  -- example: 'cmaj7/e;6' will return midi notes {88,91,95,96}
  --                   or will return names {E6,G6,B6,C7}
  --          'gbm'       will return midi notes {66,70,73,77}
  --                   or will return midi names {F#4,A#4,C#5,F5}

  local db = self:get_database()
  db_chords={
    {"1P 3M 5P","major","M","^",""},
    {"1P 3M 5P 7M","major seventh","maj7","Δ","ma7","M7","Maj7","^7"},
    {"1P 3M 5P 7M 9M","major ninth","maj9","Δ9","^9"},
    {"1P 3M 5P 7M 9M 13M","major thirteenth","maj13","Maj13 ^13"},
    {"1P 3M 5P 6M","sixth","6","add6","add13","M6"},
    {"1P 3M 5P 6M 9M","sixth/ninth","6/9","69","M69"},
    {"1P 3M 6m 7M","major seventh flat sixth","M7b6","^7b6"},
    {"1P 3M 5P 7M 11A","major seventh sharp eleventh","maj#4","Δ#4","Δ#11","M7#11","^7#11","maj7#11"},
    -- ==Minor==
    -- '''Normal'''
    {"1P 3m 5P","minor","m","min","-"},
    {"1P 3m 5P 7m","minor seventh","m7","min7","mi7","-7"},
    {"1P 3m 5P 7M","minor/major seventh","m/ma7","m/maj7","mM7","mMaj7","m/M7","-Δ7","mΔ","-^7"},
    {"1P 3m 5P 6M","minor sixth","m6","-6"},
    {"1P 3m 5P 7m 9M","minor ninth","m9","-9"},
    {"1P 3m 5P 7M 9M","minor/major ninth","mM9","mMaj9","-^9"},
    {"1P 3m 5P 7m 9M 11P","minor eleventh","m11","-11"},
    {"1P 3m 5P 7m 9M 13M","minor thirteenth","m13","-13"},
    -- '''Diminished'''
    {"1P 3m 5d","diminished","dim","°","o"},
    {"1P 3m 5d 7d","diminished seventh","dim7","°7","o7"},
    {"1P 3m 5d 7m","half-diminished","m7b5","ø","-7b5","h7","h"},
    -- ==Dominant/Seventh==
    -- '''Normal'''
    {"1P 3M 5P 7m","dominant seventh","7","dom"},
    {"1P 3M 5P 7m 9M","dominant ninth","9"},
    {"1P 3M 5P 7m 9M 13M","dominant thirteenth","13"},
    {"1P 3M 5P 7m 11A","lydian dominant seventh","7#11","7#4"},
    -- '''Altered'''
    {"1P 3M 5P 7m 9m","dominant flat ninth","7b9"},
    {"1P 3M 5P 7m 9A","dominant sharp ninth","7#9"},
    {"1P 3M 7m 9m","altered","alt7"},
    -- '''Suspended'''
    {"1P 4P 5P","suspended fourth","sus4","sus"},
    {"1P 2M 5P","suspended second","sus2"},
    {"1P 4P 5P 7m","suspended fourth seventh","7sus4","7sus"},
    {"1P 5P 7m 9M 11P","eleventh","11"},
    {"1P 4P 5P 7m 9m","suspended fourth flat ninth","b9sus","phryg","7b9sus","7b9sus4"},
    -- ==Other==
    {"1P 5P","fifth","5"},
    {"1P 3M 5A","augmented","aug","+","+5","^#5"},
    {"1P 3m 5A","minor augmented","m#5","-#5","m+"},
    {"1P 3M 5A 7M","augmented seventh","maj7#5","maj7+5","+maj7","^7#5"},
    {"1P 3M 5P 7M 9M 11A","major sharp eleventh (lydian)","maj9#11","Δ9#11","^9#11"},
    -- ==Legacy==
    {"1P 2M 4P 5P","","sus24","sus4add9"},
    {"1P 3M 5A 7M 9M","","maj9#5","Maj9#5"},
    {"1P 3M 5A 7m","","7#5","+7","7+","7aug","aug7"},
    {"1P 3M 5A 7m 9A","","7#5#9","7#9#5","7alt"},
    {"1P 3M 5A 7m 9M","","9#5","9+"},
    {"1P 3M 5A 7m 9M 11A","","9#5#11"},
    {"1P 3M 5A 7m 9m","","7#5b9","7b9#5"},
    {"1P 3M 5A 7m 9m 11A","","7#5b9#11"},
    {"1P 3M 5A 9A","","+add#9"},
    {"1P 3M 5A 9M","","M#5add9","+add9"},
    {"1P 3M 5P 6M 11A","","M6#11","M6b5","6#11","6b5"},
    {"1P 3M 5P 6M 7M 9M","","M7add13"},
    {"1P 3M 5P 6M 9M 11A","","69#11"},
    {"1P 3m 5P 6M 9M","","m69","-69"},
    {"1P 3M 5P 6m 7m","","7b6"},
    {"1P 3M 5P 7M 9A 11A","","maj7#9#11"},
    {"1P 3M 5P 7M 9M 11A 13M","","M13#11","maj13#11","M13+4","M13#4"},
    {"1P 3M 5P 7M 9m","","M7b9"},
    {"1P 3M 5P 7m 11A 13m","","7#11b13","7b5b13"},
    {"1P 3M 5P 7m 13M","","7add6","67","7add13"},
    {"1P 3M 5P 7m 9A 11A","","7#9#11","7b5#9","7#9b5"},
    {"1P 3M 5P 7m 9A 11A 13M","","13#9#11"},
    {"1P 3M 5P 7m 9A 11A 13m","","7#9#11b13"},
    {"1P 3M 5P 7m 9A 13M","","13#9"},
    {"1P 3M 5P 7m 9A 13m","","7#9b13"},
    {"1P 3M 5P 7m 9M 11A","","9#11","9+4","9#4"},
    {"1P 3M 5P 7m 9M 11A 13M","","13#11","13+4","13#4"},
    {"1P 3M 5P 7m 9M 11A 13m","","9#11b13","9b5b13"},
    {"1P 3M 5P 7m 9m 11A","","7b9#11","7b5b9","7b9b5"},
    {"1P 3M 5P 7m 9m 11A 13M","","13b9#11"},
    {"1P 3M 5P 7m 9m 11A 13m","","7b9b13#11","7b9#11b13","7b5b9b13"},
    {"1P 3M 5P 7m 9m 13M","","13b9"},
    {"1P 3M 5P 7m 9m 13m","","7b9b13"},
    {"1P 3M 5P 7m 9m 9A","","7b9#9"},
    {"1P 3M 5P 9M","","Madd9","2","add9","add2"},
    {"1P 3M 5P 9m","","Maddb9"},
    {"1P 3M 5d","","Mb5"},
    {"1P 3M 5d 6M 7m 9M","","13b5"},
    {"1P 3M 5d 7M","","M7b5"},
    {"1P 3M 5d 7M 9M","","M9b5"},
    {"1P 3M 5d 7m","","7b5"},
    {"1P 3M 5d 7m 9M","","9b5"},
    {"1P 3M 7m","","7no5"},
    {"1P 3M 7m 13m","","7b13"},
    {"1P 3M 7m 9M","","9no5"},
    {"1P 3M 7m 9M 13M","","13no5"},
    {"1P 3M 7m 9M 13m","","9b13"},
    {"1P 3m 4P 5P","","madd4"},
    {"1P 3m 5P 6m 7M","","mMaj7b6"},
    {"1P 3m 5P 6m 7M 9M","","mMaj9b6"},
    {"1P 3m 5P 7m 11P","","m7add11","m7add4"},
    {"1P 3m 5P 9M","","madd9"},
    {"1P 3m 5d 6M 7M","","o7M7"},
    {"1P 3m 5d 7M","","oM7"},
    {"1P 3m 6m 7M","","mb6M7"},
    {"1P 3m 6m 7m","","m7#5"},
    {"1P 3m 6m 7m 9M","","m9#5"},
    {"1P 3m 5A 7m 9M 11P","","m11A"},
    {"1P 3m 6m 9m","","mb6b9"},
    {"1P 2M 3m 5d 7m","","m9b5"},
    {"1P 4P 5A 7M","","M7#5sus4"},
    {"1P 4P 5A 7M 9M","","M9#5sus4"},
    {"1P 4P 5A 7m","","7#5sus4"},
    {"1P 4P 5P 7M","","M7sus4"},
    {"1P 4P 5P 7M 9M","","M9sus4"},
    {"1P 4P 5P 7m 9M","","9sus4","9sus"},
    {"1P 4P 5P 7m 9M 13M","","13sus4","13sus"},
    {"1P 4P 5P 7m 9m 13m","","7sus4b9b13","7b9b13sus4"},
    {"1P 4P 7m 10m","","4","quartal"},
    {"1P 5P 7m 9m 11P","","11b9"},
  }
  notes_white={"C","D","E","F","G","A","B"}
  notes_scale_sharp={"C","C#","D","D#","E","F","F#","G","G#","A","A#","B","C","C#","D","D#","E","F","F#","G","G#","A","A#","B","C","C#","D","D#","E","F","F#","G","G#","A","A#","B"}
  notes_scale_acc1={"B#","Db","D","Eb","Fb","E#","Gb","G","Ab","A","Bb","Cb"}
  notes_scale_acc2={"C","Cs","D","Ds","E","F","Fs","G","Gs","A","As","B"}
  notes_scale_acc3={"Bs","Db","D","Eb","Fb","Es","Gb","G","Ab","A","Bb","Cb"}
  notes_adds={"","#","b","s"}
  notes_all={}
  for i,n in ipairs(notes_white) do
    for j,a in ipairs(notes_adds) do
      table.insert(notes_all,(n..a))
    end
  end
  
  chord_match=""
  
  -- get octave
  octave=4
  if string.match(c,";") then
    for i,s in pairs(c:split(";")) do
      if i==1 then
        c=s
      else
        octave=tonumber(s)
      end
    end
  end
  
  -- get transpositions
  transpose_note=''
  if string.match(c,"/") then
    for i,s in pairs(c:split("/")) do
      if i==1 then
        c=s
      else
        transpose_note=s
      end
    end
  end
  
  -- find the root note name
  note_match=""
  transpose_note_match=""
  chord_rest=""
  for i,n in ipairs(notes_all) do
    if transpose_note~="" and #n>#transpose_note_match then
      if n:lower()==transpose_note or n==transpose_note then
        transpose_note_match=n
      end
    end
    if #n>#note_match then
      -- check if has prefix
      s,e=c:find(n)
      if s==1 then
        note_match=n
        chord_rest=string.sub(c,e+1)
      end
      s,e=c:find(n:lower())
      if s==1 then
        note_match=n
        chord_rest=string.sub(c,e+1)
      end
    end
  end
  if note_match=="" then
    return {},false
  end
  
  -- convert to canonical sharp scale
  -- e.g. Fb -> E, Gs -> G#
  for i,n in ipairs(notes_scale_acc1) do
    if note_match==n then
      note_match=notes_scale_sharp[i]
      break
    end
  end
  for i,n in ipairs(notes_scale_acc2) do
    if note_match==n then
      note_match=notes_scale_sharp[i]
      break
    end
  end
  for i,n in ipairs(notes_scale_acc3) do
    if note_match==n then
      note_match=notes_scale_sharp[i]
      break
    end
  end
  if transpose_note_match~="" then
    for i,n in ipairs(notes_scale_acc1) do
      if transpose_note_match==n then
        transpose_note_match=notes_scale_sharp[i]
        break
      end
    end
    for i,n in ipairs(notes_scale_acc2) do
      if transpose_note_match==n then
        transpose_note_match=notes_scale_sharp[i]
        break
      end
    end
    for i,n in ipairs(notes_scale_acc3) do
      if transpose_note_match==n then
        transpose_note_match=notes_scale_sharp[i]
        break
      end
    end
  end
  
  -- find longest matching chord pattern
  chord_match="" -- (no chord match is major chord)
  chord_intervals="1P 3m 5P"
  for _,chord_type in ipairs(db_chords) do
    for i,chord_pattern in ipairs(chord_type) do
      if i>2 then
        if #chord_pattern>#chord_match and (chord_rest==chord_pattern or chord_rest:lower()==chord_pattern:lower()) then
          chord_match=chord_pattern
          chord_intervals=chord_type[1]
        end
      end
    end
  end
  --print("chord_match for "..chord_rest..": "..chord_match)
  
  -- find location of root
  root_position=1
  for i,n in ipairs(notes_scale_sharp) do
    if n==note_match then
      root_position=i
      break
    end
  end
  
  -- find notes from intervals
  whole_note_semitones={0,2,4,5,7,9,11,12}
  notes_in_chord={}
  for interval in string.gmatch(chord_intervals,"%S+") do
    -- get major note position
    major_note_position=(string.match(interval,"%d+")-1)%7+1
    -- find semitones from root
    semitones=whole_note_semitones[major_note_position]
    -- adjust semitones based on interval
    if string.match(interval,"m") then
      semitones=semitones-1
    elseif string.match(interval,"A") then
      semitones=semitones+1
    end
    -- get note in scale from root position
    note_in_chord=notes_scale_sharp[root_position+semitones]
    table.insert(notes_in_chord,note_in_chord)
  end
  
  -- if tranposition, rotate until new root
  if transpose_note_match~="" then
    found_note=false
    for i=1,#notes_in_chord do
      if notes_in_chord[1]==transpose_note_match then
        found_note=true
        break
      end
      table.insert(notes_in_chord,table.remove(notes_in_chord,1))
    end
    if not found_note then
      table.insert(notes_in_chord,1,transpose_note_match)
    end
  end
  
  -- convert to midi
  if octave==nil then
    octave=4
  end
  midi_notes_in_chord={}
  last_note=0
  for i,n in ipairs(notes_in_chord) do
    for _,d in ipairs(db) do
      if d.m>last_note and (d.i==n..octave or d.i==n..(octave+1) or d.i==n..(octave+2) or d.i==n..(octave+3)) then
        last_note=d.m
        table.insert(midi_notes_in_chord,d.m)
        notes_in_chord[i]=d.i
        break
      end
    end
  end

  -- return
  if return_names~=nil and return_names then
    return notes_in_chord,true
  end
  return midi_notes_in_chord,true
end

return music