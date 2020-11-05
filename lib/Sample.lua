--
-- Sample class
-- contains information for sample
-- and directly plays/stops/loads sample
--

Sample = {
  voice = 0,
  rate_compensation = 1,
  frequency = 440,
  buffer = 1,
  position = {1, 3}, -- start and end
  filename = '',
  last_played = 0, -- keep track of when it was last played TODO return this
}

function Sample:new(o)
  -- class for sample https://www.lua.org/pil/16.1.html
  o = o or {} -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end

function Sample:get_filename()
  return self.filename
end

function Sample:get_length()
  return self.position[2] - self.position[1]
end

function Sample:play(voice, frequency, velocity)
  -- plays sample in a one-shot loop
  softcut.position(voice, self.position[1])
  softcut.loop_start(voice, self.position[1])
  softcut.loop_end(voice, self.position[2])
  softcut.rate(self.rate_compensation * frequency / self.frequency)
  softcut.level(velocity)
end

function Sample:is_playing()
  return self.voice > 0
end

function Sample:stop()
  -- stops sample (sets level to 0)
  -- probably better ways to do this like
  -- keeping track of position and putting
  -- a loop_end right before it.
  softcut.level(self.voice, 0)
end

function Sample:load(filename, position)
  -- loads sample into position
  -- and returns where in the buffer it ends up
  
  local ch, samples, samplerate = audio.file_info(filename)
  local duration = samples / 48000.0
  self.filename = filename
  self.rate_compensation = samplerate / 48000.0 -- compensate for files that aren't 48Khz
  self.position = {position, position + duration}
  -- TODO: get frequency information from the filename itself
  -- (regex for NUMBERhz)
  -- if REGEX then self.frequency = X
  
  -- read it into softcut
  softcut.buffer_read_mono(filename, 0, position, -1, 1, 1)
  -- return new position in buffer
  return position + duration + 1
end
