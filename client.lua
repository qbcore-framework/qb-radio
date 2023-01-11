local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData() -- Just for resource restart (same as event handler)
local radioMenu = false
local onRadio = false
local RadioChannel = 0
local RadioVolume = 50
local hasRadio = false
local radioProp = nil

--Function
local function LoadAnimDic(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

local function SplitStr(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[#t+1] = str
    end
    return t
end

local function connecttoradio(channel)
    RadioChannel = channel
    local player = PlayerId()
    if onRadio then
        exports["pma-voice"]:setRadioChannel(0)
    else
        onRadio = true
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
    end
    exports["pma-voice"]:setRadioChannel(channel)
    TriggerServerEvent("qb-radio:server:addradiolist", channel)
    if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
        QBCore.Functions.Notify(Config.messages['joined_to_radio'] ..channel.. ' MHz', 'success')
    else
        QBCore.Functions.Notify(Config.messages['joined_to_radio'] ..channel.. '.00 MHz', 'success')
    end
    
    TriggerServerEvent("qb-log:server:CreateLog", "radio", channel .." Radio Joined", "green", ""..GetPlayerName(GetPlayerFromServerId(GetPlayerServerId(PlayerId()))).. " Has Joined The Radio " .. channel)
end

local function closeEvent()
	TriggerEvent("InteractSound_CL:PlayOnOne","click",0.6)
end

local function leaveradio()
    closeEvent()
    local player = PlayerId()
    local rchannel = RadioChannel
    RadioChannel = 0
    onRadio = false
    exports["pma-voice"]:setRadioChannel(0)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    QBCore.Functions.Notify(Config.messages['you_leave'] , 'error')
    TriggerServerEvent("qb-radio:remove:removeradiolist")
    TriggerServerEvent("qb-log:server:CreateLog", "radio", rchannel .." Radio Left", "red", ""..GetPlayerName(GetPlayerFromServerId(GetPlayerServerId(PlayerId()))).. " has Left The Radio " .. rchannel)
end

local function toggleRadioAnimation(pState)
	LoadAnimDic("cellphone@")
	if pState then
		TriggerEvent("attachItemRadio","radio01")
		TaskPlayAnim(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
		radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(radioProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
	else
		StopAnimTask(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 1.0)
		ClearPedTasks(PlayerPedId())
		if radioProp ~= 0 then
			DeleteObject(radioProp)
			radioProp = 0
		end
	end
end

local function toggleRadio(toggle)
    radioMenu = toggle
    SetNuiFocus(radioMenu, radioMenu)
    if radioMenu then
        toggleRadioAnimation(true)
        SendNUIMessage({type = "open"})
    else
        toggleRadioAnimation(false)
        SendNUIMessage({type = "close"})
    end
end

local function IsRadioOn()
    return onRadio
end

local function DoRadioCheck(PlayerItems)
    local _hasRadio = false

    for _, item in pairs(PlayerItems) do
        if item.name == "radio" then
            _hasRadio = true
            break;
        end
    end

    hasRadio = _hasRadio
end

--Exports
exports("IsRadioOn", IsRadioOn)

--Events
-- list connected players

RegisterNUICallback('getPlayers', function (_, cb)
    QBCore.Functions.TriggerCallback('qb-radio:remove:getlist', function(playerlist)
        if playerlist then
            cb(playerlist)
        else
            cb(nil)
        end
    end, RadioChannel)
end)

-- Handles state right when the player selects their character and location.
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    DoRadioCheck(PlayerData.items)
end)

-- Resets state on logout, in case of character change.
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    DoRadioCheck({})
    PlayerData = {}
    leaveradio()
end)

-- Handles state when PlayerData is changed. We're just looking for inventory updates.
RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    DoRadioCheck(PlayerData.items)
end)

-- Handles state if resource is restarted live.
AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        PlayerData = QBCore.Functions.GetPlayerData()
        DoRadioCheck(PlayerData.items)
    end
end)

RegisterNetEvent('qb-radio:use', function()
    toggleRadio(not radioMenu)
end)

RegisterNetEvent('qb-radio:onRadioDrop', function()
    if RadioChannel ~= 0 then
        leaveradio()
    end
end)

-- NUI
RegisterNUICallback('joinRadio', function(data, cb)
    local rchannel = tonumber(data.channel)
    if rchannel ~= nil then
        if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
            if rchannel ~= RadioChannel then
                if Config.RestrictedChannels[rchannel] ~= nil then
                    if Config.RestrictedChannels[rchannel][PlayerData.job.name] and PlayerData.job.onduty then
                        connecttoradio(rchannel)
                    else
                        QBCore.Functions.Notify(Config.messages['restricted_channel_error'], 'error')
                    end
                else
                    connecttoradio(rchannel)
                end
            else
                QBCore.Functions.Notify(Config.messages['you_on_radio'] , 'error')
            end
        else
            QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
        end
    else
        QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
    end
    cb("ok")
end)

RegisterNUICallback('leaveRadio', function(_, cb)
    local player = PlayerId()
    local rchannel = RadioChannel
    if RadioChannel == 0 then
        QBCore.Functions.Notify(Config.messages['not_on_radio'], 'error')
    else
        leaveradio()
    end
    cb("ok")
end)

RegisterNUICallback("volumeUp", function(_, cb)
	if RadioVolume <= 95 then
		RadioVolume = RadioVolume + 5
		QBCore.Functions.Notify(Config.messages["volume_radio"] .. RadioVolume, "success")
		exports["pma-voice"]:setRadioVolume(RadioVolume)
	else
		QBCore.Functions.Notify(Config.messages["decrease_radio_volume"], "error")
	end
    cb('ok')
end)

RegisterNUICallback("volumeDown", function(_, cb)
	if RadioVolume >= 10 then
		RadioVolume = RadioVolume - 5
		QBCore.Functions.Notify(Config.messages["volume_radio"] .. RadioVolume, "success")
		exports["pma-voice"]:setRadioVolume(RadioVolume)
	else
		QBCore.Functions.Notify(Config.messages["increase_radio_volume"], "error")
	end
    cb('ok')
end)

RegisterNUICallback("increaseradiochannel", function(_, cb)
    --local newChannel = RadioChannel + 1
    local newChannel = tonumber(data.channel) + 1
    TriggerServerEvent("qb-log:server:CreateLog", "radio", "Radio Changed + ", "yellow", ""..GetPlayerName(GetPlayerFromServerId(GetPlayerServerId(PlayerId()))).. " Has Changed The Radio from "..RadioChannel.." to " .. newChannel)
    connecttoradio(newChannel)
    cb("ok")
end)

RegisterNUICallback("decreaseradiochannel", function(_, cb)
    if not onRadio then return end
    -- local newChannel = RadioChannel - 1
    local newChannel = tonumber(data.channel) - 1
    if newChannel >= 1 then
        TriggerServerEvent("qb-log:server:CreateLog", "radio", "Radio Changed - ", "yellow", ""..GetPlayerName(GetPlayerFromServerId(GetPlayerServerId(PlayerId()))).. " Has Changed The Radio from "..RadioChannel.." to " .. newChannel)
        connecttoradio(newChannel)
        cb("ok")
    end
end)

RegisterNUICallback('poweredOff', function(_, cb)
    leaveradio()
    cb("ok")
end)

RegisterNUICallback('escape', function(_, cb)
    toggleRadio(false)
    cb("ok")
end)

--Main Thread
CreateThread(function()
    while true do
        Wait(1000)
        if LocalPlayer.state.isLoggedIn and onRadio then
            if not hasRadio or PlayerData.metadata.isdead then
                if RadioChannel ~= 0 then
                    leaveradio()
                end
            end
        end
    end
end)

-- Leave Radio
RegisterNetEvent('qb-radio:client:leaveRadio', function()
    leaveradio()
end)

RegisterNetEvent('qb-radio:client:volumeUpradio', function(val)
    local newvalue = tonumber(val)
    if newvalue <= 100  and newvalue >= 0 then
        RadioVolume = newvalue
		QBCore.Functions.Notify(Config.messages["volume_radio"] .. RadioVolume, "success")
		exports["pma-voice"]:setRadioVolume(RadioVolume)
	else
		QBCore.Functions.Notify("Invalid Volume Amount", "error")
	end
end)

RegisterNetEvent('qb-radio:client:JoinRadioChannel1', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function()
        local rchannel = 1
        if rchannel ~= nil then
            if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
                if rchannel ~= RadioChannel then
                    if Config.RestrictedChannels[rchannel] ~= nil then
                        if Config.RestrictedChannels[rchannel][PlayerData.job.name] and PlayerData.job.onduty then
                            connecttoradio(rchannel)
                        else
                            QBCore.Functions.Notify(Config.messages['restricted_channel_error'], 'error')
                        end
                    else
                        connecttoradio(rchannel)
                    end
                else
                    QBCore.Functions.Notify(Config.messages['you_on_radio'] , 'error')
                end
            else
                QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
            end
        else
            QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
        end
    end, 'radio')
end)

