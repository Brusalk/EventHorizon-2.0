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
cooldownInfo = {} -- Indexed by spellbar data. Values are of form [cooldownDuration, textureUsed, cooldownID] or nil if no active
-- This way we keep the spellbar namespaces clear from other modules affecting our data by their poor programming skill :)
-- On a sidenote, being able to use a complex table like spellbars as indicies in a dictionary makes Lua the best programming language EVER!
local GetSpellCooldown, IsSpellKnown, GetSpellInfo = GetSpellCooldown, IsSpellKnown, GetSpellInfo -- localize our global functions for faster retrieval

-- [[ Helper Functions ]] --

local function addCooldown(spellbar, cooldownID, start, duration)
	if not spellbar or not start or not duration then return end
	--Make sure we have valid inputs and that the newDuration for the cd is longer than the previous
	local curTime = GetTime()
	
	if start + duration == 0 and cooldownInfo[spellbar] and cooldownID == cooldownInfo[spellbar][3] and cooldownInfo[spellbar][1]-curTime > 0 then -- we have a CD to reset
		ns:removeSpellUpdate(spellbar, "cooldown"..cooldownInfo[spellbar][1])
		ns:freeTempTexture(cooldownInfo[spellbar][2])
		cooldownInfo[spellbar] = nil
		return
	end

	local newEndTime = duration + start
	local newDuration = newEndTime - curTime
	
	local gcdStart, gcdDuration = GetSpellCooldown(ns:getConfig("gcdSpellID"))
	local gcdTime = gcdStart + gcdDuration

	if newEndTime <= gcdTime then return end
	if cooldownInfo[spellbar] and cooldownInfo[spellbar][1] > start+duration-0.1 and cooldownInfo[spellbar][1] < start+duration+0.1 then return end
	
	local barHeight = spellbar:GetHeight()
	
	local texture = ns:getTempTexture(spellbar)
	texture:SetPoint("TOP", spellbar, "TOP", 0, -barHeight*ns:getLayout("cooldown").top )-- texture init setup
	texture:SetPoint("LEFT", ns.barAnchor, "LEFT", ns:getPositionByTime(0))
	texture:SetPoint("BOTTOM", spellbar, "BOTTOM", 0, barHeight*(1-ns:getLayout("cooldown").bottom))
	texture:SetDrawLayer("BORDER", 1)
	texture:SetTexture(ns:getConfig("texture"))
	texture:SetVertexColor(unpack(ns:getColor("cooldown")))
	texture:SetBlendMode(ns:getBlendMode("cooldown"))
	texture:SetWidth(ns:getPositionByTime(newDuration))
	texture:Show()
	
	if cooldownInfo[spellbar] and cooldownInfo[spellbar][1]-curTime > 0 then -- The old cd isn't ticking off in negative land. If it is we can just ignore it
		ns:removeSpellUpdate(spellbar, "cooldown"..cooldownInfo[spellbar][1])
		ns:freeTempTexture(cooldownInfo[spellbar][2])
	end
	
	cooldownInfo[spellbar] = {newEndTime, texture, cooldownID}


	-- Handle the movement of the bar
	local past, future, width, timeElapsed = ns.config.past, ns.config.future, ns.config.width - (ns.config.icons and (ns.config.iconWidth < 1 and (ns.config.width-2*ns.config.padding)*ns.config.iconWidth or ns.config.iconWidth)+1 or 0), 0
	local secondsPerPixel = 0
	local timeRemaining = newDuration
	print("Adding cooldown ", cooldownID, " to bar ", spellbar.index, " for ", newDuration, " secs")
	ns:addSpellUpdate(spellbar, "cooldown"..newEndTime, function(self, elapsed, ...)
		secondsPerPixel = secondsPerPixel > 0 and secondsPerPixel or (future-past)/width
		timeElapsed = timeElapsed + elapsed
		if timeElapsed >= secondsPerPixel*.3 then -- Limit it to only when we need to move more than 1 pixel.
			timeRemaining = timeRemaining - timeElapsed
			timeElapsed = 0
			if timeRemaining > past then -- If the duration's more than the past time. (-3 by default)
				texture:SetWidth(ns:getPositionByTime(timeRemaining))
			else
				ns:removeSpellUpdate(spellbar, "cooldown"..newEndTime)
				ns:freeTempTexture(texture)
			end
		end
	end)
end

local function cooldownEventHandler(event, ...)
	for i, spellbar in ipairs(ns.spellbars.active) do
		local cooldownIDTable = ns:getSpellbarConfig(spellbar, "cooldown")		
		cooldownIDTable = type(cooldownIDTable)~= "table" and {cooldownIDTable} or cooldownIDTable
		for j, cooldownID in ipairs(cooldownIDTable) do
			local start, duration = GetSpellCooldown(cooldownID)
			if start and duration and IsSpellKnown(cooldownID) then
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
	
end


-- [[ onDisable ]] --

local function disable()
	-- Disable all active spellupdates for CDs as they apparently no longer care about us :(
	for i,spellbar in ipairs(ns.spellbars.index) do -- ipairs is faster than pairs when you have consecutive numbered indicies
		ns:removeSpellUpdate(spellbar, "cooldown")
		ns:freeTempTexture(cooldownInfo[spellbar][2])
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
	
	ns:addColor(moduleKey, "cooldown", {1, 1, 1, 0.5})
	
	ns:addBlendMode(moduleKey, "cooldown", "BLEND")
	
	ns:addLayout(moduleKey, "cooldown", {
		top = 0,
		bottom = 1
	})
	
	-- Hook spellbar show/hide
	
	ns:hookSpellbarShow(moduleKey, function(spellbar)
		local gcdStart, gcdDuration = GetSpellCooldown((GetSpellInfo(ns:getConfig("gcdSpellID"))))
		local gcdTime = gcdStart + gcdDuration
		local cooldownIDTable = ns:getSpellbarConfig(spellbar, "cooldown")	
		cooldownIDTable = type(cooldownIDTable)~= "table" and {cooldownIDTable} or cooldownIDTable		
		for i, cooldownID in ipairs(cooldownIDTable) do
			local start, duration = GetSpellCooldown(cooldownID)
			if start+duration > gcdTime and IsSpellKnown(cooldownID) then
				addCooldown(spellbar, cooldownID, duration) -- addCooldown handles the actual display order of CDs. Here we only care about the known CDs for the spellbar and pass it on down the line
			end
		end		
	end)
	
	ns:hookSpellbarHide(moduleKey, function(spellbar)
		ns:removeSpellUpdate(spellbar, "cooldown")
		if cooldownInfo[spellbar] and cooldownInfo[spellbar][2] then
			ns:freeTempTexture(cooldownInfo[spellbar][2])
		end
		cooldownInfo[spellbar] = nil		
	end)
	
	ns:hookSpellbarSettingsUpdate(moduleKey, function(spellbar)
		if spellbar == ns.spellbars.active[#ns.spellbars.active] then -- This is the last spellbar that's being updated, go through them all easily
			cooldownEventHandler() -- Just go through all the active spellbars 
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