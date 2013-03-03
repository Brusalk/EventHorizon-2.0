local ns = EventHorizon

local DEBUG = true

local blizzPrint = print
local function print(...)
	if DEBUG then
		blizzPrint(...)
	end
end

local moduleKey = "EventHorizon_Cooldown"

-- [[ Cooldown Locals ]] --

local t = {}
local cooldownInfo = {} -- Indexed by spellbar data. Values are of form [cooldownDuration, textureUsed, cooldownID] or nil if no active
-- This way we keep the spellbar namespaces clear from other modules affecting our data by their poor programming skill :)
-- On a sidenote, being able to use a complex table like spellbars as indicies in a dictionary makes Lua the best programming language EVER!
local GetSpellCooldown, IsSpellKnown, GetSpellInfo = GetSpellCooldown, IsSpellKnown, GetSpellInfo -- localize our global functions for faster retrieval
t.cooldownInfo = cooldownInfo -- Expose our cooldownInfo table to the module namespace so other addons and stuff can interact with us
-- [[ Helper Functions ]] --

local function addCooldown(spellbar, cooldownID, start, duration)
	
	if not (spellbar and cooldownID and start and duration) then return end
	
	local info = cooldownInfo[spellbar]
	
	if info and info.timedBar and info.start and info.duration then -- We have a previous cooldown that we need to check. 
	-- We only update the cooldown if the cooldown gets longer, OR if the cooldownID is the same
		if info.cooldownID == cooldownID then -- Update this anyway.
			info.timedBar = ns:updateTimedBar(moduleKey, info.timedBar, start+duration)
			print("Updated same bar:", duration)
			info.start = start
			info.duration = duration
		else -- They're not the same, so we want to show the one that ends the soonest.
			if info.start + info.duration > start + duration then -- Our new cooldown is actually shorter, so update with that new value
				info.timedBar = ns:updateTimedBar(moduleKey, info.timedBar, start+duration)
				print("Updated bar:", duration)
				info.start = start
				info.duration = duration	
				info.cooldownID = cooldownID
			-- Existing is shorter, so we do nothing.
			end
		end
	else -- This is a new cooldown for this spellbar, so we need to set stuff up
		-- (moduleKey, spellbar, duration, barKey, tickTime, tickKey)
		cooldownInfo[spellbar] = {}
		cooldownInfo[spellbar].timedBar = ns:addTimedBar(moduleKey, spellbar, duration, "cooldown", function() cooldownInfo[spellbar] = nil print("Bar",spellbar.index,": End") return end) -- this method and related automatically handle the getConfig settings stuff with the 4th arg.
		print("Added bar:", duration)
		cooldownInfo[spellbar].start = start
		cooldownInfo[spellbar].duration = duration
		cooldownInfo[spellbar].cooldownID = cooldownID
	end
	
end

local function cooldownEventHandler(event, ...)
	local gcdStart, gcdDuration = GetSpellCooldown(GetSpellInfo(ns:getConfig("gcdSpellID")))
	local gcdTime = gcdStart + gcdDuration
	for i, spellbar in ipairs(ns.spellbars.active) do
		local cooldownIDTable = ns:getSpellbarConfig(spellbar, "cooldown")		
		cooldownIDTable = type(cooldownIDTable)~= "table" and {cooldownIDTable} or cooldownIDTable
		for j, cooldownID in ipairs(cooldownIDTable) do
			local start, duration = GetSpellCooldown(cooldownID)
			if start and duration and IsSpellKnown(cooldownID) and start+duration > gcdTime then -- Make sure we're only doing cooldown stuff for cooldowns that are longer than a GCD. (We don't want to show a bar on every spellbar for every GCD)
				addCooldown(spellbar, cooldownID, start, duration) -- addCooldown handles the actual display order of CDs. Here we only care about the known CDs for the spellbar and pass it on down the line
			end
		end			
	end
end
-- [[ onEnable ]] --

local function enable()
	-- Go through all the active spellbars and check their CDs
	--cooldownEventHandler() -- That was easy
	
	-- Register our CD event handler
	ns:registerModuleEvent(moduleKey, cooldownEventHandler, "SPELL_UPDATE_COOLDOWN")
	--cooldownEventHandler("SPELL_UPDATE_COOLDOWN") This gets called when the spellbars are shown the first time.
	
end


-- [[ onDisable ]] --

local function disable()
	-- Disable all active spellupdates for CDs as they apparently no longer care about us :(
	for i,spellbar in ipairs(ns.spellbars.index) do -- ipairs is faster than pairs when you have consecutive numbered indicies
		ns:removeTimedBar(moduleKey, cooldownInfo[spellbar].timedBar)
		cooldownInfo[spellbar] = nil
	end
		
	-- Unregister our CD event.
	ns:unregisterModuleEvent(moduleKey, "SPELL_UPDATE_COOLDOWN")
	
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
		--cooldownEventHandler("SPELL_UPDATE_COOLDOWN")
	end)
	
	ns:hookSpellbarHide(moduleKey, function(spellbar)
		if cooldownInfo[spellbar] then
			ns:removeTimedBar(moduleKey, cooldownInfo[spellbar])
			cooldownInfo[spellbar] = nil
		end
	end)
	
	ns:hookSpellbarSettingsUpdate(moduleKey, function(spellbar)
		if cooldownInfo[spellbar] and cooldownInfo[spellbar].timedBar and cooldownInfo[spellbar].start and cooldownInfo[spellbar].duration then	
			ns:updateTimedBar(moduleKey, cooldownInfo[spellbar].timedBar, "cooldown", cooldownInfo[spellbar].start + cooldownInfo[spellbar].duration)
		end
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