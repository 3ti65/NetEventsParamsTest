class 'NetEventsParamsTestClient'

local variablesTable = require "__shared/Variables"
local variables = nil

local clientMultiInstanceClass = require "ClientMultiInstanceClass"

function NetEventsParamsTestClient:__init()
	print("Initializing NetEventsParamsTestClient")
	variables = variablesTable:GetVariables()
	
	self:RegisterEvents()
end

function NetEventsParamsTestClient:RegisterEvents()
	NetEvents:Subscribe('startClientServerTest', self, self.OnStartClientServerTest)
	NetEvents:Subscribe('serverTestMixed', self, self.OnServerTestMixed)
	NetEvents:Subscribe('serverTestValue', self, self.OnServerTestValue)
	NetEvents:Subscribe('serverTestLinearTransform', self, self.OnServerTestLinearTransform)
	NetEvents:Subscribe('serverTestValueTable', self, self.OnServerTestValueTable)
	NetEvents:Subscribe('serverTestLinearTransformTable', self, self.OnServerTestLinearTransformTable)

	NetEvents:Subscribe('ServerMultiInstanceTest', self, self.OnServerMultiInstanceTest)
	NetEvents:Subscribe('StartClientMultiInstanceTest', self, self.OnStartClientMultiInstanceTest)
end

function NetEventsParamsTestClient:OnServerMultiInstanceTest(name)
	print('NetEventsParamsTestClient:OnServerMultiInstanceTest() Server -> Client. Success for instance ' .. name)
end

function NetEventsParamsTestClient:OnStartClientMultiInstanceTest(count, player)
	local instances = { }

	for i = 1, count do 
		local instanceName = 'ClientInstance:' .. i
		table.insert(instances, clientMultiInstanceClass(instanceName))
	end

	-- print(instances)

	for _, instance in ipairs(instances) do
		print('Testing instance: ' .. instance.name)
		instance:Test(player)
	end
end

function NetEventsParamsTestClient:OnStartClientServerTest()
	NetEvents:SendLocal('clientTestMixed',
						variables["guids"][1], 
						variables["vecTwos"][1], 
						variables["vecThrees"][1], 
						variables["vecFours"][1], 
						variables["linearTransforms"][1])

	NetEventsParamsTestClient:SendClientToServerNetEventTestValue('guids', 'Guid', 'clientTestValue')
	NetEventsParamsTestClient:SendClientToServerNetEventTestValue('vecTwos', 'Vec2', 'clientTestValue')
	NetEventsParamsTestClient:SendClientToServerNetEventTestValue('vecThrees', 'Vec3', 'clientTestValue')
	NetEventsParamsTestClient:SendClientToServerNetEventTestValue('vecFours', 'Vec4', 'clientTestValue')
	NetEventsParamsTestClient:SendClientToServerNetEventTestValue('linearTransforms', 'LinearTransform', 'clientTestLinearTransform')
	
	-- NetEventsParamsTestClient:SendClientToServerNetEventTestTable('guids', 'Guid', 'clientTestValueTable')
	-- NetEventsParamsTestClient:SendClientToServerNetEventTestTable('vecTwos', 'Vec2', 'clientTestValueTable')
	-- NetEventsParamsTestClient:SendClientToServerNetEventTestTable('vecThrees', 'Vec3', 'clientTestValueTable')
	-- NetEventsParamsTestClient:SendClientToServerNetEventTestTable('vecFours', 'Vec4', 'clientTestValueTable')
	-- NetEventsParamsTestClient:SendClientToServerNetEventTestTable('linearTransforms', 'LinearTransform', 'clientTestLinearTransformTable')
end

function NetEventsParamsTestClient:CheckSameValue(valueOne, valueTwo)
	if valueOne == nil then
		error('NetEventsParamsTestClient: variables table value was nil. <<<<<<<<<<<<<<<<<<<<<<')
		return false
	end
	
	if valueTwo == nil then
		error('NetEventsParamsTestClient: value sent through NetEvents was nil. <<<<<<<<<<<<<<<<<<<<<<')
		return false
	end
		
	if valueOne ~= valueTwo then
		error('NetEventsParamsTestClient: values were not the same - value one: ' .. tostring(valueOne) .. ' - value two: ' .. tostring(valueTwo))
		return false
	end
	
	return true
end

function NetEventsParamsTestClient:CheckSameLinearTransform(linearTransformOne, linearTransformTwo)
	if linearTransformOne == nil then
		error('NetEventsParamsTestClient: variables table value was nil. <<<<<<<<<<<<<<<<<<<<<<')
		return false
	end
	
	if linearTransformTwo == nil then
		error('NetEventsParamsTestClient: value sent through NetEvents was nil. <<<<<<<<<<<<<<<<<<<<<<')
		return false
	end
		
	if linearTransformOne.left ~= linearTransformTwo.left or
		linearTransformOne.up ~= linearTransformTwo.up or
		linearTransformOne.forward ~= linearTransformTwo.forward or
		linearTransformOne.trans ~= linearTransformTwo.trans then
		error('NetEventsParamsTestClient: two linearTransforms were not the same - linearTransform one: ' .. tostring(linearTransformOne) .. ' - linearTransform two: ' .. tostring(linearTransformTwo) .. ' <<<<<<<<<<<<<<<<<<<<<<')
		return false
	end
	
	return true
