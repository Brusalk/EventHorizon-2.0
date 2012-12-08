function EventHorizon:InitializeClass()
	self.config.gcdSpellID = 118 -- Polymorph
	self.config.hastedSpellID = {118,1.7}
	
	
	
	
	
	-- Frost --
		
	--57761 -- Brain Freeze
	
	--Pet Freeze/frost bolt

	self:newSpell({
		cast = 116,
		cooldown = 33395,
		debuff = 116,
		requiredTree = 3,
	})
	

	
	--Lvl 75 talents/Fire blast (for use if glyphed) (3 separate bars)

	--[[ Delete this line for a bar for Nether tempest
	self:newSpell({ -- Nether Tempest
		debuff = {114923,1},
		cooldown = 2136,
		requiredTree = 3,
		requiredLevel = 75,
		--requiredTalent = 13,
	})
	--]]
	
	--[[ Delete this line for a bar for living bomb
	self:newSpell({ -- Living Bomb
		cooldown = 2136,
		debuff = {44457,3},
		requiredTree = 3,
		requiredLevel = 75,
		--requiredTalent = 14,
	})
	--]]
	
	self:newSpell({ -- Frost Bomb
		cast = 112948,
		cooldown = 112948,
		debuff = 112948,
		requiredTree = 3,
		requiredLevel = 75,
		--requiredTalent = 15,
	})
	--]]
	
	
		--Finger of Frost/Ice Orb
	self:newSpell({
		playerbuff = 44544,
		cooldown = 84714,
		requiredTree = 3,
	})
	--Brain Freeze/icy Veins
	
	self:newSpell({
		cooldown = 12472,
		playerbuff = 57761,
		requiredTree = 3,
	})
	
	
	-- Arcane
	
	-- Arcane Blast/Arcane Missiles/AM buff
	
	self:newSpell({
		cast = 30451,
		channel = 5143,
		playerbuff = 79683,
		requiredTree = 1,
	})
	
	
	-- Arcane Charges/Arcane Barrage
	self:newSpell({
		cooldown = 44425,
		auraunit = "player",
		debuff = 36032,
		requiredTree = 1,
	})
	
		
	
	-- Evocation/Lvl 75 talent
	--Lvl 75 talents/Fire blast (for use if glyphed) (3 separate bars)

	-- Delete this line for a bar for Nether tempest
	self:newSpell({ -- Nether Tempest
		channel = 12051,
		cooldown = 12051,
		debuff = {114923,1},
		requiredTree = 1,
		requiredLevel = 75,
		--requiredTalent = 13,
	})
	--]]
	
	--[[ Delete this line for a bar for living bomb
	self:newSpell({ -- Living Bomb
		channel = 12051,
		cooldown = 12051,
		debuff = {44457,3},
		requiredTree = 1,
		requiredLevel = 75,
		--requiredTalent = 14,
	})
	--]]
	
	--[[ Delete this line for a bar for frost bomb
	self:newSpell({ -- Frost Bomb
		cooldown = 112948,
		debuff = 112948,
		requiredTree = 1,
		requiredLevel = 75,
		--requiredTalent = 15,
	})
	
	self:newSpell({
		cooldown = 12051,
		channel = 12051,
		requiredTree = 1,
	})
	--]]
	
	
	--Arcane Power
	
	self:newSpell({
		cooldown = 12042,
		requiredTree = 1,
	})
	
	self:newSpell({
		itemID = 36799,
		requiredTree = 1,
	})
	
	
	
	--[[Fire
	48107 -- Heating Up
	108853 -- Inferno Blast
	11129 -- Combustion
	11366 -- Pyroblast (3 secs)
	48108 -- Pyroblast! (proc)
	12564 -- ignite]]
	
	-- casts/Inferno Blast/ignite
	self:newSpell({
		cast = {133, 11366, 2948},
		debuff = {12564,2},
		cooldown = 108853,
		icon = 108853,
		requiredTree = 2,
	})
	
	-- Pyroblast! and Heating Up
	self:newSpell({
		playerbuff = {{48107,0},{48108,0}},
		requiredTree = 2,
	})
	
	
		--Lvl 75 talents/Fire blast (for use if glyphed) (3 separate bars)

	
	self:newSpell({ -- Nether Tempest
		debuff = {114923,1},
		requiredTree = 2,
		requiredLevel = 75,
		--requiredTalent = 13,
	})
	--]]
	
	--[[ Delete this line for a bar for living bomb
	self:newSpell({ -- Living Bomb
		debuff = {44457,3},
		requiredTree = 2,
		requiredLevel = 75,
		--requiredTalent = 14,
	})
	--]]
	
	--[[ Delete this line for a bar for Frost Bomb
	self:newSpell({ -- Frost Bomb
		cast = 112948,
		cooldown = 112948,
		debuff = 112948,
		requiredTree = 2,
		requiredLevel = 75,
		--requiredTalent = 15,
	})
	--]]
	
	
	-- Pyroblast!/Pyroblast DoT/Mirror Images
	self:newSpell({
		debuff = {11366,3},
		requiredTree = 2,
		cooldown = 55342,
	})
		
	
	
	
	
	
	
	
	--[[ OLD
	-- Casts + Hot Streak + Brain Freeze + AM (exclusive anyway)
	self:newSpell({
		spellID = 133,
		cast = {11366,133,116,44614,2948,82731},
		channeled = 5143,
		numhits = 0,
		playerbuff = {48108,57761,79683},
		refreshable = true,
	})
	
	-- Arcane
	
	-- Arcane Blast + AB [de]buff + ABar CD
	self:newSpell({
		spellID = 30451,
		debuff = 36032,
		cooldown = 44425,
		auraunit = 'player',
		refreshable = true,
		cast = true,
		requiredTree = 1,
	})
	
	-- Arcane Power
	self:newSpell({
		spellID = 12042,
		playerbuff = true,
		cooldown = true,
		requiredTree = 1,
		requiredLevel = 69,
	})
	
	-- Presence of Mind
	self:newSpell({
		spellID = 12043,
		playerbuff = true,
		cooldown = true,
		requiredTree = 1,
	})
	
	-- Fire
	
	-- Fire Blast + Impact
	self:newSpell({
		spellID = 2136,
		playerbuff = 64343,
		cooldown = true,
		requiredTree = {0,2},
	})
	
	-- Living Bomb
	self:newSpell({
		spellID = 44457,
		debuff = true,
		dot = 3,
		hasted = true,
		requiredTree = 2,
		requiredLevel = 69,
	})
	
	-- Frost
	
	-- Deep Freeze + Fingers of Frost
	self:newSpell({
		spellID = 44572,
		playerbuff = 44544,
		cooldown = true,
		requiredTree = 3,
	})
	
	-- Icy Veins
	self:newSpell({
		spellID = 12472,
		playerbuff = true,
		cooldown = true,
		requiredTree = 3,
	})]]
end
