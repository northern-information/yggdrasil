-- DEPTH
-- depth;16
-- 1 depth;16
commands:register{
  invocations = { "depth", "d" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 then return false end
    return
      (
        fn.is_int(branch[1].leaves[1])
        and Validator:new(branch[2], invocations):ok()
        and fn.is_int(branch[2].leaves[3])
      ) or (
        Validator:new(branch[1], invocations):ok()
        and fn.is_int(branch[1].leaves[3])
      )
  end,
  payload = function(branch)
    local out = {
      class = "DEPTH"
    }
    if #branch == 1 then
      out.depth = branch[1].leaves[3]
      out.x = "all"
    elseif #branch == 2 then
      out.depth = branch[2].leaves[3]
      out.x = branch[1].leaves[1]
    end
    return out
  end,
  action = function(payload)
    if payload.x == "all" then
      for k, track in pairs(tracker:get_tracks()) do
        tracker:set_track_depth(track:get_x(), payload.depth)
      end
    else
      tracker:update_track(payload)
    end
  end
}