QBCore.Functions.CreateUseableItem("radio", function(source, item)
    TriggerClientEvent('qb-radio:use', source)
end)

QBCore.Functions.CreateCallback('qb-radio:server:GetItem', function(source, cb, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player ~= nil then
        local RadioItem = Player.Functions.GetItemByName(item)
        if RadioItem ~= nil and not Player.PlayerData.metadata["isdead"] and
            not Player.PlayerData.metadata["inlaststand"] then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

for i = 1, Config.RestrictedChannels do 
    exports['pma-voice']:addChannelCheck(i, function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        if Config.AllowedJobs[Player.PlayerData.job.name] and Player.PlayerData.job.onduty then
            return true
        end
        return false
    end)
end