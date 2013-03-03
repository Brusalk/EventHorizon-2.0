local DEBUG = true
local EHN,ns = ...
--[[
-- [  TESTING FOR CORE FUNCTIONS  ] --
ns.Testing = {}
local f = CreateFrame("frame")

-- [ EH:addTimedBar() ] --
--  Test: accuracy

ns.Testing["addTimedBar"] = {
	one = {
		timeRun = 0,
		timeDone = 0,
		test = function(...)
			local duration, tickTime = ...
			ns:addTimedBar("core", ns.spellbars.active[1], duration or 4, "cooldown", tickTime or 1, "debuffTick")
			print("Starting Test: ", GetTime())
			ns.Testing["addTimedBar"].one.timeRun = GetTime()
			ns.Testing["addTimedBar"].one.timeDone = GetTime() + (duration or 4)
		end,
		done = function()
			print("Expected End: ", ns.Testing["addTimedBar"].one.timeDone - ns.config.past)
			print("Actually Fin: ", GetTime())
			print("Time Difference: ", ns.Testing["addTimedBar"].one.timeDone - ns.config.past - GetTime())
			if math.abs(ns.Testing["addTimedBar"].one.timeDone - ns.config.past - GetTime()) <= 0.01 then
				ns.Testing["addTimedBar"].one.result = true
			end
		end,
		running = false,
		result = false,
	},
	two = {
		timeRun = 0,
		timeDone = 0,
		test = function(...)
			local duration, tickTime = ...
			local timedBar = ns:addTimedBar("core", ns.spellbars.active[2], duration or 9, "cooldown", tickTime or 3, "debuffTick")
			print("Starting Test: ", GetTime())
			ns.Testing["addTimedBar"].two.timeRun = GetTime()
			ns.Testing["addTimedBar"].two.timeDone = GetTime() + (duration or 9)
			ns.Testing["addTimedBar"].two.testFrame = CreateFrame("frame")
			local f = ns.Testing["addTimedBar"].two.testFrame
			local t = 0
			f:SetScript("OnUpdate", function(self, elapsed)
				t = t + elapsed
				if t > 4 then -- After 4 seconds provide new tickTimes and endTimed
					timedBar = ns:updateTimedBar("core", timedBar, ns.Testing["addTimedBar"].two.timeDone + 8, 2) -- Add 4 more ticks to the bar ticking every 2 seconds
					ns.Testing["addTimedBar"].two.timedDone = ns.Testing["addTimedBar"].two.timeRun+3+3+2+2+2+2
					f:SetScript("OnUpdate", nil)
				end
			end)
		end,
		done = function()
			print("Expected End: ", ns.Testing["addTimedBar"].two.timeDone)
			print("Actually Fin: ", GetTime()+ns.config.past)
			print("Time Difference: ", ns.Testing["addTimedBar"].two.timeDone - GetTime() - ns.config.past)
			if math.abs(ns.Testing["addTimedBar"].two.timeDone - ns.config.past - GetTime()) <= 0.01 then
				ns.Testing["addTimedBar"].two.result = true
			end
		end,
		running = false,
		result = false,
	},
}


function ns:RunTests(testKey,...)
	for i, testTable in pairs(ns.Testing[testKey]) do
		testTable.running = true
		testTable.test(...)
	end
end

function ns:FinishTest(testKey, testIndex)
	local passedAllTests = true
	
	if testKey and testIndex == "all" then
		for testIndexTemp, testTable in pairs(ns.Testing[testKey]) do
			if ns.Testing[testKey][testIndexTemp].running then
				ns.Testing[testKey][testIndexTemp].done()
				passedAllTests = passedAllTests and (ns.Testing[testKey][testIndexTemp].result or false) or false
				ns.Testing[testKey][testIndexTemp].running = nil
			end
		end
		
		print(passedAllTests and "Passed All Tests Successfully!" or "Failed one or more tests")
	elseif testKey and testIndex and ns.Testing[testKey] and ns.Testing[testKey][testIndex].done and ns.Testing[testKey][testIndex].running then
		ns.Testing[testKey][testIndex].done()
		ns.Testing[testKey][testIndexTemp].running = nil
		print("Passed: ", ns.Testing[testKey][testIndex].result)
	end
end


--]]




