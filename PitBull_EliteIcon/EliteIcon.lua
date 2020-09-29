﻿if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 1639 $"):match("%d+"))

local PitBull = PitBull
local PitBull_EliteIcon = PitBull:NewModule("EliteIcon", "LibRockEvent-1.0")
local self = PitBull_EliteIcon
if PitBull.revision < VERSION then
	PitBull.version = "r" .. VERSION
	PitBull.revision = VERSION
	PitBull.date = ("$Date: 2008-03-30 05:33:10 +0000 (Sun, 30 Mar 2008) $"):match("%d%d%d%d%-%d%d%-%d%d")
end

local localization = (GetLocale() == "koKR") and {
	["Show an icon on the unit frame when the unit is in PvP mode."] = "유닛이 PvP 모드 상태인 경우에 유닛 프레임에 아이콘을 보여줍니다.",
	["PvP"] = "PvP",
	["Change settings for the PvP icon."] = "PvP 아이콘을 위한 설정을 변경합니다.",
	["Enable"] = "활성화",
	["Enables the PvP icon, indicating if this unit is flagged for PvP."] = "이 유닛이 PvP 전투 상태임을 가리키는 PvP 아이콘을 활성화합니다.",
} or (GetLocale() == "zhCN") and {
	["Show an icon on the unit frame when the unit is in PvP mode."] = "当单位开启了PvP在其单位框体上显示一个图标。",
	["PvP"] = "PvP",
	["Change settings for the PvP icon."] = "PvP图标选项。",
	["Enable"] = "启用",
	["Enables the PvP icon, indicating if this unit is flagged for PvP."] = "启用PvP图标，指示该单位是否开启了PvP。",
} or (GetLocale() == "frFR") and {
	["Show an icon on the unit frame when the unit is in PvP mode."] = "Affiche une icône sur la fenêtre d'unité lorsque l'unité est en mode JcJ.",
	["PvP"] = "JcJ",
	["Change settings for the PvP icon."] = "Modifier les paramètres pour l'icône JcJ.",
	["Enable"] = "Activer",
	["Enables the PvP icon, indicating if this unit is flagged for PvP."] = "Active l'icône JcJ, indiquant si l'unité est en mode JcJ.",
} or (GetLocale() == "zhTW") and {
	["Show an icon on the unit frame when the unit is in PvP mode."] = "當單位處於PVP狀態下在單位框架上顯示PVP圖示",
	["PvP"] = "PvP",
	["Change settings for the PvP icon."] = "更改PVP圖示設定.",
	["Enable"] = "啟用",
	["Enables the PvP icon, indicating if this unit is flagged for PvP."] = "啟用PVP圖示,指示物件PVP標誌.",
} or {}

local L = PitBull:L("PitBull-EliteIcon", localization)

