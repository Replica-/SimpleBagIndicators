-- Cell Cache
local Cache = {}

-- Quality/Rarity colors
local colors = {}
for i = 0, 8 do
	local r, g, b, hex = GetItemQualityColor(i)
	colors[i] = {r, g, b}
end

local questData = {
	[0] = {str = ''},
	[1] = {str =''},
	[2] = {str='BoE'},
	[3] = {str='BoU'},
	[4] = {str='Q'},
	[5] = {str=''},
}

local texData = {
    [1] = {
        parentKey = "EQ1",
        point = "BOTTOMRIGHT",
        level = "ARTWORK",
        subLevel = 1,
        coords = { 0.0, 0.5, 0.0, 0.5 },
		r = 255,
		g = 255,
		b = 0
    },
    [2] = {
        parentKey = "EQ2",
        point = "BOTTOMLEFT",
        level = "ARTWORK",
        subLevel = 1,
        coords = { 0.5, 1.0, 0.0, 0.5 },
		r = 0,
		g = 0,
		b = 255
    },
    [3] = {
        parentKey = "EQ3",
        point = "TOPLEFT",
        level = "ARTWORK",
        subLevel = 1,
        coords = { 0.5, 1.0, 0.5, 1.0 },
		r = 0,
		g = 255,
		b = 0
    },
    [4] = {
        parentKey = "EQ4",
        point = "TOPRIGHT",
        level = "ARTWORK",
        subLevel = 1,
        coords = { 0.0, 0.5, 0.5, 1.0 },
		r = 255,
		g = 0,
		b = 0
    },
}

local function MakeTexture(frame)
    local tex = frame:CreateTexture(frame:GetName() .. '_text',level)
    return tex
end

local ResetCell = function(cell) 
	cell.bind:SetText("")
	cell.bindType:SetText("")
	cell:SetBackdropBorderColor(0,0,0, 0)
	cell.tex:Hide()
end

-- Main Update
local Update = function(self, bag, slot)

	local found = 0
	local message, rarity, mult, itemLink, isBound, _
	
	local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
	if (containerInfo) then
		isBound = containerInfo.isBound
		itemLink = containerInfo.hyperlink
	end
	
	if (itemLink) then

		local _, _, itemQuality, itemLevel, _, itemType, _, _, _, _, _, _, _, bindType = GetItemInfo(itemLink)
		
		-- Retrieve or create the button's info container.
		local container = Cache[self]
		if (not container) then
			
			local borderWidth = 2
			
			local backdrop = {
				edgeFile = "Interface\\Buttons\\WHITE8x8",
				tileEdge = true,
				edgeSize = borderWidth,
				insets = {left = 4, right = 4, top = 4, bottom = 4},
			}

			container = CreateFrame("Frame", 'Text', self, "BackdropTemplate")
			container:SetFrameLevel(self:GetFrameLevel() + 5)
			container:SetAllPoints()
			container:SetBackdrop(backdrop)	

			container.bindType = container:CreateFontString()
			container.bindType:SetFontObject(NumberFont_Outline_Med or NumberFontNormal)
			container.bindType:SetDrawLayer("ARTWORK", 1)
			container.bindType:SetPoint("BOTTOMLEFT", 0,0)
			container.bindType:SetShadowOffset(1, -1)
			container.bindType:SetShadowColor(0, 0, 0, .5)

			container.bind = container:CreateFontString()
			container.bind:SetFontObject(NumberFont_Outline_Med or NumberFontNormal)
			container.bind:SetDrawLayer("ARTWORK", 1)
			container.bind:SetPoint("TOPLEFT", 0,0)
			container.bind:SetShadowOffset(1, -1)
			container.bind:SetShadowColor(0, 0, 0, .5)
			container.tex = MakeTexture(container)
			
			local td = texData[1]
			container.tex:ClearAllPoints()
			container.tex:SetPoint(td.point, container, "BOTTOM")
			container.tex:SetSize(16, 10)
			container.tex:SetColorTexture(td.r,td.g,td.b);
			container.tex:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 1), CreateColor(1, 1, 1, 0.2))

			Cache[self] = container
			
		end

		ResetCell(container)

		if (itemQuality ~= nil and itemQuality >= 2) then
			-- quality
			local col = colors[itemQuality]
			r, g, b = col[1], col[2], col[3]
			container:SetBackdropBorderColor(r,g,b, 0.6)
		end

		if (itemType == 'Armor' or itemType == 'Weapon') then
			-- bind type
			if (bindType ~= nil) then
				local bindStr = questData[bindType].str	
				container.bindType:SetTextColor(255, 255, 255)
				container.bindType:SetText(bindStr)
			end

			-- ilvl
			if (itemLevel ~= nil)  and (itemLevel ~= 1) then			
				container.bind:SetTextColor(255, 255, 255)
				container.bind:SetText(itemLevel)
			end

			-- Check the equipment sets
			for i, id in ipairs(C_EquipmentSet.GetEquipmentSetIDs()) do
				if i < 4 then
					local locations = C_EquipmentSet.GetItemLocations(id) or {}
					for _, l in pairs(locations) do
					
						local _, _, _, _, bagSlot, bagBag = EquipmentManager_UnpackLocation(l)
						if (bagBag ~= false) then
							if (bagSlot == slot) and (bagBag == bag) then
								found = found + 1
							end
						end
					end
				end
			end

					
			if found > 0 then
				container.tex:Show()
			end
		end
	else
		local cache = Cache[self]
		if (cache) then
			ResetCell(cache)
		end
	end

