local QBCore = exports['qb-core']:GetCoreObject()
local radioMenu = false
local isLoggedIn = false
local onRadio = false
local RadioChannel = 0
local RadioVolume = 50

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    leaveradio()
end)

RegisterNetEvent('qb-radio:use', function()
    toggleRadio(not radioMenu)
end)

RegisterNetEvent('qb-radio:onRadioDrop', function()
    if RadioChannel ~= 0 then
        leaveradio()
    end
end)

-- Main Thread

CreateThread(function()
    while true do
        Wait(1000)
        if isLoggedIn and onRadio then
            QBCore.Functions.TriggerCallback('qb-radio:server:GetItem', function(hasItem)
                if not hasItem then
                    if RadioChannel ~= 0 then
                        leaveradio()
                    end
                end
            end,"radio")
        end
    end
end)

-- Functions

function connecttoradio(channel)
    RadioChannel = channel
    if onRadio then
        exports["pma-voice"]:setRadioChannel(0)
    else
        onRadio = true
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
    end
    exports["pma-voice"]:setRadioChannel(channel)
    if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
        QBCore.Functions.Notify(Config.messages['joined_to_radio'] ..channel.. ' MHz', 'success')
    else
        QBCore.Functions.Notify(Config.messages['joined_to_radio'] ..channel.. '.00 MHz', 'success')
    end
end

function leaveradio()
    RadioChannel = 0
    onRadio = false
    exports["pma-voice"]:setRadioChannel(0)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    QBCore.Functions.Notify(Config.messages['you_leave'] , 'error')
end

function SplitStr(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function IsRadioOn()
    return onRadio
end

exports("IsRadioOn", IsRadioOn)

-- NUI
RegisterNUICallback('joinRadio', function(data, cb)
    local rchannel = tonumber(data.channel)
    if rchannel ~= nil then
        if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
            if rchannel ~= RadioChannel then
                if Config.RestrictedChannels[rchannel] ~= nil then
                    local xPlayer = QBCore.Functions.GetPlayerData()
                    if Config.RestrictedChannels[rchannel][xPlayer.job.name] and xPlayer.job.onduty then
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
end)

function toggleRadio(toggle)
    radioMenu = toggle
    SetNuiFocus(radioMenu, radioMenu)
    if radioMenu then
        PhonePlayIn()
        SendNUIMessage({type = "open"})
    else
        PhonePlayOut()
        SendNUIMessage({type = "close"})
    end
end

RegisterNUICallback('leaveRadio', function(data, cb)
    if RadioChannel == 0 then
        QBCore.Functions.Notify(Config.messages['not_on_radio'], 'error')
    else
        leaveradio()
    end
end)

RegisterNUICallback("volumeUp", function()
	if RadioVolume <= 95 then
		RadioVolume = RadioVolume + 5
		QBCore.Functions.Notify(Config.messages["volume_radio"] .. RadioVolume, "success")
		exports["pma-voice"]:setRadioVolume(RadioVolume)
	else
		QBCore.Functions.Notify(Config.messages["decrease_radio_volume"], "error")
	end
end)

RegisterNUICallback("volumeDown", function()
	if RadioVolume >= 10 then
		RadioVolume = RadioVolume - 5
		QBCore.Functions.Notify(Config.messages["volume_radio"] .. RadioVolume, "success")
		exports["pma-voice"]:setRadioVolume(RadioVolume)
	else
		QBCore.Functions.Notify(Config.messages["increase_radio_volume"], "error")
	end
end)

RegisterNUICallback("increaseradiochannel", function(data, cb)
    local newChannel = RadioChannel + 1
	exports["pma-voice"]:setRadioChannel(newChannel)
	QBCore.Functions.Notify(Config.messages["increase_decrease_radio_channel"] .. newChannel, "success")
end)

RegisterNUICallback("decreaseradiochannel", function(data, cb)
    if not onRadio then return end
    local newChannel = RadioChannel - 1
    if newChannel >= 1 then
		exports["pma-voice"]:setRadioChannel(newChannel)
		QBCore.Functions.Notify(Config.messages["increase_decrease_radio_channel"] .. newChannel, "success")
    end
end)

RegisterNUICallback('escape', function(data, cb)
    toggleRadio(false)
end)
