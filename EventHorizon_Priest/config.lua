local usemouseover = true	-- Make this false or nil (or just delete the line altogether) to make your healing bars not change when you mouse over something.

function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 588 -- Inner Fire
	self.config.hastedSpellID = {2006,10} -- Resurrection

	
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
	
	
	
	-- Holy/Disc
	
	-- Evangelism/Archangel now disc only
	self:newSpell({
		playerbuff = 81662,
		cooldown = 81700,
		refreshable = true,
		requiredTree = 1,
		requiredLevel = 50,
	})
	
	-- Renew/PoM CD
	self:newSpell({
		playerbuff = 139,
		auraunit = usemouseover and 'mouseover' or 'target',
		cooldown = 33076,
		refreshable = true,
		hasted = true,
		requiredLevel = 26,
		stance = 0, -- keep it from being shown in shadowform
	})
	
	-- Casts + Serendipity / Borrowed Time
	self:newSpell({
		cast = {32546,2061,2060,2050,14914,724,32375,129250,596,585,88685},
		playerbuff = {{63731,0},{59887,0}},
		stance = 0,-- keep it from being shown in shadowform
	})
	
	-- Discipline
	
	-- Penance + Grace
	self:newSpell({
		playerbuff = 47930,
		channeled = 47540,
		numhits = 0,
		cooldown = 47540,
		refreshable = true,
		auraunit = usemouseover and 'mouseover' or 'target',
		requiredTree = 1,
	})
	
	-- Weakened Soul/inner focus
	self:newSpell({
		debuff = 6788,
		cooldown = 89485,
		auraunit = usemouseover and 'mouseover' or 'target',
		requiredTree = 1,
	})
	-- Holy
	
	-- Holy Word: Chastise + Chakra effects
	self:newSpell({
		playerbuff = {{88682,0},{88684,0}},
		auraunit = usemouseover and 'mouseover' or 'target',
		cooldown = 88684,
		requiredTree = 2,
	})
	
	-- Circle of Healing
	self:newSpell({
		playerbuff = 88689,
		cooldown = 34861,
		requiredTree = 2,
		requiredLevel = 59,
	})
	
	--Chakra
	self:newSpell({
		playerbuff = {{81207,0},{81209,0},{81206,0},{81208,0}},
		cooldown = 81206,
		requiredTree = 2,
		requiredLevel = 49,
	})
	
	
	-- Shadow
	
	-- Vampiric Touch/swd cd
	self:newSpell({
		debuff = {34914,3},
		cast = 34914,
		cooldown = 32379,
		refreshable = true,
		hasted = true,
		recast = true,
		requiredTree = 3,
		requiredLevel = 28,
	})
	
	-- Shadow Word: Pain/mind bender cd
	self:newSpell({
		debuff = {589,3},
		hasted = true,
		cooldown = {123040, 34433},
		refreshable = true,
		requiredTree = 3,
		requiredLevel = 4,
	})
	

	
	-- Mind Blast/Spike/Melt
	self:newSpell({
		cast = {8092,73510},
		cooldown = 8092,
		playerbuff = 81292,
		refreshable = true,
		requiredTree = 3,
	})
	
	
	-- Mind Flay/Devouring Plague (by request)
	self:newSpell({
		channel = {15407,3},
		debuff = {2944,1},
		requiredTree = 3,
	})
	
	--lvl 90 talents
	self:newSpell({ 
		cooldown = {120517, 110744, 121135}, -- halo, shadow halo, divine star, shadow divine star, cascade, shadow cascade
		requiredLevel = 90,
		requiredTalent = {16,17,18},
	})

	
end