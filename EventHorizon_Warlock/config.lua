function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 686
	self.config.hastedSpellID = {6201,3} -- Create Healthstone
	self.config.nonAffectingHaste = {64371,1.2}
	
	-- Affliction
	-- [Seed of] Corruption
	self:NewSpell({
		spellID = 172,
		debuff = {172,27243},
		icon = 172,
		cast = 27243,
		dot = 3,
		hasted = true,
		refreshable = true,
		requiredLevel = 4,
	})
	
	-- Bane
	self:NewSpell({
		spellID = 980,
		debuff = {980,603,80240},
		dot = 2,
		refreshable = true,
		hasted = true,
		requiredLevel = 8,
	})

	-- Unstable Affliction
	self:NewSpell({
		spellID = 30108,
		cast = true,
		debuff = true,
		dot = 3,
		hasted = true,
		refreshable = true,
		requiredTree = 1,
		requiredLevel = 10,
	})
	
	-- Haunt
	self:NewSpell({
		spellID = 48181,
		cast = true,
		debuff = true,
		cooldown = true,
		requiredTree = 1,
		requiredLevel = 10,
	})
	
	-- Malefic Grasp
	self:NewSpell({
		spellID = 103103,
		channeled = true,
		requiredTree = 1,
		requiredLevel = 10,
	})
	
	-- Soul Swap
	self:NewSpell({
		spellID = 86121,
		debuff = {86121,1120},
		playerbuff = true,
		requiredTree = 1,
		requiredLevel = 10,
	})	

	-- Curse
	self:NewSpell({
		spellID = 1490,
		debuff = {18223,109466,1490},
		requiredLevel = 16,
	})
	
	
	
	--[[ -- NOT YET ADDED --
		-- Metamorphosis
	self:NewSpell({
		spellID = 47241,
		playerbuff = true,
		cooldown = true,
		requiredTree = 2,
		requiredLevel = 69,
	})
	
	-- Hand of Gul'dan + Decimation (for lack of a better spot)
	self:NewSpell({
		spellID = 71521,
		playerbuff = 63165,
		cooldown = true,
		cast = true,
		requiredTree = 2,
		requiredLevel = 39,
	})
	
	-- Immolate (Destro + Demo)
	self:NewSpell({
		spellID = 348,
		debuff = true,
		cast = true,
		hasted = true,
		dot = 3,
		refreshable = true,
		requiredTree = {0,2,3},
		requiredLevel = 3,
	})
	
	-- Conflagrate
	self:NewSpell({
		spellID = 17962,
		cooldown = true,
		playerbuff = 54274,
		requiredTree = 3,
	})
	
	-- Bane
	self:NewSpell({
		spellID = 980,
		debuff = {980,603,80240},
		dot = 2,
		refreshable = true,
		hasted = true,
		requiredLevel = 8,
	})
	
	-- Immolation Aura
	self:NewSpell({
		spellID = 50589,
		playerbuff = true,
		cooldown = true,
		stance = 2,
		requiredTree = 2,
	}) ]]--
	
end