--[[
    Barker UI
    Author: Claude
]]

Barker_UI = Barker_UI or {}

local UI = Barker_UI
local BK = BK

-- ===========================================
-- Constants and settings
-- ===========================================

UI.isVisible = false
UI.selectedTab = 1
UI.maxFrameWidth = 430
UI.maxFrameHeight = 480

-- ===========================================
-- UI Utility Functions
-- ===========================================

-- Create a titled panel
function UI:CreatePanel(parent, title, width, height)
    local panel = CreateFrame("Frame", nil, parent)
    panel:SetSize(width or 390, height or 300)
    
    panel.bg = panel:CreateTexture(nil, "BACKGROUND")
    panel.bg:SetAllPoints()
    panel.bg:SetColorTexture(0, 0, 0, 0.5)
    
    panel.border = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    panel.border:SetAllPoints()
    panel.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    panel.border:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    
    if title then
        panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        panel.title:SetPoint("TOPLEFT", 12, -8)
        panel.title:SetText(title)
    end
    
    return panel
end

-- Create a tab button
function UI:CreateTab(parent, id, text)
    local tab = CreateFrame("Button", "Barker_Tab" .. id, parent, "PanelTabButtonTemplate")
    tab:SetText(text)
    tab:SetID(id)
    
    tab:SetScript("OnClick", function(self)
        UI:SelectTab(self:GetID())
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end)
    
    return tab
end

-- Create a check button
function UI:CreateCheckButton(parent, name, text, tooltip)
    local check = CreateFrame("CheckButton", "Barker_" .. name, parent, "UICheckButtonTemplate")
    check.text = _G[check:GetName() .. "Text"]
    check.text:SetText(text)
    
    if tooltip then
        check.tooltipText = tooltip
    end
    
    return check
end

-- Create a slider
function UI:CreateSlider(parent, name, text, min, max, step, tooltip)
    local slider = CreateFrame("Slider", "Barker_" .. name, parent, "OptionsSliderTemplate")
    local sliderName = slider:GetName()
    
    _G[sliderName .. "Text"]:SetText(text)
    _G[sliderName .. "Low"]:SetText(min)
    _G[sliderName .. "High"]:SetText(max)
    
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    
    if tooltip then
        slider.tooltipText = tooltip
    end
    
    return slider
end

-- Create an edit box
function UI:CreateEditBox(parent, name, width, height)
    local editBox = CreateFrame("EditBox", "Barker_" .. name, parent, "InputBoxTemplate")
    editBox:SetSize(width or 250, height or 20)
    editBox:SetAutoFocus(false)
    
    return editBox
end

-- Create a button
function UI:CreateButton(parent, name, text, width, height)
    local button = CreateFrame("Button", "Barker_" .. name, parent, "UIPanelButtonTemplate")
    button:SetSize(width or 80, height or 22)
    button:SetText(text)
    
    return button
end

-- Create a dropdown menu
function UI:CreateDropdown(parent, name, text, width)
    local dropdown = CreateFrame("Frame", "Barker_" .. name, parent, "UIDropDownMenuTemplate")
    
    local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", 20, 10)
    label:SetText(text)
    
    UIDropDownMenu_SetWidth(dropdown, width or 120)
    
    return dropdown, label
end

-- ===========================================
-- UI Creation Functions
-- ===========================================

