local Replicated = game:GetService("ReplicatedStorage")
local Roact = require(Replicated.Modules.Roact)

local CounterSubtractButton = Roact.Component:extend("CounterSubtractButton")
local Store = require(script.Parent.Parent.State.Store)

function CounterSubtractButton:render()
	return Roact.createElement("TextButton", {
		TextScaled = true,
		Size = UDim2.fromScale(.25, 1),
		Text = "-",
		LayoutOrder = 0,

		[Roact.Event.MouseButton1Click] = function()
			Store:Decrement("Count", 1, 0)
		end
	})
end

return CounterSubtractButton
