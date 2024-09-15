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
	[66] = {str='WuE'}
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

local function MakeTexture(frame, order)
    local tex = frame:CreateTexture(frame:GetName() .. '_text',level, nil, order)
    return tex
end

local ResetCell = function(cell) 
	cell.bind:SetText("")
	cell.bindType:SetText("")
	cell:SetBackdropBorderColor(0,0,0, 0)
	cell.tex:Hide()
	cell.texbg:Hide()
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
		
		local wue = false

		local itemObj = Item:CreateFromBagAndSlot(bag, slot)
		
		if ( itemObj ) then
			wue = C_Item.IsBoundToAccountUntilEquip(ItemLocation:CreateFromBagAndSlot(bag,slot))
			itemLevel = itemObj:GetCurrentItemLevel()
		end

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
			
			local td = texData[1]
	
			container.tex = MakeTexture(container, -6)
			container.tex:SetPoint(td.point, container, "BOTTOM", 0,0)
			container.tex:SetSize(19, 19)
			container.tex:Show()
			
			container.texbg = MakeTexture(container, -7)
			container.texbg:SetPoint(td.point, container, "BOTTOM", 1,-1)
			container.texbg:SetSize(21, 21)
			container.texbg:SetColorTexture(1,1,1);
			container.texbg:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.7), CreateColor(1, 1, 1, 0.7))
			container.texbg:Show()

			Cache[self] = container
			
		end

		ResetCell(container)

		if (itemQuality ~= nil and itemQuality >= 2) then
			-- quality
			local col = colors[itemQuality]
			r, g, b = col[1], col[2], col[3]
			container:SetBackdropBorderColor(r,g,b, 0.6)
			
			if (Coloured_Set) then
				container.texbg:SetColorTexture(r*1.5,g*1.5,b*1.5, 1)
			else 
				container.texbg:SetColorTexture(255,255,255, 1)
			end
			--container.texbg:SetColorTexture(r*3,g*3,b*3, 1)
		end

		if (itemType == 'Armor' or itemType == 'Weapon') then
			-- bind type
			if (bindType ~= nil) then
				
				-- If we're bound then just make it blank
				if (C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(bag, slot))) then
						bindType = 1
				end
				local bindStr = questData[bindType].str
				if (wue) then 
					bindStr = questData[66].str
				end

				if (Coloured_Bind) then
					local col = colors[itemQuality]
					r, g, b = col[1], col[2], col[3]
					container.bindType:SetTextColor(r*3, g*3, b*3)
				else
					container.bindType:SetTextColor(255, 255, 255)
				end
				
				container.bindType:SetText(bindStr)
			end

			-- ilvl
			if (itemLevel ~= nil)  and (itemLevel ~= 1) then			
				local col = colors[itemQuality]

				if (Coloured_Ilvl) then
					r, g, b = col[1], col[2], col[3]
				else 
					r, g, b = 255,255,255
				end
				
				container.bind:SetTextColor(r*3, g*3, b*3)
			
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

								local _, iconFileID = C_EquipmentSet.GetEquipmentSetInfo(id)
								container.tex:SetTexture(iconFileID)

								found = found + 1
							end
						end
					end
				end
			end

					
			if found > 0 then
				container.texbg:Show()	
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
	for id,button in self:EnumerateItems() do
		if (button.hasItem) then
			Update(button, bag, button:GetID())
		else
			local cache = Cache[button]
			if (cache and cache.bind) then
				ResetCell(cache)
			end
		end
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
	local bag = BANK_CONTAINER
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

-- Parse the main bankframe
local UpdatePlayer = function()
	local BankSlotsFrame = BankSlotsFrame
	local bag =  "player"
	for id = 1, 10 do
		local button = Pla["Item"..id]
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
		Update(self, BANK_CONTAINER, self:GetID())
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
				Update(button, BANK_CONTAINER, button:GetID())
			end
		end
	end
end

