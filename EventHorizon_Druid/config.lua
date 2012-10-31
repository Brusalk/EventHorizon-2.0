local usemouseover = true	-- Make this false or nil (or just delete the line altogether) to make your healing bars not change when you mouse over something.

function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 17057 -- Bear Form
	self.config.hastedSpellID = {50769,10} -- Revive
	
	-- Feral bars

	-- Rip 
	self:newSpell({
		spellID = 1079,
		debuff = {1079,2},
		refreshable = true,
		stance = 3,
		requiredTree = {2,3},
	})
	
	-- Rake
	self:newSpell({
		spellID = 1822,
		debuff = {1822,3},
		refreshable = true,
		stance = 3,
		requiredLevel = 8,
	})
	
	-- Savage Roar
	self:newSpell({
		spellID = 52610,
		playerbuff = 52610,
		stance = 3,
		requiredTree = 2,
	})
	
	-- Tiger's Fury
	self:newSpell({
		spellID = 5217,
		cooldown = 5217,
		playerbuff = 5217,
		stance = 3,
		requiredTree = 2,
		requiredLevel = 24,
	})	
		
	-- Berserk
	self:newSpell({
		spellID = 50334,
		playerbuff = 50334,
		cooldown = 50334,
		stance = 3,
		requiredTree = {2,3},
		requiredLevel = 69,
	})
	
	-- Guardian bars

	-- Mangle
	self:newSpell({
		spellID = 33878,
		unique = true,
		refreshable = true,
		cooldown = true,
		stance = 1,
	})	
	
	-- Lacerate
	self:newSpell({
		spellID = 33745,
		debuff = true,
		refreshable = true,
		cooldown = true,
		dot = 3,
		stance = 1,
		requiredLevel = 18,
	})
	
	-- Thrash
	self:newSpell({
		spellID = 106830,
		debuff = true, -- "true" for bleed debuff, "115798" for Weakened Blows debuff
		refreshable = true,
		dot = 3,
		cooldown = true,
		stance = 1,
		requiredTree = {2,3},
		requiredLevel = 28,
	})	

	-- Swipe
	self:newSpell({
		spellID = 779,
		cooldown = true,
		stance = 1,
		requiredLevel = 22,
	})
	
	-- Enrage
	self:newSpell({
		spellID = 5229,
		playerbuff = true,
		cooldown = true,
		stance = 1,
		requiredTree = 3,
		requiredLevel = 10,
	})

	-- Barkskin
	self:newSpell({
		spellID = 22812,
		playerbuff = true,
		cooldown = true,
		stance = 1,
		requiredLevel = 44,
	})


	-- Balance bars - NOTE: Untalented Druids will see some of these.
	
	-- Starsurge
	self:newSpell({
		spellID = 78674,
		cast = 78674,
		cooldown = 78674,
		playerbuff = 93400, -- Shooting Stars
		requiredTree = 1,
	})

	-- Wrath
	self:newSpell({
		spellID = 5176,
		playerbuff = 48517, -- If using another method to track Eclipse phases, can monitor Solar Empowerment with "129633"
		cast = 5176,
		requiredTree = {0,1},
	})
	
	-- Starfire
	self:newSpell({
		spellID = 2912,
		playerbuff = 48518, -- If using another method to track Eclipse phases, can monitor Lunar Empowerment with "129632"
		cast = 2912,
		requiredLevel = 8,
		requiredTree = {0,1},
	})
	
	-- [Sun/Moon]fire
	self:newSpell({
		spellID = 8921,
		debuff = {8921,93402},
		hasted = true,
		refreshable = true,
		requiredLevel = 4,
		requiredTree = {0,1},
	})
	

	-- Starfall
	self:newSpell({
		spellID = 48505,
		playerbuff = 48505,
		cooldown = 48505,
		requiredLevel = 69,
		requiredTree = 1,
	})
	
	-- Resto bars
	
	-- Lifebloom
	self:newSpell({
		spellID = 33763,
		playerbuff = true,
		auraunit = usemouseover and 'mouseover' or 'target',
		dot = 1,
		hasted = true,
		refreshable = true,
		requiredLevel = 64,
		requiredTree = 4,
	})
	
	-- Rejuvenation + Swiftmend
	self:newSpell({
		spellID = 774,
		playerbuff = true,
		cooldown = 18562,
		auraunit = usemouseover and 'mouseover' or 'target',
		dot = 3,
		hasted = true,
		requiredTree = 4,
	})

	-- Casted Heals + Nature's Swiftness/Cenarion Ward
	self:newSpell({
		spellID = 8936,
		cast = {8936,5185,50464},
		cooldown = {17116,102351},
		playerbuff = true,
		auraunit = usemouseover and 'mouseover' or 'target',
		dot = 2,
		hasted = true,
		requiredTree = 4,
	})
	
	-- Wild Growth + Harmony
	self:newSpell({
		spellID = 48438,
		cooldown = true,
		playerbuff = 100977,
		requiredTree = 4,
	})	
	
end