local DEBUG = true
local EHN,ns = ...

--[[  TESTING FOR CORE FUNCTIONS  ]]--
ns.Testing = {}
local f = CreateFrame("frame")

--[[ EH:addTimedBar() ]]--
--  Test: accuracy

ns.Testing["addTimedBar"] = {
	one = {
		timeRun = 0,
		timeDone = 0,
		test = function(...)
			local duration, tickTime = ...
			ns:addTimedBar("core", ns.spellbars.active[1], duration or 4, 3, "cooldown", tickTime or 1, "debuffTick")
			print("Starting Test: ", GetTime())
			ns.Testing["addTimedBar"].one.timeRun = GetTime()
			ns.Testing["addTimedBar"].one.timeDone = GetTime() + (duration or 4)
		end,
		done = function()
			print("Expected End: ", ns.Testing["addTimedBar"].one.timeDone - ns.config.past)
			print("Actually Fin: ", GetTime())
			print("Time Difference: ", ns.Testing["addTimedBar"].one.timeDone - ns.config.past - GetTime())
		end,
		result = true,
	},
}


function ns:RunTests(testKey,...)
	for i, testTable in pairs(ns.Testing[testKey]) do
		testTable.test(...)
	end
end