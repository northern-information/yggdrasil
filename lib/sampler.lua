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
  sampler.steal_voices = true -- if steal voices, then pull the oldest voice, even if its playing  
  -- initialize softcut voices
  for i=1,6 do
    softcut.enable(i,1)
    softcut.level(i,1)
    softcut.pan(i,0)
    softcut.rate(i,1)
    softcut.loop(i,0)
    softcut.rec(i,0)
    softcut.buffer(i,1)
    softcut.position(i,0)
    softcut.level_slew_time(i,0.01)
    softcut.rate_slew_time(i,0.01)
    softcut.post_filter_dry(i,0.0)
    softcut.post_filter_lp(i,1.0)
    softcut.post_filter_rq(i,0.3)
    softcut.post_filter_fc(i,44100)
  end
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
  -- if voice stealing, return the oldest voice
  local oldest_voice = 1
  local oldest = 0
  for voice = 1, 6 do
    if self.steal_voices and self.voices[i].get_time_since_played() > oldest then 
      oldest = self.voices[i].get_time_since_played()
      oldest_voice = voice 
    end
    if (not self.voices[i].is_playing) and (not self.steal_voices) then
      self.voices[i].is_playing = true
      return voice
    end
  end
  if self.steal_voices then 
    return oldest_voice
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
