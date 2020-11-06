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
    sampler.voices[i] = {duration = 0, track=0, last_played=0}
  end
  -- table of samples addressed by sample name
  sampler.samples = {}
  sampler.buffer_position = 1
  sampler.steal_voices = true -- if steal voices, then pull the oldest voice, even if its playing
  -- initialize softcut voices
  for i = 1, 6 do
    softcut.enable(i, 1)
    softcut.level(i, 1)
    softcut.pan(i, 0)
    softcut.rate(i, 1)
    softcut.loop(i, 0)
    softcut.rec(i, 0)
    softcut.buffer(i, 1)
    softcut.position(i, 0)
    softcut.level_slew_time(i, 0.01)
    softcut.rate_slew_time(i, 0.01)
    softcut.post_filter_dry(i, 0.0)
    softcut.post_filter_lp(i, 1.0)
    softcut.post_filter_rq(i, 0.3)
    softcut.post_filter_fc(i, 44100)
  end
end

function sampler:play(track, sample_name, frequency, velocity)
  if frequency == nil then 
    return 
  end
  -- plays sample in a one-shot loop
  -- then uses a clock to sleep and reset
  -- voice to 0 (not playing)
  print("request for "..sample_name.." on track "..track)
  local voice = self:acquire_voice(track)
  if voice then
    local duration = self.samples[sample_name]:play(voice, frequency, velocity)
    if duration ~= nil then 
      self.voices[voice].track = track 
      self.voices[voice].last_played = os.clock()
      self.voices[voice].duration=duration 
    end
    print("acquired voice "..voice.." for track "..track.." for "..self.voices[voice].duration.."s")
  else
    -- could not acquire voice, exit gracefully
    return
  end
end


function sampler:acquire_voice(track)
  -- first, see if there are any voices that 
  -- are on that track and cut those short 
  -- ?? open to thoughts on this
  for i=1,6 do
    if self.voices[i].track==track then 
      return i 
    end
  end 

  -- next, try to find the first available voice
  -- OR the oldest voice (if stealing voices)
  local oldest_voice = 1
  local oldest = 0
  for i = 1, 6 do
    if (os.clock()-self.voices[i].last_played) > self.voices[i].duration then
      return i 
    end
    -- try to get oldest if stealing voices
    if self.steal_voices and (os.clock()-self.voices[i].last_played)> oldest then
      oldest = (os.clock()-self.voices[i].last_played)
      oldest_voice = i
    end
  end
  if self.steal_voices then
    return oldest_voice
  end
  return false
end


function sampler:load_sample(path_to_file)
  sample_name = path_to_file:match("^.+/(.+).wav$")
  if self.samples[sample_name] ~= nil then
    -- already has sample loaded
    return
  end
  -- create a new sample
  self.samples[sample_name] = Sample:new()
  -- load the file into the sample
  new_position = self.samples[sample_name]:load(path_to_file, self.buffer_position)
  -- update the buffer position for the next sample
  if new_position then
    self.buffer_position = new_position
  end
end

function sampler:load_directory(dir)
  -- TODO: for each file in directory, load sample
end

return sampler