-- Create the main UI frame
function UI:CreateMainFrame()
    -- Create the main frame
    local frame = CreateFrame("Frame", "Barker_MainFrame", UIParent, "UIPanelDialogTemplate")
    frame:SetFrameStrata("HIGH")
    frame:SetSize(UI.maxFrameWidth, UI.maxFrameHeight)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()
    
    UI.mainFrame = frame
    
    -- Set title
    _G[frame:GetName() .. "TitleText"]:SetText("Barker " .. BK.version)
    
    -- Create close button
    local closeButton = _G[frame:GetName() .. "Close"]
    closeButton:SetScript("OnClick", function()
        UI:Hide()
    end)
    
    -- Create tab container and content panels
    UI:CreateTabs(frame)
    
    -- Create panels for each tab
    UI:CreateGeneralPanel(frame.tabPanels[1])
    UI:CreateMessagesPanel(frame.tabPanels[2])
    UI:CreateChannelsPanel(frame.tabPanels[3])
    UI:CreateSchedulingPanel(frame.tabPanels[4])
    UI:CreateHelpPanel(frame.tabPanels[5])
    
    -- Select the first tab by default
    UI:SelectTab(1)
    
    return frame
end

-- Create the tabs
function UI:CreateTabs(frame)
    frame.tabs = {}
    frame.tabPanels = {}
    
    -- Create tabs
    local tabNames = {
        BARKER_TAB_GENERAL,
        BARKER_TAB_MESSAGES,
        BARKER_TAB_CHANNELS,
        BARKER_TAB_SCHEDULING,
        BARKER_TAB_HELP
    }
    
    local firstTab = nil
    
    for i, name in ipairs(tabNames) do
        local tab = UI:CreateTab(frame, i, name)
        
        if i == 1 then
            tab:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 6, 7)
            firstTab = tab
        else
            tab:SetPoint("TOPLEFT", frame.tabs[i-1], "TOPRIGHT", -5, 0)
        end
        
        frame.tabs[i] = tab
        
        -- Create panel for this tab
        local panel = CreateFrame("Frame", nil, frame)
        panel:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
        panel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 8)
        panel:Hide()
        
        frame.tabPanels[i] = panel
    end
end

-- Select a tab
function UI:SelectTab(id)
    if not UI.mainFrame then return end
    
    -- Hide all panels first
    for i, panel in ipairs(UI.mainFrame.tabPanels) do
        panel:Hide()
    end
    
    -- Show the selected panel
    UI.mainFrame.tabPanels[id]:Show()
    UI.selectedTab = id
    
    -- Update tab appearances
    PanelTemplates_UpdateTabs(UI.mainFrame)
end

