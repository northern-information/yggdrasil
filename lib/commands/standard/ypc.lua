-- YPC
-- 1 1 ypc;load;piano_440.wav
-- 1 1 ypc;l;piano_440.wav
-- 1 ypc;llaod;piano_440.wav
-- 1 ypc;l;piano_440.wav
-- ypc;bank;909
-- ypc;b;909
commands:register{
  invocations = { "ypc" },
  signature = function(branch, invocations)
    if #branch ~= 1 and #branch ~= 2 and #branch ~= 3 then return false end
    return (
      #branch == 3
      and fn.is_int(branch[1].leaves[1])
      and fn.is_int(branch[2].leaves[1])
      and Validator:new(branch[3], invocations):ok()
      and branch[3].leaves[1] == "ypc"
      and branch[3].leaves[5] ~= nil
    ) or (
      #branch == 2
      and fn.is_int(branch[1].leaves[1])
      and Validator:new(branch[2], invocations):ok()
      and branch[2].leaves[1] == "ypc"
      and branch[2].leaves[5] ~= nil
    ) or (
      #branch == 1
      and Validator:new(branch[1], invocations):ok()
    )
  end,
  payload = function(branch)
    local out = {
        class = "YPC"
    }
    if #branch == 1 then
      if branch[1].leaves[3] == "bank" or branch[1].leaves[3] == "b" then
        out["action"] = "bank"
        out["directory"] = branch[1].leaves[5]
      end
    elseif #branch == 2 then
      if branch[2].leaves[3] == "load" or branch[2].leaves[3] == "l" then
        out["action"] = "load"
        out["filename"] = branch[2].leaves[5]
        out["x"] = branch[1].leaves[1]
      end
    elseif #branch == 3 then
      if branch[3].leaves[3] == "load" or branch[3].leaves[3] == "l" then
        out["action"] = "load"
        out["filename"] = branch[3].leaves[5]
        out["x"] = branch[1].leaves[1]
        out["y"] = branch[2].leaves[1]
      end
    end
    return out
  end,
  action = function(payload)
    if payload.action == "bank" then
      tracker:clear_all_samples()
      ypc:load_bank(payload.directory)
    elseif payload.action == "load" then
      tracker:deselect()
      tracker:select_track(payload.x)
      tracker:update_track(payload)
    end
  end
}