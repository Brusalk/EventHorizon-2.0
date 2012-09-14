local ns = EventHorizon

-- [[ GCD Locals ]] --
local lastGCDTime = 0
local t = {}

t.gcd = CreateFrame("frame") -- GCD Anchor Frame


-- [[ Helper Functions ]] --

local function startGCD()
	if not ns.shown then return end

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


-- [[ onEnable ]] --

local function enable()
	
	
end


-- [[ onDisable ]] --

local function disable()


end


-- [[ onInit ]] --

local function init()
	
	t.gcd:SetPoint("TOPLEFT", ns.frame.barAnchor, "TOPLEFT")
	t.gcd:SetPoint("BOTTOMLEFT", ns.frame.barAnchor, "BOTTOMLEFT")
	
	
	-- Add our GCD options to the right tables
	ns:addColor("gcd", {1, 1, 1, 0.5})
	ns:addBlendMode("gcd", "BLEND")
	ns:addBlendMode("gcdLine", "ADD")
	ns:addLayout("gcd", {
		top = 0,
		bottom = 1,
	})
	ns:addLayout("gcdLine", {
		top = 0,
		bottom = 1,
	})


	-- Register for SPELL_UPDATE_COOLDOWN
	ns:registerModuleEvent("EventHorizon_GCD", function()
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
	
	-- Hook into spellbar creation
	ns:hookSpellbarCreation("EventHorizon_GCD", function(spellbar)
		local barHeight = spellbar:GetHeight()
		local layout = ns:getLayout("gcd")
		
		spellbar.gcd = t.gcd:CreateTexture() -- Make a new GCD texture for this spellbar.
		spellbar.gcd:SetPoint("TOP", spellbar, "TOP", 0, -barHeight*layout[1])
		spellbar.gcd:SetPoint("BOTTOM", spellbar, "BOTTOM", 0, barHeight*layout[2])
		spellbar.gcd:SetPoint("LEFT", t.gcd, "RIGHT")
		spellbar.gcd:SetWidth(1)

		spellbar.gcd:SetDrawLayer("BORDER", 5) -- Put it over everything
	end)
	
	-- Hook into spellbar hide & show routines
	ns:hookSpellbarHide("EventHorizon_GCD", function(spellbar)
		spellbar.gcd:Hide()
	end)
	
	ns:hookSpellbarShow("EventHorizon_GCD", function(spellbar)
		spellbar.gcd:Show()
	end)
	
	-- Hook into spellbar appearance update
	ns:hookSpellbarUpdate("EventHorizon_GCD", function(spellbar)
		local barHeight = spellbar:GetHeight()
		local layout = ns:getLayout("gcd")
		
		spellbar.gcd:SetTexture(ns:getColor("gcd"))
		spellbar.gcd:SetBlendMode(ns:getBlendMode("gcd"))
		spellbar.gcd:SetPoint("TOP", spellbar, "TOP", 0, - barHeight*layout[1])
		spellbar.gcd:SetPoint("BOTTOM", spellbar, "BOTTOM", 0, barHeight*layout[2])
		
	end)
	
end





-- [[ Registering with EH ]] --

ns:addModule("EventHorizon_GCD", {
	description = "GCD Functionality for EventHorizon. By Brusalk.",
	defaultState = true, -- On by default
	onDisable = disable(),
	onEnable = enable(),
	onInit = init(),
	table = t,
})