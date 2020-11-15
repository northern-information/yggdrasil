--
-- Sample class
-- contains information for sample
-- and directly plays/stops/loads sample
--

Sample = {}

function Sample:new()
  local s = setmetatable({}, { 
    __index = Sample,
    -- __tostring = function(s) return s:to_string() end
  })
  s.voice = 0
  s.rate_compensation = 1
  s.frequency = 440
  s.buffer = 1
  s.position = {1, 3} -- start and end
  s.name = ''
  s.filename = ''
  s.path = ''
  return s
end

function Sample:to_string()
  return self:get_filename()
end

function Sample:get_filename()
  return self.filename
end

function Sample:get_length()
  return self.position[2] - self.position[1]
end

function Sample:play(voice, frequency, velocity)
  if frequency == nil then 
    return 
  end
  if velocity == nil then 
    velocity = 1
  end
  if voice < 1 or voice > 6 then 
    error("bad voice")
  end
  local rate = self.rate_compensation * frequency / self.frequency
  local duration = (self.position[2]-self.position[1])/rate
  -- plays sample in a one-shot loop
  print("playing "..self.name.." on voice "..voice.." at "..frequency.." with velocity "..velocity)

  -- unsure whether clock is needed here
  -- it might be faster to help play in sync
  -- at really fast speeds
  clock.run(function() 
    softcut.position(voice, self.position[1])
    softcut.loop_start(voice, self.position[1])
    softcut.loop_end(voice, self.position[2])
    softcut.rate(voice,rate)
    softcut.level(voice,velocity)
    softcut.play(voice,1)
  end)
  -- return how long this is going to take
  return duration 
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
  self.name = filename:match("^.+/(.+).wav$")
  local ch, samples, sample_rate = audio.file_info(filename)
  local duration = samples / 48000.0
  self.filename = filename
  self.rate_compensation = sample_rate / 48000.0 -- compensate for files that aren't 48Khz
  self.position = {position, position + duration}

  -- get frequency information from the filename itself
  -- the frequency should be the LAST number in filename
  local hz = 440
  for num in string.gmatch(filename,"(%d+)hz") do 
    hz = tonumber(num)
  end
  if hz > 10 and hz < 20000 then
    self.frequency = hz
  end
  print("loaded " .. self.name .. " at " .. self.frequency .. "hz")

  -- read it into softcut
  softcut.buffer_read_mono(filename, 0, position, -1, 1, 1)
  -- return new position in buffer
  return position + duration + 1
end
