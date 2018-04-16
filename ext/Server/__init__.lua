class 'NetEventsParamsTestServer'

local stringExtensions = require "__shared/StringExtensions"
local variablesTable = require "__shared/Variables"
local variables = nil

local serverMultiInstanceClass = require "ServerMultiInstanceClass"

function NetEventsParamsTestServer:__init()
	print("Initializing NetEventsParamsTestServer")
	variables = variablesTable:GetVariables()
	
	self:RegisterEvents()
end

function NetEventsParamsTestServer:RegisterEvents()
	Events:Subscribe('Player:Chat', self, self.OnChat)
	
	NetEvents:Subscribe('clientTestMixed', self, self.OnClientTestMixed)
	NetEvents:Subscribe('clientTestValue', self, self.OnClientTestValue)
	NetEvents:Subscribe('clientTestLinearTransform', self, self.OnClientTestLinearTransform)
	NetEvents:Subscribe('clientTestValueTable', self, self.OnClientTestValueTable)
	NetEvents:Subscribe('clientTestLinearTransformTable', self, self.OnClientTestLinearTransformTable)

	NetEvents:Subscribe('ClientMultiInstanceTest', self, self.OnClientMultiInstanceTest)
end

function NetEventsParamsTestServer:OnChat(player, recipientMask, message)
	if message == '' then
		return
	end

	print(message)
	
	local parts = message:split(' ')
	
	if parts[1] == 'serverclient' then
		print(variables["guids"])
		print(variables["vecTwos"])
		print(variables["vecThrees"])
		print(variables["vecFours"])
		print(variables["linearTransforms"])
		
		NetEvents:SendTo('serverTestMixed',
						 player,
						 variables["guids"][1], 
						 variables["vecTwos"][1], 
						 variables["vecThrees"][1], 
						 variables["vecFours"][1], 
						 variables["linearTransforms"][1])

		NetEventsParamsTestServer:SendServerToClientNetEventTestValue('guids', 'Guid', 'serverTestValue', player)
		NetEventsParamsTestServer:SendServerToClientNetEventTestValue('vecTwos', 'Vec2', 'serverTestValue', player)
		NetEventsParamsTestServer:SendServerToClientNetEventTestValue('vecThrees', 'Vec3', 'serverTestValue', player)
		NetEventsParamsTestServer:SendServerToClientNetEventTestValue('vecFours', 'Vec4', 'serverTestValue', player)
		NetEventsParamsTestServer:SendServerToClientNetEventTestValue('linearTransforms', 'LinearTransform', 'serverTestLinearTransform', player)
		
		-- NetEventsParamsTestServer:SendServerToClientNetEventTestTable('guids', 'Guid', 'serverTestValueTable', player)
		-- NetEventsParamsTestServer:SendServerToClientNetEventTestTable('vecTwos', 'Vec2', 'serverTestValueTable', player)
		-- NetEventsParamsTestServer:SendServerToClientNetEventTestTable('vecThrees', 'Vec3', 'serverTestValueTable', player)
		-- NetEventsParamsTestServer:SendServerToClientNetEventTestTable('vecFours', 'Vec4', 'serverTestValueTable', player)
		-- NetEventsParamsTestServer:SendServerToClientNetEventTestTable('linearTransforms', 'LinearTransform', 'serverTestLinearTransformTable', player)
	end
	
	if parts [1] == 'clientserver' then
		NetEvents:SendTo('startClientServerTest', player)
	end

	if parts[1] == 'servermulti' then
		NetEventsParamsTestServer:CheckServerMultiInstance(5, player)
	end

	if parts[1] == 'clientmulti' then
		NetEvents:SendTo('StartClientMultiInstanceTest', player, 5)
	end		
end

function NetEventsParamsTestServer:CheckServerMultiInstance(count, player)
	local instances = { }

	for i = 1, count do 
		local instanceName = 'ServerInstance:' .. i
		table.insert(instances, serverMultiInstanceClass(instanceName))
	end

	-- print(instances)

	for _, instance in ipairs(instances) do
		print('Testing instance: ' .. instance.name)
		instance:Test(player)
	end
end

function NetEventsParamsTestServer:OnClientMultiInstanceTest(player, name)
	print('NetEventsParamsTestServer:OnClientMultiInstanceTest() Client -> Server. Success for instance ' .. name)
end

function NetEventsParamsTestServer:CheckSameValue(valueOne, valueTwo)
	if valueOne == nil then
		error('NetEventsParamsTestServer: variables table value was nil. <<<<<<<<<<<<<<<<<<<<<<')
		return false
	end
	
	if valueTwo == nil then
		error('NetEventsParamsTestServer: value sent through NetEvents was nil. <<<<<<<<<<<<<<<<<<<<<<')
		return false
	end
		
	if valueOne ~= valueTwo then
		error('NetEventsParamsTestServer: values were not the same - value one: ' .. tostring(valueOne) .. ' - value two: ' .. tostring(valueTwo) .. ' <<<<<<<<<<<<<<<<<<<<<<')
		return false
	end
	
	return true
end

