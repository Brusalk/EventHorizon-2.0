local usemouseover = true	-- Make this false or nil (or just delete the line altogether) to make your healing bars not change when you mouse over something.

function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 115921 -- Legacy of the Emperor
	self.config.hastedSpellID = {115178,10} -- Resuscitate

	-- Mistweaver

	--Soothing Mist
	self:newSpell({
		refreshable = true,
		playerbuff = 115175,
		auraunit = usemouseover and 'mouseover' or 'target',
		hasted = true,
		requiredTree = 2,
		requiredLevel = 10,
	})

	--Renewing Mist
	self:newSpell({
		spellID = 115151,
		refreshable = true,
		playerbuff = 115151,
		auraunit = usemouseover and 'mouseover' or 'target',
		hasted = true,
		cooldown = true,
		requiredTree = 2,
		requiredLevel = 10,
	})
	
	--Enveloping Mist
	self:newSpell({
		spellID = 124682,
		cast = {124682,116694},
		refreshable = true,
		playerbuff = 124682,
		auraunit = usemouseover and 'mouseover' or 'target',
		hasted = true,
		requiredTree = 2,
		requiredLevel = 10,
	})

	--Mana Tea
	self:newSpell({
		spellID = 115867,
		playerbuff = 115867,
		cooldown = 123761,
		cast = 115867,
		channeled = 115867,
		requiredTree = 2,
		requiredLevel = 58,
	})
	
	--Second tier talents (mouseover target)
	self:newSpell({
		spellID = 124081,
		playerbuff = 124081,
		cooldown = {115098,124081},
		auraunit = usemouseover and 'mouseover' or 'target',
		cast = 123986,
		requiredLevel = 30,
		requiredTree = 2,
	})

	--Windwalker
	
	--Tiger Power
	self:newSpell({
		spellID = 125359,
		playerbuff = 125359,
		requiredTree = 3,
		requiredLevel = 10,
	})
	
	--Rising Sun Kick
	self:newSpell({
		spellID = 107428,
		cooldown = 107428,
		debuff = 107428,
		requiredTree = 3,
		requiredLevel = 10,
	})
	
	--Fist of Fury + Spinning Crane Kick
	self:newSpell({
		spellID = 113656,
		cooldown = 113656,
		playerbuff = 101546,
		channeled = 113656,
		requiredTree = 3,
		requiredLevel = 10,
	})
	
	--Tigereye Brew
	self:newSpell({
		spellID = 125195,
		playerbuff = 125195,
		requiredTree = 3,
		requiredLevel = 60,
	})
		
	--General
	
	--Second tier talents
	self:newSpell({
		spellID = 124081,
		playerbuff = 124081,
		cooldown = {115098,124081},
		cast = 123986,
		requiredLevel = 30,
		requiredTree = {1,3},
	})
end