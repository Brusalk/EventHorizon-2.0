local usemouseover = true	-- Make this false or nil (or just delete the line altogether) to make your healing bars not change when you mouse over something.

function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 20217 -- Holy Light
	self.config.hastedSpellID = {7328,10} -- Redemption, probably not needed at all
	
	-- General - Judgement
	self:newSpell({
		cooldown = 20271,
		requiredLevel = 3,
		requiredTree = {0,1,3},
	})
	
	-- Crusader Strike
	self:newSpell({
		cooldown = 35395,
		requiredTree = {0,2,3},	-- Everyone but Holy
		keepIcon = true,
	})
	
	-- Holy
	
	-- Holy Shock
	self:newSpell({
		cooldown = 20473,
		requiredTree = 1,
	})
	
	-- Casts
	self:newSpell({
		cast = {635,19750,82326,879},
		requiredTree = 1,
		requiredLevel = 14,
	})
	
	-- Light of Dawn
	self:newSpell({
		cooldown = 85222,
		requiredTree = 1,
		requiredLevel = 69,
	})
	
	-- Holy Radiance
	self:newSpell({
		playerbuff = 82327,
		requiredTree = 1,
		requiredLevel = 83,
	})
	
	-- Prot
	
	-- Avenger's Shield + Holy Shield
	self:newSpell({
		cooldown = 31935,
		requiredTree = 2,
		keepIcon = true,
	})
	
	-- Judgement
	self:newSpell({
		cooldown = 20271,
		requiredTree = 2,
		keepIcon = true,
	})
	
	-- Holy Wrath
	self:newSpell({
		cooldown = 119072,
		requiredTree = 2,
		requiredLevel = 28,
	})
	
	-- Consecration
	self:newSpell({
		cooldown = 26573,
		playerbuff = 26573,
		requiredTree = 2,
		requiredLevel = 20,
	})

	
	--Ret
	
	--Inquisition/Exorcism
	self:newSpell({
		playerbuff = 84963,
		cooldown = 879, 
		requiredTree = 3,
		requiredLevel = 81,
	})
	
	--Avenging Wrath/Hammer of Wrath
	self:newSpell({
		playerbuff = 31884,
		cooldown = 24275,
		requiredTree = 3,
		keepIcon = true,
	})
		
	
	-- LEVEL 90 TALENTS
	self:newSpell({
		cooldown = {114165, 114158, 114157},
		playerbuff = {{114165,0}, {114157,0}},
		debuff = 114158,		
		requiredLevel = 90,
	})
	
end