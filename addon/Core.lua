AdvancedTooltips = LibStub("AceAddon-3.0"):NewAddon("AdvancedTooltips", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local libS = LibStub("AceSerializer-3.0")
local libC = LibStub("LibCompress")
local lwin = LibStub("LibWindow-1.1")
local libCE = libC:GetAddonEncodeTable()
local LSM = LibStub("LibSharedMedia-3.0")

ReoriginationArray_Weekly = {}
ReoriginationArray_Weekly[1] = 53568
ReoriginationArray_Weekly[2] = 53569
ReoriginationArray_Weekly[3] = 53570

ReoriginationArray_Stacks = {}
ReoriginationArray_Stacks[1] = 53571
ReoriginationArray_Stacks[2] = 53572
ReoriginationArray_Stacks[3] = 53573
ReoriginationArray_Stacks[4] = 53574
ReoriginationArray_Stacks[5] = 53575
ReoriginationArray_Stacks[6] = 53576
ReoriginationArray_Stacks[7] = 53577
ReoriginationArray_Stacks[8] = 53578
ReoriginationArray_Stacks[9] = 53579
ReoriginationArray_Stacks[10] = 53580

stats = {}
stats[9] = "Critical Strike"
stats[18] = "Haste"
stats[26] = "Mastery"
stats[29] = "Versatility"

ReoriginationArray_Descriptions = {}
ReoriginationArray_Descriptions[0] = "Reorigination Array Hidden Quest completed for this week."
ReoriginationArray_Descriptions[1] = "Defeat 1 more boss in Uldir this week."
ReoriginationArray_Descriptions[2] = "Defeat 2 more bosses in Uldir this week."
ReoriginationArray_Descriptions[3] = "Defeat 3 more bosses in Uldir this week."

E_CHANCE = 1
E_RPPM = 2
E_NAME = 3
E_ICD = 4
E_AZERITE_POWER = 5

-----------------
-- Addon Setup --
-----------------c

local AdvancedTooltips_Version = "1.0.0"

local configDefaults = {
	randomType = true
}

function AdvancedTooltips:GetConfig(key)
	if AdvancedTooltips_Config[key] == nil then
		return configDefaults[key]
	else
		return AdvancedTooltips_Config[key]
	end
end

function AdvancedTooltips:SetConfig(key, value)
	if configDefaults[key] == value then
		AdvancedTooltips_Config[key] = nil
	else
		AdvancedTooltips_Config[key] = value
	end
end

function AdvancedTooltips:RestoreDefaults()
	AdvancedTooltips_Config = {}
	self:UpdateMedia()
	self:UpdateDisplayed()
	LibStub("AceConfigRegistry-3.0"):NotifyChange("AdvancedTooltips")
end

local blizOptionsPanel
function AdvancedTooltips:OnInitialize()
	if AdvancedTooltips_State == nil then
		AdvancedTooltips_State = {  }
	end
	if AdvancedTooltips_Config == nil then AdvancedTooltips_Config = { } end

	local ver = AdvancedTooltips_Version
	if ver:sub(1,1) == "@" then ver = "dev" end
	
	local options = {
		name = "Advanced Tooltips "..ver,
		handler = AdvancedTooltips,
		type = "group",
		args = {
			RandomType = {
				type = "toggle",
				order = 1,
				name = "RandomType",
				desc = "Enables / Disables the showing of the type of a random effect.",
				set = function(info,val) AdvancedTooltips_Config.randomType = val end,
				get = function(inf0) return AdvancedTooltips_Config.randomType end
			},
			help = {
				type = "execute",
				order = 99,
				name = "Help",
				hidden = true,
				func = function()
					LibStub("AceConfigCmd-3.0").HandleCommand(self, "att", "AdvancedTooltips", "")
				end
			},
		}
	}

	self:RegisterChatCommand("att", "ChatCommand")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("AdvancedTooltips", options)

	-- Fill in reorigination array quest text
end

function AdvancedTooltips:ChatCommand(input)
	LibStub("AceConfigCmd-3.0").HandleCommand(self, "att", "AdvancedTooltips", input)
	print(AdvancedTooltips_Config.randomType)
end

function linkToID(itemLink)
	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	return tonumber(Id)
end

function itemEnchant(itemLink)
	local _, _, Color, Ltype, Id, Enchant, Gem1, Gem2, Gem3, Gem4, Suffix, Unique, LinkLvl, reforging, Name = string.find(itemLink, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	return tonumber(Enchant)
end

enter = false



local function ProcessItem(itemLink, tooltip)

	if itemLink == nil then return end

    local id = linkToID(itemLink)

    bonusLine = false
    

    if AdvancedTooltips.Items[id] ~= nil then
        item = AdvancedTooltips.Items[id]
		-- Check each spell possability
		for i=1, 5, 1 do
			-- See if we have info for this item
			if item[i] ~= nil and item[i][E_CHANCE] ~= nil then
				-- Add a spacing line
				if bonusLine == false then
					tooltip:AddLine(" ")
					bonusLine = true
				end

				local strLeft = item[i][E_NAME]
				local strRight = ""

				-- Check for RPPM
				if item[i][E_RPPM] == 1 then
					strRight = strRight..string.format("RPPM: %.2f (%.2f)", item[i][E_CHANCE], item[i][E_CHANCE] * (1 + UnitSpellHaste("player")/100))
					if item[i][E_ICD] ~= 0 then
						strRight = strRight..string.format(" (%.1f second ICD)", item[i][E_ICD] / 1000)
					end
				else
					strRight = strRight..string.format("%.2f%%", item[i][E_CHANCE])
					if item[i][E_ICD] ~= 0 then
						strRight = strRight..string.format(" (%.1f second ICD)", item[i][E_ICD]/ 1000)
					end
				end
				tooltip:AddDoubleLine(strLeft, strRight, 0, .7, .7, 0, .7, .7)
			end
		end
	end

	-- Heart of Azeroth
	if id == 158075 then
		tooltip:AddLine(" ")
    
        local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()
        local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        
        tooltip:AddDoubleLine("Rank",C_AzeriteItem.GetPowerLevel(azeriteItemLocation), 0,.7,.7,0,.7,.7)
        tooltip:AddDoubleLine("Progress",string.format("%d/%d (%.2f%%)", xp, totalLevelXP, xp/totalLevelXP*100), 0,.7,.7,0,.7,.7)

	end

end

function alreadyAdded(str1, tooltip)
	if str1 == nil then
		return false
	end

	for i = 1,15 do
		local frame = _G[tooltip:GetName() .. "TextLeft" .. i]
		local text
		if frame then text = frame:GetText() end
		if text and string.find(text, str1, 1, true) then return true end
	  end
end



function AddReoriginationInfo(tooltip)
	tooltip:AddLine(" ")
	-- Check the status of the reorigination count.
	ReoriginationLevel = 10
	while ReoriginationLevel > 0 and IsQuestFlaggedCompleted(ReoriginationArray_Stacks[ReoriginationLevel]) == false  do
		ReoriginationLevel = ReoriginationLevel - 1
	end

	tooltip:AddDoubleLine("Reorigination Stacks: ", ReoriginationLevel.."/10", 0, .7, .7, 0, .7, .7)

	if ReoriginationLevel ~= 10 then
		local WeeklyKills = 3
		while WeeklyKills ~= 0 and IsQuestFlaggedCompleted(ReoriginationArray_Weekly[WeeklyKills]) == false do
			WeeklyKills = WeeklyKills - 1
		end

		-- 0 = Red
		-- 1 or 2 = Yellow
		-- 3 = Green

		colorString = ""
		if WeeklyKills == 0 then
			colorString = "|cffff0000"
		elseif WeeklyKills ~= 3 then
			colorString = "|cffffff00"
		else
			colorString = "|cff00ff00"
		end

		tooltip:AddDoubleLine("Weekly: ", colorString..WeeklyKills.."/3", 0, .7, .7, 0, .7, .7)
	else
		tooltip:AddDoubleLine("Weekly", "|cff00ff00Max", 0, .7, .7, 0, .7, .7)
	end

	-- Grab the secondary stats to give the benefit
	local stat_values = {}
	for i, v in pairs(stats) do
		stat_values[i] = GetCombatRating(i)
	end

	-- find the largest
	local largest = 9
	for i,v in pairs(stat_values) do
		if stat_values[largest] < stat_values[i] then
			largest = i
		end
	end

	tooltip:AddDoubleLine("Bonus: ", 75 * ReoriginationLevel.." "..stats[largest], 0, .7, .7, 0, .7, .7)

end



function GetSpellChanceInfo(rank)
	if AdvancedTooltips.SpellData[rank] == nil then return nil end

	str = ""
	str2 = ""

    data = AdvancedTooltips.SpellData[rank]

	if data[E_CHANCE] ~= nil and data[E_CHANCE] < 100.0 then
			
		if data[E_RPPM] == 1 then
			str = "RPPM: "..string.format("%.2f", data[E_CHANCE])

			-- Get haste % to calc "actual" rppm
			local actualRPPM = data[E_CHANCE] * (1 + UnitSpellHaste("player")/100)
			local actualRPPMString = string.format("%.2f", actualRPPM)
			str = str.." ("..actualRPPMString..")"
			if data[E_ICD] ~= nil then
				str2 = str2..string.format("%.1f seconds ICD", data[E_ICD]/1000)
			end
		else
			str = string.format("%.2f%%", data[E_CHANCE])
		end
	elseif data[E_ICD] ~= nil then
		str = string.format("ICD: %.1f seconds", data[E_ICD]/1000)
	end

	itemData = {}
	itemData["str"] = str
	itemData["str2"] = str2
	itemData["name"] = select(1, GetSpellInfo(rank))

	-- 274441 - Barbed Shot has a chance equal to your critical strike chance to grant you 298 Agility for 8 sec.
	if rank == 274441 then
		itemData["str2"] = "Critical Strike chance"
		str = string.format("%.2f%%", GetCritChance())
		itemData["str"] = str
	end

	return itemData

end

function ItemTooltip(rank, tooltip)
	str = ""
	str2 = ""
	if AdvancedTooltips.SpellData[rank] ~= nil then
		str = GetSpellChanceInfo(rank)["str"]
		str2 = GetSpellChanceInfo(rank)["str2"]
		
		-- work around the talent bug (calls OnSetTooltipSpell twice)
		if str ~= "" and alreadyAdded(str, tooltip) then
			return
		end

		-- Seperator line, only if we're adding information
		-- don't return here so we can bring in reorigination array below (archive has no proc)
		if str~= "" then tooltip:AddLine(" ") end

		if str2 ~= "" then
			tooltip:AddDoubleLine(str, str2, 0, .7, .7, 0, .7, .7)
		else
			tooltip:AddLine(str, 0, .7, .7)
		end
	end
	
	-- Archive and Laser Matrix
	if rank == 280555 or rank == 280559 then
		AddReoriginationInfo(tooltip)
	end
end


function GetAzeriteSpellID(powerID)
	local powerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
  	if (powerInfo) then
    	local azeriteSpellID = powerInfo["spellID"]
    	return azeriteSpellID
  	end
end



function ScanForTrait(tooltip, powerName)
	-- AzeriteTooltip replaces the tooltip.
	-- Depending on the order of events (and I have NO idea of the order)
	-- we will get called either first or second, so we need to check for BOTH
	-- forms of the trait.
	-- |cFF00FF00 |T2000853::20:20:0:0:64:64:4:60:4:60|t {Name}|r
	-- is what we're looking for. We will gsub their
	-- \124 characters to \124\124
	local atooltipPattern = "||cFF00FF00%s-||T%d-:20:20:0:0:64:64:4:60:4:60||t%s-"..powerName.."||r"
	for i = 8, tooltip:NumLines() do
		local left = _G[tooltip:GetName().."TextLeft"..i]
		local text = left:GetText()
		if text ~= nil then
			local isATP = gsub(text, "\124", "\124\124"):match("||T%d+") ~= nil
			if text:find(powerName) and isATP == false then
				return true
			elseif gsub(text, "\124", "\124\124"):match(atooltipPattern, 1) then
				return true
			end
		end
    end
end

function AddEnchantInfo(tooltip, itemHeaderAdded, spellID)
	spellData = GetSpellChanceInfo(spellID)
	if spellData ~= nil then
		if itemHeaderAdded == false then
			tooltip:AddLine(" ")
		end
		tooltip:AddDoubleLine(spellData["name"], spellData["str"], 0, .7, .7, 0, .7, .7)
	end
end



function OnTooltip_Item(self, tooltip)
	if enter == true then
		return
	end
	enter = true

	local isUldirItem = false
	local itemHeaderAdded = false

	local name,link = self:GetItem()

	if link == nil then
		sn,sid = self:GetSpell()
		if sid ~= nil and sid ~= 0 then
			AddEnchantInfo(tooltip, itemHeaderAdded, sid)
		end
		return
	end

	ProcessItem(link, tooltip)

	-- Azerite check
	if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(link) then
        local tierInfo = C_AzeriteEmpoweredItem.GetAllTierInfoByItemID(linkToID(link))
		for i=1,3,1 do
			if tierInfo[i] ~= nil then
				for k,v in pairs(tierInfo[i]["azeritePowerIDs"]) do
                    if ScanForTrait(self, select(1, GetSpellInfo(GetAzeriteSpellID(v)))) then
						local spellInfo = GetSpellChanceInfo(GetAzeriteSpellID(v))
						if spellInfo ~= nil then
							-- If we have strings
							if spellInfo["str"] ~= nil and string.len(spellInfo["str"]) > 0 then
								if itemHeaderAdded == false then
									tooltip:AddLine(" ")
									itemHeaderAdded = true
								end
								tooltip:AddDoubleLine(spellInfo["name"], spellInfo["str"], 0, .7, .7, 0, .7, .7)
							end
						end
					end

					-- Check for Laser Matrix or Archive
					if i == 1 and (v == 485 or v == 483) then
						isUldirItem = true
					end
				end
			end
		end
	end

	if isUldirItem then
		-- Laser matrix or Archive...
		AddReoriginationInfo(tooltip)
	end


	-- Weapon Enchant
	if itemEnchant(link) ~= nil and itemEnchant(link) ~= 0 then
		if AdvancedTooltips.EnchantData[itemEnchant(link)] ~= nil then
			AddEnchantInfo(tooltip, itemHeaderAdded, AdvancedTooltips.EnchantData[itemEnchant(link)])
		end
	end

	-- Logic for looking at weapon enchants items
	if AdvancedTooltips.EnchantData[linkToID(link)] ~= nil then
		AddEnchantInfo(tooltip, itemHeaderAdded, AdvancedTooltips.EnchantData[linkToID(link)])
	end

	tooltip:Show()
	enter = false
end

function OnTooltipSpell(self, tooltip)
	-- Case for linked spell
	local name,rank,id = self:GetSpell()
	if rank ~= nil then
		ItemTooltip(rank, tooltip)
	end
	tooltip:Show()
end


function AdvancedTooltips:OnEnable()
	GameTooltip:HookScript("OnTooltipSetItem", function(...) OnTooltip_Item(..., GameTooltip) end)
	ItemRefTooltip:HookScript("OnTooltipSetItem", function(...) OnTooltip_Item(..., ItemRefTooltip) end)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", function(...) OnTooltip_Item(..., ShoppingTooltip1) end)
	ShoppingTooltip2:HookScript("OnTooltipSetItem", function(...) OnTooltip_Item(..., ShoppingTooltip2) end)
	GameTooltip:HookScript("OnTooltipSetSpell", function(...) OnTooltipSpell(..., GameTooltip) end)
	ItemRefTooltip:HookScript("OnTooltipSetSpell", function(...) OnTooltipSpell(..., ItemRefTooltip) end)
	WorldMapTooltip.ItemTooltip.Tooltip:HookScript('OnTooltipSetItem', function(...) OnTooltip_Item(..., WorldMapTooltip.ItemTooltip.Tooltip) end)
end

function AdvancedTooltips:AfterEnable()

end