end

function NetEventsParamsTestClient:OnServerTestMixed(guid, 
													 vecTwo, 
													 vecThree, 
													 vecFour, 
													 linearTransform)
													 
	if NetEventsParamsTestClient:CheckSameValue(variables["guids"][1], guid) and
	   NetEventsParamsTestClient:CheckSameValue(variables["vecTwos"][1], vecTwo) and
	   NetEventsParamsTestClient:CheckSameValue(variables["vecThrees"][1], vecThree) and	
	   NetEventsParamsTestClient:CheckSameValue(variables["vecFours"][1], vecFour) and
	   NetEventsParamsTestClient:CheckSameLinearTransform(variables["linearTransforms"][1], linearTransform) then
		print('NetEventsParamsTestClient:OnServerTestValue() Server -> Client success for mixed test')
	else
		error('NetEventsParamsTestClient:OnServerTestValue() Server -> Client failed for mixed test <<<<<<<<<<<<<<<<<<<<<<')
	end
end

function NetEventsParamsTestClient:OnServerTestValue(value, index, tableName)
	local shouldBeValue = variables[tableName][index]
	
	if shouldBeValue == nil then
		error('Tried to access the value at index ' .. index .. ' from table ' .. tableName .. ', but it was nil. <<<<<<<<<<<<<<<<<<<<<<')
	end
	
	if NetEventsParamsTestClient:CheckSameValue(shouldBeValue, value) then
		print('NetEventsParamsTestClient:OnServerTestValue() Server -> Client success for ' .. tableName)
	else
		error('NetEventsParamsTestClient:OnServerTestValue() Server -> Client failed for ' .. tableName .. '. Values that were tested: Value 1: ' .. tostring(shouldBeValue) .. ', Value 2: ' .. tostring(value) .. ' <<<<<<<<<<<<<<<<<<<<<<')
	end
end

function NetEventsParamsTestClient:OnServerTestValueTable(tbl, tableName) -- doesnt work, client crashes before getting here
	print('NetEventsParamsTestClient:OnServerTestValueTable() received table ' .. tableName)

	for i,v in ipairs(tbl) do
		NetEventsParamsTestClient:OnServerTestValue(v, i, tableName)
	end
end

function NetEventsParamsTestClient:OnServerTestLinearTransform(value, index, tableName) -- special treatment because no '==' operator available yet for LinearTranforms
	local shouldBeValue = variables[tableName][index]
	
	if shouldBeValue == nil then
		error('Tried to access the value at index ' .. index .. ' from table ' .. tableName .. ', but it was nil. <<<<<<<<<<<<<<<<<<<<<<')
	end
	
	if NetEventsParamsTestClient:CheckSameLinearTransform(shouldBeValue, value) then
		print('NetEventsParamsTestClient:OnServerTestLinearTransform() Server -> Client success for ' .. tableName)
	else
		error('NetEventsParamsTestClient:OnServerTestLinearTransform() Server -> Client failed for ' .. tableName .. '. Values that were tested: Value 1: ' .. tostring(shouldBeValue) .. ', Value 2: ' .. tostring(value) .. ' <<<<<<<<<<<<<<<<<<<<<<')
	end
end

function NetEventsParamsTestClient:OnServerTestLinearTransformTable(tbl, tableName) -- doesnt work, client crashes before getting here
	print('NetEventsParamsTestClient:OnServerTestLinearTransformTable() received table ' .. tableName)

	for i,v in ipairs(tbl) do
		NetEventsParamsTestClient:OnServerTestLinearTransform(v, i, tableName)
	end
end

function NetEventsParamsTestClient:SendClientToServerNetEventTestValue(tableName, valueName, netEventName)
	for i,v in ipairs(variables[tableName]) do
		print('NetEventsParamsTestClient: Sending ' .. valueName .. ': ' .. tostring(v))
		NetEvents:SendLocal(netEventName, v, i, tableName)
	end
end

function NetEventsParamsTestClient:SendClientToServerNetEventTestTable(tableName, valueName, netEventName)
	print('NetEventsParamsTestClient: Sending all values of type ' .. valueName .. ' of table ' .. tableName .. ' at the same time')
	NetEvents:SendLocal(netEventName, variables[tableName], tableName)
end

g_NetEventsParamsTestClient = NetEventsParamsTestClient()
