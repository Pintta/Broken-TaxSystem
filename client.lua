local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('Broken-TaxSystem:openTaxAccount', function()
    QBCore.Functions.TriggerCallback('Broken-TaxSystem:getTaxAccount', function(totalTaxPaid)
        exports['qb-menu']:openMenu({
            {
                header = 'Verotili',
                isMenuHeader = true
            }, {
                header = 'Maksetut verot',
                txt = '💸'..totalTaxPaid.. '€',
                isMenuHeader = true
            }, {
                header = 'Sulje',
                params = {
                    event = 'qb-menu:client:closeMenu'
                }
            }
        })
    end)
end)

RegisterNetEvent('Broken-TaxSystem:refundMenu', function()
    local players = QBCore.Functions.GetPlayersFromCoords(GetEntityCoords(PlayerPedId()), 10.0)
    local menu = {}
    for _, playerId in pairs(players) do
        local Player = QBCore.Functions.GetPlayer(playerId)
        if Player then
            local citizenId = Player.PlayerData.citizenid
            QBCore.Functions.TriggerCallback('Broken-TaxSystem:getRefundableAmount', function(maxRefundable)
                table.insert(menu, {
                    header = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                    txt = 'Veronpalautuksen määrä: ' ..maxRefundable..'€',
                    params = {
                        event = 'Broken-TaxSystem:refundPlayer',
                        args = {
                            targetCitizenId = citizenId,
                            maxRefundable = maxRefundable
                        }
                    }
                })
            end, citizenId)
        end
    end
    if #menu == 0 then
        table.insert(menu, {
            header = 'Ei pelaajia lähellä',
            isMenuHeader = true
        })
    end
    table.insert(menu, {
        header = 'Sulje',
        params = {
            event = 'qb-menu:client:closeMenu'
        }
    })
    SetTimeout(500, function()
        exports['qb-menu']:openMenu(menu)
    end)
end)

RegisterNetEvent('Broken-TaxSystem:refundPlayer', function(data)
    local targetCitizenId = data.targetCitizenId
    local maxRefundable = data.maxRefundable
    local input = exports['qb-input']:ShowInput({
        header = 'Maksa veronpalautus',
        submitText = 'Maksa',
        inputs = {
            {
                text = 'Max '..maxRefundable..'€',
                name = 'amount',
                type = 'number',
                isRequired = true
            }
        }
    })
    if input then
        local amount = tonumber(input.amount)
        if amount and amount > 0 and amount <= maxRefundable then
            TriggerServerEvent('Broken-TaxSystem:payRefund', targetCitizenId, amount)
        else
            QBCore.Functions.Notify('Määrä ei ole mahdollista '..maxRefundable..'€', 'error')
        end
    end
end)