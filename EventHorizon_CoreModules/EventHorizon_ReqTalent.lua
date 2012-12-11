local ns = EventHorizon

local DEBUG = false

local t = {}

local blizzPrint = print
local function print(...)
	if DEBUG then
		blizzPrint(...)
	end
end

local moduleKey = "EventHorizon_ReqTalent" -- Name of the game

-- [[ Helper Functions ]] --

local function requirementCheck(spellbar)

	local r = ns:getSpellbarConfig(spellbar, "requiredTalent")
	
	if not r then return true end
	
	if type(r)=="number" then
		r = {r}
	end
	
	if type(r)=="table" then
		for i,talentNum in ipairs(r) do
			if talentNum > 0 and talentNum <= 18 then
				local name, _, _, _, sel, available = GetTalentInfo(talentNum)
				if sel and not available then  -- Selected, so talent is chosen (outlined) and not available, which means that the talent tier is either not level-appropriate OR the player has talents selected in the tier already.
					return true
				end
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
	"PLAYER_TALENT_UPDATE",
	"TALENTS_INVOLUNTARILY_RESET"
	)
	ns:applySettings()	
	
end


-- [[ onDisable ]] --

local function disable()

	ns:unregisterModuleEvent(moduleKey, 
	"ACTIVE_TALENT_GROUP_CHANGED",
	"PLAYER_TALENT_UPDATE",
	"TALENTS_INVOLUNTARILY_RESET"
	)
	ns:applySettings()	
	
end


-- [[ onInit ]] --

local function init()
	
		ns:addSpellbarRequirement(moduleKey, "requiredTalent", requirementCheck)
	
end





-- [[ Registering with EH ]] --

ns:addModule(moduleKey, {
	description = "Talent Requirement for EventHorizon. By Brusalk.",
	defaultState = true, -- On by default
	onDisable = disable,
	onEnable = enable,
	onInit = init,
	moduleTable = t,
})