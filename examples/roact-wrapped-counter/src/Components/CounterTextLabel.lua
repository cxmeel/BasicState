local Replicated = game:GetService("ReplicatedStorage")
local Roact = require(Replicated.Modules.Roact)

local CounterTextLabel = Roact.Component:extend("CounterTextLabel")
local Store = require(script.Parent.Parent.State.Store)

function CounterTextLabel:init(props)
	self.decorator = props.Decorator or ""
end

function CounterTextLabel:render()
	return Roact.createElement("TextLabel", {
		TextScaled = true,
		Size = UDim2.fromScale(.5, 1),
		Text = string.format("%s%d", self.decorator, Store:Get("Count")),
		LayoutOrder = 1
	})
end

return Store:Roact(CounterTextLabel)