-- Create general settings panel
function UI:CreateGeneralPanel(panel)
    -- Enable checkbox
    local enableCheck = UI:CreateCheckButton(panel, "Enable", BARKER_ENABLE, BARKER_ENABLE_TT)
    enableCheck:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -10)
    enableCheck:SetScript("OnClick", function(self)
        if self:GetChecked() then
            BK:Enable()
        else
            BK:Disable()
        end
    end)
    panel.enableCheck = enableCheck
    
    -- Base rate slider
    local rateSlider = UI:CreateSlider(panel, "Rate", BARKER_BASE_RATE, BK.MAX_RATE, 300, 5, BARKER_BASE_RATE_TT)
    rateSlider:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 0, -30)
    rateSlider:SetWidth(350)
    rateSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        BK_characterConfig.baseRate = value
        _G[self:GetName() .. "Text"]:SetText(BARKER_BASE_RATE .. " (" .. value .. "s)")
    end)
    panel.rateSlider = rateSlider
    
    -- Rate variance slider
    local varianceSlider = UI:CreateSlider(panel, "Variance", BARKER_RATE_VARIANCE, 0, 60, 1, BARKER_RATE_VARIANCE_TT)
    varianceSlider:SetPoint("TOPLEFT", rateSlider, "BOTTOMLEFT", 0, -45)
    varianceSlider:SetWidth(350)
    varianceSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        BK_characterConfig.rateVariance = value
        _G[self:GetName() .. "Text"]:SetText(BARKER_RATE_VARIANCE .. " (+" .. value .. "s)")
    end)
    panel.varianceSlider = varianceSlider
    
    -- Max messages limit
    local maxMsgLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    maxMsgLabel:SetPoint("TOPLEFT", varianceSlider, "BOTTOMLEFT", 0, -30)
    maxMsgLabel:SetText(BARKER_MAX_MESSAGES_LIMIT)
    
    local maxMsgBox = UI:CreateEditBox(panel, "MaxMessages", 100, 20)
    maxMsgBox:SetPoint("TOPLEFT", maxMsgLabel, "BOTTOMLEFT", 5, -5)
    maxMsgBox:SetScript("OnEnterPressed", function(self)
        local value = tonumber(self:GetText()) or 0
        if value < 0 then value = 0 end
        BK:SetMaxMessages(value)
        self:SetText(tostring(value))
        self:ClearFocus()
        UI:UpdateControls()
    end)
    panel.maxMsgBox = maxMsgBox
    
    -- Alternate channels checkbox
    local alternateCheck = UI:CreateCheckButton(panel, "Alternate", BARKER_ALTERNATE_CHANNELS, BARKER_ALTERNATE_CHANNELS_TT)
    alternateCheck:SetPoint("TOPLEFT", maxMsgBox, "BOTTOMLEFT", -5, -15)
    alternateCheck:SetScript("OnClick", function(self)
        BK:ToggleAlternateChannels()
    end)
    panel.alternateCheck = alternateCheck
    
    -- Show in chat checkbox
    local showChatCheck = UI:CreateCheckButton(panel, "ShowChat", BARKER_SHOW_IN_CHAT, BARKER_SHOW_IN_CHAT_TT)
    showChatCheck:SetPoint("TOPLEFT", alternateCheck, "BOTTOMLEFT", 0, -5)
    showChatCheck:SetScript("OnClick", function(self)
        BK:ToggleShowInChat()
    end)
    panel.showChatCheck = showChatCheck
    
    -- Debug mode
    local debugCheck = UI:CreateCheckButton(panel, "Debug", BARKER_DEBUG, BARKER_DEBUG_TT)
    debugCheck:SetPoint("TOPLEFT", showChatCheck, "BOTTOMLEFT", 0, -5)
    debugCheck:SetScript("OnClick", function(self)
        BK:ToggleDebug()
    end)
    panel.debugCheck = debugCheck
    
    -- Status panel
    local statusPanel = UI:CreatePanel(panel, BARKER_STATUS, 390, 100)
    statusPanel:SetPoint("TOPLEFT", debugCheck, "BOTTOMLEFT", 0, -20)
    
    local statusText = statusPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("TOPLEFT", statusPanel, "TOPLEFT", 10, -25)
    statusText:SetPoint("BOTTOMRIGHT", statusPanel, "BOTTOMRIGHT", -10, 10)
    statusText:SetJustifyH("LEFT")
    statusText:SetJustifyV("TOP")
    
    panel.statusText = statusText
end

-- Create messages panel
function UI:CreateMessagesPanel(panel)
    -- Message mode selection
    local modeDropdown, modeLabel = UI:CreateDropdown(panel, "MessageMode", BARKER_MESSAGE_MODE)
    modeDropdown:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -25)
    
    UIDropDownMenu_Initialize(modeDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        
        info.func = function(self)
            BK:SetMessageMode(self.value)
            UIDropDownMenu_SetSelectedValue(modeDropdown, self.value)
            CloseDropDownMenus()
        end
        
        info.text = BARKER_MODE_SEQUENTIAL
        info.value = "sequential"
        info.checked = (BK_characterConfig.messageMode == "sequential")
        UIDropDownMenu_AddButton(info, level)
        
        info.text = BARKER_MODE_RANDOM
        info.value = "random"
        info.checked = (BK_characterConfig.messageMode == "random")
        UIDropDownMenu_AddButton(info, level)
    end)
    
    panel.modeDropdown = modeDropdown
    
    -- New message input
    local newMsgLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    newMsgLabel:SetPoint("TOPLEFT", modeDropdown, "BOTTOMLEFT", 0, -15)
    newMsgLabel:SetText(BARKER_NEW_MESSAGE)
    
    local newMsgBox = UI:CreateEditBox(panel, "NewMessage", 350, 20)
    newMsgBox:SetPoint("TOPLEFT", newMsgLabel, "BOTTOMLEFT", 5, -5)
    
    local addMsgBtn = UI:CreateButton(panel, "AddMessage", BARKER_ADD, 80, 22)
    addMsgBtn:SetPoint("TOPLEFT", newMsgBox, "BOTTOMLEFT", 0, -5)
    addMsgBtn:SetScript("OnClick", function()
        local msg = newMsgBox:GetText()
        if msg and msg ~= "" then
            BK:AddMessage(msg)
            newMsgBox:SetText("")
            UI:UpdateMessageList()
        end
    end)
    
    newMsgBox:SetScript("OnEnterPressed", function(self)
        addMsgBtn:Click()
        self:ClearFocus()
    end)
    
    panel.newMsgBox = newMsgBox
    
    -- Message list
    local msgListPanel = UI:CreatePanel(panel, BARKER_MESSAGE_LIST, 390, 250)
    msgListPanel:SetPoint("TOPLEFT", addMsgBtn, "BOTTOMLEFT", 0, -15)
    
    panel.messageFrames = {}
    panel.msgListPanel = msgListPanel
    
    UI:CreateMessageList(panel)
