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

-- note these cannot be alphabetical due to dependencies

fn          = include("lib/functions")    -- global untilities
parameters  = include("lib/parameters")   -- exposed norns parameters
view        = include("lib/view")         -- handle view logic
filesystem  = include("lib/filesystem")   -- manipulate files
page        = include("lib/page")         -- mvc "controller" for the page
keyboard    = include("lib/keyboard")     -- clickity-clack keyboard stuff
keys        = include("lib/keys")         -- keycodes, keycodes everywhere
buffer      = include("lib/buffer")       -- liminal space for all the characters
commands    = include("lib/commands")     -- registered text-based commands
runner      = include("lib/runner")       -- executes valid commands
tracker     = include("lib/tracker")      -- core of yggdrasil
music       = include("lib/music")        -- essentially musicutil abstractions
synth       = include("lib/synth")        -- supercollider
graphics    = include("lib/graphics")     -- everything you see on the screen

-- classes
include("lib/Branch")       -- "words" of commands
include("lib/Command")      -- "sentences" entered into the buffer
include("lib/Interpreter")  -- translates text commands into programmatic meaning
include("lib/Slot")         -- smallest musical unit
include("lib/Track")        -- organizes slots
include("lib/Validator")    -- works with the interpreter to validate command invocations

-- dev only stuff
dev = io.open(_path["code"] .. lib .. "dev.lua", "r")
if dev ~= nil then
  io.close(dev)
  include(lib .. "dev")
end