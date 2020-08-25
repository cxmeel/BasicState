--[[
	Import the BasicState module from ReplicatedStorage.
--]]
local Replicated = game:GetService("ReplicatedStorage")
local BasicState = require(Replicated.Modules.BasicState)

--[[
	Create a new BasicState store with an inital Count value
	of 0 and ShowApp as true.
--]]
local Store = BasicState.new({
	Count = 0,
	ShowApp = true
})

--[[
	When the value of Count changes, print the change to the
	output.
--]]
Store:GetChangedSignal("Count"):Connect(function(NewValue, OldValue)
	print("Count was updated from", OldValue, "to", NewValue)
end)

--[[
	Export our new BasicState store.
--]]
return Store
