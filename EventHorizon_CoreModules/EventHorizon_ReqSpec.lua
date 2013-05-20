local ns = EventHorizon

local DEBUG = false

local t = {}

local blizzPrint = print
local function print(...)
    if DEBUG then
        blizzPrint(...)
    end
end

local moduleKey = "EventHorizon_ReqSpec" -- Name of the game

-- [[ Helper Functions ]] --

local function requirementCheck(spellbar)
    local rT = ns:getSpellbarConfig(spellbar, "requiredTree")
    
    if not rT then return true end
    
    if type(rT) == "number" or type(rT) == "table" then
        local activeTree = GetSpecialization()
        
        if type(rT) == "number" then
            rT = {rT}
        end
        
        for i,tree in ipairs(rT) do
            if tree == activeTree then
                return true
            end
        end
    end
end
        
-- [[ onEnable ]] --

local function enable()
    
    ns:registerModuleEvent(moduleKey, function(...)
        ns:applySettings()        
    end,
    "ACTIVE_TALENT_GROUP_CHANGED",
    "PLAYER_SPECIALIZATION_CHANGED",
    "PLAYER_SPECIALIZATION_UPDATE"
    )
    ns:applySettings()    
end


-- [[ onDisable ]] --

local function disable()

    ns:unregisterModuleEvent(moduleKey, 
    "ACTIVE_TALENT_GROUP_CHANGED",
    "PLAYER_SPECIALIZATION_CHANGED",
    "PLAYER_SPECIALIZATION_UPDATE"
    )
    ns:applySettings()    
end


-- [[ onInit ]] --

local function init()
    
        ns:addSpellbarRequirement(moduleKey, "requiredTree", requirementCheck)
    
end





-- [[ Registering with EH ]] --

ns:addModule(moduleKey, {
    description = "Specialization Requirement for EventHorizon. By Brusalk.",
    defaultState = true, -- On by default
    onDisable = disable,
    onEnable = enable,
    onInit = init,
    moduleTable = t,
})