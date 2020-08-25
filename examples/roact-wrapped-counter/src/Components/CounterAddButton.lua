local Replicated = game:GetService("ReplicatedStorage")
local Roact = require(Replicated.Modules.Roact)

local CounterAddButton = Roact.Component:extend("CounterAddButton")
local Store = require(script.Parent.Parent.State.Store)

function CounterAddButton:render()
	return Roact.createElement("TextButton", {
		TextScaled = true,
		Size = UDim2.fromScale(.25, 1),
		Text = "+",
		LayoutOrder = 2,

		[Roact.Event.MouseButton1Click] = function()
			Store:Increment("Count", 1, 12)
		end
	})
end

return CounterAddButton
