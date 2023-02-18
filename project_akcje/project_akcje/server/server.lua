ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('project_akcje:getActions', function(source, cb)
    local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM akcje_graczy WHERE identifier=@id', {['@id'] = xPlayer.identifier}, function(result)
        cb(result)
	end)
end)

ESX.RegisterServerCallback('project_akcje:getGielda', function(source, cb)
	MySQL.Async.fetchAll('SELECT * FROM gielda', {}, function(result)
        cb(result)
	end)
end)

RegisterServerEvent('project_akcje:buy', function(name, short, count)
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)
	local nick = GetPlayerName(source)

	MySQL.Async.fetchAll('SELECT price FROM gielda WHERE company_name=@name', {['@name'] = name}, function(result)
		price = math.floor(tonumber(result[1].price)) * count

		if xPlayer.getAccount('bank').money >= price then
			xPlayer.removeAccountMoney('bank', price)
			TriggerClientEvent('pNotify:SendNotification', _source, {text = 'Kupiłeś akcje firmy '..name..' za '..price, 50})
			TriggerEvent('logi:logiS', '16711680', 'Giełda - Kupywanie', '**' .. nick .. ' [' .. _source .. '] ('..xPlayer.getName()..')** kupił akcje firmy **' .. short .. '** za **$' .. price .. '** w ilości **' .. count .. '**', 'https://discord.com/api/webhooks/819575734921986089/uv4ymXnRU5UdLNWxtb9snJ6q9LqH0vl-7acYLOe5nDGN-8rbHoWWSUDkuolRvuWEFB_8')
			
			MySQL.Async.fetchAll('SELECT * FROM akcje_graczy WHERE identifier = @id AND company_name=@name AND company_short=@short', {
				['@id']   = xPlayer.identifier,
				['@name']  = name,
				['@short'] = short
			}, function(result)
				if result[1] then
					local newCount = result[1].count + count
		
					MySQL.Async.execute('UPDATE akcje_graczy SET `count`=@count WHERE identifier = @id AND company_name=@name AND company_short=@short', {
						['@id']   = xPlayer.identifier,
						['@name']  = name,
						['@short'] = short,
						['@count']  = newCount
					}, function(rowsChanged)
					end)
				else
					MySQL.Async.execute('INSERT INTO akcje_graczy (identifier, company_name, company_short, count) VALUES (@id, @name, @short, @count)', {
						['@id']   = xPlayer.identifier,
						['@name']  = name,
						['@short'] = short,
						['@count']  = count
					}, function(rowsChanged)
					end)
				end
			end)
		else
			TriggerClientEvent('pNotify:SendNotification', _source, {text = 'Nie stać cię na zakup akcji', 50})
		end
	end)
end)

RegisterServerEvent('project_akcje:sell', function(name, short, count, owned)
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)
	local result = owned - count
	local nick = GetPlayerName(source)

	MySQL.Async.fetchAll('SELECT price FROM gielda WHERE company_name=@name', {['@name'] = name}, function(result)
		price = math.floor(tonumber(result[1].price)) * count

		xPlayer.addAccountMoney('bank', price)
		TriggerClientEvent('pNotify:SendNotification', _source, {text = 'Sprzedałeś akcje firmy '..name..' za '..price, 50})
		TriggerEvent('logi:logiS', '16711680', 'Giełda - Sprzedawanie', '**' .. nick .. ' [' .. _source .. '] ('..xPlayer.getName()..')** sprzedał akcje firmy **' .. short .. '** za **$' .. price .. '** w ilości **' .. count .. '**', 'https://discord.com/api/webhooks/819575734921986089/uv4ymXnRU5UdLNWxtb9snJ6q9LqH0vl-7acYLOe5nDGN-8rbHoWWSUDkuolRvuWEFB_8')
	end)

	if tonumber(owned) > tonumber(count) then
		MySQL.Async.execute('UPDATE akcje_graczy SET `count`=@count WHERE identifier = @id AND company_name=@name AND company_short=@short AND count=@actual', {
			['@id']   = xPlayer.identifier,
			['@name']  = name,
			['@short'] = short,
			['@actual'] = owned,
			['@count']  = result
		}, function(rowsChanged)
		end)
	elseif owned == count then	
		MySQL.Async.execute('DELETE FROM akcje_graczy WHERE identifier = @id AND company_name=@name AND company_short=@short AND count=@count', {
			['@id']   = xPlayer.identifier,
			['@name']  = name,
			['@short'] = short,
			['@count']  = count
		}, function(rowsChanged)
		end)
	end
end)