function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 686
	self.config.hastedSpellID = {6201,3} -- Create Healthstone
	self.config.nonAffectingHaste = {64371,1.2}
	
	--  ***  Affliction *** --
	-- [Seed of] Corruption
	self:newSpell({
		debuff = {{172,2},{27243,2}},
		icon = 172,
		cast = 27243,
		refreshable = true,
		requiredLevel = 3,
		requiredTree = {1,2},
	})
	
	-- Agony
	self:newSpell({
		debuff = {{980,2},{603,2},{80240,2}},
		refreshable = true,
		requiredTree = 1,
		requiredLevel = 36,
	})

	-- Unstable Affliction
	self:newSpell({
		cast = 30108,
		debuff = {30108,2},
		refreshable = true,
		requiredTree = 1,
	})
	
	-- Haunt
	self:newSpell({
		cast = 48181,
		debuff = 48181,
		cooldown = 48181,
		requiredTree = 1,
		requiredLevel = 62,
	})
	
	-- Malefic Grasp/drain soul/drain life
	self:newSpell({
		channel = {{103103, 4}, {1120, 6}, {689,4}},
		requiredTree = 1,
		requiredLevel = 42,
	})
	
	
	--[[ DELETE THIS LINE IF YOU WANT SOUL SWAP
	--Soul Swap
	self:newSpell({
		playerbuff = 86211,
		requiredTree = 1,
		requiredLevel = 79,
	})	
	--]]
	
	
	-- Demonology
	-- Doom
	self:newSpell({
		debuff = {603,15},
		refreshable = true,
		hasted = false,
		requiredTree = 2,
	})


	-- Hand of Guldan and Shadowflame
	self:newSpell({
		cooldown = 105174,
		debuff = {47960,1},
		requiredLevel = 10,
		requiredTree = 2,
	})

	-- Shadow Bolt, Soulfire and HellFire/Harvest Life
	self:newSpell({
		cast = {686,6353},
		channeled = {{1949,0},{108371,0}},
		requiredLevel = 10,
		requiredTree = 2,
	})	

	-- Molten Core Buff and Decimation
	self:newSpell({
		playerbuff = {{122355,0},{108869,0}},
		requiredTree = 2,
	})


	-- *** Destruction *** --
	
	--Immolate
	self:newSpell({
		cast = 348,
		debuff = {348,3},
		recast = true,
		requiredTree = 3,
	})
	
	--Conflag/backdraft/incinerate
	self:newSpell({
		playerbuff = 117828,
		cooldown = 17962, 
		cast = 29722, 
		requiredTree = 3,
	})
	
	--Dark Soul/chaos bolt
	self:newSpell({
		spellID = 113858,
		cast = 116858,
		cooldown = 113858,
		playerbuff = 113858,
		requiredTree = 3,
		icon = 113858,
	})
	
	
	-- *** All Trees *** --
	-- Curse
	self:newSpell({
		debuff = {{1490,0},{18223,0},{109466,0}},
		requiredLevel = 16,
	})



--[[function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 686
	self.config.hastedSpellID = {6201,3} -- Create Healthstone
	self.config.nonAffectingHaste = {64371,1.2}
	
	-- Affliction
	-- [Seed of] Corruption
	self:newSpell({
		debuff = {172,27243},
		icon = 172,
		cast = 27243,
		dot = 3,
		hasted = true,
		refreshable = true,
		requiredLevel = 4,
		requiredTree = 1,
	})
	
	-- Bane
	self:newSpell({
		spellID = 980,
		debuff = {980,603,80240},
		dot = 2,
		refreshable = true,
		hasted = true,
		requiredLevel = 8,
		requiredTree = {0,1,2},
	})

	-- Unstable Affliction
	self:newSpell({
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
	self:newSpell({
		cast = 48181,
		debuff = 48181,
		channeled = 103103,
		requiredTree = 1,
		requiredLevel = 10,
	})
	
	
	
	--Destruction
	
	--Immolate
	self:newSpell({
		spellID = 348,
		cast = 348,
		debuff = 348,
		dot = 3,
		requiredTree = 3,
	})
	
	--Conflag/backdraft/incinerate
	self:newSpell({
		playerbuff = 117828,
		cooldown = 17962, 
		cast = 29722, 
		requiredTree = 3,
	})
	
	--Dark Soul/chaos bolt
	self:newSpell({
		spellID = 113858,
		cast = 116858,
		cooldown = 113858,
		playerbuff = 113858,
		requiredTree = 3,
		icon = 113858,
	})
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	]]
	--[[ -- NOT YET ADDED --
		-- Metamorphosis
	self:newSpell({
		spellID = 47241,
		playerbuff = true,
		cooldown = true,
		requiredTree = 2,
		requiredLevel = 69,
	})
	
	-- Hand of Gul'dan + Decimation (for lack of a better spot)
	self:newSpell({
		spellID = 71521,
		playerbuff = 63165,
		cooldown = true,
		cast = true,
		requiredTree = 2,
		requiredLevel = 39,
	})
	
	-- Immolate (Destro + Demo)
	self:newSpell({
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
	self:newSpell({
		spellID = 17962,
		cooldown = true,
		playerbuff = 54274,
		requiredTree = 3,
	})
	
	-- Bane
	self:newSpell({
		spellID = 980,
		debuff = {980,603,80240},
		dot = 2,
		refreshable = true,
		hasted = true,
		requiredLevel = 8,
	})
	
	-- Immolation Aura
	self:newSpell({
		spellID = 50589,
		playerbuff = true,
		cooldown = true,
		stance = 2,
		requiredTree = 2,
	}) ]]--
	
end