end

-- Create the message list
function UI:CreateMessageList(panel)
    local MESSAGES_PER_PAGE = 5
    local ITEM_HEIGHT = 42
    
    local scrollFrame = CreateFrame("ScrollFrame", "Barker_MessageScrollFrame", panel.msgListPanel, "FauxScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel.msgListPanel, "TOPLEFT", 5, -25)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel.msgListPanel, "BOTTOMRIGHT", -27, 5)
    scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ITEM_HEIGHT, function() UI:UpdateMessageList() end)
    end)
    
    panel.scrollFrame = scrollFrame
    
    -- Create message items
    for i = 1, MESSAGES_PER_PAGE do
        local item = CreateFrame("Frame", "Barker_MessageItem" .. i, scrollFrame)
        item:SetSize(360, ITEM_HEIGHT)
        
        if i == 1 then
            item:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 5, 0)
        else
            item:SetPoint("TOPLEFT", panel.messageFrames[i-1], "BOTTOMLEFT", 0, -2)
        end
        
        -- Message text
        item.text = item:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        item.text:SetPoint("TOPLEFT", item, "TOPLEFT", 5, -5)
        item.text:SetPoint("RIGHT", item, "RIGHT", -5, 0)
        item.text:SetJustifyH("LEFT")
        item.text:SetHeight(20)
        
        -- Background for better visibility
        item.bg = item:CreateTexture(nil, "BACKGROUND")
        item.bg:SetAllPoints()
        item.bg:SetColorTexture(1, 1, 1, 0.05)
        
        -- Border for better visibility
        item.border = CreateFrame("Frame", nil, item, "BackdropTemplate")
        item.border:SetAllPoints()
        item.border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        item.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
        
        -- Remove button
        item.removeBtn = UI:CreateButton(item, "RemoveMessage" .. i, BARKER_REMOVE, 70, 18)
        item.removeBtn:SetPoint("BOTTOMRIGHT", item, "BOTTOMRIGHT", -5, 2)
        
        -- Index - for reference
        item.index = i
        
        panel.messageFrames[i] = item
    end
end

