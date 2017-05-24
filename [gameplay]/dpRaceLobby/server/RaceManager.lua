RaceManager = {}

local pendingRaces = {}
local racesCounter = 1
local lastMapId = 1

local function removePendingRace(id)
	if type(id) ~= "number" then
		return false
	end
	for i = 1, #pendingRaces do
		if pendingRaces[i].id == id then
			table.remove(pendingRaces, i)
			return true
		end
	end
	return false
end

local function getPendingRace(id)
	if type(id) ~= "number" then
		return false
	end
	for i = 1, #pendingRaces do
		if pendingRaces[i].id == id then
			return pendingRaces[i]
		end
	end
	return false
end

local function cancelPendingRace(id, cancelPlayer)
	if type(id) ~= "number" then
		return false
	end
	local race = getPendingRace(id)
	if not race then
		return false
	end
	for i, player in ipairs(race.players) do
		if isElement(player) then
			player:setData("MatchmakingRaceId", false)
			triggerClientEvent(player, "dpRaceLobby.raceCancelled", resourceRoot, cancelPlayer)
		end
	end
	removePendingRace(id)
	return true
end

local function selectRandomMap(gamemode)
	if gamemode == "drift" then
		return "drift-" .. tostring(math.random(1, 3))
	else
		return "sprint-1"
	end
end

function RaceManager.raceReady(playersList, mapName, rank)
	local raceId = racesCounter
	table.insert(pendingRaces, {
		id = raceId, 
		map = mapName,
		players = playersList,
		rank = rank,
		readyCount = 0
	})
	racesCounter = racesCounter + 1
	setTimer(cancelPendingRace, GlobalConfig.PENDING_RACE_TIMEOUT, 1, raceId)

	for i, player in ipairs(playersList) do
		player:setData("MatchmakingRaceId", raceId)
		triggerClientEvent(player, "dpRaceLobby.raceFound", resourceRoot)
	end	
end

function RaceManager.startRace(raceInfo)
	for i, player in ipairs(raceInfo.players) do
		player:setData("MatchmakingRaceId", false)
		triggerClientEvent(player, "dpRaceLobby.raceStart", resourceRoot)

		-- Выкинуть пассажиров
		if player.vehicle then
			for _, p in pairs(player.vehicle.occupants) do
				if p ~= player then
					p.vehicle = nil
				end
			end
		end
	end

	-- Создание карты и настройки
	local raceMap = exports.dpRaceManager:loadRaceMap(raceInfo.map)
	local raceSettings = {
		separateDimension = true,
		gamemode = raceMap.gamemode,
		duration = raceMap.duration
	}
	local race = exports.dpRaceManager:createRace(raceSettings, raceMap)
	race:setData("dpRaceLobby.raceInfo", raceInfo)
	if not race then
		return false
	end
	
	for i, player in ipairs(raceInfo.players) do
		fadeCamera(player, false, 0.5)
	end
	-- Добавить игроков в гонку
	setTimer(function ()
		for i, player in ipairs(raceInfo.players) do
			if isElement(player) then
				exports.dpRaceManager:raceAddPlayer(race, player)
			end
		end
	end, 1000, 1)
	-- Камера
	setTimer(function ()
		for i, player in ipairs(raceInfo.players) do
			if isElement(player) then
				fadeCamera(player, true)
			end
		end
	end, 2000, 1)
	-- Запуск гонки
	setTimer(function ()
		if isElement(race) then
			exports.dpRaceManager:startRace(race)
		end
	end, 6000, 1)
end

addEvent("dpRaceLobby.cancelSearch", true)
addEventHandler("dpRaceLobby.cancelSearch", resourceRoot, function ()
	cancelPendingRace(client:getData("MatchmakingRaceId"), client)
end)

addEvent("dpRaceLobby.acceptRace", true)
addEventHandler("dpRaceLobby.acceptRace", resourceRoot, function ()
	local race = getPendingRace(client:getData("MatchmakingRaceId"))
	if not race then
		return 
	end
	race.readyCount = race.readyCount + 1
	if race.readyCount >= #race.players then
		RaceManager.startRace(race)
	else
		for i, player in ipairs(race.players) do 
			if isElement(player) then
				triggerClientEvent(player, "dpRaceLobby.updateReadyCount", resourceRoot, race.readyCount, #race.players)
			end
		end		
	end
end)