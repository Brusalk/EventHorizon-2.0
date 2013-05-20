local ns = EventHorizon

local DEBUG = false

local t = {}

local blizzPrint = print
local function print(...)
    if DEBUG then
        blizzPrint(...)
    end
end

local moduleKey = "EventHorizon_ReqLevel" -- Name of the game

-- [[ Helper Functions ]] --

local function requirementCheck(spellbar)

    local r = ns:getSpellbarConfig(spellbar, "requiredLevel")
    
    if not r then return true end
    
    if type(r)=="number" and r <= UnitLevel("player") then
        return true
    end
    
end
        
-- [[ onEnable ]] --

local function enable()
    
    ns:registerModuleEvent(moduleKey, function(...)
        ns:applySettings()        
    end,
    "PLAYER_LEVEL_UP"
    )
    ns:applySettings()    
    
end


-- [[ onDisable ]] --

local function disable()

    ns:unregisterModuleEvent(moduleKey, 
    "PLAYER_LEVEL_UP"
    )
    ns:applySettings()    
    
end


-- [[ onInit ]] --

local function init()
    
        ns:addSpellbarRequirement(moduleKey, "requiredLevel", requirementCheck)
    
end





-- [[ Registering with EH ]] --

ns:addModule(moduleKey, {
    description = "Level Requirement for EventHorizon. By Brusalk.",
    defaultState = true, -- On by default
    onDisable = disable,
    onEnable = enable,
    onInit = init,
    moduleTable = t,
})