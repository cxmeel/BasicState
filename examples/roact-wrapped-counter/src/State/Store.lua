local Replicated = game:GetService("ReplicatedStorage")
local BasicState = require(Replicated.Modules.BasicState)

local Store = BasicState.new({
	Count = 0,
	ShowApp = true
})

Store:GetChangedSignal("Count"):Connect(function(NewValue, OldValue)
	print("Count was updated from", OldValue, "to", NewValue)
end)

return Store
