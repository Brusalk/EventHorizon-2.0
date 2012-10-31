local EHN,ns = ...

local _,class = UnitClass('player')	-- These locals make in-line conditions a little easier. See the color section for a few examples.
local DK = class == "DEATHKNIGHT"
local Druid = class == "DRUID"
local Hunter = class == "HUNTER"
local Mage = class == "MAGE"
local Paladin = class == "PALADIN"
local Priest = class == "PRIEST"
local Rogue = class == "ROGUE"
local Shaman = class == "SHAMAN"
local Warlock = class == "WARLOCK"
local Warrior = class == "WARRIOR"
ns.colors = {}


-- DO NOT MODIFY ABOVE THIS LINE --




ns.cConfig = {
	-- Position
	anchor = {"CENTER", UIParent, "CENTER"},

	--Bar Options
	height = 100,        		-- Height of the total frame. EH will now automatically resize the height of spellBars depending on how many are active
	width = 400,        		-- Width of the total frame. (This includes the actual spellBar, as well as the icon) 
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
ns.cColors = {
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
ns.cBlendModes = {
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
ns.cLayouts = {
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
