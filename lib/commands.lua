commands = {}

function commands.init()
  commands.all = {}
  commands.phenomena = {}
  commands:register_all()
  commands.k3 = nil
end

function commands:set_k3(s)
  self.k3 = s
end

function commands:fire_k3()
  if self.k3 ~= nil then
    runner:run(self.k3)
  else
    tracker:set_message("Assign K3 with: k3 = ...")
  end
end

function commands:get_all()
  return self.all
end

function commands:get_phenomena()
  return self.phenomena
end


function commands:register(t)
  local class, phenomenon = self:extract_class_and_phenomenon(t)
  --[[
  loop through all registered classes
  then all their invocations
  then all the incoming invocations
  and alert if there are duplicates
  ]]
  for k, command in pairs(self.all) do
    for kk, existing_invocation in pairs(command.invocations) do
      for kkk, new_invocation in pairs(t.invocations) do
        if existing_invocation == new_invocation then
          fn.print_matron_message("Error: Invocation " .. new_invocation .. " on " .. class .. " is already registered to " .. k .. "! Overwriting...")
        end
      end
    end
  end
  -- if class == "ARPEGGIO" then
    self.all[class] = t
    if phenomenon then
      self.phenomena[class] = t
    end
  -- end
end

--[[
to keep with DRY principals this allows
us to only type the class name once in a definition
it also serves as a mini-validation and
check against some of the structures of the
command composition. it is simply extracting
the classname from the payload.
]]
function commands:extract_class_and_phenomenon(t)
  local dummy_branches = {}
  local dummy_branch = Branch:new("stub;1;2;3;4")
  for i = 1, 4 do  dummy_branches[i] = dummy_branch end
  local result = t.payload(dummy_branches)
  return result.class, (result.phenomenon ~= nil)
end

--[[
add new commands in yggdrasil/lib/commands/*
add new commands in yggdrasil/lib/phenomenon/*
 - "invocations" defines the valid aliases
 - "signature" defines what string from the terminal fits with this command
 - "payload" defines how to format the string for execution
 - "action" combines the payload with the final executable method/function
]]
function commands:register_all()
  local standard = filesystem:scandir(_path.code .. config.settings.commands_path)
  for k, file in pairs(standard) do
    include(config.settings.commands_path .. string.gsub(file, ".lua", ""))
  end
  local phenomenon = filesystem:scandir(_path.code .. config.settings.phenomenon_path)
  for k, file in pairs(phenomenon) do
    include(config.settings.phenomenon_path .. string.gsub(file, ".lua", ""))
  end
  fn.print_matron_message(">>> Yggdrasil Ready <<<")
end -- register all

return commands