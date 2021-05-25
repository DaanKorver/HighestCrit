SLASH_HCRIT1 = "/hcrit"

local playerGUID = UnitGUID("player")
local playerName = UnitName("player")
local MSG_CRITICAL_HIT = "|cffffcc00You just hit |cff00ccff%d |cffffcc00damage with your %s! Thats a new Record!"

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") 
f:SetScript("OnEvent", function(self, event)
	self:COMBAT_LOG_EVENT_UNFILTERED(CombatLogGetCurrentEventInfo())
end)

function PrintHighestCrit(amount, action)
	print(MSG_CRITICAL_HIT:format(amount, action))
end

function f:COMBAT_LOG_EVENT_UNFILTERED(...)
	local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
	local spellId, spellName, spellSchool
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand

	if subevent == "SWING_DAMAGE" then
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
	elseif subevent == "SPELL_DAMAGE" then
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
	end

	if critical and sourceGUID == playerGUID then
		-- get the link of the spell or the MELEE globalstring
		if HighestCrit < amount then
			HighestCrit = amount
			local action = spellId and GetSpellLink(spellId) or MELEE
			HighestCritAction = action
			PrintHighestCrit(amount, action)
			PlaySoundFile("Interface\\AddOns\\HighestCrit\\Sounds\\HighestCrit.mp3")
		end
	end
end

function getHighestCrit()
	if(HighestCrit == nil) then
		HighestCrit = 0
	end
	print("|cffffcc00Your highest ever critical strike was: " .. "|cff00ccff"  .. HighestCrit .. "|cffffcc00. Achieved with " .. HighestCritAction)
end

function resetHighestCrit()
	HighestCrit = 0
	print("|cffff0000Your highest ever critical strike has been reset")
end

local commands = {
	["show"] = {
		["description"] = "Shows your highest crit ever"
	},
	["reset"] = {
		["description"] = "Resets your current crit highscore"
	},
}

function showCommands()
	print("-------------- |cffffcc00Hcrit Commands |cffffffff--------------")
	for command in pairs(commands) do
		local desc = commands[command].description
		print("|cffffff00/hcrit " .. command .. " - |cffffffff" .. desc)
	end
	print("------------------------------------------------------")
end


function executeCommand(commandId)
	if(commandId == "show") then getHighestCrit()
	elseif(commandId == "reset") then resetHighestCrit()
	else showCommands()
	end
end





SlashCmdList["HCRIT"] = executeCommand