local DEBUG = true
local EHN,ns = ...
EventHorizon = ns
EH = ns


-- [[ Base Frames ]] --
ns.frame = CreateFrame("frame")
ns.barAnchor = CreateFrame("frame")
ns.barAnchor:SetWidth(1)


-- [[ Saved Vars ]] --

EventHorizonSavedVars = EventHorizonSavedVars or {
    modules = {},
}
EventHorizonSavedVarsPerCharacter = EventHorizonSavedVarsPerCharacter or {
    
}


-- [[ Addon Scoped Tables ]] --

ns.events = {}        -- contains all of the handler functions for events referenced by event
ns.modules = {        -- contains all module information/defaults.
    spellbarHooks = { -- Table used for holding handler functions for each module for hooking into parts of spellbar functionality
        onShow = {},
        onHide = {},
        onSettingsUpdate = {},
        onCreation = {},
    },
    spellbarConfig = {}, -- Table used for holding all non-standard spellbar config options added by modules.
    -- I don't think this is needed, but just in case... spellbarRequired = {} -- Table used for holding all requirements
}       
ns.config = {} -- Contains current config values. If using in-game options this table's updated with those values
ns.layouts = {} -- same as above
ns.blendModes = {}
ns.colors = {}
ns.spellbarConfig = {} -- all above ditto
ns.spellbars = {  -- contains the spellbars which have been added by ns:NewSpell(), as well as references to spellbars by various attributes (Doing this frontloads the work when creating the bars on startup, as opposed to requiring it later while processing speed matters
    index = {}, -- in order of creation via newspell
    active = {}, -- contains all active spellbars.
    required = {}, -- contains subtables which represent requirements defined by modules. Subtables are indexed by requirement and valued with the spellbar and it's requirement Function.
}
ns.validatorFunctions = { -- used for the options menu and validating user input for options
    addColor = {},
    addBlendMode = {},
    addLayout = {},
    addConfig = {},
    addSpellbarConfig = {},
    addSpellbarRequirement = {},
    defaults = {}, -- default built in validation functions. 
}
-- [[ Utility Tables/Local Scope ]] --

local errors = {} -- Table containing verbose error messages (in english)
local L = ns.localization -- Metatable for localization
local textures = { -- Table used for tempTexture system
    free = {},
    used = {},
}
local DB = EventHorizonSavedVars
local DBPC = EventHorizonSavedVarsPerCharacter
local addonInit = true -- true while addon is still being initialized. All functionality is postponed until addon is fully setup. Addon is setup when addonInit = nil
local class -- player's class

-- Localized global functions:
local UnitClass = UnitClass

-- [[ Utility Functions ]] --

local printBlizz = print
local function printhelp(...) if select('#',...)>0 then return tostring((select(1,...))), printhelp(select(2,...)) end end
local function print(...)
    printBlizz('EventHorizon: '.. strjoin(" ", printhelp(...)))
end

local function debug(...)
    if DEBUG then
        printBlizz('EHZ-Debug: ' .. strjoin(" ", printhelp(...)))
    end
end

local function round(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end

function ns:error(fxn, errorKey)
    if not fxn or not DEBUG then return end
    if errorKey then
        print("Error in function " .. fxn .. ":", errors[fxn][errorKey] or "Double-Fault. Error not found >.<")
    else
        print("Error:", fxn)
    end
end

function ns:addError(fxn, err)
    if not DEBUG then return end
    errors[fxn] = {}
    for i,v in pairs(err) do
        errors[fxn][i] = v
    end
end

ns:addError("mergeDef", {inputs = "one or more of inputs def, t1 are not defined"})
local function mergeDef(def, t1, t2)

    if not def or not t1 then ns:error("mergeDef", "inputs") return end
    local tmp = {}
    for i,v in pairs(def) do
        if t2 and (t2[i] or t2[i] == false) then -- t2 is actually an optional table.
            tmp[i] = t2[i]
            --print("Overwriting value ", i, " with value ", v, " from myconfig.lua")
        elseif t1[i] or t1[i] == false then -- Be sure to include values of false as well. 
            tmp[i] = t1[i]
        else
            tmp[i] = v
        end
    end
    return tmp
end

ns:addError("tableMerge", {inputs = "At least 2 table inputs are required for this function!"})
local function tableMerge(...) 
    if select('#', ...) < 2 then print(select(1,...)) ns:error("tableMerge", "inputs") return end
    local toReturn = {}
    print(select(1,...))
    for j,spellbar in pairs(...) do -- do it this way so we don't actually do anything to the tables passed in
        --print(spellbar.index)
        table.insert(toReturn, spellbar)
        --print("Adding " .. spellbar)
    end
    local n = #toReturn -- get the size of the initial table - it won't get any bigger than this
    for i=2, select('#', ...) do
        local tab = select(i, ...)
        if type(tab) == "table" then --ignore any inputs which aren't tables
                -- we have to iterate with pairs because after the first run, our table will have empty indices
            for j, v in pairs(toReturn) do -- for everything that's common up to this point in iteration:
                --print("Testing " .. v)
                local found = false
                for k,spellbar in pairs(tab) do -- for everything in this new table to check
                    if v == spellbar then        -- if we found that the spellbar exists in this new table, say we found it
                        found = true
                        --print("Found " .. spellbar)
                    end
                end
                if not found then -- if we didn't find this element, then remove it from the common table
                    --print("Removing " .. toReturn[j])
                    toReturn[j] = nil -- set to nil to remove without changing the array
                end
            end
            -- note that the resulting table has a bunch of empty indices after each loop            
        end
    end
    -- now we can do a single cleanup run
    for j = 1, n do -- iterate over the maximum size of the table
        local v = toReturn[j] -- get the value at the current index
        if v then -- if we have a non-nil value    
            toReturn[j] = nil -- remove the value from its current index
               table.insert(toReturn, v) -- put the value in the first empty index
           end
    end
    return toReturn -- return everything that's common
end



-- [[ Built in Validation Functions ]] --

ns.validatorFunctions.defaults.addColor = function(input)
    if type(input) ~= "table" then return end
    if input[1] == true then -- class colored
        if type(input[2])=="number" and type(input[3])=="number" and input[2] >= 0 and input[2] <= 1 and input[3] >= 0 and input[3] <= 1 then
            return true -- woo
        end
    elseif type(input[1])=="number" then
        for i,num in ipairs(input) do
            if type(num)~= "number" or num > 1 or num < 0 then return false end
        end
    end
    return false    
end

ns.validatorFunctions.defaults.addBlendMode = function(input)
    if type(input) == "string" then
        if input == "ADD" or input == "ALPHAKEY" or input == "BLEND" or input == "DISABLE" or input == "MOD" then
            return true
        end
    end
    return false        
end

ns.validatorFunctions.defaults.addLayout = function(input)
    if type(input) ~= "table" then return end
    if input.top and input.bottom and input.top < input.bottom and input.top >= 0 and input.top < 1 and input.bottom > 0 and input.bottom <= 1 then
        return true
    end
    return false        
end

ns.validatorFunctions.defaults.addConfig = function() return true end
ns.validatorFunctions.defaults.addSpellbarConfig = function() return true end
ns.validatorFunctions.defaults.addSpellbarRequirement = function() return true end



-- [[ Module Functions ]] --

-- [[ Module Registration ]] --

ns:addError("addModule", {
    inputs = "Error in module addition. Both a key and an options table are required",
    moduleExists = "That module already exists.",
})
function ns:addModule(key, options)
    if key == "core" then return end
    if not key or not options or type(options) ~= "table" then ns:error("addModule", "inputs") return end
    if ns.modules[key] then ns:error("addModule", "moduleExists") return end
    
    ns.modules[key] = options
    
    local savedModule = EventHorizonSavedVars.modules[key]
    if not savedModule or type(savedModule) ~= "table" then -- This is the first run of the module
        savedModule = {} -- I love Lua
    end

    if savedModule.active or (options.defaultState == true and savedModule.active == nil) then -- if either it's been previously enabled or it's the first run of the module and it defaults on then
        ns:enableModule(key)
    else
        ns:disableModule(key)
    end
    
    options.onInit() -- initialized.
    
    for i,spellbar in ipairs(ns.spellbars.index) do -- Fake the spellbar creation for all bars created up to this point. Any created after this are called automatically by newSpell
        if ns.modules.spellbarHooks.onCreation[key] then
            ns.modules.spellbarHooks.onCreation[key](spellbar)
        end
    end
    
    debug("Added Module " .. key)
    
    return ns.modules[key]
end


-- [[ Module Control ]] --
function ns:enableModule(key)
    if key == "core" then return end
    if ns.modules[key] and not ns.modules[key].active then
        ns.modules[key].onEnable()
        ns.modules[key].active = true
        EventHorizonSavedVars.modules[key].active = true
    end
    
    debug("Enabled Module " .. key)
end

function ns:disableModule(key)
    if key == "core" then return end
    if ns.modules[key] and ns.modules[key].active then
        ns.modules[key].onDisable()
        ns.modules[key].active = false
        EventHorizonSavedVars.modules[key].active = false
    end
    
    debug("Disabled Module " .. key)
end


-- [[ Module API ]] --

ns:addError("registerModuleEvent", {inputs = "one or more of inputs moduleKey, event, handler are not defined"})
function ns:registerModuleEvent(moduleKey, handler, ...)
    if select('#',...) == 0 or not handler or not moduleKey then ns:error("registerModuleEvent", "inputs") return end    
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to register an event. Ensure that the module is enabled") return end
    if moduleKey ~= "core" and not ns.modules[moduleKey].active then ns:error("Module " .. moduleKey .. " is attempting to register event while disabled") return end
    
    if #ns.events == 0 then -- Just to make sure that we have defined the event-handler code already
        ns.frame:SetScript("OnEvent", function(self, event, ...)
            if ns.events[event] then
                for moduleKey,handler in pairs(ns.events[event]) do
                    handler(event, ...)
                end
            end
        end)
    end
    
    local tmp = 1
    local event = ...
    while true do
        event = select(tmp,...)
        if event then
            if not ns.events[event] then
                ns.frame:RegisterEvent(event)
                ns.events[event] = {}
            end
            ns.events[event][moduleKey] = handler
        else
            break
        end
        tmp = tmp + 1
    end
end

-- unregisterModuleEvent:
--   moduleKey: key of module
--   ...: string(s) of event(s) to unregister for moduleKey
ns:addError("unregisterModuleEvent", {inputs = "one or more inputs of moduleKey, event(s) are required and were not provided"})
function ns:unregisterModuleEvent(moduleKey, ...)
    if select('#',...) == 0 or not moduleKey then ns:error("registerModuleEvent", "inputs") return end
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to register an event. Ensure that the module is enabled") return end
    if moduleKey ~= "core" and not ns.modules[moduleKey].active then ns:error("Module " .. moduleKey .. " is attempting to register event while disabled") return end

    local tmp = 1
    local event = ...
    while true do
        event = select(tmp,...)
        if event then
            if ns.events[event][moduleKey] then
                ns.events[event][moduleKey] = nil
                local test
                for _,_ in pairs(ns.events[event]) do
                    test = true
                    break
                end
                if not test then -- if we have no active event handlers
                    ns.frame:UnregisterEvent(event)
                end
            end
        else
            break
        end
        tmp = tmp + 1
    end
end


-- [[ Module Settings API ]] --


-- [[ Set ]] --
function ns:addColor(moduleKey, optionsKey, color, validator)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to add a color. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end
    if moduleKey ~= "core" and not ns.modules[moduleKey].active then ns:error("Module " .. moduleKey .. " is attempting to add a color while disabled. Please ensure that while disabled a module is not attempting to do anything.") return end
    if not optionsKey or type(color) ~= "table" or #color <= 2 or #color > 4 then error("Error in inputs for EventHorizon:addColor. Check the API for valid values/input types") return end
    if ns.colors[optionsKey] then error("Input for optionsKey for EventHorizon:addColor() already exists. Please ensure that you don't have duplicate modules installed in different folders") return end
        
    ns.defaultColors[optionsKey] = color
    ns.colors = mergeDef(ns.defaultColors, ns.cColors, ns.pColors)
    
    ns.validatorFunctions.addColor[optionsKey] = validator or ns.validatorFunctions.defaults.addColor -- add their custom validator function or our default one for color
    
    debug("Added ", color, " to color table")
end

function ns:addBlendMode(moduleKey, optionsKey, default, validator)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to add a blend mode. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end
    if moduleKey ~= "core" and not ns.modules[moduleKey].active then ns:error("Module " .. moduleKey .. " is attempting to add a blend mode while disabled. Please ensure that while disabled a module is not attempting to do anything.") return end
    if not optionsKey or type(default) ~= "string" then error("Error in inputs for EventHorizon:addBlendMode. Check the API for valid values/input types") return end
    if ns.blendModes[optionsKey] then error("Input for optionsKey for EventHorizon:addBlendMode() already exists. Please ensure that you don't have duplicate modules installed in different folders") return end
        
    ns.defaultBlendModes[optionsKey] = default
    ns.blendModes = mergeDef(ns.defaultBlendModes, ns.cBlendModes, ns.pBlendModes)
    
    ns.validatorFunctions.addBlendMode[optionsKey] = validator or ns.validatorFunctions.defaults.addBlendMode
    
    debug("Added ", default, " to blendModes table")
end

function ns:addLayout(moduleKey, optionsKey, default, validator)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to add a layout. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end
    if moduleKey ~= "core" and not ns.modules[moduleKey].active then ns:error("Module " .. moduleKey .. " is attempting to add a layout while disabled. Please ensure that while disabled a module is not attempting to do anything.") return end
    if not optionsKey or type(default) ~= "table" or not (default.top and default.bottom) or type(default.top) ~= "number" or type(default.bottom) ~= "number" then error("Error in inputs for EventHorizon:addLayout. Check the API for valid values/input types") return end
    if ns.layouts[optionsKey] then error("Input for optionsKey for EventHorizon:addLayout already exists. Please ensure that you don't have duplicate modules installed in different folders") return end
        
    ns.defaultLayouts[optionsKey] = default
    ns.layouts = mergeDef(ns.defaultLayouts, ns.cLayouts, ns.pLayouts)
    
    ns.validatorFunctions.addLayout[optionsKey] = validator or ns.validatorFunctions.defaults.addLayout
    
    debug("Added table: ", unpack(default), " to layout table")
end

function ns:addConfig(moduleKey, optionsKey, default, validator)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to add a config option. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end
    if moduleKey ~= "core" and not ns.modules[moduleKey].active then ns:error("Module " .. moduleKey .. " is attempting to add a config option while disabled. Please ensure that while disabled a module is not attempting to do anything.") return end
    if not optionsKey or not default then error("Error in inputs for EventHorizon:addConfig. Check the API for valid values/input types") return end
    if ns.config[optionsKey] then error("Input for optionsKey for EventHorizon:addConfig() already exists. Please ensure that you don't have duplicate modules installed in different folders") return end
    
    ns.defaultConfig[optionsKey] = default
    ns.config = mergeDef(ns.defaultConfig, ns.cConfig, ns.pConfig)
    
    ns.validatorFunctions.addConfig[optionsKey] = validator or ns.validatorFunctions.defaults.addConfig
    
    debug("Added ", default, " to config table")
end

function ns:addSpellbarConfig(moduleKey, optionsKey, default, validator)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to add a spellbar config option. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end
    if moduleKey ~= "core" and not ns.modules[moduleKey].active then ns:error("Module " .. moduleKey .. " is attempting to add a spellbar config option while disabled. Please ensure that while disabled a module is not attempting to do anything.") return end
    if not optionsKey or not default then error("Error in inputs for EventHorizon:addSpellbarConfig. Check the API for valid values/input types") return end
    if ns.spellbarConfig[optionsKey] then error("Input for optionsKey for EventHorizon:addSpellbarConfig() already exists. Please ensure that you don't have duplicate modules installed in different folders") return end
    
    ns.spellbarConfig[optionsKey] = default
    
    ns.validatorFunctions.addSpellbarConfig[optionsKey] = validator or ns.validatorFunctions.defaults.addSpellbarConfig
    
    debug("Added ", default, " to spellbarConfig table")
end

function ns:addSpellbarRequirement(moduleKey, optionsKey, requirementFunction) -- requirementFunction is passed a spellbar. Should return true if the spellbar should be set to active for this requirement
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to add a spellbar requirement option. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end
    if moduleKey ~= "core" and not ns.modules[moduleKey].active then ns:error("Module " .. moduleKey .. " is attempting to add a spellbar requirement option while disabled. Please ensure that while disabled a module is not attempting to do anything.") return end
    if not optionsKey or not default then error("Error in inputs for EventHorizon:addSpellbarRequirement. Check the API for valid values/input types") return end
    if ns.spellbars.required[optionsKey] then error("Input for optionsKey for EventHorizon:addSpellbarRequirement() already exists. Please ensure that you don't have duplicate modules installed in different folders") return end

    ns.spellbars.required[optionsKey] = {}         -- This table stores all of the spellbars that meet the most recent checkRequirements as returned by requirementFunction.
                                                 -- That way if you want to check all of the spellbars that meet a requirement, like say requiredStance = {1,2}, 
                                                 -- then you just have to read the spellbars in ns.spellbars.required[optionsKey][1] and [2] to see.
    
    ns.validatorFunctions.addSpellbarRequirement[moduleKey] = ns.validatorFunctions.addSpellbarRequirement[moduleKey] or {} -- This is so we can enforce the active module constraint for requirement checking
    ns.validatorFunctions.addSpellbarRequirement[moduleKey][optionsKey] = requirementFunction or ns.validatorFunctions.defaults.addSpellbarRequirement
    
end



-- [[ Get ]] --

ns:addError("getColor", {inputs = "color information must be a table of {r,g,b,a} or {true, burn%, alpha} for class colored"})
function ns:getColor(key)
    --print(key, " : ", ns.colors[key])
    if not key or not ns.colors[key] or type(ns.colors[key]) ~= "table" or #ns.colors[key]<3 or #ns.colors[key]>4 then ns:error("getColor", "inputs") return end
    local classColor = RAID_CLASS_COLORS[select(2,UnitClass("player"))]
    if ns.colors[key][1] == true then -- Class coloring/burn/alpha
        local burn = ns.colors[key][2]
        return {classColor.r * burn, classColor.g * burn, classColor.b * burn, ns.colors[key][3]}
    elseif type(ns.colors[key][1]) == "number" then
        return ns.colors[key]
    else
        return {1,1,1,0.5} -- Arbitrary Default is Arbitrary
    end
end

function ns:getBlendMode(key)
    return ns.blendModes[key] or "BLEND"
end

function ns:getLayout(key)
    if ns.layouts[key] then
        return ns.layouts[key]
    else
        return {top = ns.layouts.default.top, bottom = ns.layouts.default.bottom}
    end
end

function ns:getConfig(key)
    return ns.config[key]
end

function ns:getSpellbarConfig(optionsKey)
    return ns.spellbarConfig[optionsKey]
end


-- [[ Modules API - Spellbar Hooks ]] --


function ns:hookSpellbarCreation(moduleKey, handler)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to hook into spellbarCreation. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end

    if not ns.modules.spellbarHooks.onCreation[moduleKey] then
        ns.modules.spellbarHooks.onCreation[moduleKey] = handler
    end
end

function ns:hookSpellbarShow(moduleKey, handler, override)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to hook into spellbarShow. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end

    if not ns.modules.spellbarHooks.onShow[moduleKey] or (ns.modules.spellbarHooks.onShow[moduleKey] and override) then
        ns.modules.spellbarHooks.onShow[moduleKey] = handler
    end        
end

function ns:hookSpellbarHide(moduleKey, handler, override)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to hook into spellbarHide. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end
    
    if not ns.modules.spellbarHooks.onHide[moduleKey] or (ns.modules.spellbarHooks.onHide[moduleKey] and override) then
        ns.modules.spellbarHooks.onHide[moduleKey] = handler
    end        
end

function ns:hookSpellbarSettingsUpdate(moduleKey, handler, override)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to hook into spellbarSettingsUpdate. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end
    
    if not ns.modules.spellbarHooks.onSettingsUpdate[moduleKey] or (ns.modules.spellbarHooks.onSettingsUpdate[moduleKey] and override) then
        ns.modules.spellbarHooks.onSettingsUpdate[moduleKey] = handler
    end            
end


-- [[ Modules API - SavedVars ]] --


function ns:addSavedVariable(moduleKey, var)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to add a saved variable. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end
    
    DB.moduleSavedVars = DB.moduleSavedVars or {}
    
    if not DB.moduleSavedVars[moduleKey] then
        DB.moduleSavedVars[moduleKey] = var
        return true
    end
end

function ns:getSavedVariable(moduleKey)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to get a saved variable. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end

    return DB.moduleSavedVars[moduleKey]
end

function ns:addSavedVariablePerCharacter(moduleKey, var)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to add a saved variable for this character. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end
    
    DBPC.moduleSavedVars = DBPC.moduleSavedVars or {}
    
    if not DBPC.moduleSavedVars[moduleKey] then
        DBPC.moduleSavedVars[moduleKey] = var
        return true
    end
end

function ns:getSavedVariablePerCharacter(moduleKey)
    if moduleKey ~= "core" and not ns.modules[moduleKey] then ns:error("Module " .. moduleKey .. " is not recognized and is attempting to get a saved variable for this character. Ensure that the module is enabled and registered with EventHorizon before doing anything else!") return end

    return DBPC.moduleSavedVars[moduleKey]
end


-- [[ Temp Textures ]] --

function ns:getTempTexture(parent)
    local numFree, numUsed = #textures.free, #textures.used
    local texture
        if textures.free[numFree] then -- Check if we have a free texture to use. (Pull from the end to make it easy)
        texture = textures.free[numFree]
        textures.free[numFree] = nil
        table.insert(textures.used, texture)
        print("Gave premade texture ", texture.name)
    else -- We have to make a new texture
        texture = ns.frame:CreateTexture("EventHorizon_Texture"..(numFree + numUsed + 1))
        texture.name = "EventHorizon_Texture"..(numFree + numUsed + 1)
        table.insert(textures.used, texture)
        print("Made new texture ", texture.name)
    end
    
    texture:Hide()
    texture:SetParent(parent or ns.frame)
    
    return texture    
end

function ns:freeTempTexture(texture)
    
    local found
    
    for i,v in ipairs(textures.used) do
        if v == texture then
            table.insert(textures.free, texture) -- Free the texture up
            table.remove(textures.used, i)
            print("Freed up texture ", texture.name)
            texture:Hide() -- Hide it.
            texture:ClearAllPoints() -- Unset it's location settings
            return
        end
    end
    
    print("Attempting to remove a non used texture?")    
end


-- [[ Spellbar Functions ]] -- 


function ns:addSpellUpdate(spellbar, key, fxn)
    spellbar.update = spellbar.update or {}
    if not spellbar.updateCount or spellbar.updateCount == 0 then -- Either it's first init or we've already disabled the update script to save proc time
        spellbar:SetScript("OnUpdate", function(self, elapsed, ...)
            for k,fxn in pairs(spellbar.update) do
                fxn(self, elapsed)
            end                
        end)
    end
    spellbar.update[key] = fxn
    spellbar.updateCount = (spellbar.updateCount or 0) + 1
    spellbar.lastUpdateTime = 0
end

function ns:removeSpellUpdate(spellbar, key)
    if spellbar.update[key] then
        if spellbar.updateCount == 1 then -- Save proc time when no updates for bar active
            spellbar:SetScript("OnUpdate", nil)
        end
        spellbar.update[key] = nil
        spellbar.updateCount = spellbar.updateCount - 1
    end
end

-- getPositionByTime(t)
--  t: time in seconds away from 0 to get the position of. -3 would return the position of the beginning of the spellbar by default config. Use this in conjunction with a frame anchored to ns.barAnchor to put stuff on the spellbar.
function ns:getPositionByTime(t)
    local past, future, width = ns.config.past, ns.config.future, ns.spellbars.active[1].bar:GetWidth()
    -- each pixel is (future-past)/width seconds long
    -- the beginning of the bar is the far left, so an input of -3 should return an offset of 0
    -- a value of 0 would equal 3 s in the future if we recenter the bar around t = -3
    t = t > future and future or t < past and past or t -- limit the return to actually be in bounds
    return t*(width/(future-past)) + (width/(future-past))*-past
end

ns:addError("newSpell", {
    cooldown = "Class Config: cooldown should be a spellID or a table of spellIDs of which the spellbar will show the longest",
    debuff = "Class Config: debuff should be a spellID or a table of a spellID and the unhasted time between ticks or a table of multiple tables of a spellID and unhasted time between ticks. EventHorizon will show the shortest", 
    buff = "Class Config: buff should be a spellID or a table of a spellID and the unhasted time between ticks or a table of multiple tables of a spellID and unhasted time between ticks. EventHorizon will show the shortest", 
    unitID = "Class Config: unitID should be either a unitID or a table of 2 unitIDs representing first the unitID EH should check for debuffs, and second for buffs",
    stance = "Class Config: stance should be either a number or a table of numbers representing the stance the player must be in one of for the spellbar to show",
    tree = "Class Config: tree should be either a number or a table of numbers which represents the spec which should be active to show",
    cast = "Class Config: cast should be either a spellID or a table of spellIDs that the spellbar will show as casts",
    talent = "Class Config: talent should be a number or a table of numbers which represents the talents, one of which is required to be learned for the spellbar to show",
    requiredLevel = "Class Config: level should be a number between 0 and GetMaxPlayerLevel which the player must be at least that level for the spellbar to show",
})
function ns:newSpell(spellConfig)
    
    local spellbar = CreateFrame("Frame") -- make the spellbar frames and textures
    spellbar.icon = CreateFrame("Frame",nil,spellbar)
    spellbar.bar = CreateFrame("Frame",nil,spellbar)    -- bar on which ticks/debuff/buff/cast are anchored. Width is config.width - iconWidth
    spellbar.bar.texture = spellbar.bar:CreateTexture()
    spellbar.icon.texture = spellbar.icon:CreateTexture()
    spellbar.icon.stacks = spellbar.icon:CreateFontString()

    spellbar.icon:SetPoint("TOPLEFT", spellbar, "TOPLEFT") -- inheirits height settings from spellbar
    spellbar.icon:SetPoint("BOTTOMLEFT", spellbar, "BOTTOMLEFT") 
    
    spellbar.icon.stacks:SetPoint(ns.config.stackPosition[1], spellbar.icon, ns.config.stackPosition[1], ns.config.stackPosition[2], ns.config.stackPosition[3]) -- slightly offset inside the icon
    spellbar.icon.stacks:SetJustifyH("RIGHT")
    
    spellbar.bar:SetPoint("BOTTOMRIGHT", spellbar, "BOTTOMRIGHT")     -- inheirits height settings from spellbar.
    spellbar.bar:SetPoint("TOPLEFT", spellbar, "TOPLEFT", self.config.icons and (self.config.iconWidth < 1 and (self.config.width-2*self.config.padding)*self.config.iconWidth or self.config.iconWidth)+1 or 0, 0) -- inheirits width settings natually from width of spellbar and icon
    
    spellbar.bar.texture:SetAllPoints(spellbar.bar)
    spellbar.icon.texture:SetAllPoints(spellbar.icon)

    spellbar.bar.texture:SetDrawLayer("BACKGROUND")
    spellbar.bar:SetFrameStrata("LOW")
    spellbar.icon.texture:SetDrawLayer("BORDER")
    
    spellbar.updating = {} -- helper tables indexed by type of bar being updated/updating
    spellbar.update = {}
    
    spellbar.iconManager = {}
    
    
    spellbar.spellConfig = spellConfig -- spellbar specific settings
    

    spellbar:SetScript("OnHide", function()
        for moduleKey, fxn in pairs(ns.modules.spellbarHooks.onHide) do
            if ns.modules[moduleKey].active then
                fxn(spellbar)
            end
        end
        spellbar.lastUpdateTime = GetTime()
    end)
    
    spellbar:SetScript("OnShow", function()
        for moduleKey, fxn in pairs(ns.modules.spellbarHooks.onShow) do
            if ns.modules[moduleKey].active then
                fxn(spellbar)
            end
        end
        for k,fxn in pairs(spellbar.update) do -- When the spellbar's hidden we have some fun stuff to deal with since the frame's no longer updated. This fudges it :P
            fxn(self, GetTime() - spellbar.lastUpdateTime)
        end
    end)
    
    spellbar.index = #ns.spellbars.index
    table.insert(ns.spellbars.index, spellbar)
    
    for moduleKey, moduleHandler in pairs(ns.modules.spellbarHooks.onCreation) do -- if the player adds a new bar in the config menu, or somehow a module loaded before first creation..
        if ns.modules[moduleKey].active then
            moduleHandler(spellbar)
        end
    end
end

ns:addError("updateSpellbarSettings", {inputs = "Input spellbar was either not defined or not initialized yet."})
function ns:updateSpellbarSettings(spellbar)
    if not spellbar or not spellbar.spellConfig then ns:error("updateSettings", "inputs") return end
    
    local c = ns.config
    local numactive = (#ns.spellbars.active>0 and #ns.spellbars.active or 1)
    
    spellbar:SetWidth(c.width - 2*c.padding)
    spellbar:SetHeight( round((c.height - 2*c.padding)/ numactive - c.barSpacing ) )
    
    if ns.config.icons then
        spellbar.icon:Show()
        spellbar.icon:SetWidth(c.iconWidth < 1 and (c.width-2*c.padding)*c.iconWidth or c.iconWidth)

        if c.stackFont then
            spellbar.icon.stacks:SetFont(c.stackFont,c.stackSize)
            if c.stackShadow then
                spellbar.icon.stacks:SetShadowColor(unpack(c.stackShadow))
                spellbar.icon.stacks:SetShadowOffset(unpack(c.stackShadowOffset))
            end
        else
            spellbar.icon.stacks:SetFontObject('NumberFontNormalSmall')
        end
        
        spellbar.icon.stacks:SetPoint(ns.config.stackPosition[1], spellbar.icon, ns.config.stackPosition[1], ns.config.stackPosition[2], ns.config.stackPosition[3]) -- slightly offset inside the icon
        spellbar.icon.stacks:SetVertexColor(c.stackColor and unpack(c.stackColor) or unpack({1,1,1,1}))
        
        updateIcon(spellbar)
    else
        spellbar.icon:Hide()
    end
    
    spellbar.bar.texture:SetTexture(ns.config.barTexture)
    spellbar.bar.texture:SetVertexColor(unpack(ns:getColor("barBackground")))
    spellbar.bar.texture:SetBlendMode(ns.blendModes.barBackground)
    
    for moduleKey, moduleHandler in pairs(ns.modules.spellbarHooks.onSettingsUpdate) do 
        if ns.modules[moduleKey].active then
            moduleHandler(spellbar)
        end
    end
end

-- [[ Spellbar Icon Function ]] --

-- updateIcon:
--  Updates the icon/stack settings of the icon on the spellbar self
--   self: spellbar reference
--   spellID: spellID to set icon to
--   stacks: number to display on the stacks counter
ns:addError("updateIcon", {inputs = "input spellBar was not of correct type or not all defined"})
function ns:updateSpellbarIcon(spellbar, spellID, stacks)
    if not spellbar or not spellbar.spellConfig then ns:error("updateIcon", "inputs") return end
    --Quick Note: This assumes that the spellbar's dims have been updated and are correct
    
    if not ns.config.icons then return end -- don't do anything if they've disabled icons
    
    
    local left,right,top,bottom = 0.07, 0.93, 0.07, 0.93
    local c = ns.config
    local height, width = spellbar:GetHeight(), (c.iconWidth < 1 and c.width* c.iconWidth or c.iconWidth)
    if height > width then    -- icon is taller than it is wide
        left = left + (1-(width/height))/2
        right = right - (1-(width/height))/2
    else -- vars.barheight = height of frame. barheight2 = icon width
        top = top + (1-(height/width))/2
        bottom = bottom - (1-(height/width))/2
    end

    if spellID then
        if type(spellID) == "string" then -- If they passed newSpells' config option icon a string, use that
            spellbar.icon.texture:SetTexture(spellID)
        else
            spellbar.icon.texture:SetTexture(select(3,GetSpellInfo(spellID)))
        end
        spellbar.icon.texture:SetTexCoord(left, right, top, bottom)
    end
    if stacks then
        spellbar.icon.stacks:SetText(stacks > 0 and "" ..stacks or "")
        spellbar.icon.stacks:SetPoint(ns.config.stackPosition[1], spellbar.icon, ns.config.stackPosition[1], ns.config.stackPosition[2], ns.config.stackPosition[3])
    end
    
    
end

-- getIconForSpellbar
--  Returns either the spellID of the currently shown icon for spellbar, or what the default should be if there is no active icon
function ns:getIconForSpellbar(spellbar)
    local c = spellbar.spellConfig
    
    if spellbar.currentIcon then
        return spellbar.currentIcon
    end
    
    local iconOrder = ns:getConfig("iconDisplayOrder") -- 1 is first display, Nth is last display
    for orderNum, moduleKey in pairs(iconOrder) do
        if spellbar.iconManager[moduleKey] then
            return spellbar.iconManager[moduleKey]() -- return the highest display order spellID to set for the icon
        end
    end
end


-- [[ EventHorizon Functions ]] --

-- checkRequirements: 
--  Sets all frames which meet current active requirements active. 
function ns:checkRequirements()
    table.wipe(ns.spellbars.active)
    --ns.validatorFunctions.addSpellbarRequirement[optionsKey]
    for i,spellbar in ipairs(ns.spellbars.index) do
        local active = true
        for moduleKey, requirements in pairs(ns.validatorFunctions.addSpellbarRequirement) do
            if ns.modules[moduleKey].active then-- make sure the module that added the requirements actually active
                for optionsKey, requirementFunction in pairs(requirements) do
                    if not requirementFunction(spellbar) then -- One of the requirements setup for this bar were not met, so don't show this spellbar
                        active = nil
                    else
                        table.insert(ns.spellbars.required[optionsKey], spellbar) -- add it to the list of spellbars which matched this requirement, in case someone wants it for some reason
                    end
                end
            end
        end
        if active then -- none of the spellbars were reported as should be hidden, so add it to our active list
            table.insert(ns.spellbars.active, spellbar)
        end
    end
    table.sort(ns.spellbars.active, function(a,b) return a.index < b.index end) -- sort them by index so they retain some resemblance of order.
end


function ns:updateSettings() 
    updating = true
    local f = ns.frame
    
    f:SetWidth(ns.config.width)
    f:SetHeight( ((#ns.spellbars.active>0 and #ns.spellbars.active or 1) > ns.config.minBars and ns.config.height or (#ns.spellbars.active>0 and #ns.spellbars.active or 1)*(ns.config.height/ (#ns.spellbars.active>0 and #ns.spellbars.active or 1))) - ns.config.barSpacing)
    if ns.config.backdrop then -- make backdrop settings
        f.texture = f.texture or CreateFrame("Frame") -- make sure we have a backdrop texture
        f.texture:SetBackdrop({
            bgFile = ns.config.texture,
            edgeFile = ns.config.border,
            tile = true,
            tileSize = 32,
            edgeSize = ns.config.edgeSize,
            insets = ns.config.inset,            
        })
        f.texture:ClearAllPoints() -- set padding
        f.texture:SetPoint("TOPLEFT", f, "TOPLEFT")
        f.texture:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
        f.texture:SetBackdropColor(unpack(ns:getColor("bg")))
        f.texture:SetBackdropBorderColor(unpack(ns:getColor("border")))
        --f.texture:SetAlpha(ns.colors.bg[4])
        f.texture:SetFrameStrata("LOW")
        
    end -- end backdrop settings
    
    --start spellbar settings
    local prevSpellbar
    barSpacing = ns.config.barSpacing
    for i,spellbar in ipairs(ns.spellbars.active) do -- now we set up the active bars. These are in order of creationIndex
        spellbar.updateSettings(spellbar)
        spellbar:Show()
        if i==1 then        
            spellbar:ClearAllPoints()
            spellbar:SetPoint("TOPLEFT", f, "TOPLEFT", ns.config.padding, -ns.config.padding)
            spellbar:SetPoint("TOPRIGHT", f, "TOPRIGHT", -ns.config.padding, -ns.config.padding)
            
        else
            spellbar:ClearAllPoints()
            spellbar:SetPoint("TOPLEFT", prevSpellbar, "BOTTOMLEFT", 0, -barSpacing)
            spellbar:SetPoint("TOPRIGHT", prevSpellbar, "BOTTOMRIGHT", 0, -barSpacing)
        end
        
        spellbar.updateIcon(spellbar, getIconForSpellbar(spellbar), 0) 
        -- Default icon is the first cast, then the first debuff, then the first cooldown, then the first playerbuff. If it's not one of these then what the fuck is this spellbar for :3
        
        spellbar.bar:SetPoint("TOPLEFT", spellbar, "TOPLEFT", self.config.icons and (self.config.iconWidth < 1 and (self.config.width-2*self.config.padding)*self.config.iconWidth or self.config.iconWidth)+1 or 0, 0) -- inheirits width settings natually from width of spellbar and icon
        
        spellbar.cast:SetHeight(spellbar:GetHeight() * (ns:getLayout("cast")[2]-ns:getLayout("cast")[1]))
        
        -- spellbar.cooldown:SetHeight(spellbar:GetHeight() * (ns:getLayout("cooldown")[2]-ns:getLayout("cooldown")[1]))
        
        -- spellbar.debuff:SetHeight(spellbar:GetHeight() * (ns:getLayout("debuff")[2]-ns:getLayout("debuff")[1]))
        
        -- spellbar.buff:SetHeight(spellbar:GetHeight() * (ns:getLayout("buff")[2]-ns:getLayout("buff")[1]))
        
        

        spellbar.cast:SetPoint("TOPLEFT", ns.frame.barAnchor, "TOPLEFT", ns:getPositionByTime(0),0)
        spellbar.cast:SetPoint("BOTTOMLEFT", ns.frame.barAnchor, "BOTTOMLEFT", ns:getPositionByTime(0),0)
        
        prevSpellbar = spellbar
        
        -- Module Hooks:
    
        for moduleKey, fxn in pairs(spellbarHooks.onSpellbarSettingsUpdate) do
            if ns.modules[moduleKey].active then
                fxn(spellbar)
            end
        end

    end
    
    -- end spellbar settings
    

    --store the width of the spellbar.bar
    ns.frame.barAnchor:SetPoint("TOPLEFT", ns.frame, "TOPLEFT", ns.config.padding + (self.config.icons and (self.config.iconWidth < 1 and (self.config.width-2*self.config.padding)*self.config.iconWidth or self.config.iconWidth)+1 or 0), 0)
    ns.frame.barAnchor:SetPoint("BOTTOMLEFT", ns.frame, "BOTTOMLEFT",  ns.config.padding + (self.config.icons and (self.config.iconWidth < 1 and (self.config.width-2*self.config.padding)*self.config.iconWidth or self.config.iconWidth)+1 or 0), 0)
    
    updating = nil
end

function ns:applySettings()
    ns:checkRequirements()
    
    for i,spellbar in ipairs(ns.spellbars.index) do
        spellbar:Hide()
    end
    for i,spellbar in ipairs(ns.spellbars.active) do
        spellbar:Show()
    end
    
    if #ns.spellbars.active > 0 then -- make sure we actually have bars to show.
        ns.frame:Show()
        ns.shown = true
        ns:updateSettings()
    else
        ns.shown = nil -- no need to update settings if they can't even see it
        ns.frame:Hide()
    end
end




--------------------------------------
-- [[    Addon Initialization    ]] --
--------------------------------------

ns:registerModuleEvent("core", function(...)
    class = select(2,UnitClass('player'))
    
    LoadAddOn("EventHorizon_".. class:sub(1,1)..class:sub(2):lower())
    EventHorizon:InitializeClass()
    
    ns:registerModuleEvent("core", function(...)
        if not addonInit then -- make sure that we're not waiting on the addon to load still (Stupid f'ing GetShapeshiftForm)
            ns:applySettings()
        end
    end,
    "UPDATE_SHAPESHIFT_FORM",
    "UPDATE_SHAPESHIFT_FORMS",
    "PLAYER_SPECIALIZATION_UPDATE",
    "PLAYER_SPECIALIZATION_CHANGED",
    "PLAYER_LEVEL_UP",
    "GLYPH_ADDED",
    "GLYPH_ENABLED",
    "GLYPH_REMOVED",
    "GLYPH_UPDATED",
    "GLYPH_DISABLED"
    )

    ns:applySettings() -- Since modules load after EventHorizon loads they just do all their stuff after we go on with our business.
    
    addonInit = nil
end,
"PLAYER_ENTERING_WORLD")


-- [[ Default Configuration Tables ]] --


ns.defaultConfig = {
    -- Position
    anchor = {"CENTER", UIParent, "CENTER"},

    --Bar Options
    height = 300,                -- Height of the total frame. EH will now automatically resize the height of spellBars depending on how many are active
    width = 500,                -- Width of the total frame. (This includes the actual spellBar, as well as the icon) 
    barSpacing = 0,              -- Amount of space vertically between spellBars
    minBars = 3,                 -- If there are less than or equal to minBars shown, Eh will resize the bars as if there were minBars actually shown. In other words, the total frame will become shorter, rather than the bars becoming larger. You can also think of it like setting an upper-limit on how tall a spellBar can be. (that being height/minBars)
    texture = "Interface\\Addons\\EventHorizon\\Smooth",
                                -- If a path to a texture, EH will use that. If a table of {r, g, b, a}, EH will use that.
    barTexture = "Interface\\Addons\\EventHorizon\\Smooth", -- Path to a texture to use for the background of individual spellbars.

    textureAlphaMultiplier = 2,    -- Textures generally appear darker than a solid color. The alpha value is multiplied by this to counteract this effect
    
    --Icon Options
    icons = true,                 -- If set to false or nil, EH will not show icons and only show the spellBar.
    iconWidth = 0.1,            -- Width of the icon. If <1 EH assumes this is a percent of the width. If >1 EH will set it as a pixel value.
    
    --Stack Indicator Options
    stackFont = false,            -- If this is set to a font path, EH will use that font for the stack indicator
    stackSize = false,            -- Sets the font size of the indicator if set to a number
    stackOutline = false,         -- Sets the outline of the font. Valid: "OUTLINE", "THICKOUTLINE", "MONOCHROME"
    stackColor = false,            -- Sets the color of the font. {R, G, B, A}
    stackShadow = false,         -- Sets whether there should be a shadow effect on the text
    stackShadowOffset = false,    -- Sets the offset from the text the shadow should be {x,y}
    stackPosition = {"BOTTOMRIGHT", -2, 2},        -- Sets the position and offset of the stack Indicator relative to the icon. { RelativePoint, xOffSet, yOffSet } Default: {"BOTTOMRIGHT", -2, 2}
    
    --Backdrop Options
    backdrop = true,            -- Whether to setup a backdrop (true) or not (false)
    texture = "Interface\\ChatFrame\\ChatFrameBackground",
                                -- Path to the texture to use as the backdrop
    border = "Interface\\Tooltips\\UI-Tooltip-Border",
                                -- Path to the texture to use as a border
    padding = 2,                 -- Extra space (in pixels) between the barFrames/Icons and the backdrop
    edgeSize = 8,                 -- Thickness of the frame's border. You'll have to mess around with this if you change the border texture to make it look right
    inset = {top = 2, bottom = 2, left = 2, right = 2},
                                -- Changes the distance between the border texture and the backdrop texture. Moves the backdrop in x pixels.
    
    --Time Settings
    past = -3,                    -- Time in the past in seconds to show to the left of the now line (As a negative number)
    future = 12,                 -- Time in the future to show to the right of the now line
    futureLog = false,            -- For the future. I may implement a log scale for the future if enabled. NYI
    
}
ns.defaultColors = {
    debuffTick = {true,Priest and 0.7 or 1,1},            -- Tick markers. Default = {true,Priest and 0.7 or 1,1} (class colored, dimmed a bit if you're a Priest, opaque)
    buffTick = {true,Priest and 0.7 or 1,1},            -- Tick markers. Default = {true,Priest and 0.7 or 1,1} (class colored, dimmed a bit if you're a Priest, opaque)
    channelTick = {0,1,0.2,0.25},                    -- Tick markers for channeled spells. Default is the same as casting.
    cast = {0,1,0.2,0.25},                            -- Casting bars. Default = {0,1,0,0.25} (green, 0.25 unmodified alpha)
    castLine = {0,1,0,0.3},                        -- The end-of-cast line, shown for casts and channels over 1.5 seconds. Default = {0,1,0,0.3} (green, 0.3 unmodified alpha)
    cooldown = {0.6,0.8,1,0.3},                        -- Cooldown bars. Default = {0.6,0.8,1,0.3} (mute teal, 0.3 unmodified alpha)
    debuff = {true,Priest and 0.7 or 1,0.3},    -- YOUR debuff bars. Default = {true,Priest and 0.7 or 1,0.3} (class colored, dimmed a bit if you're a Priest, 0.3 unmodified alpha)
    buff = {true,Priest and 0.7 or 1,0.3},    -- Buff bars. Default = {true,Priest and 0.7 or 1,0.3} (class colored, dimmed a bit if you're a Priest, 0.3 unmodified alpha)
    nowLine = {1,1,1,0.3},                            -- The "Now" line.
    bg = {0,0,0,0.6},                 -- Color of the frame's background. Default = {0,0,0,0.6} (black, 60% opacity)
    barBackground = {1,1,1,0.2},           -- Color of the background of individual bars
    border = {1,1,1,1},                        -- Color of the frame's border. Default = {1,1,1,1} (white, fully opaque)
}
ns.defaultBlendModes = {
    debuffTick = "ADD",        
    buffTick = "ADD",
    channeltick = "ADD",                    
    cast = "BLEND",                -- If cast is set to show a line, it inheirits this.                                
    cooldown = "ADD",                        
    debuff = "ADD",    
    buff = "ADD",    
    nowline = "ADD",
    bg = "BLEND",                 
    barBackground = "BLEND",          
    border = "BLEND",        
}
ns.defaultLayouts = {
    debuffTick = {                -- debuff Tick markers.
        top = 0,
        bottom = 0.12,
    },
    buffTick = {                -- buff tick markers. Lets you have debuffs and buffs on the same bar
        top = 0.88,
        bottom = 1,
    },
    channelTick = {
        top = 0,
        bottom = 0.12,
    },
    cast = {                    -- If cast is set to show a line, it inheirits this.        
        top = 0,
        bottom = 1,
    },                                
    cooldown = {
        top = 0,
        bottom = 1,
    },                            
    debuff = {
        top = 0,
        bottom = 1,
    },    
    buff = {
        top = 0,
        bottom = 1,
    },        
    nowline = {
        top = 0,
        bottom = 1,
    },    
    barBackground = {
        top = 0,
        bottom = 1,
    },             
    recastZone = {                -- The recast line for spells like Vampiric Touch and Immolate.
        top = 0,
        bottom = 0.25,
    },
    cantCast = {                -- The blank section below the recast line.
        top = 0.25,
        bottom = 1,
    },
    default = {                    -- Just about everything else.
        top = 0,
        bottom = 1,
    },
}
ns.config = mergeDef(ns.defaultConfig, ns.cConfig, ns.pConfig) -- default: default. c = config.lua config table. p = myConfig.lua config table
ns.colors = mergeDef(ns.defaultColors, ns.cColors, ns.pColors)
ns.blendModes = mergeDef(ns.defaultBlendModes, ns.cBlendModes, ns.pBlendModes)
ns.layouts = mergeDef(ns.defaultLayouts, ns.cLayouts, ns.pLayouts)






