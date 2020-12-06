-- ypc
-- orchestrates many samples
-- keeping track of which voices are available
-- and keeps track of which samples are loaded
--

local ypc = {}

function ypc.init()
  -- keeping track of active voices
  ypc.voices = {}
  for i = 1, 6 do
    ypc.voices[i] = {duration = 0, track=0, last_played=0}
  end
  -- table of samples addressed by sample name
  ypc.samples = {}
  ypc.buffer_position = 1
  ypc.steal_voices = true -- if steal voices, then pull the oldest voice, even if its playing
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
  ypc.bank = "factory"
  ypc:load_bank(ypc.bank)
end

function ypc:play(track, sample_name, frequency, velocity)
  if track == nil 
  or sample_name == nil 
  or sample_name == "" 
  or self.samples[sample_name] == nil 
  or frequency == nil
  or velocity == nil then 
    return 
  end
  -- plays sample in a one-shot loop
  -- then uses a clock to sleep and reset
  -- voice to 0 (not playing)
  local voice = self:acquire_voice(track)
  if voice then
    print(sample_name, self.samples[sample_name], voice, frequency, velocity)
    local duration = self.samples[sample_name]:play(voice, frequency, velocity)
    if duration ~= nil then 
      self.voices[voice].track = track 
      self.voices[voice].last_played = os.clock()
      self.voices[voice].duration = duration 
    end
  else
    -- could not acquire voice, exit gracefully
    return
  end
end


function ypc:acquire_voice(track)
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

function ypc:load_bank(s)
  local bank_path = filesystem:get_sample_path() .. s
  if not filesystem:file_or_directory_exists(bank_path) then
    tracker:set_message("Bank does not exist: " .. bank_path)
  else
    self.bank = s
    local filenames = filesystem:scandir(bank_path)
    for k, filename in pairs(filenames) do
      local path_to_file = bank_path .. "/" .. filename
      local sample_name = path_to_file:match("^.+/(.+).wav$")
      if self.samples[sample_name] ~= nil then
        -- already has sample loaded
        return
      end
      -- create a new sample
      self.samples[sample_name] = Sample:new()
      -- load the file into the sample
      local new_position = self.samples[sample_name]:load(path_to_file, self.buffer_position)
      -- update the buffer position for the next sample
      if new_position then
        self.buffer_position = new_position
      end
    end
  end
end

function ypc:get_samples()
  return filesystem:scandir(filesystem:get_sample_path() .. self:get_bank())
end

function ypc:get_bank()
  return self.bank
end

function ypc:show_bank()
  tracker:set_message(self:get_bank())
end

return ypc
