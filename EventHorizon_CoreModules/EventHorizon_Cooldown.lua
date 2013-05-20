local ns = EventHorizon

local DEBUG = ns.DEBUG

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
local BlizzCooldown, GetSpellCharges, IsSpellKnown, GetSpellInfo = GetSpellCooldown, GetSpellCharges, IsSpellKnown, GetSpellInfo -- localize our global functions for faster retrieval
t.cooldownInfo = cooldownInfo -- Expose our cooldownInfo table to the module namespace so other addons and stuff can interact with us
-- [[ Helper Functions ]] --

local function GetSpellCooldown(spellID)
    if not spellID or not (type(spellID)=="table" or type(spellID)=="number" or type(spellID)=="string") then 
        return 0, 0, 0 -- It's not a valid spell
    end

    local charges, maxCharges, cStart, cDuration = GetSpellCharges(spellID)
    -- return start, duration, enable
    if charges and charges == 0 then -- This cooldown is a spell with charges
        --print("Charges:", cStart + cDuration, GetTime())
        --print(cStart, start, "  ", cDuration, duration)
        
        local timeToOneCharge = cStart + cDuration - GetTime()
        
        return cStart, timeToOneCharge, 1
    elseif charges and charges ~= 0 then -- It's a spell with charges, but it's not at 0 charges, so we don't care. Pass out with enable = 0.
        --print("Charges:", ">0", GetTime())
        return 0, cDuration, 0
    end
    --print("No Charges:")
    return BlizzCooldown(spellID) -- If we got here, then it's a spell without charges, so use the normal GetSpellCooldown()
    
end

local function isTimedBarDone(timedBar)
    local done = timedBar.segments[timedBar.ticks]:GetRight() <= ns.nowLine:GetRight()
    print(done and "done" or "")
    return nil
end

local function null() -- null function to pass to addTimedBar
    return
end

--[[local function addCooldown(spellbar, cooldownID, start, duration)
    
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
            local start, duration, enabled = GetSpellCooldown(cooldownID)
            if start ~= 0 and duration and IsSpellKnown(cooldownID) and start+duration > gcdTime and enabled == 1 then -- Make sure we're only doing cooldown stuff for cooldowns that are longer than a GCD. (We don't want to show a bar on every spellbar for every GCD)
                addCooldown(spellbar, cooldownID, start, duration) -- addCooldown handles the actual display order of CDs. Here we only care about the known CDs for the spellbar and pass it on down the line
            else
                local info = cooldownInfo[spellbar]
                if info then
                    local now = GetTime()
                    
                    if info.start + info.duration > ( (enabled == 1 and start~=0 and duration) and start+duration or now) then
                        info.timedBar = ns:updateTimedBar(moduleKey, info.timedBar, now)
                    end
                end
            end
        end            
    end
end

--]]

local function cooldownEventHandler(event, ...)
    for i, spellbar in pairs(ns.spellbars.active) do
        local self = cooldownInfo[spellbar] or {}
        
        local cooldownConfig = ns:getSpellbarConfig(spellbar, "cooldown")
        if type(cooldownConfig) == "string" or type(cooldownConfig) == "number" then 
            cooldownConfig = {cooldownConfig}
        end
        --print("1")
        if type(cooldownConfig) == "table" then
            local start, startMax, duration, durationMax, enabled, enabledMax = 0, 0, 0, 0, 0, 0
            for j, spell in ipairs(cooldownConfig) do
                start, duration, enabled = GetSpellCooldown(spell)
                if start+duration > startMax+durationMax and enabled then 
                    startMax     = start
                    durationMax = duration
                    enabledMax     = enabled
                    --print("New Max:", start, duration, enabled)
                end            
            end
            -- startMax/durationMax/enabledMax now hold the value of the cooldown of the longest duration CD in the cooldown table
            --print("2")
            if startMax ~= 0 and enabledMax then -- We have a cooldown to work with
                --local gcdStart, gcdDuration, gcdEnable = GetSpellCooldown(ns:getConfig("gcdSpellID"))
                --print("3", startMax+durationMax, gcdStart+gcdDuration, gcdEnable)
                --if gcdEnable and startMax+durationMax > gcdStart+gcdDuration then -- The cooldown isn't just because of a GCD
                    --print("4")
                    if self.timedBar and isTimedBarDone(self.timedBar) then
                        self.timedBar = nil
                        self.endTime  = 0
                    end
                    
                    if not self.timedBar then -- We don't have an active timed bar, or we have a timed bar that has gone past the now line
                        self.timedBar     = ns:addTimedBar(moduleKey, spellbar, durationMax, "cooldown",  function()
                                                                                                            self.timedBar = nil
                                                                                                            self.endTime  = 0
                                                                                                        end)
                        self.endTime    = startMax + durationMax    
                        --print("5")
                    
                    else -- We have to update an existing timed bar
                        -- Existing CD is different
                        if self.endTime ~= startMax + durationMax then
                            self.timedBar    = ns:updateTimedBar(moduleKey, self.timedBar, startMax + durationMax)
                            self.endTime    = startMax + durationMax
                        end                        
                        --print("6")
                    end
                    
                --end
            end
        end
        --print("7")
        cooldownInfo[spellbar] = self
    end