-- Update the message list display
function UI:UpdateMessageList()
    local panel = UI.mainFrame.tabPanels[2]
    local messages = BK_characterConfig.messages
    local offset = FauxScrollFrame_GetOffset(panel.scrollFrame)
    
    -- Update the scrollFrame
    FauxScrollFrame_Update(panel.scrollFrame, #messages, #panel.messageFrames, panel.messageFrames[1]:GetHeight())
    
    -- Update each visible item
    for i = 1, #panel.messageFrames do
        local item = panel.messageFrames[i]
        local messageIndex = i + offset
        
        if messageIndex <= #messages then
            local message = messages[messageIndex]
            
            item.text:SetText(messageIndex .. ": " .. message)
            item.messageIndex = messageIndex
            
            item.removeBtn:SetScript("OnClick", function()
                BK:RemoveMessage(item.messageIndex)
                UI:UpdateMessageList()
            end)
            
            item:Show()
        else
            item:Hide()
        end
    end
end

-- Create channels panel
function UI:CreateChannelsPanel(panel)
    -- Channel selection dropdown
    local channelDropdown, channelLabel = UI:CreateDropdown(panel, "ChannelType", BARKER_CHANNEL_TYPE)
    channelDropdown:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -25)
    
    UIDropDownMenu_Initialize(channelDropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        
        info.func = function(self)
            UIDropDownMenu_SetSelectedValue(channelDropdown, self.value)
            
            -- Handle custom channel number
            if self.value == "CHANNEL" then
                panel.channelNumberBox:Show()
                panel.channelNumberLabel:Show()
            else
                panel.channelNumberBox:Hide()
                panel.channelNumberLabel:Hide()
                panel.channelNumberBox:SetText("")
            end
        end
        
        for _, channelInfo in ipairs(BK.CHANNEL_TYPES) do
            info.text = channelInfo.display or channelInfo.name
            info.value = channelInfo.id
            info.checked = false
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    
    panel.channelDropdown = channelDropdown
    
    -- Custom channel number input (for numeric channels)
    local channelNumberLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    channelNumberLabel:SetPoint("TOPLEFT", channelDropdown, "TOPRIGHT", 20, 0)
    channelNumberLabel:SetText(BARKER_CHANNEL_NUMBER)
    channelNumberLabel:Hide()
    
    local channelNumberBox = UI:CreateEditBox(panel, "ChannelNumber", 50, 20)
    channelNumberBox:SetPoint("TOPLEFT", channelNumberLabel, "BOTTOMLEFT", 5, -5)
    channelNumberBox:Hide()
    
    panel.channelNumberLabel = channelNumberLabel
    panel.channelNumberBox = channelNumberBox
    
    -- Custom rate
    local customRateCheck = UI:CreateCheckButton(panel, "CustomRate", BARKER_CUSTOM_RATE, BARKER_CUSTOM_RATE_TT)
    customRateCheck:SetPoint("TOPLEFT", channelDropdown, "BOTTOMLEFT", 0, -15)
    
    local customRateSlider = UI:CreateSlider(panel, "CustomRate", BARKER_RATE, BK.MAX_RATE, 300, 5)
    customRateSlider:SetPoint("TOPLEFT", customRateCheck, "BOTTOMLEFT", 0, -30)
    customRateSlider:SetWidth(350)
    customRateSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        _G[self:GetName() .. "Text"]:SetText(BARKER_RATE .. " (" .. value .. "s)")
    end)
    customRateSlider:Disable()
    
    customRateCheck:SetScript("OnClick", function(self)
        if self:GetChecked() then
            customRateSlider:Enable()
        else
            customRateSlider:Disable()
        end
    end)
    
    panel.customRateCheck = customRateCheck
    panel.customRateSlider = customRateSlider
    
    -- Add channel button
    local addChannelBtn = UI:CreateButton(panel, "AddChannel", BARKER_ADD_CHANNEL, 120, 22)
    addChannelBtn:SetPoint("TOPLEFT", customRateSlider, "BOTTOMLEFT", 0, -15)
    addChannelBtn:SetScript("OnClick", function()
        local channelType = UIDropDownMenu_GetSelectedValue(channelDropdown)
        if not channelType then return end
        
        local channelName = channelType:lower()
        if channelType == "CHANNEL" then
            channelName = channelNumberBox:GetText()
            if not channelName or channelName == "" then return end
        end
        
        local rate = nil
        if customRateCheck:GetChecked() then
            rate = math.floor(customRateSlider:GetValue())
        end
        
        BK:AddChannel(channelName, rate)
        UI:UpdateChannelList()
    end)
    
    -- Channel list
    local channelListPanel = UI:CreatePanel(panel, BARKER_CHANNEL_LIST, 390, 250)
    channelListPanel:SetPoint("TOPLEFT", addChannelBtn, "BOTTOMLEFT", 0, -15)
    
    panel.channelFrames = {}
    panel.channelListPanel = channelListPanel
    
    UI:CreateChannelList(panel)
