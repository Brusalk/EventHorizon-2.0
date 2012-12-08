function EventHorizon:InitializeClass()
	
	self.config.gcdSpellID = 49895
	
	-- General rotation
	
	-- Icy Touch
	self:newSpell({
		debuff = {55095,3},
		refreshable = true,
		hasted = false,
	})
	
	-- Plague Strike
	self:newSpell({
		debuff = {55078,3},
		refreshable = true,
		hasted = false,
	})
	
	-- Blood Tap
	self:newSpell({
		playerbuff = 45529,
		cooldown = 45529,
		requiredLevel = 64,
	})
	
	-- Blood tree (no requiredTalent entries until trees are more solid)
	
	-- Rune Tap
	self:newSpell({
		cooldown = 48982,
		requiredTree = 1,
	})
	
	-- Vampiric Blood
	self:newSpell({
		playerbuff = 55233,
		cooldown = 55233,
		requiredTree = 1,
	})
	
	-- Bone Shield
	self:newSpell({
		playerbuff = 49222,
		cooldown = 49222,
		requiredTree = 1,
	})
	
	-- Dancing Rune Weapon
	self:newSpell({
		cooldown = 49028,
		requiredTree = 1,
	})
	
	-- Frost tree (again, no requiredTalents yet)
	
	-- Rime
	self:newSpell({
		playerbuff = 59052,
		requiredTree = 2,
	})
	
	-- Pillar of Frost
	self:newSpell({
		playerbuff = 51271,
		cooldown = 51271,
		requiredTree = 2,
	})
	
	-- Unholy tree
	
	-- Unholy Blight
	self:newSpell({
		debuff = 115989,
		requiredTree = 3,
	})
	
	-- Sudden Doom
	self:newSpell({
		playerbuff = 81340,
		requiredTree = 3,
	})
	
	-- Shadow Infusion + Dark Transformation (Yes, they're exclusive)
	self:newSpell({
		playerbuff = {{91342,0},{63560,0}},
		auraunit = 'pet',
		requiredTree = 3,
	})
end