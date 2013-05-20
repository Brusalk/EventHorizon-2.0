local local_EHN, local_ns = ... 
local ns = EventHorizon

local DEBUG = ns.DEBUG

local blizzPrint = print
local function print(...)
    if DEBUG then
        blizzPrint(...)
    end
end

local function none() return end

local moduleKey = "EventHorizon_Cast"

-- [[ Cooldown Locals ]] --

local t = {}
local castInfo = {}
t.castInfo = castInfo -- Expose our table to the module namespace

local UnitCastingInfo = UnitCastingInfo

-- [[ Helper Functions ]] --



local function isFromPlayer(unitID)
    return string.lower(unitID) == "player"
end

local function spellbarConfigMatchesSpellID(spellbarConfig, spellID)

    if type(spellbarConfig) == "number" then
        return spellbarConfig == spellID
        
    elseif type(spellbarConfig) == "table" then
        for i, spellbarConfigID in ipairs(spellbarConfig) do
            if spellbarConfigID == spellID then
                return true
            end
        end
        -- All spellIDs in the spellID table were valid
    end
    return false
end

local function filterEvent(event, unitID, spellname, rank, lineID, spellID)
    -- Filter out events which we don't care about.
    if not isFromPlayer(unitID) then return end
    
    for i, spellbar in ipairs(ns.spellbars.active) do
        local spellbarConfig = ns:getSpellbarConfig(spellbar, "cast")
        if spellbarConfig and spellbarConfigMatchesSpellID(spellbarConfig, spellID) then
            if t["handle_" .. event] then
                t["handle_" .. event](spellbar, unitID, spellname, rank, lineID, spellID)
            end
        end
        
    end
end

local function setCastInfo(spellbar, lineID, timedBar)
    
    if not castInfo[spellbar] or type(castInfo[spellbar]) ~= "table" then
        castInfo[spellbar] = {}
    end
    
    castInfo[spellbar][lineID] = timedBar    
    
end

local function getCastInfo(spellbar, lineID)
    if castInfo[spellbar] then
        return castInfo[spellbar][lineID]
    end
end

t.handle_UNIT_SPELLCAST_START = function(spellbar, unitID, spellName, rank, lineID, spellID)
    
    if not getCastInfo(spellbar, lineID) then
        local name, subtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("player")
        --if castID ~= lineID then return end
        
        local duration = endTime/1000 - GetTime()
        setCastInfo(spellbar, lineID, ns:addTimedBar(moduleKey, spellbar, duration, "cast", none))
        print("Spell", spellName, "started casting")
    end

end

t.handle_UNIT_SPELLCAST_INTERRUPTED = function(spellbar, unitID, spellName, rank, lineID, spellID)

    if getCastInfo(spellbar, lineID) then
        setCastInfo(spellbar, lineID, ns:updateTimedBar(moduleKey, getCastInfo(spellbar, lineID), GetTime()))
        print("Spell", spellName, "was interrupted")
    end 
end

t.handle_UNIT_SPELLCAST_SUCCEEDED = function(spellbar, unitID, spellName, rank, lineID, spellID)

    if getCastInfo(spellbar, lineID) then
        setCastInfo(spellbar, lineID, nil)
        print("Spell", spellName, "finished casting")
    end
    
end

t.handle_UNIT_SPELLCAST_DELAYED = function(spellbar, unitID, spellName, rank, lineID, spellID)

    if getCastInfo(spellbar, lineID) then
        local name, subtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("player")
        setCastInfo(spellbar, lineID, ns:updateTimedBar(moduleKey, getCastInfo(spellbar, lineID), endTime))
        print("Spell", spellName, "was delayed")
    end

end

t.handle_UNIT_SPELLCAST_SENT = function(spellbar, unitID, spellName, rank, lineID, spellID)

end

t.handle_UNIT_SPELLCAST_FAILED = t.handle_UNIT_SPELLCAST_INTERRUPTED

t.handle_UNIT_SPELLCAST_FAILED_QUIET = t.handle_UNIT_SPELLCAST_INTERRUPTED

t.handle_UNIT_SPELLCAST_STOP = t.handle_UNIT_SPELLCAST_INTERRUPTED



t.events = { -- Table of all our relevant events and their corresponding functions to be called when they happen.
    UNIT_SPELLCAST_DELAYED = filterEvent,
    UNIT_SPELLCAST_FAILED = filterEvent,
    UNIT_SPELLCAST_FAILED_QUIET = filterEvent,
    UNIT_SPELLCAST_INTERRUPTED = filterEvent,
    UNIT_SPELLCAST_SENT = filterEvent,
    UNIT_SPELLCAST_START = filterEvent,
    UNIT_SPELLCAST_STOP = filterEvent,
    UNIT_SPELLCAST_SUCCEEDED = filterEvent,
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
    for i,spellbar in ipairs(ns.spellbars.index) do -- ipairs is faster than pairs when you have consecutive numbered indicies
        if castInfo[spellbar] then
            for j, lineID in pairs(castInfo[spellbar]) do
                local timedBar = getCastInfo(spellbar, lineID)
                if timedBar then
                    setCastInfo(spellbar, lineID, ns:removeTimedBar(moduleKey, timedBar))
                end
            end
        end
    end
        
    -- Unregister our CD event.
    for event, fxn in pairs(t.events) do
        ns:unregisterModuleEvent(moduleKey, event)
    end
end


-- [[ onInit ]] --

local function init()

    ns:addSpellbarConfig(moduleKey, "cast", {}, function(spellID)
        if type(spellID) == "number" then
            return spellID > 0
        elseif type(spellID) == "table" then
            for i, spell in ipairs(spellID) do
                if spell <= 0 then
                    return false
                end
            end
            -- All spellIDs in the spellID table were valid
            return true
        else
            return false
        end
    end) -- cast to the recognized newSpell() table, give it a default of empty table (no spellIDs provided) and a validation function for numbers > 0
    
    ns:addColor(moduleKey, "cast", {1, 1, 1, 0.5}) -- Add the half-transparent white color to the color table using the default color validation function
    
    ns:addBlendMode(moduleKey, "cast", "BLEND")
    
    ns:addLayout(moduleKey, "cast", {
        top = 0,
        bottom = 1
    })
    
    -- Hook spellbar show/hide
    
    --ns:hookSpellbarShow(moduleKey, function(spellbar)

    --end)
    
    ns:hookSpellbarHide(moduleKey, function(spellbar)
        if not castInfo[spellbar] then return end
        
        for j, lineID in pairs(castInfo[spellbar]) do
            local timedBar = getCastInfo(spellbar, lineID)
            if timedBar then
                setCastInfo(spellbar, lineID, ns:removeTimedBar(moduleKey, timedBar))
            end
        end
    end)
    
    --ns:hookSpellbarSettingsUpdate(moduleKey, function(spellbar)
    
    --end)
    
end


-- [[ Registering with EH ]] --

ns:addModule(moduleKey, {
    description = "Cast Functionality for EventHorizon. By Brusalk.",
    defaultState = true, -- On by default
    onDisable = disable,
    onEnable = enable,
    onInit = init,
    table = t,
})