local _clock = {}

function _clock.init() 
  _clock.the_arrow_of_time = 0
  _clock.ppqn = config.settings.ppqn
  _clock.micro_timer = _clock.ppqn
  _clock.micro_half_timer = _clock.ppqn * 2
  _clock.ppqn_grains = {}
  for i = 1, _clock.ppqn * 2 do
    _clock.ppqn_grains[i] = i / _clock.ppqn
  end
end

function _clock.global_clock()
  -- not using getters here on the superstitious
  -- belief that it will help performance...
  while true do
    clock.sync(1 / _clock.ppqn)
    _clock.the_arrow_of_time = _clock.the_arrow_of_time + 1
    _clock.micro_timer = fn.cycle(_clock.micro_timer - 1, 1, _clock.ppqn)
    _clock.micro_half_timer = fn.cycle(_clock.micro_half_timer - 1, 1, _clock.ppqn * 2)
    if tracker.playback then
      for k, track in pairs(tracker.tracks) do
        if track.ppqn_table[_clock.micro_timer] or track.ppqn_table[_clock.micro_half_timer] then
          track:advance()
          fn.dirty_screen(true)
        end
      end
    end
  end
end

-- snap a value to to the grains of a the ppqn resolution
function _clock:snap_to_ppqn_grains(value)
  local nearest, index
  for i, grain in ipairs(self.ppqn_grains) do
    if not nearest or (math.abs(value - grain) < nearest) then
      nearest = math.abs(value - grain)
      index = i
    end
  end
  return self.ppqn_grains[index]
end

-- each track has a table of all grains in the resolution with boolean values
-- 1 = false
-- 2 = true
-- ...
-- 97 = false
-- 96 = true
function _clock:build_ppqn_table(sync)
  out = {}
  for i = 1, self.ppqn * 2 do
    local check = self:snap_to_ppqn_grains(i / self.ppqn) % sync
    out[i] = (check == 0 or (check <= .0000001)) -- account for 3rds, .999999, etc.
  end
  return out
end

function _clock:get_the_arrow_of_time()
  return self.the_arrow_of_time
end

return _clock