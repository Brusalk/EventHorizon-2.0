local EHN,ns = ...

local localeTable
local localeFxn = GetLocale

if localeFxn() == "enUS" then -- US English
    localeTable = {
        every = "every ",
    
    }
    
elseif localeFxn() == "deDE" then -- German localization
    localeTable = {
        every = "alle ",
    
    }

elseif localeFxn() == "enGB" then -- British English
    localeTable = {
        every = "every ",
    
    }

elseif localeFxn() == "enES" then -- Spanish (European)
    localeTable = {
        every = "cada ",
    
    }


elseif localeFxn() == "esMX" then -- Spanish (Latin American)
    localeTable = {
        every = "cada ",
    
    }


elseif localeFxn() == "frFr" then -- French
    localeTable = {
        every = "les ",
    
    }
--[[
elseif localeFxn() == "koKR" then -- Korean (No kr.wowhead.com :(((
    localeTable = {
        every = nil,
    
    }


elseif localeFxn() == "ruRU" then -- Russian
    localeTable = {
        every = "? ",
    
    }


elseif localeFxn() == "zhCN" then -- Chinese (simplified)
    localeTable = {
        every = nil,
    
    }


elseif localeFxn() == "zhTW" then -- Chinese (traditional)
    localeTable = {
        every = nil,
    
    }
--]]
else
    print("EventHorizon: There is no localization for your current locale ".. localeFxn() .. ". If you would be so kind as to help me out I'd be very appreciative. In the mean-time DoT/HoT/Channel ticks will not work!")
    
end




ns.localization = setmetatable(localeTable or {}, {__index=function(t,i) return i end})

