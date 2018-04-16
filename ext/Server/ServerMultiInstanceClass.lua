class 'ServerMultiInstanceClass'

function ServerMultiInstanceClass:__init(name)
	self.name = name
end

function ServerMultiInstanceClass:Test(player)
	print('sending netevent for instance - ' .. self.name)
	NetEvents:BroadcastLocal('ServerMultiInstanceTest', self.name)
end

return ServerMultiInstanceClass