local function MyEquipmentFlyout_OnUpdate(itemButton)
    print("EquipmentFlyout_OnUpdate has been called!")
	local id = itemButton.id or itemButton:GetID();
	local flyout = EquipmentFlyoutFrame;
	if flyout:IsShown() and (flyout.button ~= itemButton) then
		flyout:Hide();
	end
	local buttons = flyout.buttons;
	
	if ( flyout.button ~= itemButton ) then
		flyout.currentPage = nil;
	end
	for i = 1, #buttons do
		local itemLocation = buttons[i]:GetItemLocation();
		print(itemLocation:IsBagAndSlot())
		if itemLocation:IsBagAndSlot() then
			local bag, slot = itemLocation:GetBagAndSlot();
			Update(buttons[i], bag, buttons[i]:GetID())
		elseif itemLocation:IsEquipmentSlot() then
			local slot = itemLocation:GetEquipmentSlot();
			Update(buttons[i], 'player', buttons[i]:GetID())
		end
		
	end
    -- Add any additional functionality you want here
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
		hooksecurefunc("BankFrameItemButton_Update", UpdateBank)
		--hooksecurefunc("EquipmentFlyout", "EquipmentFlyout_OnLoad",  EquipmentFlyout_OnLoadTest)

		--hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
		--	Update(button, "player")
		--end)

		-- For single item changes for bank

		hooksecurefunc("EquipmentFlyout_Show", MyEquipmentFlyout_OnUpdate)
		
		self:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

		self:SetScript("OnEvent", OnEvent)
	end

	-- Only when FrameXML loads & Only when saved variable is imported in
	if (event == "ADDON_LOADED" and arg1 == "SimpleBagIndicators" and frame ~= nil) then
		local panel = frame

		-- ILVL
		local helloFS = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		helloFS:SetPoint("TOPLEFT", panel, 0, -20);
		helloFS:SetText("Coloured ILVL")

		editFrame = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate");
		editFrame:SetPoint("TOPLEFT", panel, 123, -10);
		editFrame:SetMovable(false);

		if Coloured_Ilvl ~= nil then
			editFrame:SetChecked(Coloured_Ilvl)
		end

		editFrame:SetScript("OnClick", function(self)
			Coloured_Ilvl = self:GetChecked()
		end)

		-- SET
		local helloFS = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		helloFS:SetPoint("TOPLEFT", panel, 0, -60);
		helloFS:SetText("Coloured Set Border")

		editFrame = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate");
		editFrame:SetPoint("TOPLEFT", panel, 123, -50);
		editFrame:SetMovable(false);

		if Coloured_Set ~= nil then
			editFrame:SetChecked(Coloured_Set)
		end
		
		editFrame:SetScript("OnClick", function(self)
			Coloured_Set = self:GetChecked()
		end)

		-- BIND
		local helloFS = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		helloFS:SetPoint("TOPLEFT", panel, 0, -110);
		helloFS:SetText("Coloured Bind Type")

		editFrame = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate");
		editFrame:SetPoint("TOPLEFT", panel, 123, -100);
		editFrame:SetMovable(false);

		if Coloured_Bind ~= nil then
			editFrame:SetChecked(Coloured_Bind)
		end
		
		editFrame:SetScript("OnClick", function(self)
			Coloured_Bind = self:GetChecked()
		end)

	elseif event == "PLAYER_LOGOUT" then
		-- Save the time at which the character logs out
		
	end

end

-- Initialise
if (Coloured_Set == nil or Coloured_Set == '') then
	Coloured_Set = false
end

if (Coloured_Ilvl == nil or Coloured_Ilvl == '') then
	Coloured_Ilvl = false
end

if (Coloured_Bind == nil or Coloured_Bind == '') then
	Coloured_Bind = false
end

function Panel_OnLoad(panel)
    panel.name = 'SimpleBagIndicators'
	frame = panel

	Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(panel, "SimpleBagIndicators"))
end

-- Only when the addon is loaded
local f = CreateFrame("Frame", nil, WorldFrame)
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnAddonLoaded)
