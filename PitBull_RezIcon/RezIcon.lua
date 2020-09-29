if select(6, GetAddOnInfo("PitBull_" .. (debugstack():match("[i%.][t%.][B%.]ull\\Modules\\(.-)\\") or debugstack():match("[i%.][t%.][B%.]ull\\(.-)\\") or ""))) ~= "MISSING" then return end

local VERSION = tonumber(("$Revision: 1639 $"):match("%d+"))

local PitBull = PitBull
local PitBull_RezIcon = PitBull:NewModule("RezIcon","LibRockEvent-1.0", "LibRockHook-1.0")
local self = PitBull_RezIcon
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

local L = PitBull:L("PitBull-RezIcon", localization)

self.desc = L["Show a classification icon on the unit frame."]

local newFrame, delFrame = PitBull.newFrame, PitBull.delFrame
-- local ResComm = LibStub:GetLibrary("LibResComm-1.0");
-- local ResComm = LibStub:GetLibrary("LibResComm-1.0")
-- local ResComm = LibStub("LibResComm-1.0")

local ResComm
local banzai
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitName = UnitName
local ressed = false

-- local ResComm = LibStub( "LibResComm-1.0")

PitBull_RezIcon:RegisterPitBullChildFrames('rezIcon')
PitBull_RezIcon:RegisterPitBullIconLayoutHandler('rezIcon', 5)

function PitBull_RezIcon:OnInitialize()
	self.db = PitBull:GetDatabaseNamespace("RezIcon")
	PitBull:SetDatabaseNamespaceDefaults("RezIcon", "profile", {
		groups = {
			['*'] = {},
		},
	})
end

function PitBull_RezIcon:OnEnable()
	-- ResComm = Rock("LibResComm-1.0")
	ResComm = Rock("LibResComm-1.0", false, true)
	if not ResComm then
		error("PitBull_Banzai requires the library LibBanzai-2.0 to be available.")
	end
	
	-- if not ResComm then
	-- 	error("PitBull_RezIcon requires LibResComm-1.0 to be available.")
	-- end
	
	ResComm.RegisterCallback(self, "ResComm_ResStart")
	ResComm.RegisterCallback(self, "ResComm_ResEnd")
	ResComm.RegisterCallback(self, "ResComm_CanRes");
	ResComm.RegisterCallback(self, "ResComm_Ressed");
	ResComm.RegisterCallback(self, "ResComm_ResExpired");
	
end

function PitBull_RezIcon:ResComm_ResStart(event, resser, endTime, target)
	-- print("aaaaaaaaaaaaabbbb");
	-- SendChatMessage(resser .. " is ressing " .. target, "PARTY");
	-- self:Update()
	for unit in PitBull:IterateUnitFrames() do
		self:Update(unit, frame, event)
	end
end
function PitBull_RezIcon:ResComm_ResEnd(event, resser, target, complete)
	-- print("aaaaaaaaaaaaabbbb");
	-- SendChatMessage(resser .. " canceled ressing " .. target, "PARTY");
	-- self:Update()
	-- print(complete)
	for unit in PitBull:IterateUnitFrames() do
		self:Update(unit, frame, event, complete)
	end
end
function PitBull_RezIcon:ResComm_CanRes(event, name, typeToken, typeString)
	for unit in PitBull:IterateUnitFrames() do
		self:Update(unit, frame, event)
	end
end
function PitBull_RezIcon:ResComm_Ressed(event, name)
	for unit in PitBull:IterateUnitFrames() do
		self:Update(unit, frame, event)
	end
end
function PitBull_RezIcon:ResComm_ResExpired(event, name)
	for unit in PitBull:IterateUnitFrames() do
		self:Update(unit, frame, event)
	end
end


local configMode = PitBull.configMode

function PitBull_RezIcon:OnEvent(ns, event, unit)
	-- self:Update(unit)
end

function PitBull_RezIcon:OnChangeConfigMode(value)
	configMode = value
	for unit, frame in PitBull:IterateUnitFrames() do
		-- self:Update(unit, true)
	end
end

local configMode_icons = {}

