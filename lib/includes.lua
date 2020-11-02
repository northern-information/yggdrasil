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

-- handle view logic
view = include("lib/view")

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

-- registered text-based commands
commands = include("lib/commands")

-- executes valid commands
runner = include("lib/runner")

-- core of yggdrasil
tracker = include("lib/tracker")

-- audio mixing and routing
mixer = include("lib/mixer")

-- essentially musicutil abstractions
music = include("lib/music")

-- supercollider
synth = include("lib/synth")

-- documentation
docs = include("lib/docs")

-- everything you see on the screen
graphics = include("lib/graphics")

-- "words" of commands
include("lib/Branch")

-- "sentences" entered into the buffer
include("lib/Command")

-- translates text commands into programmatic meaning
include("lib/Interpreter")

-- works with the interpreter to validated command invocations
include("lib/Validator")

-- organizes slots
include("lib/Track")

-- smallest musical unit
include("lib/Slot")


-- dev only stuff
dev = io.open(_path["code"] .. lib .. "dev.lua", "r")
if dev ~= nil then
  io.close(dev)
  include(lib .. "dev")
end