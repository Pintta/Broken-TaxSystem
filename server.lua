local QBCore = exports['qb-core']:GetCoreObject()
local TaxRate = 15
local MaxPayback = 0.20 -- 20%
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
-- The system calculates the tax amount and automatically adds it to the database.  --
-- TriggerServerEvent('Broken-TaxSystem:addTax', Player.PlayerData.citizenid, PayTotal) --
--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

RegisterNetEvent('Broken-TaxSystem:addTax', function(citizenId, amount)
    local taxAmount = (TaxRate / 100) * amount
    MySQL.Async.execute('INSERT INTO verotilit (citizenid, total_tax_paid) VALUES (?, ?) ON DUPLICATE KEY UPDATE total_tax_paid = total_tax_paid + ?', {
        citizenId,
        taxAmount,
        taxAmount
    })
end)

QBCore.Functions.CreateCallback('Broken-TaxSystem:getTaxAccount', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        MySQL.Async.fetchScalar('SELECT total_tax_paid FROM verotilit WHERE citizenid = ?', {
            Player.PlayerData.citizenid
        }, function(result)
            cb(result or 0)
        end)
    end
end)

QBCore.Functions.CreateCallback('Broken-TaxSystem:getRefundableAmount', function(source, cb, citizenId)
    MySQL.Async.fetchScalar('SELECT total_tax_paid FROM verotilit WHERE citizenid = ?', {
        citizenId
    }, function(totalTaxPaid)
        if totalTaxPaid then
            local refundableAmount = math.floor(totalTaxPaid * MaxPayback)
            cb(refundableAmount)
        else
            cb(0)
        end
    end)
end)

RegisterNetEvent('Broken-TaxSystem:payRefund', function(targetCitizenId, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        MySQL.Async.fetchScalar('SELECT total_tax_paid FROM verotilit WHERE citizenid = ?', {
            targetCitizenId
        }, function(totalTaxPaid)
            if totalTaxPaid then
                local maxRefundable = math.floor(totalTaxPaid * MaxPayback)
                if amount <= maxRefundable then
                    local Target = QBCore.Functions.GetPlayerByCitizenId(targetCitizenId)
                    if Target then
                        Target.Functions.AddMoney('bank', amount, 'tax-refund')
                        TriggerClientEvent('QBCore:Notify', src, 'Suoritit veronpalautuksen '..amount..'€', 'success')
                        TriggerClientEvent('QBCore:Notify', Target.PlayerData.source, 'Sinulle maksettiin '..amount..'€ veronpalautusta.', 'success')
                    else
                        TriggerClientEvent('QBCore:Notify', src, 'Pelaajaa ei löytynyt!', 'error')
                    end
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Et voi maksaa tälläistä veronpalautus summaa henkilölle ' ..maxRefundable..'€', 'error')
                end
            else
                TriggerClientEvent('QBCore:Notify', src, 'Kyseinen henkilö ei ole maksanut veroja..', 'error')
            end
        end)
    end
end)