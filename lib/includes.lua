-- ships with norns
musicutil = require("musicutil")
tabutil = require("tabutil")
engine.name = "PolyPerc"

local lib = "yggdrasil/lib/"

-- stores application configuration
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

-- manipulate files
filesystem = include("lib/filesystem")

-- "controller" for the page
page = include("lib/page")

-- clickity-clack keyboard stuff
keyboard = include("lib/keyboard")

-- keycodes, keycodes everywhere
keys = include("lib/keys")

-- liminal space for all the characters
buffer = include("lib/buffer")

-- where the action is
commands = include("lib/commands")

-- what miracle is this?
tracker = include("lib/tracker")

-- this giant tree
include("lib/Track")

-- it stands ten thousand feet high
include("lib/Slot")

-- essentially musicutil abstractions
music = include("lib/music")

-- supercollider
synth = include("lib/synth")

-- documentation
docs = include("lib/docs")

-- dev only stuff
dev = io.open(_path["code"] .. lib .. "dev.lua", "r")
if dev ~= nil then
  io.close(dev)
  include(lib .. "dev")
end