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

--
-- sampler
-- orchestrates many samples
-- keeping track of which voices are available
-- and keeps track of which samples are loaded
--

sampler = {}

function sampler.init()
  -- keeping track of active voices
  sampler.voices = {}
  for i = 1, 6 do
    sampler.voices[i] = {is_playing = false}
  end
  -- table of samples addressed by sample name
  sampler.samples = {}
  sampler.buffer_position = 1
  
  -- TODO:
  -- initialize softcut voices
end

function sampler:play(sample_name, frequency, velocity)
  -- plays sample in a one-shot loop
  -- then uses a clock to sleep and reset
  -- voice to 0 (not playing)
  local voice = self.aquire_voice()
  if voice then
    self.samples[sample_name]:play(voice, pitch, velocity)
  else
    -- could not acquire voice, exit gracefully
    return
  end
  -- TODO sleep for length of sample and release voice
  -- clock.run(sleep(self.samples[sample_name]:get_length()))
  self.release_voice(voice)
end

function sampler:acquire_voice()
  -- find an available voice and return it
  for voice = 1, 6 do
    if not self.voices[i].is_playing then
      self.voices[i].is_playing = true
      return voice
    end
  end
  return false
end

function sampler:release_voice(voice)
  self.voices[i].is_playing = false
end

function sampler:load_sample(filename)
  if self.samples[sample_name] ~= nil then
    -- already has sample loaded
    return
  end
  -- create a new sample
  self.samples[sample_name] = Sample:new()
  -- load the file into the sample
  new_position = self.samples[sample_name]:load(filename, self.buffer_position)
  -- update the buffer position for the next sample
  if new_position then
    self.buffer_position = new_position
  end
end

function sampler:load_directory(dir)
  -- TODO: for each file in directory, load sample
end

return sampler
