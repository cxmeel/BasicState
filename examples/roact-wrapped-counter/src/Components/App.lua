local Replicated = game:GetService("ReplicatedStorage")
local Roact = require(Replicated.Modules.Roact)

local App = Roact.Component:extend("App")
local Store = require(script.Parent.Parent.State.Store)

local CounterTextLabel = require(script.Parent.CounterTextLabel)
local CounterAddButton = require(script.Parent.CounterAddButton)
local CounterSubtractButton = require(script.Parent.CounterSubtractButton)

function App:render()
	local ShowApp = self.state.ShowApp

	return Roact.createElement("Frame", {
		Size = UDim2.fromOffset(400, ShowApp and 400 or 400 * .2),
		AnchorPoint = Vector2.new(.5, .5),
		Position = UDim2.fromScale(.5, .5),
		ClipsDescendants = true
	}, {
		ToggleButton = Roact.createElement("TextButton", {
			Size = UDim2.fromScale(1, ShowApp and .2 or 1),
			Text = string.format("%s App", ShowApp and "Hide" or "Show"),
			TextScaled = true,

			[Roact.Event.MouseButton1Click] = function()
				Store:Toggle("ShowApp")
			end
		}),

		MainContainer = ShowApp and Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, .8),
			Position = UDim2.fromScale(0, .2)
		}, {
			ListLayout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),

			CounterDecrement = Roact.createElement(CounterSubtractButton),
			CounterLabel = Roact.createElement(CounterTextLabel, {
				Decorator = "#"
			}),
			CounterIncrement = Roact.createElement(CounterAddButton)
		})
	})
end

return Store:Roact(App, { "ShowApp" })
