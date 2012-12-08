function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 1978
	self.config.hastedSpellID = {56641,2} -- Steady Shot (Note: This probably isn't needed at all for Hunters, but it's here just in case)
	
	-- Serpent Sting
	self:newSpell({
		debuff = {1978,3},
		refreshable = true,
	})
	
	-- Black Arrow
	self:newSpell({
		debuff = {3674,3},
		cooldown = 3674,
		requiredTree = 3,
		requiredLevel = 50,
	})
	
	-- Explosive Shot
	self:newSpell({
		debuff = {53301,1},
		cooldown = 53301,
		requiredTree = 3,
	})
	
	-- Chimaera Shot
	self:newSpell({
		--cast = 19434,
		cooldown = 53209,
		--playerbuff = {82925,82926}, -- "Ready, Set, Aim..." + "Fire!"
		requiredTree = 2,
		requiredLevel = 60,
	})
	
	-- Kill Command + Killing Streak
	self:newSpell({
		cooldown = 34026,
		requiredTree = 1,
	})
	
	-- Steady/Cobra + Improved Steady Shot
	self:newSpell({
		cast = {56641,77767},
		playerbuff = 53224,  --same  spellid for the new Steady Focus so leave Cata Improved Stead Shot id there
		recast = true,
	})
		-- Aimed shot
	self:newSpell({
		cast = 19434,
		playerbuff = {{82925,0},{82926,0}}, -- "Ready, Set, Aim..." + "Fire!"
		requiredTree = 2,
	})
	
	-- Frenzy + Focus Fire (FF buff has the same duration as CD, no real reason to track it)
	self:newSpell({
		playerbuff = 19615,
		cooldown = 82692,
		auraunit = 'pet',
		unique = true,
		refreshable = true,
		--minstacks = 5,
		requiredTree = 1,
	})
	
	-- Bestial Wrath
	self:newSpell({
		playerbuff = 34471,
		cooldown = 19574,
		requiredTree = 1,
		requiredLevel = 40,
	})
	
	--- Dire Beast
	self:newSpell({
		cooldown = 120679,
		requiredLevel = 75,
	})
	
	--
	--- Rapid Fire  
	self:newSpell({
		cooldown = 3045,
		requiredLevel = 54,
	})    --]]

	--- Readiness ]]
	self:newSpell({
		cooldown = 23989,
		requiredLevel = 60,
	})
	
	--[[  NOTE!
	--- In order to get the following talents to work you must delete the whole line that says "DELETE THIS LINE..."
	--- If you do that then that talent will show up when you do a /reloadui
	--- Copy and Paste the line back from one of the other talents to hide it again
	]]--
	
	--[[ DELETE THIS LINE FOR THIS TALENT TO SHOW
	--- Fervor --- TALENTED!
	self:newSpell({
		cooldown = 82726,
		playerbuff = 82726,
		requiredLevel = 60,
	})
	--]]

	--[[ DELETE THIS LINE FOR THIS TALENT TO SHOW
	--Dire Beast --- TALENTED!
	self:newSpell({
		playerbuff = 120679,
		requiredLevel = 60,
	})
	]]--
	
	
	--[[ DELETE THIS LINE FOR THIS TALENT TO SHOW
	--Thrill of the Hunt --- TALENTED!
	self:newSpell({
		playerbuff = 109306,
		requiredLevel = 60,
	})
	]]--
	
	--[[ DELETE THIS LINE FOR THE TALENT BELOW TO SHOW
	--A Murder of Crows/Blink Strike/Lynx Rush
	self:newSpell({
		debuff = {131894, 1},
		cooldown = {131894, 120697, 130392,}, 
		requiredLevel = 75,
	})
	--]]
	
	
end