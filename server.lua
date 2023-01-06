local QBCore = exports['qb-core']:GetCoreObject()
local playerlist = {}

QBCore.Functions.CreateUseableItem("radio", function(source)
    TriggerClientEvent('qb-radio:use', source)
end)

for channel, config in pairs(Config.RestrictedChannels) do
    exports['pma-voice']:addChannelCheck(channel, function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        return config[Player.PlayerData.job.name] and Player.PlayerData.job.onduty
    end)
end

QBCore.Commands.Add("leaveradio", "Leave the current radio", {}, false, function(source, args)
	TriggerClientEvent("qb-radio:client:leaveradio", source)
end)

QBCore.Commands.Add("cv", "radio volume", {{name = "number", help = "vol no"}}, false, function(source, args)
    local src = source
    local RadioVolume = tonumber(args[1])
    TriggerClientEvent("qb-radio:client:volupradio", src, RadioVolume)
end)

RegisterNetEvent('qb-radio:server:addradiolist', function(rchannel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        if playerlist[src] then playerlist[src] = nil end
        Wait(100)
        playerlist[src] = {
            pid = tonumber(src),
            channel = rchannel,
            name = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname,
        }
    end
end)

RegisterNetEvent('qb-radio:remove:removeradiolist', function()
    local src = source
    if playerlist[src] then
        playerlist[src] = nil
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if playerlist[src] then
        playerlist[src] = nil
    end
end)

QBCore.Functions.CreateCallback('qb-radio:remove:getlist', function(source, cb, channel)
    local list = {}
    if playerlist then
        for k, v in pairs(playerlist) do
            if playerlist[k].channel == channel then
                list[#list+1] = {
                    pid = playerlist[k].pid,
                    channel = playerlist[k].channel,
                    name = playerlist[k].name
                }
            end
        end
        Wait(10)
        cb(list)
    else
        cb(nil)
    end
end)