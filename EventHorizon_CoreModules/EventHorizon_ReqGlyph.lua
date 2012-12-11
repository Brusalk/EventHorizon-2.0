local ns = EventHorizon

local DEBUG = false

local t = {}

local blizzPrint = print
local function print(...)
	if DEBUG then
		blizzPrint(...)
	end
end

local moduleKey = "EventHorizon_ReqGlyph" -- Name of the game

-- [[ Helper Functions ]] --

local function requirementCheck(spellbar)
	local r = ns:getSpellbarConfig(spellbar, "requiredGlyph")
	
	if not r then return true end
	
	if type(r)=="number" then
		local self = t
		
		self.glyphs = {}
		
		for i = 1,6 do
			local enabled,_,_,glyphID,_ = GetGlyphSocketInfo(i)
			if enabled and glyphID then
				self.glyphs[i] = glyphID
			else
				self.glyphs[i] = nil
			end
		end

		for i,glyphID in ipairs(self.glyphs) do
			if r == glyphID then
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
	"GLYPH_ADDED",
	"GLYPH_ENABLED",
	"GLYPH_REMOVED",
	"GLYPH_UPDATED",
	"GLYPH_DISABLED"
	)
	ns:applySettings()	
end


-- [[ onDisable ]] --

local function disable()

	ns:unregisterModuleEvent(moduleKey, 
	"GLYPH_ADDED",
	"GLYPH_ENABLED",
	"GLYPH_REMOVED",
	"GLYPH_UPDATED",
	"GLYPH_DISABLED"
	)
	ns:applySettings()	
end


-- [[ onInit ]] --

local function init()
	
		ns:addSpellbarRequirement(moduleKey, "requiredGlyph", requirementCheck)
	
end





-- [[ Registering with EH ]] --

ns:addModule(moduleKey, {
	description = "Glyph Requirement for EventHorizon. By Brusalk.",
	defaultState = true, -- On by default
	onDisable = disable,
	onEnable = enable,
	onInit = init,
	moduleTable = t,
})