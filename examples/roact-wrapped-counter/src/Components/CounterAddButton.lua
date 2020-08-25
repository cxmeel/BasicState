local Replicated = game:GetService("ReplicatedStorage")
local Roact = require(Replicated.Modules.Roact)

local CounterAddButton = Roact.Component:extend("CounterAddButton")

--[[
	Import the BasicState store.
--]]
local Store = require(script.Parent.Parent.State.Store)

function CounterAddButton:render()
	return Roact.createElement("TextButton", {
		TextScaled = true,
		Size = UDim2.fromScale(.25, 1),
		Text = "+",
		LayoutOrder = 2,

		--[[
			When this button is clicked, increment the value of Count
			in the BasicState store by 1, up to the value of 12.
		--]]
		[Roact.Event.MouseButton1Click] = function()
			Store:Increment("Count", 1, 12)
		end
	})
end

--[[
	We don't need to wrap this component, as it doesn't need to
	re-render when BasicState changes.
--]]
return CounterAddButton