function NetEventsParamsTestServer:CheckSameLinearTransform(linearTransformOne, linearTransformTwo)
	if linearTransformOne == nil then
		error('NetEventsParamsTestServer: variables table value was nil. <<<<<<<<<<<<<<<<<<<<<<')
		return false
	end
	
	if linearTransformTwo == nil then
		error('NetEventsParamsTestServer: value sent through NetEvents was nil. <<<<<<<<<<<<<<<<<<<<<<')
		return false
	end
		
	if linearTransformOne.left ~= linearTransformTwo.left or
		linearTransformOne.up ~= linearTransformTwo.up or
		linearTransformOne.forward ~= linearTransformTwo.forward or
		linearTransformOne.trans ~= linearTransformTwo.trans then
		error('NetEventsParamsTestServer: two linearTransforms were not the same - linearTransform one: ' .. tostring(linearTransformOne) .. ' - linearTransform two: ' .. tostring(linearTransformTwo) .. ' <<<<<<<<<<<<<<<<<<<<<<')
		return false
	end
	
	return true
end

function NetEventsParamsTestServer:OnClientTestMixed(player,
													 guid, 
													 vecTwo, 
													 vecThree, 
													 vecFour, 
													 linearTransform)
													 
	if NetEventsParamsTestServer:CheckSameValue(variables["guids"][1], guid) and
	   NetEventsParamsTestServer:CheckSameValue(variables["vecTwos"][1], vecTwo) and
	   NetEventsParamsTestServer:CheckSameValue(variables["vecThrees"][1], vecThree) and	
	   NetEventsParamsTestServer:CheckSameValue(variables["vecFours"][1], vecFour) and
	   NetEventsParamsTestServer:CheckSameLinearTransform(variables["linearTransforms"][1], linearTransform) then
		print('NetEventsParamsTestServer:OnClientTestMixed() Client -> Server success for mixed test')
	else
		error('NetEventsParamsTestServer:OnClientTestMixed() Client -> Server failed for mixed test. <<<<<<<<<<<<<<<<<<<<<<')
	end
end

function NetEventsParamsTestServer:OnClientTestValue(player, value, index, tableName)
	local shouldBeValue = variables[tableName][index]
	
	if shouldBeValue == nil then
		error('Tried to access the value at index ' .. index .. ' from table ' .. tableName .. ', but it was nil. <<<<<<<<<<<<<<<<<<<<<<')
	end
	
	if NetEventsParamsTestServer:CheckSameValue(shouldBeValue, value) then
		print('NetEventsParamsTestServer:OnClientTestValue() Client -> Server success for ' .. tableName)
	else
		error('NetEventsParamsTestServer:OnClientTestValue() Client -> Server failed for ' .. tableName .. '. Values that were tested: Value 1: ' .. tostring(shouldBeValue) .. ', Value 2: ' .. tostring(value))
	end
end

function NetEventsParamsTestServer:OnClientTestValueTable(player, tbl, tableName) -- probably doesnt work either
	print('NetEventsParamsTestServer:OnClientTestValueTable() received table ' .. tableName)

	for i,v in ipairs(tbl) do
		NetEventsParamsTestServer:OnClientTestValue(player, v, i, tableName)
	end
end

function NetEventsParamsTestServer:OnClientTestLinearTransform(player, value, index, tableName) -- special treatment because no '==' operator available yet for LinearTranforms
	local shouldBeValue = variables[tableName][index]
	
	if shouldBeValue == nil then
		error('Tried to access the value at index ' .. index .. ' from table ' .. tableName .. ', but it was nil. <<<<<<<<<<<<<<<<<<<<<<')
	end
	
	if NetEventsParamsTestServer:CheckSameLinearTransform(shouldBeValue, value) then
		print('NetEventsParamsTestServer:OnClientTestLinearTransform() Server -> Client success for ' .. tableName)
	else
		error('NetEventsParamsTestServer:OnClientTestLinearTransform() Server -> Client failed for ' .. tableName .. '. Values that were tested: Value 1: ' .. tostring(shouldBeValue) .. ', Value 2: ' .. tostring(value) .. ' <<<<<<<<<<<<<<<<<<<<<<')
	end
end

function NetEventsParamsTestServer:OnClientTestLinearTransformTable(player, tbl, tableName) -- probably doesnt work either
	print('NetEventsParamsTestServer:OnClientTestLinearTransformTable() received table ' .. tableName)

	for i,v in ipairs(tbl) do
		NetEventsParamsTestServer:OnClientTestLinearTransform(player, v, i, tableName)
	end
end

function NetEventsParamsTestServer:SendServerToClientNetEventTestValue(tableName, valueName, netEventName, player)
	print('NetEventsParamsTestServer: Sending values of type ' .. valueName .. ' of table ' .. tableName .. ' one by one.')
	for i,v in ipairs(variables[tableName]) do
		print('NetEventsParamsTestServer: Sending ' .. valueName .. ': ' .. tostring(v))
		NetEvents:SendTo(netEventName, player, v, i, tableName)
	end
end

function NetEventsParamsTestServer:SendServerToClientNetEventTestTable(tableName, valueName, netEventName, player)
	print('NetEventsParamsTestServer: Sending all values of type ' .. valueName .. ' of table ' .. tableName .. ' at the same time')
	NetEvents:SendTo(netEventName, player, variables[tableName], tableName)
end

g_NetEventsParamsTestServer = NetEventsParamsTestServer()

