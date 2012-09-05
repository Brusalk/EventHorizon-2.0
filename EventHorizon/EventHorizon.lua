local DEBUG = true
local EHN,ns = ...
EventHorizon = ns


ns.frame = CreateFrame("frame") -- eventFrame + vars holder
ns.gcd = CreateFrame("frame") -- GCD Anchor Frame
ns.frame.barAnchor = CreateFrame("frame") -- Frame at t=0
ns.frame.barAnchor:SetWidth(1)

-- [[ UTILITY TABLES ]] --
local errors = {}



-- [[ UTILITY FUNCTIONS ]] --
local function printhelp(...) if select('#',...)>0 then return tostring((select(1,...))), printhelp(select(2,...)) end end
local function print(...)
	ChatFrame1:AddMessage('EventHorizon: '.. strjoin(" ", printhelp(...)))
end

function round(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end

-- error: Only enabled when in debug mode
--   fxn: String with either a function name to produce the error for, or a custom error message
--   errorKey: nil or string. If nil error will produce the custom message. If a string error will use it to index errors[fxn] to find an error message
local function error(fxn, errorKey)
	if not fxn or not DEBUG then return end
	if errorKey then
		print("Error in function " .. fxn .. ":", errors[fxn][errorKey] or "Double-Fault. Error not found >.<")
	else
		print("Error:", fxn)
	end
end
local function addError(fxn, err)
	if not DEBUG then return end
	errors[fxn] = {}
	for i,v in pairs(err) do
		errors[fxn][i] = v
	end
end


-- mergeDef:
--   def: Table of default values (also contains ALL possible values)
--   t1:  Table of values to use over def and not t2 if exists
--   t2:  Table of values to use over def and t1
--  Usage: Combining the defaultConfig, config.lua and myConfig.lua options. (myConfig > config > default)
--  Returns: Table of entries where t2>t1>def
addError("mergeDef", {inputs = "one or more of inputs def, t1 are not defined"})
local function mergeDef(def, t1, t2)
	if not def or not t1 then error("mergeDef", "inputs") return end
	local tmp = {}
	for i,v in pairs(def) do
		if t2 and (t2[i] or t2[i] == false) then -- t2 is actually an optional table.
			tmp[i] = t2[i]
		elseif t1[i] or t1[i] == false then -- Be sure to include values of false as well. 
			tmp[i] = t1[i]
		else
			tmp[i] = v
		end
	end
	return tmp
end

-- addEvent:
--   event: string of event to register and handle
--   handler: function accepting inputs self, event, ... which fires when event happens. ... contains event specific args such as UnitID for UNIT_HEALTH
addError("addEvent", {inputs = "one or more of inputs event, handler are not defined"})
local function addEvent(handler, ...)
	if select('#',...) == 0 or not handler then error("addEvent", "inputs") return end
	if not ns.frame:GetScript("OnEvent") then -- Just to make sure that we have defined the event-handler code already
		ns.frame:SetScript("OnEvent", function(self, event, ...)
			if ns.events[event] then
				ns.events[event](self, event, ...) -- call the function
			else -- We have no registered function for this event. Error
				error("No registered event handler for event " .. event)
			end
		end)
	end
	
	local tmp = 1
	local event = ...
	while true do
		event = select(tmp,...)
		if event then
			ns.frame:RegisterEvent(event)
			ns.events[event] = handler	
		else
			break
		end
		tmp = tmp + 1
	end
end


-- tableMerge:
--	  tab1-tabN: tables of which elements common to all are to be returned
--  Usage: Combines the spellbar tables and returns the spellbars which are common to all inputs (and should thus be activated)
addError("tableMerge", {inputs = "At least 2 table inputs are required for this function!"})
local function tableMerge(...) 
	if select('#', ...) < 2 then print(select(1,...)) error("tableMerge", "inputs") return end
	local toReturn = {}
	print(select(1,...))
	for j,spellbar in pairs(...) do -- do it this way so we don't actually do anything to the tables passed in
		--print(spellbar.index)
		table.insert(toReturn, spellbar)
		--print("Adding " .. spellbar)
	end
	local n = #toReturn -- get the size of the initial table - it won't get any bigger than this
	for i=2, select('#', ...) do
		local tab = select(i, ...)
		if type(tab) == "table" then --ignore any inputs which aren't tables
				-- we have to iterate with pairs because after the first run, our table will have empty indices
			for j, v in pairs(toReturn) do -- for everything that's common up to this point in iteration:
				--print("Testing " .. v)
				local found = false
				for k,spellbar in pairs(tab) do -- for everything in this new table to check
					if v == spellbar then		-- if we found that the spellbar exists in this new table, say we found it
						found = true
						--print("Found " .. spellbar)
					end
				end
				if not found then -- if we didn't find this element, then remove it from the common table
					--print("Removing " .. toReturn[j])
					toReturn[j] = nil -- set to nil to remove without changing the array
				end
			end
			-- note that the resulting table has a bunch of empty indices after each loop			
		end
	end
	-- now we can do a single cleanup run
	for j = 1, n do -- iterate over the maximum size of the table
		local v = toReturn[j] -- get the value at the current index
		if v then -- if we have a non-nil value	
			toReturn[j] = nil -- remove the value from its current index
       		table.insert(toReturn, v) -- put the value in the first empty index
       	end
	end
	return toReturn -- return everything that's common
end

function testMerge()
	return tableMerge({1,2,3,4,5,6,7}, "test", {}, {2,4,6})
end


addError("getColor", {inputs = "color information must be a table of {r,g,b,a} or {true, burn%, alpha} for class colored"})
local function getColor(key)
	if not key or not ns.colors[key] or type(ns.colors[key]) ~= "table" or #ns.colors[key]<3 or #ns.colors[key]>4 then error("getColor", "inputs") return end
	local classColor = RAID_CLASS_COLORS[select(2,UnitClass("player"))]
	if ns.colors[key][1] == true then -- Class coloring/burn/alpha
		return classColor.r * ns.colors[key][2], classColor.g * ns.colors[key][2], classColor.b * ns.colors[key][2], ns.colors[key][3]
	elseif type(ns.colors[key][1]) == "number" then
		return unpack(ns.colors[key])
	end
end


local function getLayout(key)
	if ns.layouts[key] then
		return {ns.layouts[key].top, ns.layouts[key].bottom}
	else
		return {ns.layouts.default.top, ns.layouts.default.bottom}
	end
end



-- [[ SCOPE TABLES AND VARS ]] --

ns.defaultConfig = {
	--Bar Options
	height = 300,        		-- Height of the total frame. EH will now automatically resize the height of spellBars depending on how many are active
	width = 500,        		-- Width of the total frame. (This includes the actual spellBar, as well as the icon) 
	barSpacing = 0,      		-- Amount of space vertically between spellBars
	minBars = 3,         		-- If there are less than or equal to minBars shown, Eh will resize the bars as if there were minBars actually shown. In other words, the total frame will become shorter, rather than the bars becoming larger. You can also think of it like setting an upper-limit on how tall a spellBar can be. (that being height/minBars)
	texture = "Interface\\Addons\\EventHorizon\\Smooth",
								-- If a path to a texture, EH will use that. If a table of {r, g, b, a}, EH will use that.
	barTexture = "Interface\\Addons\\EventHorizon\\Smooth", -- Path to a texture to use for the background of individual spellbars.

	textureAlphaMultiplier = 2,	-- Textures generally appear darker than a solid color. The alpha value is multiplied by this to counteract this effect
	
	--Icon Options
	icons = true, 				-- If set to false or nil, EH will not show icons and only show the spellBar.
	iconWidth = 0.1,            -- Width of the icon. If <1 EH assumes this is a percent of the width. If >1 EH will set it as a pixel value.
	
	--Stack Indicator Options
	stackFont = false,			-- If this is set to a font path, EH will use that font for the stack indicator
	stackSize = false,    		-- Sets the font size of the indicator if set to a number
	stackOutline = false, 		-- Sets the outline of the font. Valid: "OUTLINE", "THICKOUTLINE", "MONOCHROME"
	stackColor = false,			-- Sets the color of the font. {R, G, B, A}
	stackShadow = false, 		-- Sets whether there should be a shadow effect on the text
	stackShadowOffset = false,	-- Sets the offset from the text the shadow should be {x,y}
	stackPosition = {"BOTTOMRIGHT", -2, 2},		-- Sets the position and offset of the stack Indicator relative to the icon. { RelativePoint, xOffSet, yOffSet } Default: {"BOTTOMRIGHT", -2, 2}
	
	--Backdrop Options
	backdrop = true,            -- Whether to setup a backdrop (true) or not (false)
	texture = "Interface\\ChatFrame\\ChatFrameBackground",
								-- Path to the texture to use as the backdrop
	border = "Interface\\Tooltips\\UI-Tooltip-Border",
								-- Path to the texture to use as a border
	padding = 2, 				-- Extra space (in pixels) between the barFrames/Icons and the backdrop
	edgeSize = 8, 				-- Thickness of the frame's border. You'll have to mess around with this if you change the border texture to make it look right
	inset = {top = 2, bottom = 2, left = 2, right = 2},
								-- Changes the distance between the border texture and the backdrop texture. Moves the backdrop in x pixels.
	
	--Time Settings
	past = -3,    				-- Time in the past in seconds to show to the left of the now line (As a negative number)
	future = 12, 				-- Time in the future to show to the right of the now line
	futureLog = false,			-- For the future. I may implement a log scale for the future if enabled. NYI
	
}
ns.defaultColors = {
	debuffTick = {true,Priest and 0.7 or 1,1},			-- Tick markers. Default = {true,Priest and 0.7 or 1,1} (class colored, dimmed a bit if you're a Priest, opaque)
	buffTick = {true,Priest and 0.7 or 1,1},			-- Tick markers. Default = {true,Priest and 0.7 or 1,1} (class colored, dimmed a bit if you're a Priest, opaque)
	channelTick = {0,1,0.2,0.25},					-- Tick markers for channeled spells. Default is the same as casting.
	cast = {0,1,0.2,0.25},							-- Casting bars. Default = {0,1,0,0.25} (green, 0.25 unmodified alpha)
	castLine = {0,1,0,0.3},						-- The end-of-cast line, shown for casts and channels over 1.5 seconds. Default = {0,1,0,0.3} (green, 0.3 unmodified alpha)
	cooldown = {0.6,0.8,1,0.3},						-- Cooldown bars. Default = {0.6,0.8,1,0.3} (mute teal, 0.3 unmodified alpha)
	debuff = {true,Priest and 0.7 or 1,0.3},	-- YOUR debuff bars. Default = {true,Priest and 0.7 or 1,0.3} (class colored, dimmed a bit if you're a Priest, 0.3 unmodified alpha)
	buff = {true,Priest and 0.7 or 1,0.3},	-- Buff bars. Default = {true,Priest and 0.7 or 1,0.3} (class colored, dimmed a bit if you're a Priest, 0.3 unmodified alpha)
	nowLine = {1,1,1,0.3},							-- The "Now" line.
	bg = {0,0,0,0.6}, 				-- Color of the frame's background. Default = {0,0,0,0.6} (black, 60% opacity)
	barBackground = {1,1,1,0.2},           -- Color of the background of individual bars
	border = {1,1,1,1},						-- Color of the frame's border. Default = {1,1,1,1} (white, fully opaque)
	gcd = {1,1,1,0.5},						-- Color of the GCD indicator. Default = {1,1,1,0.5}
}
ns.defaultBlendModes = {
	debuffTick = "ADD",		
	buffTick = "ADD",
	channeltick = "ADD",					
	cast = "BLEND",				-- If cast is set to show a line, it inheirits this.								
	cooldown = "ADD",						
	debuff = "ADD",	
	buff = "ADD",	
	nowline = "ADD",
	bg = "BLEND", 				
	barbg = "BLEND",          
	border = "BLEND",		
	gcd = "BLEND",				-- If setup to have a moving line rather than functioning like a cast, inheirits off of this
	gcdLine = "ADD",   			-- This is for the line 1 GCD in the future if enabled.
}
ns.defaultLayouts = {
	debuffTick = {				-- debuff Tick markers.
		top = 0,
		bottom = 0.12,
	},
	buffTick = {				-- buff tick markers. Lets you have debuffs and buffs on the same bar
		top = 0.88,
		bottom = 1,
	},
	channelTick = {
		top = 0,
		bottom = 0.12,
	},
	cast = {					-- If cast is set to show a line, it inheirits this.		
		top = 0,
		bottom = 1,
	},								
	cooldown = {
		top = 0,
		bottom = 1,
	},							
	debuff = {
		top = 0,
		bottom = 1,
	},	
	buff = {
		top = 0,
		bottom = 1,
	},		
	nowline = {
		top = 0,
		bottom = 1,
	},	
	barbg = {
		top = 0,
		bottom = 1,
	},	         
	gcd =  {					-- If setup to have a moving line rather than functioning like a cast, inheirits off of this
		top = 0,
		bottom = 1,
	},				
	gcdLine = {	   				-- This is for the line 1 GCD in the future if enabled.
		top = 0,
		bottom = 1,
	},

	recastZone = {				-- The recast line for spells like Vampiric Touch and Immolate.
		top = 0,
		bottom = 0.25,
	},
	cantCast = {				-- The blank section below the recast line.
		top = 0.25,
		bottom = 1,
	},
	default = {					-- Just about everything else.
		top = 0,
		bottom = 1,
	},
}

-- Build the customized config, colors, blendModes and layout tables.
ns.config = mergeDef(ns.defaultConfig, ns.cConfig, ns.pConfig) -- default: default. c = config.lua config table. p = myConfig.lua config table
ns.colors = mergeDef(ns.defaultColors, ns.cColors, ns.pColors)
ns.blendModes = mergeDef(ns.defaultBlendModes, ns.cBlendModes, ns.pBlendModes)
ns.layouts = mergeDef(ns.defaultLayouts, ns.cLayouts, ns.pLayouts)



-- [[ CORE TABLES ]] --

ns.spellbars = {  -- contains the spellbars which have been added by ns:NewSpell(), as well as references to spellbars by various attributes (Doing this frontloads the work when creating the bars on startup, as opposed to requiring it later while processing speed matters
	index = {}, -- in order of creation via newspell
	cooldown = {}, -- indexed by spellID in cooldown field
	debuff = {}, -- indexed by debuff spellID
	buff = {}, -- indexed by buff spellID
	unitID = {}, -- indexed by unitID for the spellbar. If spellConfig.unitID = "mouseover", then the spellbar is added to the mouseover subtable.
	stance = {}, -- indexed by stance number (required stance)
	tree = {}, -- indexed by required tree/spec
	cast = {}, -- indexed by cast spellIDs
	talent = {}, -- indexed by required talent number. If a talent is required for a spellbar, then in config it's set to requiredTalent = {tier, number}. 
	active = {}, -- contains all active spellbars. 
	level = {}, -- contains all of the spellbars which the player is high enough level for
	-- Using this, it's easy to determine what bars should be active. Simply merge the tables which are required, and activate spellbars which are in all the tables required.
	-- Example: Say a spellbar has the following props:
	--[[  	self:NewSpell({
				debuff = 589,
				unitID = "focus",
				stance = 1,
				tree   = {1,2},	
			}
		That created spellbar is added to index, debuff[589], stance[1] and tree[1] and tree[2] as well as talent[all indexes].
		Now we merge the required tables which match current conditions (such as active spec or required talent).
		The resulting table of spellbars are what should be set to active. 
		
		Going back to the example, stance and tree are the required fields for that spellbar.config. 
		As such, when we merge stance[activeStance], tree[activeTree] and talent[activeTalent], we are returned with a table which matches the requirements.
		Since our new spell is in all three required tables, its returned and set to active along with all other ones which match the criteria. 
		
	]]
}
ns.events = {}     -- contains all of the handler functions for events referenced by event



--  [[ SPELLBAR FUNCTIONS ]] --

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
	level = {}, -- A single number of which the player must be higher level for the bar to be shown
]]


-- updateIcon:
--  Updates the icon/stack settings of the icon on the spellbar self
--   self: spellbar reference
--   spellID: spellID to set icon to
--   stacks: number to display on the stacks counter
addError("updateIcon", {inputs = "inputs spellBar were not of correct type or not all defined"})
local function updateIcon(self, spellID, stacks)
	if not self or not self.spellConfig then error("updateIcon", "inputs") return end
	--Quick Note: This assumes that the spellbar's dims have been updated and are correct
	
	if not ns.config.icons then return end -- don't do anything if they've disabled icons
	
	
	local left,right,top,bottom = 0.07, 0.93, 0.07, 0.93
	local c = ns.config
	local height, width = self:GetHeight(), (c.iconWidth < 1 and c.width* c.iconWidth or c.iconWidth)
	if height > width then	-- icon is taller than it is wide
		left = left + (1-(width/height))/2
		right = right - (1-(width/height))/2
	else -- vars.barheight = height of frame. barheight2 = icon width
		top = top + (1-(height/width))/2
		bottom = bottom - (1-(height/width))/2
	end

	if spellID then
		if type(spellID) == "string" then -- If they passed newSpells' config option icon a string, use that
			self.icon.texture:SetTexture(spellID)
		else
			self.icon.texture:SetTexture(select(3,GetSpellInfo(spellID)))
		end
		self.icon.texture:SetTexCoord(left, right, top, bottom)
		print(spellID)
	end
	if stacks then
		self.icon.stacks:SetText(stacks > 0 and "" ..stacks or "")
		self.icon.stacks:SetPoint(ns.config.stackPosition[1], self.icon, ns.config.stackPosition[1], ns.config.stackPosition[2], ns.config.stackPosition[3])
	end
	
	
end

-- getIconForSpellbar
--  Returns the spellID of the spell to show on the icon.
local function getIconForSpellbar(spellbar)
	local c = spellbar.spellConfig
	
	if c.icon and (type(c.icon) == "string" or type(c.icon) == "number") then
		return c.icon
	end
	
	
	local debuff, cast, cooldown, buff
	
	if type(c.debuff) == "table" then
		if type(c.debuff[1]) == "table" then -- We have more than one debuff defined. Form: debuff = { {spellID, unhasted tick time}, {spellID2, unhasted tick time 2} },
			if type(c.debuff[1][1]) == "number" then
				debuff = c.debuff[1][1]
			end
		else								 -- We have only one debuff defined. Form: debuff = {spellID, unhasted tick time}
			if type(c.debuff[1]) == "number" then
				debuff = c.debuff[1]
		end
	elseif type(c.debuff) == "number" then 	 -- We have only a spellID defined. (no ticks)
		debuff = c.debuff
	end
		
	cast = c.cast and c.cast
	if type(cast) == "table" then
		cast = cast[1]
	end	
	
	cooldown = c.cooldown and c.cooldown or nil
	if type(cooldown) == "table" then
		for i,v in ipairs(cooldown) do
			local known = IsSpellKnown(v)
			local usable = IsUsableSpell(v)
			if known and usable then
				cooldown = v
			end
				-- unfortunately impossible to distinguish between unknown spells and the spell which a spell transforms to
		end
		if type(cooldown) == "table" then -- No active cooldown spells to use, so pass over it
			cooldown = nil
		end
	end
	
	if type(c.buff) == "table" then
		if type(c.buff[1]) == "table" then -- We have more than one buff defined. Form: buff = { {spellID, unhasted tick time}, {spellID2, unhasted tick time 2} },
			if type(c.buff[1][1]) == "number" then
				buff = c.buff[1][1]
			end
		else								 -- We have only one buff defined. Form: buff = {spellID, unhasted tick time}
			if type(c.buff[1]) == "number" then
				buff = c.buff[1]
		end
	elseif type(c.buff) == "number" then 	 -- We have only a spellID defined. (no ticks)
		buff = c.buff
	end
	
	
	
	--print"Done with bar"
	return debuff or cast or buff or cooldown
end


-- updateSpellbarSettings:
--  Updates the configuration settings for the spellbar self
--   self: spellbar reference to be updated
addError("updateSpellbarSettings", {inputs = "Input spellbar was either not defined or not initialized yet."})
local function updateSpellbarSettings(self)
	if not self or not self.spellConfig then error("updateSettings", "inputs") return end
	
	local c = ns.config
	local numactive = (#ns.spellbars.active>0 and #ns.spellbars.active or 1)
	
	self:SetWidth(c.width - 2*c.padding)
	self:SetHeight( round((c.height - 2*c.padding)/ numactive - c.barSpacing ) )
	
	if ns.config.icons then
		self.icon:Show()
		self.icon:SetWidth(c.iconWidth < 1 and (c.width-2*c.padding)*c.iconWidth or c.iconWidth)

		
		if c.stackFont then
			self.icon.stacks:SetFont(c.stackFont,c.stackSize)
			if c.stackShadow then
				self.icon.stacks:SetShadowColor(unpack(c.stackShadow))
				self.icon.stacks:SetShadowOffset(unpack(c.stackShadowOffset))
			end
		else
			self.icon.stacks:SetFontObject('NumberFontNormalSmall')
		end
		self.icon.stacks:SetPoint(ns.config.stackPosition[1], self.icon, ns.config.stackPosition[1], ns.config.stackPosition[2], ns.config.stackPosition[3]) -- slightly offset inside the icon

		self.icon.stacks:SetVertexColor(unpack(c.stackColor))
		
		updateIcon(self)
	else
		self.icon:Hide()
	end
	--castbar
	self.cast:SetTexture(ns.config.texture)
	self.cast:SetVertexColor(getColor("cast"))
	self.cast:SetBlendMode(ns.blendModes.cast)
	
	-- self.cooldown:SetTexture(ns.config.texture)
	-- self.cooldown:SetVertexColor(getColor("cooldown"))
	-- self.cooldown:SetBlendMode(ns.blendModes.cooldown)
	
	-- self.debuff:SetTexture(ns.config.texture)
	-- self.debuff:SetVertexColor(getColor("debuff"))
	-- self.debuff:SetBlendMode(ns.blendModes.debuff)
	
	-- self.buff:SetTexture(ns.config.texture)
	-- self.buff:SetVertexColor(getColor("buff"))
	-- self.buff:SetBlendMode(ns.blendModes.buff)
	
	self.bar.texture:SetTexture(ns.config.barTexture)
	self.bar.texture:SetVertexColor(getColor("barbg"))
	--print(getColor("barbg"))
	self.bar.texture:SetBlendMode(ns.blendModes.barbg)

	--Done Updating Spellbar self

end




addError("newSpell", {
	cooldown = "Class Config: cooldown should be a spellID or a table of spellIDs of which the spellbar will show the longest",
	debuff = "Class Config: debuff should be a spellID or a table of a spellID and the unhasted time between ticks or a table of multiple tables of a spellID and unhasted time between ticks. EventHorizon will show the shortest", 
	buff = "Class Config: buff should be a spellID or a table of a spellID and the unhasted time between ticks or a table of multiple tables of a spellID and unhasted time between ticks. EventHorizon will show the shortest", 
	unitID = "Class Config: unitID should be either a unitID or a table of 2 unitIDs representing first the unitID EH should check for debuffs, and second for buffs",
	stance = "Class Config: stance should be either a number or a table of numbers representing the stance the player must be in one of for the spellbar to show",
	tree = "Class Config: tree should be either a number or a table of numbers which represents the spec which should be active to show",
	cast = "Class Config: cast should be either a spellID or a table of spellIDs that the spellbar will show as casts",
	talent = "Class Config: talent should be a number or a table of numbers which represents the talents, one of which is required to be learned for the spellbar to show",
	requiredLevel = "Class Config: level should be a number between 0 and GetMaxPlayerLevel which the player must be at least that level for the spellbar to show",
})
function ns:newSpell(spellConfig)
	
	local spellbar = CreateFrame("Frame") -- make the spellbar frames and textures
	spellbar.icon = CreateFrame("Frame",nil,spellbar)
	spellbar.bar = CreateFrame("Frame",nil,spellbar)	-- bar on which ticks/debuff/buff/cast are anchored. Width is config.width - iconWidth
	spellbar.bar.texture = spellbar.bar:CreateTexture()
	spellbar.icon.texture = spellbar.icon:CreateTexture()
	spellbar.icon.stacks = spellbar.icon:CreateFontString()
	spellbar.cast = spellbar:CreateTexture()
	-- spellbar.debuff = spellbar:CreateTexture()
	-- spellbar.buff = spellbar:CreateTexture()
	-- spellbar.cooldown = spellbar:CreateTexture()
	spellbar.gcd = ns.gcd:CreateTexture()

		
	spellbar.icon:SetPoint("TOPLEFT", spellbar, "TOPLEFT") -- inheirits height settings from spellbar
	spellbar.icon:SetPoint("BOTTOMLEFT", spellbar, "BOTTOMLEFT") 
	
	
	spellbar.icon.stacks:SetPoint(ns.config.stackPosition[1], spellbar.icon, ns.config.stackPosition[1], ns.config.stackPosition[2], ns.config.stackPosition[3]) -- slightly offset inside the icon
	spellbar.icon.stacks:SetJustifyH("RIGHT")
	
	spellbar.bar:SetPoint("BOTTOMRIGHT", spellbar, "BOTTOMRIGHT")	 -- inheirits height settings from spellbar.
	spellbar.bar:SetPoint("TOPLEFT", spellbar, "TOPLEFT", self.config.icons and (self.config.iconWidth < 1 and (self.config.width-2*self.config.padding)*self.config.iconWidth or self.config.iconWidth)+1 or 0, 0) -- inheirits width settings natually from width of spellbar and icon
	
	spellbar.bar.texture:SetAllPoints(spellbar.bar)
	spellbar.icon.texture:SetAllPoints(spellbar.icon)
	
	-- spellbar.cooldown:SetPoint("LEFT", ns.frame.barAnchor, "RIGHT")
	-- spellbar.cooldown:SetPoint("TOP", spellbar.bar, "TOP")
	-- spellbar.cooldown:SetPoint("BOTTOM", spellbar.bar, "BOTTOM")
	
	-- spellbar.buff:SetPoint("LEFT", ns.frame.barAnchor, "RIGHT")
	-- spellbar.buff:SetPoint("TOP", spellbar.bar, "TOP")
	-- spellbar.buff:SetPoint("BOTTOM", spellbar.bar, "BOTTOM")
	
	-- spellbar.debuff:SetPoint("LEFT", ns.frame.barAnchor, "RIGHT")
	-- spellbar.debuff:SetPoint("TOP", spellbar.bar, "TOP")
	-- spellbar.debuff:SetPoint("BOTTOM", spellbar.bar, "BOTTOM")
	
	-- spellbar.cooldown:Hide()
	-- spellbar.buff:Hide()
	-- spellbar.debuff:Hide()
	spellbar.cast:Hide()
	
	
	spellbar.gcd:SetPoint("TOP", spellbar, "TOP")
	spellbar.gcd:SetPoint("BOTTOM", spellbar, "BOTTOM")
	spellbar.gcd:SetPoint("LEFT", ns.gcd, "RIGHT")
	spellbar.gcd:SetWidth(1)
	spellbar:SetScript("OnHide", function(self) -- Make it so this bars GCD is effectively parented to both ns.gcd (which controls the position of all gcd bars) and the spellbar itself
		self.gcd:Hide()
	end)
	spellbar:SetScript("OnShow", function(self)
		self.gcd:Show()
	end)


	

	spellbar.bar.texture:SetDrawLayer("BACKGROUND")
	spellbar.bar:SetFrameStrata("LOW")
	spellbar.icon.texture:SetDrawLayer("BORDER")
	spellbar.cast:SetDrawLayer("BORDER", 4)
	-- spellbar.debuff:SetDrawLayer("BORDER", 3)
	-- spellbar.buff:SetDrawLayer("BORDER", 2)
	-- spellbar.cooldown:SetDrawLayer("BORDER", 1)
	spellbar.gcd:SetDrawLayer("BORDER", 5)
	
	
	
	--spellbar specific functions
	spellbar.updateIcon = updateIcon -- function which updates a spellbars icon+stacks counter
	spellbar.updateSettings = updateSpellbarSettings -- updates a spellbar's texture/misc settings. Doing it this way means I only have to update the bars that are getting shown, as opposed to all of them
	
	spellbar.updating = {} -- helper tables indexed by type of bar being updated/updating
	spellbar.update = {}
	
	--spellbar specific sub-tables
	spellbar.tracked = { -- This table keeps track of debuffs/buffs for this spellbar indexed by guid. (This is the key table which allows remembering debuffs/buffs when switching units
		buff = {},
		debuff = {},
	}
	spellbar.ticks = { -- This table contains all of the tick data for the buffs/debuffs on the unit indexed by guid
		buff = {},
		debuff = {},
	} 
	spellbar.spellConfig = spellConfig -- spellbar specific settings
	
	
	table.insert(ns.spellbars.index, spellbar) -- insert spellbar into the right tables as well as make sure values are within bounds
	spellbar.index = #ns.spellbars.index
	--combination of default-setting and inserting into the right tables
	--cooldown
	if type(spellConfig.cooldown) == "number" then   	-- cooldown is ALWAYS a table, just empty if either invalid value or non-existant.
		spellConfig.cooldown = {spellConfig.cooldown}
	elseif spellConfig.cooldown == nil then
		spellConfig.cooldown = {}
	elseif type(spellConfig.cooldown) ~= "table" then
		spellConfig.cooldown = {}
		error("newSpell", "cooldown")
	end
	for i,v in pairs(spellConfig.cooldown) do
		if type(v) == "number" then
			ns.spellbars.cooldown[v] = ns.spellbars.cooldown[v] or {} -- Make sure that this index is a table so we can insert values
			table.insert(ns.spellbars.cooldown[v], spellbar)
		else
			error("newSpell", "cooldown")
		end
	end
	
	--debuff
	if type(spellConfig.debuff) == "number" then	-- Always a table. 
		spellConfig.debuff = {spellConfig.debuff, 0}
	elseif spellConfig.debuff == nil then
		spellConfig.debuff = {0,0}	
	elseif type(spellConfig.debuff) ~= "table" then
		spellConfig.debuff = {0,0}
		error("newSpell", "debuff")
		print("1")
	end
	if type(spellConfig.debuff[1]) == "table" then -- We have debuff = { {spellID1, unhasted ticks}, {spellID2, unhasted ticks 2} }
		for i, debuff in ipairs(spellConfig.debuff) do
			if type(debuff[1]) ~= "number" or type(debuff[2]) ~= "number" then error("newSpell", "debuff")	else
				ns.spellbars.debuff[debuff[1]] = ns.spellbars.debuff[debuff[1]] or {}
				table.insert(ns.spellbars.debuff[debuff[1]], spellbar)				
			end
		end
	else
		ns.spellbars.debuff[spellConfig.debuff[1]] = ns.spellbars.debuff[spellConfig.debuff[1]] or {}
		table.insert(ns.spellbars.debuff[spellConfig.debuff[1]], spellbar)
	end

	--buff
	if type(spellConfig.buff) == "number" then
		spellConfig.buff = {spellConfig.buff}
	elseif spellConfig.buff == nil then
		spellConfig.buff = {}
	elseif type(spellConfig.buff) ~= "table" then
		spellConfig.buff = {} -- makes it easy. Don't have to deal with existance checking this way
		error("newSpell", "buff")
	end
	if type(spellConfig.buff[1]) == "table" then -- We have buff = { {spellID1, unhasted ticks}, {spellID2, unhasted ticks 2} }
		for i, buff in ipairs(spellConfig.buff) do
			if type(buff[1]) ~= "number" or type(buff[2]) ~= "number" then error("newSpell", "buff")	else
				ns.spellbars.buff[buff[1]] = ns.spellbars.buff[buff[1]] or {}
				table.insert(ns.spellbars.buff[buff[1]], spellbar)				
			end
		end
	else
		ns.spellbars.buff[spellConfig.buff[1]] = ns.spellbars.buff[spellConfig.buff[1]] or {}
		table.insert(ns.spellbars.buff[spellConfig.buff[1]], spellbar)
	end
	
	--unitID
	if type(spellConfig.unitID) == "string" then -- unitId can be either a string of 1 unitID in which case both debuff and buff will check that unit, a table of unitIDs of the form {debuffUnitID, buffUnitID} or nil, in which case it defaults to target for both
		spellConfig.unitID = {spellConfig.unitID,spellConfig.unitID}
	elseif type(spellConfig.unitID) ~= "table" then
		spellConfig.unitID = {"target", "target"} -- makes it easy. Don't have to deal with existance checking this way
	else -- it's a table
		if #spellConfig.unitID > 2 or #spellConfig.unitID < 2 or type(spellConfig.unitID[1]) ~= "string" or type(spellConfig.unitID[2]) ~= "string" then
			spellConfig.unitID = {"target", "target"}
			error("newSpell", "unitID")
		end
	end
	ns.spellbars.unitID[v] = ns.spellbars.unitID[v] or {}
	table.insert(ns.spellbars.unitID[v], spellbar)
	
	
		--stance
	if type(spellConfig.stance) == "number" then
		spellConfig.stance = {spellConfig.stance}
	elseif spellConfig.stance == nil then
		spellConfig.stance = {}
		for i=0,GetNumShapeshiftForms() do
			table.insert(spellConfig.stance, i)
		end
	elseif type(spellConfig.stance) ~= "table" then
		spellConfig.stance = {} -- makes it easy. Don't have to deal with existance checking this way
		for i=0,GetNumShapeshiftForms() do
			table.insert(spellConfig.stance, i)
		end 
		error("newSpell", "stance")
	end
	for i,v in pairs(spellConfig.stance) do
		if type(v) == "number" then
			ns.spellbars.stance[v] = ns.spellbars.stance[v] or {}
			table.insert(ns.spellbars.stance[v], spellbar)
		else
			error("newSpell", "stance")
		end
	end
	
		--tree
	if type(spellConfig.requiredTree) == "number" then
		spellConfig.requiredTree = {spellConfig.requiredTree}
	elseif spellConfig.requiredTree == nil then
		spellConfig.requiredTree = (select(2,UnitClass("player"))=="DRUID") and {1,2,3,4} or {1,2,3}
	elseif type(spellConfig.requiredTree) ~= "table" then
		spellConfig.requiredTree = (select(2,UnitClass("player"))=="DRUID") and {1,2,3,4} or {1,2,3} -- makes it easy. Don't have to deal with existance checking this way
		error("newSpell", "tree")
	end
	for i,v in pairs(spellConfig.requiredTree) do
		if type(v) == "number" and v >= 1 and v <= (select(2,UnitClass("player"))=="DRUID" and 4 or 3) then
			ns.spellbars.tree[v] = ns.spellbars.tree[v] or {}
			table.insert(ns.spellbars.tree[v], spellbar)
		else
			error("newSpell", "tree")
		end
	end
	
		--cast
	if type(spellConfig.cast) == "number" then
		spellConfig.cast = {spellConfig.cast}
	elseif spellConfig.cast == nil then
		spellConfig.cast = {}
	elseif type(spellConfig.cast) ~= "table" then
		spellConfig.cast = {} -- makes it easy. Don't have to deal with existance checking this way
		error("newSpell", "cast")
	end
	for i,v in pairs(spellConfig.cast) do
		if type(v) == "number" and v >= 1 then
			ns.spellbars.cast[v] = ns.spellbars.cast[v] or {}
			table.insert(ns.spellbars.cast[v], spellbar)
		else
			error("newSpell", "cast")
		end
	end
	
		--talent
	if type(spellConfig.requiredTalent) == "number" then
		spellConfig.requiredTalent = {spellConfig.requiredTalent}
	elseif spellConfig.requiredTalent == nil then
		spellConfig.requiredTalent = {}
		for i=1,18 do
			table.insert(spellConfig.requiredTalent, i)
		end
	elseif type(spellConfig.requiredTalent) ~= "table" then
		spellConfig.requiredTalent = {}
		for i=1,18 do -- makes it easy. Don't have to deal with existance checking later on this way
			table.insert(spellConfig.requiredTalent, i)
		end 
		error("newSpell", "talent")
	end
	for i,v in pairs(spellConfig.requiredTalent) do

		if type(v) == "number" and v <= 18 and v >= 1 then
			ns.spellbars.talent[v] = ns.spellbars.talent[v] or {}
			table.insert(ns.spellbars.talent[v], spellbar)
		else
			error("newSpell", "talent")
		end
	end
	
	--requiredLevel
	if not spellConfig.requiredLevel then
		spellConfig.requiredLevel = 0
	elseif type(spellConfig.requiredLevel) ~= "number" or spellConfig.requiredLevel < 0 or spellConfig.requiredLevel > GetMaxPlayerLevel() then
		spellConfig.requiredLevel = 0
		error("newSpell", "requiredLevel")
	end
	for i=spellConfig.requiredLevel, GetMaxPlayerLevel() do
		ns.spellbars.level[i] = ns.spellbars.level[i] or {}
		table.insert(ns.spellbars.level[i], spellbar)
	end
	-- Done adding spellbar to correct tables

	return spellbar
end




-- checkRequirements: 
--  Sets all frames which meet current active requirements active. 
function ns:checkRequirements()
	table.wipe(ns.spellbars.active)
	
	local toActivate = tableMerge(ns.spellbars.tree[GetSpecialization()] or {}, ns.spellbars.level[UnitLevel("player")] or {}, ns.spellbars.stance[GetShapeshiftForm()])
	local talents = {}
	for i=1, 18 do -- have to get a list of all spellbars which match currently learned talents, and then merge that with toActivate
		if select(5,GetTalentInfo(i)) and select(6,GetTalentInfo(i)) then -- talent is <learned></learned>
			for k,spellbar in pairs(ns.spellbars.talent[i]) do
				local temp, found = spellbar, false
				for _,spellbar2 in ipairs(talents) do
					if spellbar == spellbar2 then
						found = true
					end
				end
				if not found then 
					table.insert(talents, spellbar)
				end
			end
		end
	end
	toActivate = tableMerge(toActivate, talents)
	-- toActivate now holds all the spellbars which match all of the active requirements. Easy :D
	
	-- Order the spellbars by their index to make it easy later to set them up in the correct order

	
	for i,spellbar in pairs(toActivate) do
		table.insert(ns.spellbars.active, spellbar) -- Can now assume that ns.spellbars.active has been sorted by creationIndex
	end
	table.sort(ns.spellbars.active, function(a,b) return a.index < b.index end)
end

--  [[ SETTING FUNCTIONS ]] --


-- updateSettings:
--  Updates the settings of the mainframe, as well as any active frames. This is called either when ns.config/similar are updated, or at EH init
local updating
function ns:updateSettings() 
	updating = true
	local f = ns.frame
	
	f:SetWidth(ns.config.width)
	f:SetHeight( ((#ns.spellbars.active>0 and #ns.spellbars.active or 1) > ns.config.minBars and ns.config.height or (#ns.spellbars.active>0 and #ns.spellbars.active or 1)*(ns.config.height/ (#ns.spellbars.active>0 and #ns.spellbars.active or 1))) - ns.config.barSpacing)
	--print(f:GetHeight())
	if ns.config.backdrop then -- make backdrop settings
		f.texture = f.texture or CreateFrame("Frame") -- make sure we have a backdrop texture
		f.texture:SetBackdrop({
			bgFile = ns.config.texture,
			edgeFile = ns.config.border,
			tile = true,
			tileSize = 32,
			edgeSize = ns.config.edgeSize,
			insets = ns.config.inset,			
		})
		f.texture:ClearAllPoints() -- set padding
		f.texture:SetPoint("TOPLEFT", f, "TOPLEFT")
		f.texture:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
		f.texture:SetBackdropColor(getColor("bg"))
		f.texture:SetBackdropBorderColor(getColor("border"))
		--f.texture:SetAlpha(ns.colors.bg[4])
		f.texture:SetFrameStrata("LOW")
		
	end -- end backdrop settings
	
	--start spellbar settings
	local prevSpellbar
	barSpacing = ns.config.barSpacing
	for i,spellbar in ipairs(ns.spellbars.active) do -- now we set up the active bars. These are in order of creationIndex
		spellbar.updateSettings(spellbar)
		spellbar:Show()
		if i==1 then		
			f.width = spellbar.bar:GetWidth()
			spellbar:ClearAllPoints()
			spellbar:SetPoint("TOPLEFT", f, "TOPLEFT", ns.config.padding, -ns.config.padding)
			spellbar:SetPoint("TOPRIGHT", f, "TOPRIGHT", -ns.config.padding, -ns.config.padding)
			
		else
			spellbar:ClearAllPoints()
			spellbar:SetPoint("TOPLEFT", prevSpellbar, "BOTTOMLEFT", 0, -barSpacing)
			spellbar:SetPoint("TOPRIGHT", prevSpellbar, "BOTTOMRIGHT", 0, -barSpacing)
		end
		
		spellbar.updateIcon(spellbar, getIconForSpellbar(spellbar), 0) 
		-- Default icon is the first cast, then the first debuff, then the first cooldown, then the first playerbuff. If it's not one of these then what the fuck is this spellbar for :3
		
		spellbar.bar:SetPoint("TOPLEFT", spellbar, "TOPLEFT", self.config.icons and (self.config.iconWidth < 1 and (self.config.width-2*self.config.padding)*self.config.iconWidth or self.config.iconWidth)+1 or 0, 0) -- inheirits width settings natually from width of spellbar and icon
		
		spellbar.cast:SetHeight(spellbar:GetHeight() * (getLayout("cast")[2]-getLayout("cast")[1]))
		
		-- spellbar.cooldown:SetHeight(spellbar:GetHeight() * (getLayout("cooldown")[2]-getLayout("cooldown")[1]))
		
		-- spellbar.debuff:SetHeight(spellbar:GetHeight() * (getLayout("debuff")[2]-getLayout("debuff")[1]))
		
		-- spellbar.buff:SetHeight(spellbar:GetHeight() * (getLayout("buff")[2]-getLayout("buff")[1]))
		
		spellbar.gcd:SetTexture(getColor("gcd"))

		spellbar.cast:SetPoint("TOPLEFT", ns.frame.barAnchor, "TOPLEFT", ns:getPositionByTime(0),0)
		spellbar.cast:SetPoint("BOTTOMLEFT", ns.frame.barAnchor, "BOTTOMLEFT", ns:getPositionByTime(0),0)
		
		prevSpellbar = spellbar

	end
	
	-- end spellbar settings
	
	-- start GCD setting
	
	-- end GCD setting
	
	--store the width of the spellbar.bar
	f.width = prevSpellbar.bar:GetWidth()
	ns.frame.barAnchor:SetPoint("TOPLEFT", ns.frame, "TOPRIGHT", -ns.frame.width - ns.config.padding - 2, 0)
	ns.frame.barAnchor:SetPoint("BOTTOMLEFT", ns.frame, "BOTTOMRIGHT", -ns.frame.width - ns.config.padding - 2, 0)
	ns.gcd:SetPoint("TOPLEFT", ns.frame.barAnchor, "TOPRIGHT")
	ns.gcd:SetPoint("BOTTOMLEFT", ns.frame.barAnchor, "BOTTOMRIGHT")

	--Update the gcd frame
	updating = nil
end

function ns:applySettings()
	if updating then return end
	ns:checkRequirements()
	for i,spellbar in ipairs(ns.spellbars.index) do
		spellbar:Hide()
	end
	if #ns.spellbars.active > 0 then -- make sure we actually have bars to show.
		ns.frame:Show()
		ns.shown = true
		ns:updateSettings()
	else
		ns.shown = nil
		ns.frame:Hide()
	end
end



--  [[ GCD INDICATOR ]] --


function ns:startGCD()
	if not ns.shown then return end
	
	local start, duration = GetSpellCooldown(ns.config.gcdSpellID)
	local endTime
	if start and duration and duration > 0 then
		endTime = start+duration
	else
		endTime = nil
	end
	if endTime then
		ns.gcd:Show()
		ns.gcd:SetScript("OnUpdate", function(self, elapsed, ...)
			if endTime then
				local width = ns:getPositionByTime(endTime - GetTime())
				if width > ns:getPositionByTime(0) then
					ns.gcd:SetWidth(width)
				else
					ns.gcd:SetScript("OnUpdate", nil)
					ns.gcd:Hide()
				end
			else
				ns.gcd:SetScript("OnUpdate", nil)
				ns.gcd:Hide()
			end
		end)
	end
end



-- getPositionByTime(t)
--  t: time in seconds away from 0 to get the position of. -3 would return the position of the beginning of the spellbar by default config
function ns:getPositionByTime(t)
	local past, future, width = ns.config.past, ns.config.future, ns.frame.width
	-- each pixel is (future-past)/width seconds long
	-- the beginning of the bar is the far left, so an input of -3 should return an offset of 0
	-- a value of 0 would equal 3 s in the future if we recenter the bar around t = -3
	t = t > future and future or t < past and past or t -- limit the return to actually be in bounds
	return t*(width/(future-past)) + (width/(future-past))*-past
end


--   [[ buff/debuff/cooldown helpers ]]   --

function ns:addCooldown(spellbar, endTime)
	if not spellbar or not endTime then return end
	if endTime < ns.config.past then return end
	--spellbar.cooldown:Show()
	--spellbar.cooldown:SetPoint("LEFT", ns.frame.barAnchor, "RIGHT", ns:getPositionByTime(0), 0)

	spellbar.updating["cooldown"] = endTime
	local currTime = GetTime()
	local startTime = currTime
	print("Requested Texture")
	local texture = ns:getTempTexture(spellbar)

	texture:SetPoint("TOP", spellbar, "TOP")
	texture:SetPoint("LEFT", ns.frame.barAnchor, "RIGHT")
	texture:SetHeight(spellbar:GetHeight() * (getLayout("cooldown")[2]-getLayout("cooldown")[1]))
	texture:SetDrawLayer("BORDER", 1)
	texture:SetTexture(ns.config.texture)
	texture:SetVertexColor(getColor("cooldown"))
	texture:SetBlendMode(ns.blendModes.cooldown)
	
	ns:addSpellUpdate(spellbar, "cooldown", function(self, elapsed, ...)
		currTime = currTime + elapsed
		if endTime then
			local width = ns:getPositionByTime(endTime - currTime)
			--print(width)
			if width > 0 then
				if currTime - startTime < -ns.config.past then
					texture:SetPoint("LEFT", ns.frame.barAnchor, "RIGHT", ns:getPositionByTime(0-(currTime - startTime)), 0)
					texture:SetWidth(width - ns:getPositionByTime(startTime - currTime))
				else
					texture:SetPoint("LEFT", ns.frame.barAnchor, "RIGHT")
					texture:SetWidth(width)
				end		
			
			else
				ns:removeSpellUpdate(spellbar, "cooldown")
				ns:freeTempTexture(texture)
			end
		else
			ns:removeSpellUpdate(spellbar, "cooldown")
			ns:freeTempTexture(texture)
		end
	end)
end


local textures = {
	num = 0,
	free = {},
	used = {},
}
function ns:getTempTexture(parent) -- This can save some processing time/garbage collection time when creating/using lots of textures
	local texture
	if not textures.free[1] then
		texture = ns.frame:CreateTexture("EventHorizonTexture"..(textures.num))
		textures.num = textures.num+1
		print("Made new texture", texture:GetName())
	else
		texture = textures.free[1]
		table.remove(textures.free, 1)
	end
	table.insert(textures.used, texture)

	texture:SetParent(parent)
	print("Gave Texture: ", texture:GetName())
	return texture
end

function ns:freeTempTexture(texture)
	texture:Hide()
	for i,v in ipairs(textures.used) do
		if v == texture then
			table.remove(textures.used, i)
			table.insert(textures.free, texture)
			return
		end
	end
	--If we get here the texture object passed in wasn't in our used table. No idea what to do. Nothing I guess
end

function ns:addSpellUpdate(spellbar, key, fxn)
	spellbar.update = spellbar.update or {}
	if not spellbar:GetScript("OnUpdate") then
		spellbar:SetScript("OnUpdate", function(self, elapsed, ...)
			for k,fxn in pairs(spellbar.update) do
				fxn(self, elapsed)
			end				
		end)
	end
	spellbar.update[key] = fxn
	spellbar.updateCount = (spellbar.updateCount or 0) + 1
end

function ns:removeSpellUpdate(spellbar, key)
	if spellbar.update[key] then
		if spellbar.updateCount == 1 then
			spellbar:SetScript("OnUpdate", nil)
		end
		spellbar.update[key] = nil
		spellbar.updateCount = spellbar.updateCount - 1
	end
end












--  [[ ADDON INIT FUNCTIONS ]] --
local enable = true
local addonInit = true
addEvent(function(...)
	if not enable then return end
	local class = select(2,UnitClass('player'))
	
	LoadAddOn("EventHorizon_".. class:sub(1,1)..class:sub(2):lower())
	EventHorizon:InitializeClass()
	
	--print(GetShapeshiftForm(), GetNumShapeshiftForms())

	ns.frame:SetScript("OnUpdate", function() 
		
		if GetShapeshiftForm() <= GetNumShapeshiftForms() then
			ns:applySettings()
			ns.frame:SetPoint("CENTER", UIParent, "CENTER", 0,-200)
			
			ns.frame:SetScript("OnUpdate", nil)

			
			ns.gcd:Hide()
			
					
					
					
			addEvent(function(...)
				if not addonInit then -- make sure that we're not waiting on the addon to load still (Stupid f'ing GetShapeshiftForm)
					ns:applySettings()
				end
			end,
			"UPDATE_SHAPESHIFT_FORM",
			"UPDATE_SHAPESHIFT_FORMS",
			"PLAYER_SPECIALIZATION_UPDATE",
			"PLAYER_SPECIALIZATION_CHANGED",
			"PLAYER_LEVEL_UP",
			"GLYPH_ADDED",
			"GLYPH_ENABLED",
			"GLYPH_REMOVED",
			"GLYPH_UPDATED",
			"GLYPH_DISABLED",
			"LFG_LOCK_INFO_RECEIVED"
			)

			addEvent(function(...)
				ns:startGCD()
				print("Start")
				for _, spellbar in ipairs(ns.spellbars.active) do
					local start, duration = GetSpellCooldown(ns.config.gcdSpellID)
					local endTime = start + duration
					print("GCD:", endTime)
					for i,spellID in ipairs(spellbar.spellConfig.cooldown) do
						local start2, duration2 = GetSpellCooldown(spellID)
						--print(duration2 + start2)
						if endTime < duration2 + start2 and IsSpellKnown(spellID) then
							endTime = duration2 + start2
							print("EndTime:", endTime)
						end
					end
					if endTime > (spellbar.updating["cooldown"] or start + duration) then
						print("Added CD")
						ns:addCooldown(spellbar, endTime)
					end
				end
			end,
			"SPELL_UPDATE_COOLDOWN"
			)


			
			
			
			
			
			
			addonInit = nil
		end
	end)
	
end,
"PLAYER_ENTERING_WORLD")


function ns:active()
	for i,v in pairs(ns.spellbars.active) do
		print(v.index .. " : " .. getIconForSpellbar(v))
	end
end
