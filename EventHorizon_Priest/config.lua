local usemouseover = true	-- Make this false or nil (or just delete the line altogether) to make your healing bars not change when you mouse over something.

function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 588 -- Inner Fire
	self.config.hastedSpellID = {2006,10} -- Resurrection
	
	old = true
	
	if old then
		
		-- Vampiric Touch/swd cd
	self:NewSpell({
		spellID = 34914,
		debuff = 34914,
		cast = 34914,
		cooldown = 32379,
		dot = 3,
		refreshable = true,
		hasted = true,
		requiredTree = 3,
		requiredLevel = 28,
		stance = 1,
	})
	
	-- Shadow Word: Pain/mind bender cd
	self:NewSpell({
		spellID = 589,
		debuff = 589,
		dot = 3,
		hasted = true,
		cooldown = {123040, 34433},
		refreshable = true,
		requiredTree = 3,
		requiredLevel = 4,
		stance = 1,
	})
	

	
	-- Mind Blast/Spike/Melt
	self:NewSpell({
		spellID = 8092,
		cast = {8092,73510},
		cooldown = 8092,
		buff = 81292,
		refreshable = true,
		requiredTree = 3,
		stance = 1,
	})
	
	
	--lvl 90 talents
	self:NewSpell({ 
		spellID = 120517,
		cooldown = {120517, 110744, 121135}, -- halo, shadow halo, divine star, shadow divine star, cascade, shadow cascade
		requiredLevel = 90,
		requiredTalent = {16,17,18},
	})
	
	else
	
	
	
	
	
	
	
	
	
	--[[ 
spellbar.config = {
	cooldown = {}, -- a single spellID or a table of spellIDs of which the spellbar will show the longest
	debuff = {}, -- a single spellID of a debuff or a table of a spellID and the time between it's ticks unhasted.
	buff = {}, -- a single spellID of a buff or a table of spellIDs of buffs which the spellbar will show the shortest. (Mostly used for exclusive buffs such as Chakras)
	unitID = {}, -- the unitID of which this spellbar should check. if unit doesn't exist, (such as no focus target), will switch to target. If a table is provided, EH will prioritize the first one, then checking the successive ones for existance. Example: unitID = {"mouseover", "focus", "raid1"} will check for mouseover. If that doesn't exist, goes to focus. If that doesn't exist, goes to raid member 1. If that doesn't exist goes to target.
	stance = {}, -- the stance number or a table of stance numbers which the player has to be in for spellbar to show (0 is no form)
	tree = {}, -- the spec number or a table of spec numbers which player has to be in for spellbar to show
	cast = {}, -- spellID or table of spellIDs to show casts for. If an entry is a table of form {spellID, #}, then spellID is a channel and has # seconds between ticks unhasted.
	talent = {}, -- a number or table of numbers which represent the talent which is required. If a table then spellbar will show if at least one talent is learned.
				 -- Example (Priest): talent = { 18 , 17 }
				 -- 1 is top left talent, 2 is top middle, 3 is top right. 2nd tier is 4-6, 3rd 7-9 etc.
				 -- Spellbar will show if the priest is talented into Divine Star or Halo
]]
	
	
	
	--[[-- Holy/Disc
	
	-- Evangelism/Archangel now disc only
	self:newSpell({
		spellID = 81659,
		playerbuff = 81662,
		cooldown = 81659,
		refreshable = true,
		requiredTree = 1,
		requiredLevel = 50,
	})
	
	-- Renew
	self:newSpell({
		spellID = 139,
		playerbuff = true,
		auraunit = usemouseover and 'mouseover' or 'target',
		refreshable = true,
		hasted = true,
		requiredTree = {0,1,2},
		requiredLevel = 8,
	})
	
	-- Casts + Serendipity / Borrowed Time
	self:newSpell({
		spellID = 2061,
		cast = {585,2061,8092,2050,14914,9484,32546,8129,596,2061},
		playerbuff = {63731,59887},
		requiredTree = {0,1,2},
	})
	
	-- Discipline
	
	-- Penance + Grace
	self:newSpell({
		spellID = 47540,
		playerbuff = 47930,
		channeled = true,
		numhits = 0,
		cooldown = true,
		refreshable = true,
		auraunit = usemouseover and 'mouseover' or 'target',
		requiredTree = 1,
	})
	
	-- Weakened Soul
	self:newSpell({
		spellID = 6788,
		debuff = true,
		auraunit = usemouseover and 'mouseover' or 'target',
		requiredTree = 1,
	})
	
	-- Holy
	
	-- Holy Word: Chastise + Chakra effects
	self:newSpell({
		spellID = 88625,
		playerbuff = {88682,88684},
		auraunit = usemouseover and 'mouseover' or 'target',
		cooldown = true,
		requiredTree = 2,
	})
	
	-- Circle of Healing
	self:newSpell({
		spellID = 34861,
		playerbuff = 88689,
		cooldown = true,
		requiredTree = 2,
		requiredLevel = 59,
	})
	
	-- Chakra
	self:newSpell({
		spellID = 14751,
		playerbuff = {81207,81209,81206,81208},
		cooldown = true,
		requiredTree = 2,
		requiredLevel = 49,
	})
	]]
	
	-- Shadow
	
	
	
	
	
		-- Vampiric Touch/swd cd
	self:newSpell({
		debuff = {34914,3},
		cast = 34914,
		cooldown = 32379,
		refreshable = true,
		hasted = true,
		requiredTree = 3,
		requiredLevel = 28,
		stance = 1,
	})
	
	-- Shadow Word: Pain/mind bender cd
	self:newSpell({
		debuff = {589,3},
		hasted = true,
		cooldown = {123040, 34433},
		refreshable = true,
		requiredTree = 3,
		requiredLevel = 4,
		stance = 1,
	})
	

	
	-- Mind Blast/Spike/Melt
	self:newSpell({
		cast = {8092,73510},
		cooldown = 8092,
		buff = 81292,
		refreshable = true,
		requiredTree = 3,
		stance = 1,
	})
	
	
	--lvl 90 talents
	self:newSpell({ 
		cooldown = {120517, 110744, 121135}, -- halo, shadow halo, divine star, shadow divine star, cascade, shadow cascade
		requiredLevel = 90,
		requiredTalent = {16,17,18},
	})


		--lvl 90 talents
	
	--[[ Mind Flay/Sear + Shadow Word: Death + Orbs
	self:newSpell({
		spellID = 15407,
		channeled = {{48045,5},{15407,3}},
		cooldown = 32379,
		refreshable = true,
		requiredTree = 3,
	})
	]]
	-- General
	
	-- Evangelism/Archangel now disc only
	self:newSpell({
		spellID = 81659,
		buff = 81662,
		cooldown = 81659,
		refreshable = true,
		requiredTree = 1,
		requiredLevel = 50,
	})
	
	
	
	
	
	
	
	
	
	
	--[[
		-- Vampiric Touch/swd cd
	self:newSpell({
		spellID = 34914,
		debuff = true,
		cast = true,
		dot = 3,
		cooldown = 32379,
		refreshable = true,
		hasted = true,
		requiredTree = 3,
		requiredLevel = 28,
	})
	
	-- Shadow Word: Pain/mind bender cd
	self:newSpell({
		spellID = 589,
		debuff = true,
		dot = 3,
		hasted = true,
		cooldown = {123040, 34433},
		refreshable = true,
		requiredTree = 3,
		requiredLevel = 4,
	})
	

	
	-- Mind Blast/Spike/Melt
	self:newSpell({
		spellID = 8092,
		cast = {8092,73510},
		cooldown = true,
		playerbuff = 81292,
		refreshable = true,
		requiredTree = 3,
	})
	
	
	--lvl 90 talents
	self:newSpell({ 
		spellID = 120692,
		cooldown = {120517, 120664, 110744, 122121, 121135, 127632}, -- halo, shadow halo, divine star, shadow divine star, cascade, shadow cascade
		requiredLevel = 90,
	})
	
	-- Mind Flay/Sear + Shadow Word: Death + Orbs
	self:newSpell({
		spellID = 15407,
		channeled = {{48045,5},{15407,3}},
		cooldown = 32379,
		refreshable = true,
		requiredTree = 3,
	})
	
	-- General
	
	-- Evangelism/Archangel now disc only
	self:newSpell({
		spellID = 81659,
		playerbuff = 81662,
		cooldown = 81659,
		refreshable = true,
		requiredTree = 1,
		requiredLevel = 50,
	})
	]]
end

end