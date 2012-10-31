function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 1978
	self.config.hastedSpellID = {56641,2} -- Steady Shot (Note: This probably isn't needed at all for Hunters, but it's here just in case)
	
	-- Serpent Sting
	self:NewSpell({
		spellID = 1978,
		debuff = true,
		dot = 3,
		refreshable = true,
	})
	
	-- Black Arrow
	self:NewSpell({
		spellID = 3674,
		debuff = true,
		cooldown = true,
		dot = 3,
		requiredTree = 3,
		requiredLevel = 50,
	})
	
	-- Explosive Shot
	self:NewSpell({
		spellID = 53301,
		debuff = true,
		cooldown = true,
		dot = 1,
		requiredTree = 3,
	})
	
	-- Chimaera Shot
	self:NewSpell({
		spellID = 53209,
		--cast = 19434,
		cooldown = true,
		--playerbuff = {82925,82926}, -- "Ready, Set, Aim..." + "Fire!"
		requiredTree = 2,
		requiredLevel = 60,
	})
	
	-- Kill Command + Killing Streak
	self:NewSpell({
		spellID = 34026,
		cooldown = true,
		requiredTree = 1,
	})
	
	-- Steady/Cobra + Improved Steady Shot
	self:NewSpell({
		spellID = 56641,
		cast = {56641,77767},
		playerbuff = 53224,  --same  spellid for the new Steady Focus so leave Cata Improved Stead Shot id there
		recast = true,
	})
		-- Aimed shot
	self:NewSpell({
		spellID = 19434,
		cast = 19434,
		playerbuff = {82925,82926}, -- "Ready, Set, Aim..." + "Fire!"
		requiredTree = 2,
	})
	
	-- Frenzy + Focus Fire (FF buff has the same duration as CD, no real reason to track it)
	self:NewSpell({
		spellID = 19615,
		playerbuff = true,
		cooldown = 82692,
		auraunit = 'pet',
		unique = true,
		refreshable = true,
		--minstacks = 5,
		requiredTree = 1,
	})
	
	-- Bestial Wrath
	self:NewSpell({
		spellID = 19574,
		playerbuff = 34471,
		cooldown = true,
		requiredTree = 1,
		requiredLevel = 40,
	})
	
	--- Dire Beast
	self:NewSpell({
		spellID = 120679,
		cooldown = true,
		requiredLevel = 75,
	})
	
	--[[
	--- Rapid Fire          ---- Incase you want to use this bar
	self:NewSpell({
		spellID = 3045,
		cooldown = true,
		requiredLevel = 54,
	})    ]]--

	--[[  NOTE!
	---Not  currently going to work unless we can find out how to recognize when of the "secondary" talents are being used. 
	--- I've been looking all over the place and haven't found it yet. Something along the lines of  ... requiredTalent = {#)
	]]--
	
		--[[
	--- Fervor --- TALENTED!
	self:NewSpell({
		spellID = 82726,
		cooldown = true,
		requiredLevel = 60,
	})

	--- Readiness --- TALENTED!
	self:NewSpell({
		spellID = 23989,
		cooldown = true,
		requiredLevel = 60,
	})
	
	--- Thrill of the Hunt --- TALENTED!
	self:NewSpell({
		spellID = 34720,
		cooldown = true,
		requiredLevel = 60,
	})
	
	]]--
	
end