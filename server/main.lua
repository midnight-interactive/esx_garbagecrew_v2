ESX = nil


local currentjobs = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)



RegisterServerEvent('esx_garbagecrew:bagdumped')
AddEventHandler('esx_garbagecrew:bagdumped', function(location, truckplate)
    local collectionfinished = false
    local _source = source
    local updated = false
    for i,v in pairs(currentjobs) do
         if v.pos == location and v.trucknumber == truckplate  then
            for workers, ids in pairs(v.workers) do
                if ids.id == _source then
                    ids.bags = ids.bags + 1
                    if v.bagsremaining <= 0 then
                        TriggerEvent('esx_garbagecrew:paycrew', i)
                    end
                    updated = true
                    break
                end
            end

            if not updated then
                local buildlist = { id = _source, bags = 1,}
                table.insert(v.workers, buildlist)
                if v.bagsremaining <= 0 then
                  TriggerEvent('esx_garbagecrew:paycrew', i)
                end
            end
        end
    end
end)



RegisterServerEvent('esx_garbagecrew:bagremoval')
AddEventHandler('esx_garbagecrew:bagremoval', function(location, trucknumber)
    print('checking for bag removal in '.. tostring(#currentjobs) .. ' jobs!')
    for i,v in pairs(currentjobs) do
        if v.pos == location and v.trucknumber == trucknumber and v.bagsremaining > 0 then
            v.bagsremaining = v.bagsremaining - 1
            break
        end
    end
 
    TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs)
end)


RegisterServerEvent('esxgarbagejob:movetruckcount')
AddEventHandler('esxgarbagejob:movetruckcount', function()
    Config.TruckPlateNumb = Config.TruckPlateNumb + 1
    if Config.TruckPlateNumb == 1000 then
        Config.TruckPlateNumb = 1
    end
    TriggerClientEvent('esxgarbagejob:movetruckcount', -1, Config.TruckPlateNumb)
end)

RegisterServerEvent('esx_garbagejob:setconfig')
AddEventHandler('esx_garbagejob:setconfig', function()
    TriggerClientEvent('esxgarbagejob:movetruckcount', -1, Config.TruckPlateNumb)
    if #currentjobs >  0 then
        TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs)
    end
end)

RegisterServerEvent('esx_garbagecrew:setworkers')
AddEventHandler('esx_garbagecrew:setworkers', function(location, trucknumber)

end)


RegisterServerEvent('esx_garbagecrew:setworkers')
AddEventHandler('esx_garbagecrew:setworkers', function(location, trucknumber, truckid)
    _source = source
    local bagtotal = math.random(Config.MinBags, Config.MaxBags)
    if currentjobs[trucknumber] ~= nil then
        currentjobs[trucknumber] = nil
    end
    local buildlist = {type = 'bags', name = 'bagcollection', jobboss = _source, pos = location, totalbags = bagtotal, bagsremaining = bagtotal, trucknumber = trucknumber, truckid = truckid, workers = {}, }
    table.insert(currentjobs, buildlist)
    TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs)
end)


AddEventHandler('esx_garbagecrew:paycrew', function(number)
    currentcrew = currentjobs[number].workers
    payamount = (Config.StopPay / currentjobs[number].totalbags) + Config.BagPay
    for i, v in pairs(currentcrew) do
        local xPlayer = ESX.GetPlayerFromId(v.id)
        local amount = math.ceil(payamount * v.bags)
        xPlayer.addMoney(tonumber(amount))
        TriggerClientEvent('esx:showNotification', v.id, '~s~Received~g~ '..tostring(amount)..' ~s~from this stop~s~!')
    end
    TriggerClientEvent('esx_garbagecrew:selectnextjob', currentjobs[number].jobboss )
    table.remove(currentjobs, number)
    TriggerClientEvent('esx_garbagecrew:updatejobs', -1, currentjobs)
end)