self.desc = L["Show a classification icon on the unit frame."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame

PitBull_EliteIcon:RegisterPitBullChildFrames('eliteIcon')
PitBull_EliteIcon:RegisterPitBullIconLayoutHandler('eliteIcon', 5)

function PitBull_EliteIcon:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("EliteIcon")
	PitBull:SetDatabaseNamespaceDefaults("EliteIcon", "profile", {
		groups = {
			['*'] = {},
		},
	})
end

function PitBull_EliteIcon:OnEnable()
	self:AddEventListener("UNIT_CLASSIFICATION_CHANGED", "OnEvent")
	-- self:AddEventListener("PLAYER_FLAGS_CHANGED", "OnEvent")
	-- self:AddEventListener("UNIT_FACTION", "OnEvent")
end


local configMode = PitBull.configMode

function PitBull_EliteIcon:OnEvent(ns, event, unit)
	self:Update(unit)
end

function PitBull_EliteIcon:OnChangeConfigMode(value)
	configMode = value
	for unit, frame in PitBull:IterateUnitFrames() do
		self:Update(unit, true)
	end
end

local configMode_icons = {}

function PitBull_EliteIcon:Update(unit, noPet)
	-- if not unit then
	-- 	unit = "player"
	-- end
	
	for frame in PitBull:IterateUnitFramesForUnit(unit) do
		if self.db.profile.groups[frame.group].ignore then
			if frame.eliteIcon then
				frame.eliteIcon = delFrame(frame.eliteIcon)
				PitBull:UpdateLayout(frame)
			end
			return
		end
		
	-- 	local has = false
		
	-- 	if UnitIsPVPFreeForAll(unit) then
	-- 		has = 'FFA'
	-- 	else
	-- 		local faction = UnitFactionGroup(unit)
	-- 		if faction and (UnitIsPVP(unit) or configMode) then
	-- 			has = faction
	-- 		end
	-- 	end
	-- 	if not has and configMode then
	-- 		has = configMode_icons[unit]
	-- 		if not has then
	-- 			if unit == "player" or unit == "pet" or unit:find("^party%d$") or unit:find("^raid%d+$") or unit:find("^partypet%d$") or unit:find("^raidpet%d+$") or unit == "targettarget" or (unit:find("targettarget$") and not unit:find("targettargettarget$")) then
	-- 				has = UnitFactionGroup("player")
	-- 			elseif unit:find("^focus") then
	-- 				has = "FFA"
	-- 			else
	-- 				local faction = UnitFactionGroup("player")
	-- 				if faction == "Horde" then
	-- 					has = "Alliance"
	-- 				else
	-- 					has = "Horde"
	-- 				end
	-- 			end
	-- 			configMode_icons[unit] = has
	-- 		end
	-- 	end
		
		local classif = UnitClassification(unit)
		-- if has then
			if not frame.eliteIcon then
				frame.eliteIcon = newFrame("Texture", frame.overlay, "ARTWORK")
				frame.eliteIcon:Hide()
				PitBull:UpdateLayout(frame)
			end
			if(classif == "rare") then
				frame.eliteIcon:SetTexture("Interface\\AddOns\\PitBull_EliteIcon\\UI-DialogBox-Silver-Dragon-right")
				frame.eliteIcon:Show()
			elseif classif == "normal" then
				frame.eliteIcon:SetTexture(nil)
			else
				frame.eliteIcon:SetTexture("Interface\\AddOns\\PitBull_EliteIcon\\UI-DialogBox-Gold-Dragon-right")
				frame.eliteIcon:Show()
			end
				
			
			-- if has == "Horde" then
			-- 	frame.eliteIcon:SetTexCoord(0.08, 0.58, 0.045, 0.545)
			-- elseif has == "Alliance" then
			-- 	frame.eliteIcon:SetTexCoord(0.07, 0.58, 0.06, 0.57)
			-- else -- FFA
			-- 	frame.eliteIcon:SetTexCoord(0.05, 0.605, 0.015, 0.57)
			-- end
		-- else
		-- 	if frame.eliteIcon then
		-- 		frame.eliteIcon = delFrame(frame.eliteIcon)

		-- 		PitBull:UpdateLayout(frame)
			-- end
		-- end
	-- end
	
	-- if not noPet then
	-- 	if unit == "player" then
	-- 		self:Update("pet")
	-- 	else
	-- 		local num = unit:match("^party(%d)$")
	-- 		if num then
	-- 			self:Update("partypet" .. num)
	-- 		end
	-- 	end
	end
end

function PitBull_EliteIcon:OnUpdateFrame(unit, frame)
	self:Update(unit, true)
end

function PitBull_EliteIcon:OnClearUnitFrame(unit, frame)
	if frame.eliteIcon then
		frame.eliteIcon = delFrame(frame.eliteIcon)
	end
end

local function getEnabled(group)
	return not PitBull_EliteIcon.db.profile.groups[group].ignore
end
local function setEnabled(group, value)
	value = not value
	PitBull_EliteIcon.db.profile.groups[group].ignore = value
	if value then
		for unit,frame in PitBull:IterateUnitFramesByGroup(group) do
			if frame.eliteIcon then
				frame.eliteIcon = delFrame(frame.eliteIcon)
			end
		end
	else
		for unit in PitBull:IterateUnitFramesByGroup(group) do
			PitBull_EliteIcon:Update(unit)
		end
	end
end
PitBull_EliteIcon:RegisterPitBullOptionsMethod(function(group)
	return {
		type = 'group',
		name = L["Elite"],
		desc = L["Change settings for the Eite icon."],
		args = {
			toggle = {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Enables the Eite indicator icon"],
				get = getEnabled,
				set = setEnabled,
				passValue = group,
			}
		}
	}
end)