end

-- Create the channel list
function UI:CreateChannelList(panel)
    local CHANNELS_PER_PAGE = 5
    local ITEM_HEIGHT = 42
    
    local scrollFrame = CreateFrame("ScrollFrame", "Barker_ChannelScrollFrame", panel.channelListPanel, "FauxScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel.channelListPanel, "TOPLEFT", 5, -25)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel.channelListPanel, "BOTTOMRIGHT", -27, 5)
    scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ITEM_HEIGHT, function() UI:UpdateChannelList() end)
    end)
    
    panel.scrollFrame = scrollFrame
    
    -- Create channel items
    for i = 1, CHANNELS_PER_PAGE do
        local item = CreateFrame("Frame", "Barker_ChannelItem" .. i, scrollFrame)
        item:SetSize(360, ITEM_HEIGHT)
        
        if i == 1 then
            item:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 5, 0)
        else
            item:SetPoint("TOPLEFT", panel.channelFrames[i-1], "BOTTOMLEFT", 0, -2)
        end
        
        -- Channel name
        item.text = item:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        item.text:SetPoint("TOPLEFT", item, "TOPLEFT", 5, -5)
        item.text:SetPoint("RIGHT", item, "RIGHT", -5, 0)
        item.text:SetJustifyH("LEFT")
        item.text:SetHeight(20)
        
        -- Background for better visibility
        item.bg = item:CreateTexture(nil, "BACKGROUND")
        item.bg:SetAllPoints()
        item.bg:SetColorTexture(1, 1, 1, 0.05)
        
        -- Border for better visibility
        item.border = CreateFrame("Frame", nil, item, "BackdropTemplate")
        item.border:SetAllPoints()
        item.border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        item.border:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.5)
        
        -- Enable/disable checkbox
        item.enableCheck = UI:CreateCheckButton(item, "EnableChannel" .. i, "")
        item.enableCheck:SetPoint("BOTTOMLEFT", item, "BOTTOMLEFT", 5, 2)
        
        -- Remove button
        item.removeBtn = UI:CreateButton(item, "RemoveChannel" .. i, BARKER_REMOVE, 70, 18)
        item.removeBtn:SetPoint("BOTTOMRIGHT", item, "BOTTOMRIGHT", -5, 2)
        
        -- Index - for reference
        item.index = i
        
        panel.channelFrames[i] = item
    end
end

