local ns = EventHorizon

local DEBUG = true

local blizzPrint = print
local function print(...)
	if DEBUG then
		blizzPrint(...)
	end
end

local moduleKey = "EventHorizon_Cast"

-- [[ Cooldown Locals ]] --

local t = {}
local castInfo = {} -- Indexed by spellbar data. Values are of form [cooldownDuration, textureUsed, cooldownID] or nil if no active
-- This way we keep the spellbar namespaces clear from other modules affecting our data by their poor programming skill :)
-- On a sidenote, being able to use a complex table like spellbars as indicies in a dictionary makes Lua the best programming language EVER!
local GetSpellCooldown, IsSpellKnown, GetSpellInfo = GetSpellCooldown, IsSpellKnown, GetSpellInfo -- localize our global functions for faster retrieval
t.castInfo = castInfo -- Expose our table to the module namespace
-- [[ Helper Functions ]] --

t.events = { -- Table of all our relevant events and their corresponding functions to be called when they happen.
	UNIT_SPELLCAST_CHANNEL_START = function() end,
	UNIT_SPELLCAST_CHANNEL_STOP = function() end,
	UNIT_SPELLCAST_CHANNEL_UPDATE = function() end,
	UNIT_SPELLCAST_DELAYED = function() end,
	UNIT_SPELLCAST_FAILED = function() end,
	UNIT_SPELLCAST_FAILED_QUIET = function() end,
	UNIT_SPELLCAST_INTERRUPTED = function() end,
	UNIT_SPELLCAST_SENT = function() end,
	UNIT_SPELLCAST_START = function() end,
	UNIT_SPELLCAST_STOP = function() end,
	UNIT_SPELLCAST_SUCCEEDED = function() end,
}




-- [[ onEnable ]] --

local function enable()
	-- Go through all our events and register them
	
	for event, fxn in pairs(t.events) do
		ns:registerModuleEvent(moduleKey, fxn, event)
	end
	
end


-- [[ onDisable ]] --

local function disable()
	-- Disable all active spellupdates for CDs as they apparently no longer care about us :(
	for i,spellbar in ipairs(ns.spellbars.index) do -- ipairs is faster than pairs when you have consecutive numbered indicies
		t.events.UNIT_SPELLCAST_STOP(spellbar)
	end
		
	-- Unregister our CD event.
	for event,fxn in pairs(t.events) do
		ns:unregisterModuleEvent(moduleKey, event)
	end
end


-- [[ onInit ]] --

local function init()

	ns:addSpellbarConfig(moduleKey, "cooldown", {}, function(spellID)
		return type(spellID)=="number" and spellID > 0
	end) -- Add cooldown to the recognized newSpell() table, give it a default of empty table (no spellIDs provided) and a validation function for numbers > 0
	
	ns:addColor(moduleKey, "cooldown", {1, 1, 1, 0.5}) -- Add the half-transparent white color to the color table using the default color validation function
	
	ns:addBlendMode(moduleKey, "cooldown", "BLEND")
	
	ns:addLayout(moduleKey, "cooldown", {
		top = 0,
		bottom = 1
	})
	
	-- Hook spellbar show/hide
	
	ns:hookSpellbarShow(moduleKey, function(spellbar)
		cooldownEventHandler("SPELL_UPDATE_COOLDOWN")
	end)
	
	ns:hookSpellbarHide(moduleKey, function(spellbar)
		ns:removeTimedBar(moduleKey, cooldownInfo[spellbar])
		cooldownInfo[spellbar] = nil	
	end)
	
	ns:hookSpellbarSettingsUpdate(moduleKey, function(spellbar)
		if cooldownInfo[spellbar] then	
			ns:updateTimedBar(moduleKey, cooldownInfo[spellbar].timedBar, "cooldown", cooldownInfo[spellbar].start + cooldownInfo[spellbar].duration)
	end)
	
	-- Don't need to do anything on spellbar creation as we latch onto the spellbar manually
	
end





-- [[ Registering with EH ]] --

ns:addModule(moduleKey, {
	description = "Cooldown Functionality for EventHorizon. By Brusalk.",
	defaultState = true, -- On by default
	onDisable = disable,
	onEnable = enable,
	onInit = init,
	table = t,
})