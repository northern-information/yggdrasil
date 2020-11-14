-- ships with norns
crow = require("crow")
musicutil = require("musicutil")
tabutil = require("tabutil")
-- engine.name = "MikaPerc"
engine.name = "YggdrasilSynth"

local lib = "yggdrasil/lib/"

-- stores application configuration
config = include("lib/config")
config_ = io.open(_path["code"] .. lib .. "config_.lua", "r")
if config_ ~= nil then
  io.close(config_)
  include(lib .. "config_")
end

-- classes
include("lib/Field")        -- text field input
include("lib/Branch")       -- "words" of commands
include("lib/Command")      -- "sentences" entered into the terminal
include("lib/Interpreter")  -- translates text commands into programmatic meaning
include("lib/Slot")         -- smallest musical unit
include("lib/Track")        -- organizes slots
include("lib/Sample")       -- individual audio sample
include("lib/Validator")    -- works with the interpreter to validate command invocations

-- note these cannot be alphabetical due to dependencies

dev         = include("lib/dev")          -- dev only stuff
fn          = include("lib/functions")    -- global untilities
parameters  = include("lib/parameters")   -- exposed norns parameters
_midi       = include("lib/_midi")        -- control midi devices
_crow       = include("lib/_crow")        -- control crow
ypc         = include("lib/ypc")          -- yggdrasil production center (softcut)
view        = include("lib/view")         -- handle view logic
filesystem  = include("lib/filesystem")   -- manipulate files
page        = include("lib/page")         -- mvc "controller" for the page
keyboard    = include("lib/keyboard")     -- clickity-clack keyboard stuff
keys        = include("lib/keys")         -- keycodes, keycodes everywhere
terminal    = include("lib/terminal")     -- main text input terminal
commands    = include("lib/commands")     -- registered text-based commands
runner      = include("lib/runner")       -- executes valid commands
tracker     = include("lib/tracker")      -- core of yggdrasil
editor      = include("lib/editor")       -- window to edit details
music       = include("lib/music")        -- essentially musicutil abstractions
synth       = include("lib/synth")        -- supercollider
graphics    = include("lib/graphics")     -- everything you see on the screen
