function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 1752
	
	-- General
	
	-- Slice and Dice
	self:newSpell({
		playerbuff = 5171,
		refreshable = true,
		requiredLevel = 22,
	})
	
	-- Recouperate (Sub)
	self:newSpell({
		playerbuff = {73651,3},
		refreshable = true,
		requiredTree = 3,
		requiredLevel = 12,
	})
	
	-- Rupture
	self:newSpell({
		debuff = {1943,2},
		refreshable = true,
		requiredLevel = 46,
	})
	
	-- Assassination
	
	-- Envenom
	self:newSpell({
		playerbuff = 32645,
		requiredTree = 1,
		requiredLevel = 54,
	})
	
	-- Combat
	
	-- Revealing Strike
	self:newSpell({
		debuff = 84617,
		requiredTree = 2,
		requiredLevel = 29,
	})
	
	-- Killing Spree
	self:newSpell({
		playerbuff = 51690,
		cooldown = 51690,
		requiredTree = 2,
		requiredLevel = 69,
	})
	
	-- Adrenaline Rush
	self:newSpell({
		playerbuff = 13750,
		cooldown = 13750,
		requiredTree = 2,
		requiredLevel = 49,
	})
	
	--[[
	-- Blade Flurry
	self:newSpell({
		playerbuff = 13877,
		cooldown = 13877,
		requiredTree = 2,
	})
	
	-- Bandit's Guile
	self:newSpell({
		debuff = {84747,84746,84745},
		requiredTree = 2,
		requiredLevel = 59,
	})
	]]--
	-- Subtlety
	
	-- Hemo
	self:newSpell({
		debuff = {{16511, 3}, {89775,3}},
		refreshable = true,
		requiredTree = 3,
		requiredLevel = 29,
	})
	
	-- Shadow Dance
	self:newSpell({
		playerbuff = 51713,
		cooldown = 51713,
		requiredTree = 3,
		requiredLevel = 69,
	})
	
	-- Shadowstep
	self:newSpell({
		playerbuff = 36563,
		uniqueID = 36563, -- Ambush/Garrote only
		cooldown = 36554,
		requiredTree = 3,
	})
	
	-- General/Bottom
	
	-- Deadly Poison
	self:newSpell({
		debuff = 2818,
		refreshable = true,
		requiredLevel = 30,
	})
	
	
	-- Overkill
	self:newSpell({
		playerbuff = 58426,
		requiredTree = 1,
		requiredLevel = 49,
	})

end
