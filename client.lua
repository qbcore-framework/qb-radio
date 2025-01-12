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
    if channel > Config.MaxFrequency or channel <= 0 then QBCore.Functions.Notify(Lang:t('restricted_channel_error'), 'error') return false end
    if Config.RestrictedChannels[channel] ~= nil then
        if not Config.RestrictedChannels[channel][PlayerData.job.name] or not PlayerData.job.onduty then
            QBCore.Functions.Notify(Lang:t('restricted_channel_error'), 'error')
            return false
        end
    end
    RadioChannel = channel
    if onRadio then
        exports["pma-voice"]:setRadioChannel(0)
    else
        onRadio = true
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
    end
    exports["pma-voice"]:setRadioChannel(channel)
    if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
        QBCore.Functions.Notify(Lang:t('joined_to_radio', {channel = channel .. ' MHz'}), 'success')
    else
        QBCore.Functions.Notify(Lang:t('joined_to_radio', {channel = channel .. '.00 MHz'}), 'success')
    end
    return true
end

local function closeEvent()
	TriggerEvent("InteractSound_CL:PlayOnOne","click",0.6)
end

local function leaveradio()
    closeEvent()
    RadioChannel = 0
    onRadio = false
    exports["pma-voice"]:setRadioChannel(0)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    QBCore.Functions.Notify(Lang:t('you_leave') , 'error')
end

local function toggleRadioAnimation(pState)
	LoadAnimDic("cellphone@")
	if pState then
		TriggerEvent("attachItemRadio","radio01")
		TaskPlayAnim(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, false, false, false)
		radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, true, true, false)
		AttachEntityToEntity(radioProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, true, false, false, false, 2, true)
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

local function DoRadioCheck()
  QBCore.Functions.TriggerCallback("qb-radio::server::hasRadio", function(value)
        hasRadio = value
    end)
end

--Exports
exports("IsRadioOn", IsRadioOn)

--Events

-- Handles state right when the player selects their character and location.
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    DoRadioCheck()
end)

-- Resets state on logout, in case of character change.
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    leaveradio()
end)

-- Handles state when PlayerData is changed. We're just looking for inventory updates.
RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    DoRadioCheck()
end)

-- Handles state if resource is restarted live.
AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        PlayerData = QBCore.Functions.GetPlayerData()
        DoRadioCheck()
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
    local rchannel = QBCore.Shared.Round(tonumber(data.channel), 2)
    if rchannel ~= nil then
        if rchannel <= Config.MaxFrequency and rchannel > 0 then
            if rchannel ~= RadioChannel then
                local canaccess = connecttoradio(rchannel)
                cb({
                    canaccess = canaccess,
                    channel = RadioChannel
                })
                return
            else
                QBCore.Functions.Notify(Lang:t('you_on_radio') , 'error')
            end
        else
            QBCore.Functions.Notify(Lang:t('invalid_radio') , 'error')
        end
    else
        QBCore.Functions.Notify(Lang:t('invalid_radio') , 'error')
    end
    cb({
        canaccess = false,
        channel = RadioChannel
    })
    return
end)

RegisterNUICallback('leaveRadio', function(_, cb)
    if RadioChannel == 0 then
        QBCore.Functions.Notify(Lang:t('not_on_radio'), 'error')
    else
        leaveradio()
    end
    cb("ok")
end)

RegisterNUICallback("volumeUp", function(_, cb)
	if RadioVolume <= 95 then
		RadioVolume = RadioVolume + 5
		QBCore.Functions.Notify(Lang:t("volume_radio", { value = RadioVolume}), "success")
		exports["pma-voice"]:setRadioVolume(RadioVolume)
	else
		QBCore.Functions.Notify(Lang:t("decrease_radio_volume"), "error")
	end
    cb('ok')
end)

RegisterNUICallback("volumeDown", function(_, cb)
	if RadioVolume >= 10 then
		RadioVolume = RadioVolume - 5
		QBCore.Functions.Notify(Lang:t("volume_radio", {value = RadioVolume}), "success")
		exports["pma-voice"]:setRadioVolume(RadioVolume)
	else
		QBCore.Functions.Notify(Lang:t("increase_radio_volume"), "error")
	end
    cb('ok')
end)

RegisterNUICallback("increaseradiochannel", function(_, cb)
    if not onRadio then return end
    local newChannel = QBCore.Shared.Round(tonumber(RadioChannel + 1), 2)
    local canaccess = connecttoradio(newChannel)
    cb({
       canaccess = canaccess,
       channel = newChannel
    })
end)

RegisterNUICallback("decreaseradiochannel", function(_, cb)
    if not onRadio then return end
    local newChannel = QBCore.Shared.Round(tonumber(RadioChannel - 1), 2)
    local canaccess = connecttoradio(newChannel)
    cb({
        canaccess = canaccess,
        channel = newChannel
    })
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
            if not hasRadio or PlayerData.metadata.isdead or PlayerData.metadata.inlaststand then
                if RadioChannel ~= 0 then
                    leaveradio()
                end
            end
        end
    end
end)
