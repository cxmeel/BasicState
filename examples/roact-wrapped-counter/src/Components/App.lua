--[[
	This is the main App component, which all other components
	are displayed by.
--]]
local Replicated = game:GetService("ReplicatedStorage")
local Roact = require(Replicated.Modules.Roact)

--[[
	Create our new App component by extending a default Roact
	component and import our BasicState store.
--]]
local App = Roact.Component:extend("App")
local Store = require(script.Parent.Parent.State.Store)

--[[
	Import the App's child components.
--]]
local CounterTextLabel = require(script.Parent.CounterTextLabel)
local CounterAddButton = require(script.Parent.CounterAddButton)
local CounterSubtractButton = require(script.Parent.CounterSubtractButton)

--[[
	Define the render method, which physically renders the
	components of our UI.
--]]
function App:render()
	--[[
		Create a new variable holding the value of ShowApp, which is
		injected into our component's state by BasicState.
	--]]
	local ShowApp = self.state.ShowApp

	--[[
		Scaffold our app's UI.
	--]]
	return Roact.createElement("Frame", {
		--[[
			If ShowApp is true, the main Frame will be 400x400px.
			If ShowApp is false, the main Frame will be 400x80px.
		--]]
		Size = UDim2.fromOffset(400, ShowApp and 400 or 400 * .2),
		AnchorPoint = Vector2.new(.5, .5),
		Position = UDim2.fromScale(.5, .5),
		ClipsDescendants = true
	}, {
		ToggleButton = Roact.createElement("TextButton", {
			--[[
				If ShowApp is true, resize the button to take 100% of the
				Frame's width and 20% of the Frame's height. The button will
				also display the text "Hide App".

				If ShowApp is false, resize the button to take 100% of the
				Frame's width and 100% of the Frame's height. The button will
				also display the text "Show App".
			]]
			Size = UDim2.fromScale(1, ShowApp and .2 or 1),
			Text = string.format("%s App", ShowApp and "Hide" or "Show"),
			TextScaled = true,

			--[[
				Upon clicking the button, toggle the value of "ShowApp" as
				stored in the BasicState store.
			--]]
			[Roact.Event.MouseButton1Click] = function()
				Store:Toggle("ShowApp")
			end,

			--[[
				Right click to delete the "Count" key from the store, and
				replace it 2s later.
			]]
			[Roact.Event.MouseButton2Click] = function()
				Store:Delete("Count")

				wait(2)
				Store:Set("Count", 0)
			end,
		}),

		--[[
			If ShowApp is false, this component will be unmounted.
		--]]
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
				--[[
					Decorator will be displayed before the counter value.
					This is to show how props are still passed as expected
					to a wrapped component.
				--]]
				Decorator = "#"
			}),
			CounterIncrement = Roact.createElement(CounterAddButton)
		})
	})
end

--[[
	Wrap the App component in the BasicState store, listening only to changes
	to the ShowApp value, and ignoring any other changes.
--]]
return Store:Roact(App, { "ShowApp" })
