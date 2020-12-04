-- YMODE
commands:register{
  invocations = { "ymode" },
  signature = function(branch, invocations)
    if #branch ~= 1 then return false end
    return Validator:new(branch[1], invocations):ok()
  end,
  payload = function(branch)
    return {
      class = "ymode"
    }
  end,
  action = function(payload)
    keys:toggle_y_mode()
  end
}