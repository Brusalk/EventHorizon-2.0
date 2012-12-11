local ns = EventHorizon

local DEBUG = false

local blizzPrint = print
local function print(...)
	if DEBUG then
		blizzPrint(...)
	end
end

local moduleKey = "EventHorizon_GCD" -- Name of the game

-- [[ GCD Locals ]] --
local lastGCDTime = 0
local t = {}
local gcdTextures = {}


t.gcd = CreateFrame("frame") -- GCD Anchor Frame

-- [[ Variables ]] --
local secondsPerPixel = 0
local past, future, width, timeElapsed
local start, duration

local GetSpellCooldown = GetSpellCooldown

-- [[ Helper Functions ]] --
local function onUpdateGCD(self,elapsed)
	timeElapsed = timeElapsed + elapsed
	if timeElapsed >= secondsPerPixel then -- Limit the hard stuff to only when we have to move at least 1 pixel. 
		if not(t.gcd.active) then
			t.gcd:SetScript("OnUpdate", nil)
			return t.gcd:Hide()
		end
		duration = duration - timeElapsed
		timeElapsed = 0
		local width = ns:getPositionByTime(duration)
		if duration > 0 then
			--print(width)
			t.gcd:SetWidth(width)		
		else
			t.gcd.active = nil
		end
	end
end

local function checkGCD()
	
	start, duration = GetSpellCooldown(ns.config.gcdSpellID)
	if start and duration and duration > 0 then
		past, future, width, timeElapsed = ns.config.past, ns.config.future, ns.config.width - (ns.config.icons and (ns.config.iconWidth < 1 and (ns.config.width-2*ns.config.padding)*ns.config.iconWidth or ns.config.iconWidth)+1 or 0), 0
		secondsPerPixel = secondsPerPixel > 0 and secondsPerPixel or (future-past)/width
		
		-- t.gcd:SetWidth(ns:getPositionByTime(duration)) -- Taro: This is already set in onupdate, no need to initialize
		
		if not(t.gcd.active) then
			print("Starting GCD")
			t.gcd.active = true
			
			t.gcd:Show()
			t.gcd:SetScript("OnUpdate", onUpdateGCD) -- Taro: Save memory by using function ref instead of creating an anonymous function every time
		end
	else
		t.gcd.active = nil -- Taro: active == nil will clear the onupdate next time it cycles.
	end
end

local function updateSettings(spellbar)
	print("EH_GCD: Updatin' dem settins")
	local barHeight = spellbar:GetHeight()
	local layout = ns:getLayout("gcd")
	local gcdBar = ns:getConfig("gcdBar")
	gcdTextures[spellbar]:ClearAllPoints()
	gcdTextures[spellbar]:SetPoint("TOP", spellbar, "TOP", 0, -barHeight*layout.top)
	gcdTextures[spellbar]:SetPoint("BOTTOM", spellbar, "BOTTOM", 0, barHeight*(1-layout.bottom))
	
	if gcdBar then
		print("Using GCD BAR")
		gcdTextures[spellbar]:SetPoint("LEFT", spellbar.nowLine, "LEFT")
		gcdTextures[spellbar]:SetPoint("RIGHT", t.gcd, "RIGHT")
	else
		gcdTextures[spellbar]:SetPoint("RIGHT", t.gcd, "RIGHT")
		gcdTextures[spellbar]:SetWidth(1)
	end
	
	gcdTextures[spellbar]:SetTexture(unpack(ns:getColor("gcd")))
	gcdTextures[spellbar]:SetBlendMode(ns:getBlendMode("gcd"))

end


-- [[ onEnable ]] --

local function enable()
	-- Register for SPELL_UPDATE_COOLDOWN
	print("EH_GCD: Registered Event")
	ns:registerModuleEvent(moduleKey, checkGCD,
	"SPELL_UPDATE_COOLDOWN"
	)
	
	for i,v in pairs(ns.spellbars.active) do
		updateSettings(v)
	end
	
	t.gcd:Hide()
end


-- [[ onDisable ]] --

local function disable()
	print("Unregistered Event")
	-- Unregister SPELL_UPDATE_COOLDOWN
	ns:unregisterModuleEvent(moduleKey, "SPELL_UPDATE_COOLDOWN")
end


-- [[ onInit ]] --

local function init()
	
	t.gcd:SetPoint("TOPLEFT", ns.barAnchor, "TOPLEFT")
	t.gcd:SetPoint("BOTTOMLEFT", ns.barAnchor, "BOTTOMLEFT")
	--[[t.gcd:SetScript("OnShow", function()
		for spellbar, gcdTexture in pairs(gcdTextures) do
			gcdTexture:Show()
		end
	end)
	t.gcd:SetScript("OnHide", function()
		for spellbar, gcdTexture in pairs(gcdTextures) do
			gcdTexture:Hide()
		end
	end)--]]
	t.gcd:SetWidth(1)
	
	-- Add our GCD options to the right tables
	ns:addColor(moduleKey, "gcd", {1, 1, 1, 0.5})
	
	ns:addBlendMode(moduleKey, "gcd", "BLEND")
	
	ns:addBlendMode(moduleKey, "gcdLine", "ADD")
	
	ns:addLayout(moduleKey, "gcd", {
		top = 0,
		bottom = 1,
	})
	
	ns:addConfig(moduleKey, "gcdBar", false, function(input)
		return type(input)=="boolean"
	end)
	
	-- Saved Vars
	
	
	-- Hook into spellbar creation
	ns:hookSpellbarCreation(moduleKey, function(spellbar)
		print("Created GCD Stuff")
		gcdTextures[spellbar] = t.gcd:CreateTexture() -- Make a new GCD texture for this spellbar.
		updateSettings(spellbar)
		gcdTextures[spellbar]:SetDrawLayer("BORDER", 5) -- Put it over everything
	end)
	
	ns:hookSpellbarShow(moduleKey, function(spellbar)
		updateSettings(spellbar)
		gcdTextures[spellbar]:Show()
	end)
	ns:hookSpellbarHide(moduleKey, function(spellbar)
		gcdTextures[spellbar]:Hide()
	end)
	
	-- Hook into spellbar appearance update
	ns:hookSpellbarSettingsUpdate(moduleKey, updateSettings)
	
end





-- [[ Registering with EH ]] --

ns:addModule(moduleKey, {
	description = "GCD Functionality for EventHorizon. By Brusalk.",
	defaultState = true, -- On by default
	onDisable = disable,
	onEnable = enable,
	onInit = init,
	moduleTable = t,
})