RegisterNetEvent('qb-radio:client:JoinRadioChannel2', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function()
        local rchannel = 2
        if rchannel ~= nil then
            if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
                if rchannel ~= RadioChannel then
                    if Config.RestrictedChannels[rchannel] ~= nil then
                        if Config.RestrictedChannels[rchannel][PlayerData.job.name] and PlayerData.job.onduty then
                            connecttoradio(rchannel)
                        else
                            QBCore.Functions.Notify(Config.messages['restricted_channel_error'], 'error')
                        end
                    else
                        connecttoradio(rchannel)
                    end
                else
                    QBCore.Functions.Notify(Config.messages['you_on_radio'] , 'error')
                end
            else
                QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
            end
        else
            QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
        end
    end, 'radio')
end)

RegisterNetEvent('qb-radio:client:JoinRadioChannel3', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function()
        local rchannel = 3
        if rchannel ~= nil then
            if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
                if rchannel ~= RadioChannel then
                    if Config.RestrictedChannels[rchannel] ~= nil then
                        if Config.RestrictedChannels[rchannel][PlayerData.job.name] and PlayerData.job.onduty then
                            connecttoradio(rchannel)
                        else
                            QBCore.Functions.Notify(Config.messages['restricted_channel_error'], 'error')
                        end
                    else
                        connecttoradio(rchannel)
                    end
                else
                    QBCore.Functions.Notify(Config.messages['you_on_radio'] , 'error')
                end
            else
                QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
            end
        else
            QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
        end
    end, 'radio')
