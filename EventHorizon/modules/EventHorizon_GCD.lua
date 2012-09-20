local ns = EventHorizon

local moduleKey = "EventHorizon_GCD" -- Name of the game

-- [[ GCD Locals ]] --
local lastGCDTime = 0
local t = {}

t.gcd = CreateFrame("frame") -- GCD Anchor Frame


-- [[ Helper Functions ]] --

local function startGCD()
	local start, duration = GetSpellCooldown(ns.config.gcdSpellID)
	if start and duration and duration > 0 then
		local past, future, width, timeElapsed = ns.config.past, ns.config.future, ns.spellbars.active[1].bar:GetWidth(), 0
		local secondsPerPixel = 0
		t.gcd:SetWidth(ns:getPositionByTime(duration))
		t.gcd:Show()
		t.gcd:SetScript("OnUpdate", function(self, elapsed, ...)
			
			secondsPerPixel = secondsPerPixel > 0 and secondsPerPixel or (future-past)/width
			timeElapsed = timeElapsed + elapsed
			if timeElapsed >= secondsPerPixel then -- Limit the hard stuff to only when we have to move at least 1 pixel. (Smart updating?)
				duration = duration - timeElapsed
				timeElapsed = 0
				local width = ns:getPositionByTime(duration)
				if duration > 0 then
					--print(width)
					t.gcd:SetWidth(width)
					
				else
					t.gcd:SetScript("OnUpdate", nil)
					t.gcd:Hide()
				end
			end
		end)
	end
end

local function updateSettings(spellbar)
	local barHeight = spellbar:GetHeight()
	local layout = ns:getLayout("gcd")
	local gcdBar = ns:getConfig("gcdBar")
	
	if gcdBar then
		spellbar.gcd:SetPoint("LEFT", ns.barAnchor, "LEFT")
		spellbar.gcd:SetPoint("RIGHT", t.gcd, "RIGHT")
	else
		spellbar.gcd:SetPoint("LEFT", t.gcd, "RIGHT")
		spellbar.gcd:SetPoint("RIGHT", t.gcd, "RIGHT", 1)
	end
	
	spellbar.gcd:SetTexture(ns:getColor("gcd"))
	spellbar.gcd:SetBlendMode(ns:getBlendMode("gcd"))
	spellbar.gcd:SetPoint("TOP", spellbar, "TOP", 0, - barHeight*layout[1])
	spellbar.gcd:SetPoint("BOTTOM", spellbar, "BOTTOM", 0, barHeight*layout[2])
end


-- [[ onEnable ]] --

local function enable()
	-- Register for SPELL_UPDATE_COOLDOWN
	ns:registerModuleEvent(moduleKey, function()
		local curTime = GetTime()
		local gcdTime = select(2,GetSpellCooldown(ns.config.gcdSpellID))
		gcdTime = gcdTime > 0.5 and gcdTime or 1.5
		if curTime > gcdTime/2+lastGCDTime then -- If it's been at least half a GCD then update the GCD
			startGCD()
			lastGCDTime = curTime
		end
	end,
	"SPELL_UPDATE_COOLDOWN"
	)
	
	for i,v in pairs(ns.spellbars.active) do
		updateSettings(v)
	end
end


-- [[ onDisable ]] --

local function disable()
	-- Unregister SPELL_UPDATE_COOLDOWN
	ns:unregisterModuleEvent(moduleKey, "SPELL_UPDATE_COOLDOWN")
	
	for i,v in pairs(ns.spellbars.active) do
		v.gcd:Hide()
	end
end


-- [[ onInit ]] --

local function init()
	
	t.gcd:SetPoint("TOPLEFT", ns.barAnchor, "TOPLEFT")
	t.gcd:SetPoint("BOTTOMLEFT", ns.barAnchor, "BOTTOMLEFT")
	
	
	-- Add our GCD options to the right tables
	ns:addColor(moduleKey, "gcd", {1, 1, 1, 0.5}, function(input)
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
	end)
	
	ns:addBlendMode(moduleKey, "gcd", "BLEND", function(input)
		if type(input) == "string" then
			if input == "ADD" or input == "ALPHAKEY" or input == "BLEND" or input == "DISABLE" or input == "MOD" then
				return true
			end
		end
		return false		
	end)
	
	ns:addBlendMode(moduleKey, "gcdLine", "ADD",function(input)
		if type(input) == "string" then
			if input == "ADD" or input == "ALPHAKEY" or input == "BLEND" or input == "DISABLE" or input == "MOD" then
				return true
			end
		end
		return false		
	end)
	
	ns:addLayout(moduleKey, "gcd", {
		top = 0,
		bottom = 1,
	}, function(input)
		if type(input) ~= "table" then return end
		if input.top and input.bottom and input.top < input.bottom and input.top >= 0 and input.top < 1 and input.bottom > 0 and input.bottom <= 1 then
			return true
		end
		return false		
	end)
	
	ns:addConfig(moduleKey, "gcdBar", false, function(input)
		return type(input)=="boolean"
	end)
	
	-- Saved Vars
	
	
	-- Hook into spellbar creation
	ns:hookSpellbarCreation(moduleKey, function(spellbar)
		spellbar.gcd = t.gcd:CreateTexture() -- Make a new GCD texture for this spellbar.
		updateSettings(spellbar)
		spellbar.gcd:SetDrawLayer("BORDER", 5) -- Put it over everything
	end)
	
	-- Hook into spellbar hide & show routines
	ns:hookSpellbarHide(moduleKey, function(spellbar)
		spellbar.gcd:Hide()
	end)
	
	ns:hookSpellbarShow(moduleKey, function(spellbar)
		spellbar.gcd:Show()
	end)
	
	-- Hook into spellbar appearance update
	ns:hookSpellbarUpdate(moduleKey, updateSettings)
	
end





-- [[ Registering with EH ]] --

ns:addModule(moduleKey, {
	description = "GCD Functionality for EventHorizon. By Brusalk.",
	defaultState = true, -- On by default
	onDisable = disable(),
	onEnable = enable(),
	onInit = init(),
	table = t,
})