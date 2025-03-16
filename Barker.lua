-- ===========================================
-- Slash command implementations
-- ===========================================

-- /bkr [on|off]
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

-- /bkrmsg <message>
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

-- /bkrmsgdel <index>
function BK:SlashBarkMessageRemove(params)
    BK:RemoveMessage(params)
end

-- /bkrmode <mode>
function BK:SlashBarkMode(params)
    BK:SetMessageMode(params)
end

-- /bkrchan <channel>
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

-- /bkrchandel <index>
function BK:SlashBarkChannelRemove(params)
    BK:RemoveChannel(tonumber(params))
end

-- /bkrchantog <index>
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

-- /bkrrate <duration>
function BK:SlashBarkRate(params)
    BK:SetRate(params)
end

-- /bkrvar <seconds>
function BK:SlashBarkVariance(params)
    BK:SetRateVariance(params)
end

-- /bkrhours <start> <stop>
function BK:SlashBarkHours(params)
    local start, stop = strsplit(" ", params, 2)
    BK:SetActiveHours(start, stop)
end

-- /bkrday <day>
function BK:SlashBarkDay(params)
    BK:ToggleActiveDay(params)
end

-- /bkrmax <count>
function BK:SlashBarkMax(params)
    BK:SetMaxMessages(params)
end

-- /bkralt
function BK:SlashBarkAlternate()
    BK:ToggleAlternateChannels()
end

-- /bkrshow
function BK:SlashBarkShowChat()
    BK:ToggleShowInChat()
end

-- /bkrdebug
function BK:SlashBarkDebug()
    BK:ToggleDebug()
end

-- /bkrinfo
function BK:SlashBarkInfo()
    BK:PrintStatus()
end

-- /bkrui
function BK:SlashBarkUI()
    if not Barker_UI then
        BK:PrintError(BARKER_UI_NOT_LOADED)
        return
    end
    
    Barker_UI:Toggle()
end

-- /bkrhelp
function BK:SlashBarkHelp()
    for _, l in pairs(BARKER_HELP) do
        DEFAULT_CHAT_FRAME:AddMessage(l, 1, 1, 1)
    end
end

-- ===========================================
-- Register slash commands
-- ===========================================

SlashCmdList["BARKER"] = function(msg) BK:SlashBark(msg) end
SLASH_BARKER1 = "/bkr"

SlashCmdList["BARKERSETMESSAGE"] = function(msg) BK:SlashBarkMessage(msg) end
SLASH_BARKERSETMESSAGE1 = "/bkrmsg"
SLASH_BARKERSETMESSAGE2 = "/bkrmessage"

SlashCmdList["BARKERRMMESSAGE"] = function(msg) BK:SlashBarkMessageRemove(msg) end
SLASH_BARKERRMMESSAGE1 = "/bkrmsgdel"
SLASH_BARKERRMMESSAGE2 = "/bkrmsgremove"

SlashCmdList["BARKERMODE"] = function(msg) BK:SlashBarkMode(msg) end
SLASH_BARKERMODE1 = "/bkrmode"

SlashCmdList["BARKERSETCHANNEL"] = function(msg) BK:SlashBarkChannel(msg) end
SLASH_BARKERSETCHANNEL1 = "/bkrchan"
SLASH_BARKERSETCHANNEL2 = "/bkrchannel"

SlashCmdList["BARKERRMCHANNEL"] = function(msg) BK:SlashBarkChannelRemove(msg) end
SLASH_BARKERRMCHANNEL1 = "/bkrchandel"
SLASH_BARKERRMCHANNEL2 = "/bkrchanremove"

SlashCmdList["BARKERTOGCHANNEL"] = function(msg) BK:SlashBarkChannelToggle(msg) end
SLASH_BARKERTOGCHANNEL1 = "/bkrchantog"

SlashCmdList["BARKERSETRATE"] = function(msg) BK:SlashBarkRate(msg) end
SLASH_BARKERSETRATE1 = "/bkrrate"

SlashCmdList["BARKERSETVARIANCE"] = function(msg) BK:SlashBarkVariance(msg) end
SLASH_BARKERSETVARIANCE1 = "/bkrvar"

SlashCmdList["BARKERSETHOURS"] = function(msg) BK:SlashBarkHours(msg) end
SLASH_BARKERSETHOURS1 = "/bkrhours"

SlashCmdList["BARKERTOGDAY"] = function(msg) BK:SlashBarkDay(msg) end
SLASH_BARKERTOGDAY1 = "/bkrday"

SlashCmdList["BARKERSETMAX"] = function(msg) BK:SlashBarkMax(msg) end
SLASH_BARKERSETMAX1 = "/bkrmax"

SlashCmdList["BARKERTOGALTERNATE"] = function() BK:SlashBarkAlternate() end
SLASH_BARKERTOGALTERNATE1 = "/bkralt"

SlashCmdList["BARKERTOGSHOWCHAT"] = function() BK:SlashBarkShowChat() end
SLASH_BARKERTOGSHOWCHAT1 = "/bkrshow"

SlashCmdList["BARKERTOGDEBUG"] = function() BK:SlashBarkDebug() end
SLASH_BARKERTOGDEBUG1 = "/bkrdebug"

SlashCmdList["BARKERINFO"] = function() BK:SlashBarkInfo() end
SLASH_BARKERINFO1 = "/bkrinfo"
SLASH_BARKERINFO2 = "/bkrconfig"

SlashCmdList["BARKERUI"] = function() BK:SlashBarkUI() end
SLASH_BARKERUI1 = "/bkrui"

SlashCmdList["BARKERHELP"] = function() BK:SlashBarkHelp() end
SLASH_BARKERHELP1 = "/bkrhelp"
SLASH_BARKERHELP2 = "/bkrman"