end



local function cooldownEventHandlerDeprecated(event, ...)
    for i, spellbar in pairs(ns.spellbars.active) do
        --print(i, ";")
        local self = cooldownInfo[spellbar] or {}
        
        spellbarConfig        = ns:getSpellbarConfig(spellbar, "cooldown")
        --print(type(spellbarConfig), spellbarConfig)
        self.cooldownTable     = type(spellbarConfig) == "table"  and spellbarConfig
        self.cooldownID        = type(spellbarConfig) == "number" and spellbarConfig
        self.spellname            = type(spellbarConfig) == "string" and spellbarConfig
        
        if self.cooldownTable or self.cooldownID or self.spellname then
            
            local start     = 0
            local duration     = 0
            local enabled
            local ready
            
            if self.cooldownTable then -- we choose the one with the longer CD (This is mostly for sfiend/mindbender bar)
                for i,cooldown in pairs(self.cooldownTable) do
                    start2, duration2, enabled2 = GetSpellCooldown(cooldown)
                    if start2+duration2 > start+duration then 
                        --print(cooldown, "better", start2+duration2, start+duration)
                        start = start2
                        duration = duration2
                        enabled = enabled2
                        ready = (enabled == 1 and start ~= 0 and duration) and start+duration
                    end
                end
            else 
                start, duration, enabled = GetSpellCooldown(self.cooldownID or self.spellname)
                ready = (enabled == 1 and start ~= 0 and duration) and start+duration
            end
            --print(start, duration, enabled, ready)
            if ready and duration>1.5 then
                -- The spell is on cooldown, but not just because of the GCD.
                
                if self.cooldown ~= ready then         -- The CD has changed since the last check
                    if not self.coolingdown then     -- No CD bar exists yet, so make one
                        self.coolingdown = ns:addTimedBar(moduleKey, spellbar, ready-start, "cooldown", function() return end)
                    elseif self.coolingdown.stop and self.coolingdown.stop ~= ready then
                        self.coolingdown.start = start
                        self.coolingdown.stop  = ready
                        print("Update 1")
                        self.coolingdown = ns:updateTimedBar(moduleKey, self.coolingdown, ready)
                    end
                    self.cooldown = ready
                end
            else
                if self.coolingdown then
                    -- spell is off cooldown or the cd expires during the GCD window
                    local now = GetTime()
                    -- see when the cooldown is ready. If the spell is currently on GCD, check the GCD end, otherwise check now
                    if self.cooldown > (ready or now) then
                        -- Cooldown ended early 
                        print("Update 2")
                        self.coolingdown.stop     = now
                        self.coolingdown         = ns:updateTimedBar(modulekey, self.coolingdown, now)
                    end
                    self.coolingdown = nil
                end
                self.cooldown = nil
            end
            cooldownInfo[spellbar] = self
            --print("Done with", i)
        end
    end
    --]]
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
        if cooldownInfo[spellbar].timedBar then
            ns:removeTimedBar(moduleKey, cooldownInfo[spellbar].timedBar)
        end
        --cooldownInfo[spellbar] = nil
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