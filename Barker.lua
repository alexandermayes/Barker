--[[
	Barker
	Author: LenweSaralonde
	Enhanced by: Claude
]]

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local ADDON_NAME = "Barker"

-- ===========================================
-- Constants and defaults
-- ===========================================

BK = BK or {}
BK.MAX_RATE = 10 -- Minimum seconds between messages
BK.MIN_VARIANCE = 0 -- Minimum variance in seconds
BK.MAX_VARIANCE = 60 -- Maximum variance in seconds
BK.MAX_MESSAGES = 10 -- Maximum number of messages in rotation
BK.MAX_CHANNELS = 5 -- Maximum number of channels

BK.isActive = false
BK.version = GetAddOnMetadata(ADDON_NAME, "Version")
BK.frame = Barker_Frame

-- Available channel types
BK.CHANNEL_TYPES = {
    { id = "SAY", name = "say", display = CHAT_MSG_SAY },
    { id = "YELL", name = "yell", display = CHAT_MSG_YELL },
    { id = "GUILD", name = "guild", display = CHAT_MSG_GUILD },
    { id = "RAID", name = "raid", display = CHAT_MSG_RAID },
    { id = "PARTY", name = "party", display = CHAT_MSG_PARTY },
    { id = "INSTANCE_CHAT", name = "instance", display = INSTANCE_CHAT },
    { id = "BATTLEGROUND", name = "bg", display = CHAT_MSG_BATTLEGROUND },
    { id = "CHANNEL", name = "channel", display = CHAT_MSG_CHANNEL },
}

-- Default configuration
BK.DEFAULT_CONFIG = {
    enabled = false,
    messages = {
        "Barker " .. (GetAddOnMetadata(ADDON_NAME, "Version") or "1.0")
    },
    messageMode = "sequential", -- sequential, random
    currentMessageIndex = 1,
    baseRate = 60,
    rateVariance = 0, -- Random additional seconds
    activeHours = { -- Hour ranges when active (0-23)
        start = 0,
        stop = 24,
    },
    activeDays = { -- Days when active (1-7, 1 = Sunday)
        [1] = true, [2] = true, [3] = true, [4] = true,
        [5] = true, [6] = true, [7] = true
    },
    channels = {
        {
            type = "SAY",
            name = "say",
            enabled = true,
            customRate = false,
            rate = 60,
        }
    },
    maxMessages = 0, -- 0 = unlimited
    messagesSent = 0,
    alternateChannels = false,
    showInChat = false,
    debug = false,
}

-- ===========================================
-- Utility Functions
-- ===========================================

-- Print debug message to chat
function BK:DebugPrint(...)
    if BK_characterConfig and BK_characterConfig.debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF88CCFF[Barker Debug]|r " .. string.format(...), 1, 1, 1)
    end
end

-- Print message to chat
function BK:Print(...)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF99Barker:|r " .. string.format(...), 1, 1, 1)
end

-- Print error message to chat
function BK:PrintError(...)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF3333Barker Error:|r " .. string.format(...), 1, 1, 1)
end

-- Format time as HH:MM
function BK:FormatTime(hours, minutes)
    return string.format("%02d:%02d", hours or 0, minutes or 0)
end

-- Trim whitespace from a string
function BK:Trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Check if current time is within active hours
function BK:IsWithinActiveHours()
    if not BK_characterConfig.activeHours then return true end
    
    local hours = tonumber(date("%H"))
    local start = BK_characterConfig.activeHours.start
    local stop = BK_characterConfig.activeHours.stop
    
    if start <= stop then
        return hours >= start and hours < stop
    else
        -- Handle overnight ranges (e.g., 22-6)
        return hours >= start or hours < stop
    end
end

-- Check if current day is active
function BK:IsActiveDay()
    if not BK_characterConfig.activeDays then return true end
    
    local day = tonumber(date("%w")) + 1 -- Lua date: 0 = Sunday, we want 1 = Sunday
    return BK_characterConfig.activeDays[day] == true
end

