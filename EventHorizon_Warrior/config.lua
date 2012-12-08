function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 5308
	--updated for mop

	-- Protection --
	
	--Shield Block/Shield Slam
	self:newSpell({
		cooldown = 23922,
		playerbuff = 2565,
		requiredTree = 3,
	})
	
	--Thunderclap
	self:newSpell({
		cooldown = 6343,
		debuff = 115798,
		requiredTree = 3,
	})
	
	--Shield Barrier/revenge
	self:newSpell({
		cooldown = 6572,
		playerbuff = 112048,
		requiredTree = 3,
	})
	
	
	--[[ Arms -- 
	
	125831 - taste for blood stacks
	52437 - sudden death
	]]
	
	-- Mortal Strike/colossus smash proc buff/sweeping strikes buff
	self:newSpell({
		cooldown = 12294,
		playerbuff = {{52437,0},{12328,0}},
		requiredTree = 1,
	})
	
	--Sudden Death/Colossus Smash
	self:newSpell({
		cooldown = 86346,
		debuff = 86346,
		requiredTree = 1,		
	})
	
	self:newSpell({
		playerbuff = 125831,
		cooldown = 78,
		requiredTree = 1,
	})
	
	--enrage/beserker rage
	self:newSpell({
		cooldown = 18499,
		playerbuff = 12880,
		requiredTree = 1,
	})
	
	
	--[[ Fury --
	131116 -- allows raging blow
	46916 -- bloodsurge
	12880 -- enrage
	]]
	
	-- Raging blow/bloodthirst
	self:newSpell({
		playerbuff = 131116,
		cooldown = 23881,
		requiredTree = 2,
	})
	
	
	-- Colossus Smash/raging blow
	self:newSpell({
		cooldown = 86346,
		debuff = 86346,
		requiredTree = 2,
	})
	
	--Beserker Rage/enrage
	self:newSpell({
		cooldown = 18499,
		playerbuff = 12880,
		requiredTree = 2,
	})
	

	
	
	-- Deadly Calm
	
	self:newSpell({
		cooldown = 85730,
		playerbuff = 85730,
		requiredTree = {1,2},
	})
	
	--[[90 talents
		self:newSpell({
			cooldown = {107574, 12292, 107570},
			buff = 107574,
			requiredTalent = {16, 17, 18},
		})		
	]]
	
	
	
	
	
	
	
	
	
	
	--[[ old
	-- Colossus Smash
	self:newSpell({
		spellID = 86346,
		cooldown = true,
		debuff = true,
		notstance = 2,
		requiredLevel = 81,
	})
	
	-- Rend
	self:newSpell({
		spellID = 772,
		debuff = true,
		dot = 3,
		refreshable = true,
		notstance = 3,
		requiredLevel = 4,
	})
	
	-- Strike (Untalented)
	self:newSpell({
		spellID = 88161,
		cooldown = true,
		requiredTree = 0,
	})
	
	-- Mortal Strike + Lambs to the Slaughter + Slam cast
	self:newSpell({
		spellID = 12294,
		cooldown = true,
		playerbuff = 84584,
		cast = 1464,
		keepIcon = true,
		requiredTree = 1,
	})
	
	-- Raging Blow + Enrage effects
	self:newSpell({
		spellID = 85288,
		playerbuff = {12880,18499,1134,12292}, -- Should pick whatever's first on the list, bar may jump
		cooldown = true,
		keepIcon = true,
		requiredTree = 2,
		requiredLevel = 39,
	})
	
	-- Bloodthirst + Bloodsurge
	self:newSpell({
		spellID = 23881,
		playerbuff = 46916,
		keepIcon = true,
		cooldown = true,
		requiredTree = 2,
	})
	
	-- Shield Slam + Sword and Board
	self:newSpell({
		spellID = 23922,
		playerbuff = 50227,
		cooldown = true,
		requiredTree = 3,
	})
	
	-- Revenge + Impending Victory
	self:newSpell({
		spellID = 6572,
		playerbuff = 82368,
		cooldown = true,
		stance = 2,
		requiredLevel = 40,
	})
	
	-- Shield Block
	self:newSpell({
		spellID = 2565,
		playerbuff = true,
		cooldown = true,
		stance = 2,
		requiredLevel = 28,
	})
	
	-- Shockwave + Thunderstruck
	self:newSpell({
		spellID = 46968,
		playerbuff = 87095,
		cooldown = true,
		requiredTree = 3,
		requiredLevel = 69,
	})
	
	-- Thunder Clap (not bothering with similar effects for now)
	self:newSpell({
		spellID = 6343,
		cooldown = true,
		debuff = true,
		unique = true,
		notstance = 3,
		requiredTree = {0,3},
		requiredLevel = 6,
	})
	
	-- Demoralizing Shout
	self:newSpell({
		spellID = 1160,
		debuff = true,
		unique = true,
		requiredTree = 3,
		requiredLevel = 52,
	})
	
	-- Whirlwind + Meat Cleaver
	self:newSpell({
		spellID = 1680,
		cooldown = true,
		playerbuff = 85738,
		keepIcon = true,
		stance = 3,
		requiredLevel = 36,
	})
	
	-- Taste for Blood
	self:newSpell({
		spellID = 60503,
		playerbuff = true,
		internalcooldown = 6,
		notstance = 3,
		requiredTalent = {1,8},
	})
		
	-- HS/Cleave + Incite
	self:newSpell({
		spellID = 78,
		cooldown = true,
		playerbuff = 86627,
		keepIcon = true,
		requiredLevel = 14,
	})
	
	-- Shouts
	self:newSpell({
		spellID = 6673,
		cooldown = true,
		playerbuff = {6673,469},
		unique = true,
		requiredLevel = 32,
	})
	
	-- Deadly Calm
	self:newSpell({
		spellID = 85730,
		cooldown = true,
		playerbuff = true,
		requiredTree = 1,
		requiredLevel = 39,
	})
	]]
end
