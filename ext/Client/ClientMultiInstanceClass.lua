class 'ClientMultiInstanceClass'

function ClientMultiInstanceClass:__init(name)
	self.name = name
end

function ClientMultiInstanceClass:Test(player)
	print('sending netevent for instance - ' .. self.name)
	NetEvents:SendLocal('ClientMultiInstanceTest', self.name)
end

return ClientMultiInstanceClass