end

-- Parse a container
local UpdateContainer = function(self)
	local bag = self:GetID()
	local name = self:GetName()
	local id = 1
	local button = _G[name.."Item"..id]
	while (button) do
		if (button.hasItem) then
			Update(button, bag, button:GetID())
		else
			local cache = Cache[button]
			if (cache and cache.bind) then
				ResetCell(cache)
			end
		end
		id = id + 1
		button = _G[name.."Item"..id]
	end
end

-- Parse combined container
local UpdateCombinedContainer = function(self)
	for id,button in self:EnumerateItems() do
		if (button.hasItem) then
			-- The buttons retain their original bagID
			Update(button, button:GetBagID(), button:GetID())
		else
			local cache = Cache[button]
			if (cache and cache.bind) then
				ResetCell(cache)
			end
		end
	end
end

-- Parse the main bankframe
local UpdateBank = function()
	local BankSlotsFrame = BankSlotsFrame
	local bag = BankSlotsFrame:GetID()
	for id = 1, NUM_BANKGENERIC_SLOTS do
		local button = BankSlotsFrame["Item"..id]
		if (button and not button.isBag) then
			if (button.hasItem) then
				Update(button, bag, button:GetID())
			else
				local cache = Cache[button]
				if (cache) then
					ResetCell(cache)
				end
			end
		end
	end
end

-- Update a single bank button, needed for classics
local UpdateBankButton = function(self)
	if (self and not self.isBag) then
		-- Always run a full update here,
		-- as the .hasItem flag might not have been set yet.
		Update(self, BankSlotsFrame:GetID(), self:GetID())
	else
		local cache = Cache[button]
		if (cache) then
			ResetCell(cache)
		end
	end
end

-- Player bank slots changed event
local OnEvent = function(self, event, ...)
	
	if (event == "PLAYERBANKSLOTS_CHANGED") then
		local slot = ...
		if (slot <= NUM_BANKGENERIC_SLOTS) then
			local button = BankSlotsFrame["Item"..slot]
			if (button and not button.isBag) then
				-- Always run a full update here,
				-- as the .hasItem flag might not have been set yet.
				Update(button, BankSlotsFrame:GetID(), button:GetID())
			end
		end
	end
end


local OnAddonLoaded = function(self, event, arg1)

	if (event == "ADDON_LOADED" and arg1 == "SimpleBagIndicators") then
		-- Load to containers
		local id = 1

		-- Hook all container frames
		local frame = _G["ContainerFrame"..id]
		while (frame and frame.Update) do
			hooksecurefunc(frame, "Update", UpdateContainer)
			id = id + 1
			frame = _G["ContainerFrame"..id]
		end

		-- Update hook
		hooksecurefunc(ContainerFrameCombinedBags, "Update", UpdateCombinedContainer)
		hooksecurefunc("BankFrame_UpdateItems", UpdateBank)

		-- For single item changes for bank
		self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

		self:SetScript("OnEvent", OnEvent)
	end

end

-- Only when the addon is loaded
local f = CreateFrame("Frame", nil, WorldFrame)
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnAddonLoaded)
