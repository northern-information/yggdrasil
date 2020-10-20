-- ships with norns
musicutil = require("musicutil")
tabutil = require("tabutil")
engine.name = "PolyPerc"

local lib = "yggdrasil/lib/"

-- stores application configuration and cell composition data
config = include("lib/config")
config_ = io.open(_path["code"] .. lib .. "config_.lua", "r")
if config_ ~= nil then
  io.close(config_)
  include(lib .. "config_")
end

-- global untilities
fn = include("lib/functions")

-- exposed norns parameters
parameters = include("lib/parameters")

-- everything you see on the screen
graphics = include("lib/graphics")

-- "controller" for the page
page = include("lib/page")

-- clickity-clack keyboard stuff
keyboard = include("lib/keyboard")

-- keycodes, keycodes everywhere
keys = include("lib/keys")


-- dev only stuff
dev = io.open(_path["code"] .. lib .. "dev.lua", "r")
if dev ~= nil then
  io.close(dev)
  include(lib .. "dev")
end