-- Update the channel list display
function UI:UpdateChannelList()
    local panel = UI.mainFrame.tabPanels[3]
    local channels = BK_characterConfig.channels
    local offset = FauxScrollFrame_GetOffset(panel.scrollFrame)
    
    -- Update the scrollFrame
    FauxScrollFrame_Update(panel.scrollFrame, #channels, #panel.channelFrames, panel.channelFrames[1]:GetHeight())
    
    -- Update each visible item
    for i = 1, #panel.channelFrames do
        local item = panel.channelFrames[i]
        local channelIndex = i + offset
        
        if channelIndex <= #channels then
            local channel = channels[channelIndex]
            local displayName = BK:GetChannelDisplayName(channel)
            local rateInfo = ""
            
            if channel.customRate then
                rateInfo = " (" .. tostring(channel.rate) .. "s)"
            end
            
            item.text:SetText(channelIndex .. ": " .. displayName .. rateInfo)
            item.channelIndex = channelIndex
            
            item.enableCheck:SetChecked(channel.enabled)
            item.enableCheck:SetScript("OnClick", function(self)
                channels[channelIndex].enabled = self:GetChecked()
            end)
            
            item.removeBtn:SetScript("OnClick", function()
                BK:RemoveChannel(channelIndex)
                UI:UpdateChannelList()
            end)
            
            item:Show()
        else
            item:Hide()
        end
    end
end

-- Create scheduling panel
function UI:CreateSchedulingPanel(panel)
    -- Active hours
    local hoursLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hoursLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -10)
    hoursLabel:SetText(BARKER_ACTIVE_HOURS_LABEL)
    
    -- Start hour
    local startHourLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    startHourLabel:SetPoint("TOPLEFT", hoursLabel, "BOTTOMLEFT", 5, -15)
    startHourLabel:SetText(BARKER_START_HOUR)
    
    local startHourSlider = UI:CreateSlider(panel, "StartHour", BARKER_START_HOUR, 0, 23, 1)
    startHourSlider:SetPoint("TOPLEFT", startHourLabel, "BOTTOMLEFT", 0, -5)
    startHourSlider:SetWidth(350)
    startHourSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        BK_characterConfig.activeHours.start = value
        _G[self:GetName() .. "Text"]:SetText(BARKER_START_HOUR .. " (" .. BK:FormatTime(value, 0) .. ")")
    end)
    
    panel.startHourSlider = startHourSlider
    
    -- End hour
    local endHourLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    endHourLabel:SetPoint("TOPLEFT", startHourSlider, "BOTTOMLEFT", 0, -15)
    endHourLabel:SetText(BARKER_END_HOUR)
    
    local endHourSlider = UI:CreateSlider(panel, "EndHour", BARKER_END_HOUR, 0, 24, 1)
    endHourSlider:SetPoint("TOPLEFT", endHourLabel, "BOTTOMLEFT", 0, -5)
    endHourSlider:SetWidth(350)
    endHourSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        BK_characterConfig.activeHours.stop = value
        _G[self:GetName() .. "Text"]:SetText(BARKER_END_HOUR .. " (" .. BK:FormatTime(value, 0) .. ")")
    end)
    
    panel.endHourSlider = endHourSlider
    
    -- Active days
    local daysLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    daysLabel:SetPoint("TOPLEFT", endHourSlider, "BOTTOMLEFT", 0, -20)
    daysLabel:SetText(BARKER_ACTIVE_DAYS)
    
    panel.dayChecks = {}
    
    -- Create checkboxes for each day
    local dayNames = {
        CALENDAR_WEEKDAY_SUNDAY,
        CALENDAR_WEEKDAY_MONDAY,
        CALENDAR_WEEKDAY_TUESDAY,
        CALENDAR_WEEKDAY_WEDNESDAY,
        CALENDAR_WEEKDAY_THURSDAY,
        CALENDAR_WEEKDAY_FRIDAY,
        CALENDAR_WEEKDAY_SATURDAY
    }
    
    for i = 1, 7 do
        local check = UI:CreateCheckButton(panel, "Day" .. i, dayNames[i])
        if i == 1 then
            check:SetPoint("TOPLEFT", daysLabel, "BOTTOMLEFT", 5, -5)
        elseif i == 5 then
            -- Start a new row
            check:SetPoint("TOPLEFT", panel.dayChecks[1], "BOTTOMLEFT", 0, -5)
        else
            check:SetPoint("LEFT", panel.dayChecks[i-1], "RIGHT", 80, 0)
        end
        
        check:SetScript("OnClick", function(self)
            BK_characterConfig.activeDays[i] = self:GetChecked()
        end)
        
        panel.dayChecks[i] = check
    end
end

