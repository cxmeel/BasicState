local Replicated = game:GetService("ReplicatedStorage")
local Roact = require(Replicated.Modules.Roact)

local CounterSubtractButton = Roact.Component:extend("CounterSubtractButton")

--[[
	Import the BasicState store.
--]]
local Store = require(script.Parent.Parent.State.Store)

function CounterSubtractButton:render()
	return Roact.createElement("TextButton", {
		TextScaled = true,
		Size = UDim2.fromScale(.25, 1),
		Text = "-",
		LayoutOrder = 0,

		--[[
			When this button is clicked, decrement the value of Count
			in the BasicState store by 1, keeping the value greater
			than or equal to 0.
		--]]
		[Roact.Event.MouseButton1Click] = function()
			Store:Decrement("Count", 1, 0)
		end
	})
end

--[[
	We don't need to wrap this component, as it doesn't need to
	re-render when BasicState changes.
--]]
return CounterSubtractButton