end)

RegisterNetEvent('qb-radio:client:JoinRadioChannel4', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function()
        local rchannel = 4
        if rchannel ~= nil then
            if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
                if rchannel ~= RadioChannel then
                    if Config.RestrictedChannels[rchannel] ~= nil then
                        if Config.RestrictedChannels[rchannel][PlayerData.job.name] and PlayerData.job.onduty then
                            connecttoradio(rchannel)
                        else
                            QBCore.Functions.Notify(Config.messages['restricted_channel_error'], 'error')
                        end
                    else
                        connecttoradio(rchannel)
                    end
                else
                    QBCore.Functions.Notify(Config.messages['you_on_radio'] , 'error')
                end
            else
                QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
            end
        else
            QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
        end
    end, 'radio')
end)

RegisterNetEvent('qb-radio:client:JoinRadioChannel5', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function()
        local rchannel = 5
        if rchannel ~= nil then
            if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
                if rchannel ~= RadioChannel then
                    if Config.RestrictedChannels[rchannel] ~= nil then
                        if Config.RestrictedChannels[rchannel][PlayerData.job.name] and PlayerData.job.onduty then
                            connecttoradio(rchannel)
                        else
                            QBCore.Functions.Notify(Config.messages['restricted_channel_error'], 'error')
                        end
                    else
                        connecttoradio(rchannel)
                    end
                else
                    QBCore.Functions.Notify(Config.messages['you_on_radio'] , 'error')
                end
            else
                QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
            end
        else
            QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
        end
    end, 'radio')
end)

RegisterNetEvent('qb-radio:client:JoinRadioChannel6', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function()
        local rchannel = 6
        if rchannel ~= nil then
            if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
                if rchannel ~= RadioChannel then
                    if Config.RestrictedChannels[rchannel] ~= nil then
                        if Config.RestrictedChannels[rchannel][PlayerData.job.name] and PlayerData.job.onduty then
                            connecttoradio(rchannel)
                        else
                            QBCore.Functions.Notify(Config.messages['restricted_channel_error'], 'error')
                        end
                    else
                        connecttoradio(rchannel)
                    end
                else
                    QBCore.Functions.Notify(Config.messages['you_on_radio'] , 'error')
                end
            else
                QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
            end
        else
            QBCore.Functions.Notify(Config.messages['invalid_radio'] , 'error')
        end
    end, 'radio')
end)