-- Create help panel
function UI:CreateHelpPanel(panel)
    -- Version info
    local versionText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    versionText:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -10)
    versionText:SetText(BARKER_VERSION .. " " .. BK.version)
    
    -- Create a scrollable help text frame
    local helpFrame = CreateFrame("ScrollFrame", "Barker_HelpScroll", panel, "UIPanelScrollFrameTemplate")
    helpFrame:SetPoint("TOPLEFT", versionText, "BOTTOMLEFT", 0, -10)
    helpFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 10)
    
    local helpContent = CreateFrame("Frame", "Barker_HelpContent", helpFrame)
    helpContent:SetSize(helpFrame:GetWidth(), 500) -- Make it tall enough for content
    helpFrame:SetScrollChild(helpContent)
    
    local helpText = helpContent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    helpText:SetPoint("TOPLEFT", helpContent, "TOPLEFT", 5, -5)
    helpText:SetPoint("TOPRIGHT", helpContent, "TOPRIGHT", -5, -5)
    helpText:SetJustifyH("LEFT")
    helpText:SetJustifyV("TOP")
    helpText:SetSpacing(2)
    
    -- Set help text from localization
    local helpString = ""
    for _, line in ipairs(BARKER_HELP) do
        helpString = helpString .. line .. "\n"
    end
    
    helpText:SetText(helpString)
end

-- ===========================================
-- UI Update Functions
-- ===========================================

-- Update all UI controls to reflect current settings
function UI:UpdateControls()
    if not UI.mainFrame then return end
    
    -- Update general tab
    local generalPanel = UI.mainFrame.tabPanels[1]
    generalPanel.enableCheck:SetChecked(BK.isActive)
    generalPanel.rateSlider:SetValue(BK_characterConfig.baseRate)
    generalPanel.varianceSlider:SetValue(BK_characterConfig.rateVariance)
    generalPanel.maxMsgBox:SetText(tostring(BK_characterConfig.maxMessages))
    generalPanel.alternateCheck:SetChecked(BK_characterConfig.alternateChannels)
    generalPanel.showChatCheck:SetChecked(BK_characterConfig.showInChat)
    generalPanel.debugCheck:SetChecked(BK_characterConfig.debug)
    
    -- Update status text
    local statusText = ""
    
    if BK.isActive then
        statusText = statusText .. "|cFF00FF00" .. BARKER_ACTIVE .. "|r\n"
    else
        statusText = statusText .. "|cFFFF0000" .. BARKER_INACTIVE .. "|r\n"
    end
    
    statusText = statusText .. BARKER_MESSAGES_SENT .. ": " .. BK_characterConfig.messagesSent
    
    if BK_characterConfig.maxMessages > 0 then
        statusText = statusText .. "/" .. BK_characterConfig.maxMessages
    end
    
    generalPanel.statusText:SetText(statusText)
    
    -- Update messages tab
    UIDropDownMenu_SetSelectedValue(UI.mainFrame.tabPanels[2].modeDropdown, BK_characterConfig.messageMode)
    UI:UpdateMessageList()
    
    -- Update channels tab
    UI:UpdateChannelList()
    
    -- Update scheduling tab
    local schedulingPanel = UI.mainFrame.tabPanels[4]
    schedulingPanel.startHourSlider:SetValue(BK_characterConfig.activeHours.start)
    schedulingPanel.endHourSlider:SetValue(BK_characterConfig.activeHours.stop)
    
    -- Update day checkboxes
    for i = 1, 7 do
        schedulingPanel.dayChecks[i]:SetChecked(BK_characterConfig.activeDays[i])
    end
end

-- ===========================================
-- UI Show/Hide Functions
-- ===========================================

-- Show the UI
function UI:Show()
    if not UI.mainFrame then
        UI:CreateMainFrame()
    end
    
    UI:UpdateControls()
    UI.mainFrame:Show()
    UI.isVisible = true
end

-- Hide the UI
function UI:Hide()
    if UI.mainFrame then
        UI.mainFrame:Hide()
    end
    UI.isVisible = false
end

-- Toggle the UI
function UI:Toggle()
    if UI.isVisible then
        UI:Hide()
    else
        UI:Show()
    end
end