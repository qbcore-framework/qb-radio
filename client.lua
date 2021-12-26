local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData() -- Just for resource restart (same as event handler)
local radioMenu = false
local onRadio = false
local RadioChannel = 0
local RadioVolume = 50

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
    PlayerData.gang = GangInfo
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
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
        if LocalPlayer.state.isLoggedIn and onRadio then
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
    closeEvent()
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
end)

function LoadAnimDic(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

function toggleRadioAnimation(pState)
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

function closeEvent()
	TriggerEvent("InteractSound_CL:PlayOnOne","click",0.6)
end

function toggleRadio(toggle)
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

RegisterNUICallback('poweredOff', function(data, cb)
	leaveradio()
end)

RegisterNUICallback('escape', function(data, cb)
    toggleRadio(false)
end)