-- Get the next message in the rotation
function BK:GetNextMessage()
    local config = BK_characterConfig
    local messages = config.messages
    
    if not messages or #messages == 0 then
        return "Barker " .. BK.version
    end
    
    local message
    
    if config.messageMode == "random" then
        local index = math.random(1, #messages)
        message = messages[index]
    else -- sequential
        config.currentMessageIndex = config.currentMessageIndex + 1
        if config.currentMessageIndex > #messages then
            config.currentMessageIndex = 1
        end
        message = messages[config.currentMessageIndex]
    end
    
    return message
end

-- Get channel system and number from channel info
function BK:GetChannelInfo(channelInfo)
    if not channelInfo then return nil, nil, nil end
    
    local channelType = channelInfo.type
    local channelName = channelInfo.name
    
    if channelType == "CHANNEL" and channelName and tonumber(channelName) then
        local id, name = GetChannelName(channelName)
        if id and id ~= 0 then
            return channelType, id, name
        end
    elseif channelType ~= "CHANNEL" then
        return channelType, nil, channelName
    end
    
    return nil, nil, nil
end

-- Check if a channel is valid
function BK:IsValidChannel(channelInfo)
    local system, id, name = BK:GetChannelInfo(channelInfo)
    return system ~= nil
end

-- Get channel display name
function BK:GetChannelDisplayName(channelInfo)
    local system, id, name = BK:GetChannelInfo(channelInfo)
    
    if not system then
        return channelInfo.name or "unknown"
    end
    
    for _, info in ipairs(BK.CHANNEL_TYPES) do
        if info.id == system then
            if system == "CHANNEL" and id then
                return id .. ". " .. (name or "")
            else
                return info.display or info.name
            end
        end
    end
    
    return channelInfo.name or "unknown"
end

-- Get the current time rate including variance
function BK:GetCurrentRate(channelInfo)
    local baseRate = BK_characterConfig.baseRate or BK.MAX_RATE
    
    if channelInfo and channelInfo.customRate and channelInfo.rate then
        baseRate = channelInfo.rate
    end
    
    local variance = BK_characterConfig.rateVariance or 0
    if variance > 0 then
        return baseRate + math.random(0, variance)
    else
        return baseRate
    end
end

-- ===========================================
-- Main Functions
-- ===========================================

-- Initialize the addon
function BK:Initialize()
    -- Register event handling
    BK.frame:RegisterEvent("VARIABLES_LOADED")
    BK.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    BK.frame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
    
    BK.frame.timeSinceLastUpdate = 0
    BK.frame.channelTimers = {}
    
    BK.frame:SetScript("OnEvent", function(self, event, ...)
        BK:OnEvent(event, ...)
    end)
    
    BK.frame:SetScript("OnUpdate", function(self, elapsed)
        BK:OnUpdate(elapsed)
    end)
end

-- Initialize saved variables and display welcome message
function BK:InitializeSavedVariables()
    -- Config key used for the old account-wide configuration table
    local characterId = GetRealmName() .. '-' .. UnitName("player")
    
    -- Check for old AutoFlood config data for migration
    local oldConfig = {}
    if AF_characterConfig then
        oldConfig = CopyTable(AF_characterConfig)
    elseif AF_config and AF_config[characterId] then 
        oldConfig = AF_config[characterId] or {}
    end
    
    -- Initialize configuration with defaults and saved values
    BK_characterConfig = Mixin(CopyTable(BK.DEFAULT_CONFIG), oldConfig, BK_characterConfig or {})
    
    -- Clean up old configs
    BK:CleanOldConfig(characterId)
    
    -- Update any missing fields with defaults
    for k, v in pairs(BK.DEFAULT_CONFIG) do
        if BK_characterConfig[k] == nil then
            BK_characterConfig[k] = CopyTable(v)
        end
    end
    
    -- Process channel configs
    for i, channel in ipairs(BK_characterConfig.channels) do
        if not channel.rate then channel.rate = BK_characterConfig.baseRate end
        if channel.customRate == nil then channel.customRate = false end
        if channel.enabled == nil then channel.enabled = true end
    end
    
    -- Initialize channel timers
    BK.frame.channelTimers = {}
    for i, channel in ipairs(BK_characterConfig.channels) do
        BK.frame.channelTimers[i] = BK:GetCurrentRate(channel)
    end
    
    -- Migrate message from old format
    if BK_characterConfig.message and not BK_characterConfig.messages then
        BK_characterConfig.messages = { BK_characterConfig.message }
        BK_characterConfig.message = nil
    end
    
    -- Display welcome message
    local s = string.gsub(BARKER_LOAD, "VERSION", BK.version)
    DEFAULT_CHAT_FRAME:AddMessage(s, 1, 1, 1)
    
    -- Restore active state
    if BK_characterConfig.enabled then
        BK:Enable()
    end
end

-- Clean the old account-wide config table
function BK:CleanOldConfig(characterId)
    -- Clean up old AutoFlood configs if they exist
    if AF_config and AF_config[characterId] then
        AF_config[characterId] = nil
        if next(AF_config) == nil then
            AF_config = nil
        end
    end
    
    -- Clean up old Barker configs if they exist
    if BK_config and BK_config[characterId] then
        BK_config[characterId] = nil
        if next(BK_config) == nil then
            BK_config = nil
        end
    end
end

-- Event handler
function BK:OnEvent(event, ...)
    if event == "VARIABLES_LOADED" then
        BK:InitializeSavedVariables()
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Refresh channel list
        BK:RefreshChannelNames()
    elseif event == "CHAT_MSG_CHANNEL_NOTICE" then
        -- Channel list has changed, refresh
        BK:RefreshChannelNames()
    end
end

-- Refresh the channel names (especially for numeric channels)
function BK:RefreshChannelNames()
    -- Update channel names if they're numeric
    for i, channelInfo in ipairs(BK_characterConfig.channels) do
        if channelInfo.type == "CHANNEL" and tonumber(channelInfo.name) then
            local id, name = GetChannelName(channelInfo.name)
            if id and id ~= 0 and name then
                BK:DebugPrint("Refreshed channel %s: %s", channelInfo.name, name)
            else
                BK:DebugPrint("Channel %s not found", channelInfo.name)
            end
        end
    end
end

-- Frame update handler
function BK:OnUpdate(elapsed)
    if not BK.isActive then return end
    
    -- Check if we should be active based on time/day restrictions
    if not BK:IsWithinActiveHours() or not BK:IsActiveDay() then
        return
    end
    
    -- Check if we've hit the max message limit
    if BK_characterConfig.maxMessages > 0 and 
       BK_characterConfig.messagesSent >= BK_characterConfig.maxMessages then
        BK:Disable()
        BK:Print(BARKER_MAX_MESSAGES_REACHED)
        return
    end
    
    -- Update timers and send messages
    if MessageQueue.GetNumPendingMessages() > 0 then
        return -- Wait for the queue to empty
    end
    
    local timers = BK.frame.channelTimers
    local channels = BK_characterConfig.channels
    
    -- Alternate channels mode
    if BK_characterConfig.alternateChannels then
        -- Find the channel with the lowest timer
        local lowestTimer = nil
        local lowestIndex = nil
        
        for i, channel in ipairs(channels) do
            if channel.enabled and BK:IsValidChannel(channel) then
                if not lowestTimer or timers[i] < lowestTimer then
                    lowestTimer = timers[i]
                    lowestIndex = i
                end
            end
        end
        
        -- Update the timer and send message if needed
        if lowestIndex and lowestTimer then
            timers[lowestIndex] = timers[lowestIndex] - elapsed
            
            if timers[lowestIndex] <= 0 then
                BK:SendMessage(channels[lowestIndex])
                timers[lowestIndex] = BK:GetCurrentRate(channels[lowestIndex])
            end
        end
    else
        -- Send to all channels independently
        for i, channel in ipairs(channels) do
            if channel.enabled and BK:IsValidChannel(channel) then
                timers[i] = (timers[i] or BK:GetCurrentRate(channel)) - elapsed
                
                if timers[i] <= 0 then
                    BK:SendMessage(channel)
                    timers[i] = BK:GetCurrentRate(channel)
                end
            end
        end
    end
end

-- Enable barking
function BK:Enable()
    BK.isActive = true
    BK_characterConfig.enabled = true
    BK_characterConfig.messagesSent = 0
    
    -- Initialize channel timers
    BK.frame.channelTimers = {}
    for i, channel in ipairs(BK_characterConfig.channels) do
        BK.frame.channelTimers[i] = BK:GetCurrentRate(channel)
    end
    
    BK:Print(BARKER_ACTIVE)
    BK:PrintStatus()
end

-- Disable barking
function BK:Disable()
    BK.isActive = false
    BK_characterConfig.enabled = false
    BK:Print(BARKER_INACTIVE)
end

-- Send a message to a channel
function BK:SendMessage(channelInfo)
    local system, channelNumber, channelName = BK:GetChannelInfo(channelInfo)
    
    if not system then
        BK:PrintError(BARKER_ERR_CHAN:gsub("CHANNEL", channelInfo.name or "unknown"))
        return false
    end
    
    local message = BK:GetNextMessage()
    
    -- Show message in chat if enabled
    if BK_characterConfig.showInChat then
        BK:Print("%s: %s", BK:GetChannelDisplayName(channelInfo), message)
    end
    
    -- Send the message
    MessageQueue.SendChatMessage(message, system, nil, channelNumber)
    BK_characterConfig.messagesSent = BK_characterConfig.messagesSent + 1
    
    return true
end

-- Show current status and settings
function BK:PrintStatus()
    if BK.isActive then
        BK:Print(BARKER_ACTIVE)
    else
        BK:Print(BARKER_INACTIVE)
    end
    
    local messageCount = #BK_characterConfig.messages
    local channelCount = 0
    
    for _, channel in ipairs(BK_characterConfig.channels) do
        if channel.enabled then
            channelCount = channelCount + 1
        end
    end
    
    -- Print basic status
    BK:Print(BARKER_STATS_MULTI:gsub("COUNT", tostring(messageCount)):gsub("RATE", tostring(BK_characterConfig.baseRate)))
    
    -- Print active channels
    for _, channel in ipairs(BK_characterConfig.channels) do
        if channel.enabled then
            local rate = channel.customRate and channel.rate or BK_characterConfig.baseRate
            BK:Print("- " .. BK:GetChannelDisplayName(channel) .. " (" .. tostring(rate) .. "s)")
        end
    end
    
    -- Print active time windows if set
    if BK_characterConfig.activeHours.start > 0 or BK_characterConfig.activeHours.stop < 24 then
        BK:Print(BARKER_ACTIVE_HOURS:gsub("START", BK:FormatTime(BK_characterConfig.activeHours.start, 0)):gsub("END", BK:FormatTime(BK_characterConfig.activeHours.stop, 0)))
    end
end

-- Parse a channel specification
function BK:ParseChannel(channelSpec)
    channelSpec = BK:Trim(channelSpec)
    
    -- Look for channel by name
    for _, info in ipairs(BK.CHANNEL_TYPES) do
        if strlower(channelSpec) == info.name then
            return { type = info.id, name = info.name }
        end
    end
    
    -- Check if it's a numeric channel
    if tonumber(channelSpec) then
        local id, name = GetChannelName(channelSpec)
        if id and id ~= 0 then
            return { type = "CHANNEL", name = channelSpec }
        end
    end
    
    -- Default to say if not recognized
    return { type = "SAY", name = "say" }
end

-- Add a channel to the configuration
function BK:AddChannel(channelSpec, rate)
    local channel = BK:ParseChannel(channelSpec)
    
    -- Set rate if specified
    if rate and tonumber(rate) and tonumber(rate) >= BK.MAX_RATE then
        channel.customRate = true
        channel.rate = tonumber(rate)
    else
        channel.customRate = false
        channel.rate = BK_characterConfig.baseRate
    end
    
    channel.enabled = true
    
    -- Prevent duplicates
    for i, existingChannel in ipairs(BK_characterConfig.channels) do
        if existingChannel.type == channel.type and existingChannel.name == channel.name then
            -- Update existing channel rate if specified
            if rate and tonumber(rate) and tonumber(rate) >= BK.MAX_RATE then
                existingChannel.customRate = true
                existingChannel.rate = tonumber(rate)
            end
            BK:Print(BARKER_CHANNEL_EXISTS:gsub("CHANNEL", BK:GetChannelDisplayName(existingChannel)))
            return
        end
    end
    
    -- Check if we've hit the maximum number of channels
    if #BK_characterConfig.channels >= BK.MAX_CHANNELS then
        BK:PrintError(BARKER_MAX_CHANNELS)
        return
    end
    
    -- Add the channel
    table.insert(BK_characterConfig.channels, channel)
    table.insert(BK.frame.channelTimers, BK:GetCurrentRate(channel))
    
    BK:Print(BARKER_CHANNEL_ADDED:gsub("CHANNEL", BK:GetChannelDisplayName(channel)))
end

-- Remove a channel from the configuration
function BK:RemoveChannel(index)
    if not BK_characterConfig.channels[index] then
        BK:PrintError(BARKER_INVALID_CHANNEL_INDEX)
        return
    end
    
    local channel = BK_characterConfig.channels[index]
    BK:Print(BARKER_CHANNEL_REMOVED:gsub("CHANNEL", BK:GetChannelDisplayName(channel)))
    
    table.remove(BK_characterConfig.channels, index)
    table.remove(BK.frame.channelTimers, index)
    
    if #BK_characterConfig.channels == 0 then
        -- Add default channel if list is empty
        BK:AddChannel("say")
    end
end

-- Set the message rate
function BK:SetRate(rate)
    if rate ~= nil and tonumber(rate) > 0 then 
        rate = tonumber(rate) 
    else
        BK:PrintError(BARKER_ERR_NUMBER)
        return
    end
    
    if rate >= BK.MAX_RATE then
        BK_characterConfig.baseRate = rate
        local s = string.gsub(BARKER_RATE, "RATE", BK_characterConfig.baseRate)
        BK:Print(s)
    else
        local s = string.gsub(BARKER_ERR_RATE, "RATE", BK.MAX_RATE)
        BK:PrintError(s)
    end
end

-- Set the message rate variance
function BK:SetRateVariance(variance)
    if variance ~= nil and tonumber(variance) >= 0 then 
        variance = tonumber(variance) 
    else
        BK:PrintError(BARKER_ERR_NUMBER)
        return
    end
    
    BK_characterConfig.rateVariance = variance
    local s = string.gsub(BARKER_RATE_VARIANCE, "VARIANCE", variance)
    BK:Print(s)
end

-- Add a message to the rotation
function BK:AddMessage(msg)
    if not msg or msg == "" then
        BK:PrintError(BARKER_ERR_EMPTY_MESSAGE)
        return
    end
    
    -- Check if we've hit the maximum number of messages
    if #BK_characterConfig.messages >= BK.MAX_MESSAGES then
        BK:PrintError(BARKER_MAX_MESSAGES)
        return
    end
    
    table.insert(BK_characterConfig.messages, msg)
    BK:Print(BARKER_MESSAGE_ADDED:gsub("INDEX", tostring(#BK_characterConfig.messages)))
end

-- Remove a message from the rotation
function BK:RemoveMessage(index)
    index = tonumber(index)
    
    if not index or not BK_characterConfig.messages[index] then
        BK:PrintError(BARKER_INVALID_MESSAGE_INDEX)
        return
    end
    
    table.remove(BK_characterConfig.messages, index)
    
    -- Reset the current index if needed
    if BK_characterConfig.currentMessageIndex > #BK_characterConfig.messages then
        BK_characterConfig.currentMessageIndex = 1
    end
    
    BK:Print(BARKER_MESSAGE_REMOVED:gsub("INDEX", tostring(index)))
    
    -- Add default message if list is empty
    if #BK_characterConfig.messages == 0 then
        BK:AddMessage("Barker " .. BK.version)
    end
end

-- Set message rotation mode
function BK:SetMessageMode(mode)
    if mode == "random" or mode == "sequential" then
        BK_characterConfig.messageMode = mode
        BK:Print(BARKER_MESSAGE_MODE:gsub("MODE", mode))
    else
        BK:PrintError(BARKER_ERR_MESSAGE_MODE)
    end
end

-- Set active hours
function BK:SetActiveHours(start, stop)
    start = tonumber(start)
    stop = tonumber(stop)
    
    if not start or start < 0 or start > 23 or
       not stop or stop < 0 or stop > 24 then
        BK:PrintError(BARKER_ERR_HOURS)
        return
    end
    
    BK_characterConfig.activeHours.start = start
    BK_characterConfig.activeHours.stop = stop
    
    BK:Print(BARKER_ACTIVE_HOURS:gsub("START", BK:FormatTime(start, 0)):gsub("END", BK:FormatTime(stop, 0)))
end

-- Toggle active day
function BK:ToggleActiveDay(day)
    day = tonumber(day)
    
    if not day or day < 1 or day > 7 then
        BK:PrintError(BARKER_ERR_DAY)
        return
    end
    
    BK_characterConfig.activeDays[day] = not BK_characterConfig.activeDays[day]
    
    local dayName = CALENDAR_WEEKDAY_NAMES[day]
    local state = BK_characterConfig.activeDays[day] and BARKER_ENABLED or BARKER_DISABLED
    
    BK:Print(BARKER_DAY_TOGGLE:gsub("DAY", dayName):gsub("STATE", state))
end

-- Set max messages
function BK:SetMaxMessages(count)
    count = tonumber(count) or 0
    
    if count < 0 then count = 0 end
    
    BK_characterConfig.maxMessages = count
    
    if count == 0 then
        BK:Print(BARKER_MAX_MESSAGES_UNLIMITED)
    else
        BK:Print(BARKER_MAX_MESSAGES_SET:gsub("COUNT", tostring(count)))
    end
end

-- Toggle alternate channels mode
function BK:ToggleAlternateChannels()
    BK_characterConfig.alternateChannels = not BK_characterConfig.alternateChannels
    
    if BK_characterConfig.alternateChannels then
        BK:Print(BARKER_ALTERNATE_ON)
    else
        BK:Print(BARKER_ALTERNATE_OFF)
    end
end

-- Toggle show in chat mode
function BK:ToggleShowInChat()
    BK_characterConfig.showInChat = not BK_characterConfig.showInChat
    
    if BK_characterConfig.showInChat then
        BK:Print(BARKER_SHOW_IN_CHAT_ON)
    else
        BK:Print(BARKER_SHOW_IN_CHAT_OFF)
    end
end

-- Toggle debug mode
function BK:ToggleDebug()
    BK_characterConfig.debug = not BK_characterConfig.debug
    
    if BK_characterConfig.debug then
        BK:Print(BARKER_DEBUG_ON)
    else
        BK:Print(BARKER_DEBUG_OFF)
    end
end

-- ===========================================
-- Slash command implementations
-- ===========================================

-- /bark [on|off]
function BK:SlashBark(params)
    if params == "on" then
        BK:Enable()
    elseif params == "off" then
        BK:Disable()
    else
        if BK.isActive then
            BK:Disable()
        else
            BK:Enable()
        end
    end
    
    -- Update UI if it exists
    if Barker_UI and Barker_UI.UpdateControls then
        Barker_UI:UpdateControls()
    end
end

-- /barkmsg <message>
function BK:SlashBarkMessage(params)
    if params == "" then
        -- Show current messages
        BK:Print(BARKER_CURRENT_MESSAGES)
        for i, msg in ipairs(BK_characterConfig.messages) do
            BK:Print("%d: %s", i, msg)
        end
    else
        BK:AddMessage(params)
    end
end

-- /barkmsgremove <index>
function BK:SlashBarkMessageRemove(params)
    BK:RemoveMessage(params)
end

-- /barkmode <mode>
function BK:SlashBarkMode(params)
    BK:SetMessageMode(params)
end

-- /barkchan <channel>
function BK:SlashBarkChannel(params)
    if params == "" then
        -- List current channels
        BK:Print(BARKER_CURRENT_CHANNELS)
        for i, channel in ipairs(BK_characterConfig.channels) do
            local enabled = channel.enabled and "" or " (" .. BARKER_DISABLED .. ")"
            local rate = channel.customRate and " - " .. channel.rate .. "s" or ""
            BK:Print("%d: %s%s%s", i, BK:GetChannelDisplayName(channel), rate, enabled)
        end
    else
        -- Add new channel
        local channelName, rate = strsplit(" ", params, 2)
        BK:AddChannel(channelName, rate)
    end
end

-- /barkchanremove <index>
function BK:SlashBarkChannelRemove(params)
    BK:RemoveChannel(tonumber(params))
end

-- /barkchantoggle <index>
function BK:SlashBarkChannelToggle(params)
    local index = tonumber(params)
    
    if not index or not BK_characterConfig.channels[index] then
        BK:PrintError(BARKER_INVALID_CHANNEL_INDEX)
        return
    end
    
    local channel = BK_characterConfig.channels[index]
    channel.enabled = not channel.enabled
    
    local state = channel.enabled and BARKER_ENABLED or BARKER_DISABLED
    BK:Print(BARKER_CHANNEL_TOGGLE:gsub("CHANNEL", BK:GetChannelDisplayName(channel)):gsub("STATE", state))
end

-- /barkrate <duration>
function BK:SlashBarkRate(params)
    BK:SetRate(params)
end

-- /barkvariance <seconds>
function BK:SlashBarkVariance(params)
    BK:SetRateVariance(params)
end

-- /barkhours <start> <stop>
function BK:SlashBarkHours(params)
    local start, stop = strsplit(" ", params, 2)
    BK:SetActiveHours(start, stop)
end

-- /barkday <day>
function BK:SlashBarkDay(params)
    BK:ToggleActiveDay(params)
end

-- /barkmax <count>
function BK:SlashBarkMax(params)
    BK:SetMaxMessages(params)
end

-- /barkalternate
function BK:SlashBarkAlternate()
    BK:ToggleAlternateChannels()
end

-- /barkshowchat
function BK:SlashBarkShowChat()
    BK:ToggleShowInChat()
end

-- /barkdebug
function BK:SlashBarkDebug()
    BK:ToggleDebug()
end

-- /barkinfo
function BK:SlashBarkInfo()
    BK:PrintStatus()
end

-- /barkui
function BK:SlashBarkUI()
    if not Barker_UI then
        BK:PrintError(BARKER_UI_NOT_LOADED)
        return
    end
    
    Barker_UI:Toggle()
end

-- /barkhelp
function BK:SlashBarkHelp()
    for _, l in pairs(BARKER_HELP) do
        DEFAULT_CHAT_FRAME:AddMessage(l, 1, 1, 1)
    end
end

-- ===========================================
-- Register slash commands
-- ===========================================

SlashCmdList["BARKER"] = function(msg) BK:SlashBark(msg) end
SLASH_BARKER1 = "/bark"

SlashCmdList["BARKERSETMESSAGE"] = function(msg) BK:SlashBarkMessage(msg) end
SLASH_BARKERSETMESSAGE1 = "/barkmessage"
SLASH_BARKERSETMESSAGE2 = "/barkmsg"

SlashCmdList["BARKERRMMESSAGE"] = function(msg) BK:SlashBarkMessageRemove(msg) end
SLASH_BARKERRMMESSAGE1 = "/barkmsgremove"
SLASH_BARKERRMMESSAGE2 = "/barkmsgdel"

SlashCmdList["BARKERMODE"] = function(msg) BK:SlashBarkMode(msg) end
SLASH_BARKERMODE1 = "/barkmode"

SlashCmdList["BARKERSETCHANNEL"] = function(msg) BK:SlashBarkChannel(msg) end
SLASH_BARKERSETCHANNEL1 = "/barkchannel"
SLASH_BARKERSETCHANNEL2 = "/barkchan"

SlashCmdList["BARKERRMCHANNEL"] = function(msg) BK:SlashBarkChannelRemove(msg) end
SLASH_BARKERRMCHANNEL1 = "/barkchanremove"
SLASH_BARKERRMCHANNEL2 = "/barkchandel"

SlashCmdList["BARKERTOGCHANNEL"] = function(msg) BK:SlashBarkChannelToggle(msg) end
SLASH_BARKERTOGCHANNEL1 = "/barkchantoggle"

SlashCmdList["BARKERSETRATE"] = function(msg) BK:SlashBarkRate(msg) end
SLASH_BARKERSETRATE1 = "/barkrate"

SlashCmdList["BARKERSETVARIANCE"] = function(msg) BK:SlashBarkVariance(msg) end
SLASH_BARKERSETVARIANCE1 = "/barkvariance"

SlashCmdList["BARKERSETHOURS"] = function(msg) BK:SlashBarkHours(msg) end
SLASH_BARKERSETHOURS1 = "/barkhours"

SlashCmdList["BARKERTOGDAY"] = function(msg) BK:SlashBarkDay(msg) end
SLASH_BARKERTOGDAY1 = "/barkday"

SlashCmdList["BARKERSETMAX"] = function(msg) BK:SlashBarkMax(msg) end
SLASH_BARKERSETMAX1 = "/barkmax"

SlashCmdList["BARKERTOGALTERNATE"] = function() BK:SlashBarkAlternate() end
SLASH_BARKERTOGALTERNATE1 = "/barkalternate"

SlashCmdList["BARKERTOGSHOWCHAT"] = function() BK:SlashBarkShowChat() end
SLASH_BARKERTOGSHOWCHAT1 = "/barkshowchat"

SlashCmdList["BARKERTOGDEBUG"] = function() BK:SlashBarkDebug() end
SLASH_BARKERTOGDEBUG1 = "/barkdebug"

SlashCmdList["BARKERINFO"] = function() BK:SlashBarkInfo() end
SLASH_BARKERINFO1 = "/barkinfo"
SLASH_BARKERINFO2 = "/barkconfig"

SlashCmdList["BARKERUI"] = function() BK:SlashBarkUI() end
SLASH_BARKERUI1 = "/barkui"

SlashCmdList["BARKERHELP"] = function() BK:SlashBarkHelp() end
SLASH_BARKERHELP1 = "/barkhelp"
SLASH_BARKERHELP2 = "/barkman"

-- Initialize the addon
BK:Initialize()