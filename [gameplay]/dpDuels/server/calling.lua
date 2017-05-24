-- Вызов игроков на дуэль (сервер)
addEvent("dpDuels.callPlayer", true)
addEventHandler("dpDuels.callPlayer", resourceRoot, function (targetPlayer, bet)
	if not isElement(targetPlayer) then
		return false
	end
	if type(bet) ~= "number" then
		return false
	end
	-- TODO: Проверить наличие денег
	if client:getData("money") < bet then
		return
	end
	if targetPlayer:getData("money") < bet then
		return
	end
	if not client.vehicle or client.vehicle.controller ~= client then
		return false
	end
	if not targetPlayer.vehicle or targetPlayer.vehicle.controller ~= targetPlayer then
		return false
	end	

	local checkpoint = PathGenerator.getNearestCheckpoint(client)
	local distance = getDistanceBetweenPoints3D(checkpoint.x, checkpoint.y, checkpoint.z,client.position.x,client.position.y,client.position.z)
	if distance > 350 then
		triggerClientEvent(client, "dpDuels.answerCall", resourceRoot, targetPlayer, false, "distance")
		return false
	end
	triggerClientEvent(targetPlayer, "dpDuels.callPlayer", resourceRoot, client, bet)
end)

addEvent("dpDuels.answerCall", true)
addEventHandler("dpDuels.answerCall", resourceRoot, function (targetPlayer, status, bet)
	if not isElement(targetPlayer) then
		return false
	end
	if not status or not bet then
		triggerClientEvent(targetPlayer, "dpDuels.answerCall", resourceRoot, client, false)
		return
	end
	if not tonumber(bet) then
		return
	end
	bet = tonumber(bet)

	if not client.vehicle or client.vehicle.controller ~= client then
		return false
	end
	if not targetPlayer.vehicle or targetPlayer.vehicle.controller ~= targetPlayer then
		return false
	end	
	-- Забрать ставку
	if not exports.dpCore:givePlayerMoney(client, -bet) then
		return false
	end
	if not exports.dpCore:givePlayerMoney(targetPlayer, -bet) then
		return false
	end

	startDuel(targetPlayer, client, bet)
end)