function PitBull_RezIcon:Update(unit, frame, event, complete)
	-- if not unit then
	-- 	unit = "player"
	-- end
	
	for frame in PitBull:IterateUnitFramesForUnit(unit) do
		if self.db.profile.groups[frame.group].ignore then
			if frame.rezIcon then
				frame.rezIcon = delFrame(frame.rezIcon)
				PitBull:UpdateLayout(frame)
			end
			return
		end
		
		-- if UnitIsDead(unit) or UnitIsGhost(unit) then
		
		
		-- end
		
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
		
	-- *********
	-- frame.rezIcon = newFrame("Texture", frame.overlay, "ARTWORK")
	
	if UnitIsDead(unit) or UnitIsGhost(unit) then
		if not frame.rezIcon then
			frame.rezIcon = newFrame("Texture", frame.overlay, "ARTWORK")
			frame.rezIcon:Hide()
			PitBull:UpdateLayout(frame)
		end
		-- if event == "ResComm_ResStart" or event =="ResComm_CanRes" or event == "ResComm_Ressed" or (event == "ResComm_ResEnd" and complete) then 

	    if event == "ResComm_ResStart"  then 
			-- if event == "ResComm_Ressed" then
			-- 	ressed = true
			-- end
			
			-- SendChatMessage(" TEST#1 ", "PARTY");
			-- if not frame.rezIcon then
			-- 	local rezIcon = newFrame("Texture", frame.overlay, "ARTWORK")
			-- 	frame.rezIcon = rezIcon
				
				frame.rezIcon:SetTexture("Interface\\AddOns\\PitBull_RezIcon\\Raid-Icon-Rez")
				frame.rezIcon:Show()
				-- PitBull:UpdateLayout(frame)
			-- end
		end
		-- if (event == "ResComm_ResEnd" and not complete and not ressed) or event == "ResComm_ResExpired" then

		if (event == "ResComm_ResEnd") or event == "ResComm_ResExpired" then
			-- SendChatMessage(" TEST#2 ", "PARTY");
			frame.rezIcon:Hide()
			frame.rezIcon:SetTexture(nil)
			ressed = false
			-- PitBull:UpdateLayout(frame)
		end
		
		-- if event == "ResComm_Ressed" then
		-- 	SendChatMessage(" TEST#3 ", "PARTY");
		-- 	-- frame.rezIcon:Hide()
		-- 	frame.rezIcon:SetTexture(nil)
		-- 	-- PitBull:UpdateLayout(frame)
		-- end
		
	-- else 
	-- 	if not frame.rezIcon then
	-- 		frame.rezIcon = delFrame(frame.rezIcon)
	-- 		PitBull:UpdateLayout(frame)
	-- 	end
	end
		-- local rezzUp = UnitHasIncomingResurrection(unit)
		-- -- if has then
		-- 	if not frame.rezIcon then
		-- 		frame.rezIcon = newFrame("Texture", frame.overlay, "ARTWORK")
		-- 		frame.rezIcon:Hide()
		-- 		PitBull:UpdateLayout(frame)
		-- 	end
		-- 	-- if(classif == "rare") then
		-- 	-- 	frame.rezIcon:SetTexture("Interface\\AddOns\\PitBull_RezIcon\\UI-DialogBox-Silver-Dragon-right")
		-- 	-- 	frame.rezIcon:Show()
		-- 	-- elseif classif == "normal" then
		-- 	-- 	frame.rezIcon:SetTexture(nil)
		-- 	-- else
		-- 	-- 	frame.rezIcon:SetTexture("Interface\\AddOns\\PitBull_RezIcon\\UI-DialogBox-Gold-Dragon-right")
		-- 	-- 	frame.rezIcon:Show()
		-- 	-- end
			
		-- 	if(rezzUp) then
		-- 		frame.rezIcon:SetTexture("Interface\\AddOns\\PitBull_RezIcon\\Raid-Icon-Rez")
		-- 		frame.rezIcon:Show()
		-- 	else
		-- 		frame.rezIcon:SetTexture(nil)
		-- 	end
	-- *********		
				
			
			-- if has == "Horde" then
			-- 	frame.rezIcon:SetTexCoord(0.08, 0.58, 0.045, 0.545)
			-- elseif has == "Alliance" then
			-- 	frame.rezIcon:SetTexCoord(0.07, 0.58, 0.06, 0.57)
			-- else -- FFA
			-- 	frame.rezIcon:SetTexCoord(0.05, 0.605, 0.015, 0.57)
			-- end
		-- else
		-- 	if frame.rezIcon then
		-- 		frame.rezIcon = delFrame(frame.rezIcon)

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

function PitBull_RezIcon:OnUpdateFrame(unit, frame)
	-- self:Update(unit, true)
end

function PitBull_RezIcon:OnClearUnitFrame(unit, frame)
	if frame.rezIcon then
		frame.rezIcon = delFrame(frame.rezIcon)
	end
end

local function getEnabled(group)
	return not PitBull_RezIcon.db.profile.groups[group].ignore
end
local function setEnabled(group, value)
	value = not value
	PitBull_RezIcon.db.profile.groups[group].ignore = value
	if value then
		for unit,frame in PitBull:IterateUnitFramesByGroup(group) do
			if frame.rezIcon then
				frame.rezIcon = delFrame(frame.rezIcon)
			end
		end
	else
		for unit in PitBull:IterateUnitFramesByGroup(group) do
			-- PitBull_RezIcon:Update(unit)
		end
	end
end
PitBull_RezIcon:RegisterPitBullOptionsMethod(function(group)
	return {
		type = 'group',
		name = L["Rez"],
		desc = L["Change settings for the Rez icon."],
		args = {
			toggle = {
				type = 'boolean',
				name = L["Enable"],
				desc = L["Enables the Rez indicator icon"],
				get = getEnabled,
				set = setEnabled,
				passValue = group,
			}
		}
	}
end)

