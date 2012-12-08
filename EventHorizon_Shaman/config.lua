local usemouseover = true	-- Make this false or nil (or just delete the line altogether) to make your healing bars not change when you mouse over something.

function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 52127 -- Water Shield
	self.config.hastedSpellID = {2008,10} -- Ancestral Spirit
	
	-- General




	-- Ascendance
	self:newSpell({
		cooldown = 114049,
		playerbuff = 114049,
		requiredTree = {1,2,3},
		requiredLevel = 90,
	})
	
	-- Elemental
	
	-- Elemental
	
	-- Flame Shock
	self:newSpell({
		debuff = {8050,3},
		cooldown = 8050,
		requiredTree = {0,1},
		requiredLevel = 5,
	})

	-- Lava Burst
	self:newSpell({
		cast = 51505,
		cooldown = 51505,
		requiredTree = 1,
		requiredLevel = 34,
	})

	-- Lightning Bolt + Chain Lightning + Earthquake + Lightning Shield Charges (minstacks 2)
	self:newSpell({
		cast = {403,421,61882},
		cooldown = 61882,
		requiredTree = 1,
		playerbuff = 324,  
		icon = 324,
	})

	-- Unleash Elements
	self:newSpell({
		cooldown = 73680,
		requiredTree = 1,
		requiredLevel = 81,
		talent = 16
	})
	
	--[[ Delete this line for elemental mastery talent 
	
	-- Elemental Mastery
	self:newSpell({
		cooldown = 16166,
		playerbuff = 16166,
		requiredTree = 1,
		requiredLevel = 60,
		--requiredTalent = 10,
	}) 
	--]]

	-- Elemental Blast
	self:newSpell({
		cooldown = 117014,
		requiredTree = 1,
		requiredLevel = 90,
		talent = 18
	})
	
	
	
	-- Enhancement --
	
	--8050 -- Flame shock
	
	-- Flame Shock
	self:newSpell({
		debuff = {8050, 3},
		cooldown = 8050,
		requiredTree = 2,
	})
	
	-- Stormstrike / Maelstrom Weapon
	self:newSpell({
		cooldown = 17364,
		requiredTree = 2,
	})
	
	-- Lavalash / Searing Flames
	self:newSpell({
		cooldown = 60103,
		playerbuff = 77661,
		requiredTree = 2,
	})
	
	-- Unleash Elements
	self:newSpell({
		cooldown = 73680,
		requiredTree = 2,
	})
	
	-- Wolves
	self:newSpell({
		cooldown = 51533,
		requiredTree = 2,
	})
	
	
	-- Restoration --
	
	--Riptide
	self:newSpell({
		playerbuff = {61295,3},
		cooldown = 61295,
		requiredTree = 3,
		auraunit = "target", 
	})
	
	-- Unleash Elements
	self:newSpell({
		playerbuff = 73685,
		cooldown = 73680,		
		requiredTree = 3,
	})
	
	--Casts/Chainheal CD if glyphed
	self:newSpell({
		cooldown = 1064,
		cast = {1064, 77472, 8004, 331, 403},
		requiredTree = 3,		
	})
	
	-- Tidal Waves/Healing Rain
	self:newSpell({
		cast = 73920,
		cooldown = 73920,
		playerbuff = 53390,
		requiredTree = 3,
	})
	
	-- Earth Shield
	self:newSpell({
		playerbuff = 974,
		auraunit = "target", 
		requiredTree = 3,
	})
	
	
	
	
	
	
	
	
	
	-- 60 Talents
	
	--[[ Delete this line for Elemental Mastery talent bar
	self:newSpell({-- Elemental Mastery
		cooldown = 16166,
		playerbuff = 16166,
		requiredLevel = 60,
		requiredTalent = 10
	})
	--]]
	
	--[[ Delete this line for Ancestral Swiftness talent bar
	self:newSpell({-- Ancestral Swiftness
		cooldown = 16118,
		playerbuff = 16118,
		requiredLevel = 60,
		requiredTalent = 11
	})
	--]]

end
