--[[
	Import the Roact module from ReplicatedStorage
--]]
local Replicated = game:GetService("ReplicatedStorage")
local Roact = require(Replicated.Modules.Roact)

--[[
	Import the main App component, which will be rendered into
	the ScreenGui
--]]
local AppComponent = require(script.Parent.Components.App)

--[[
	Mount the component to the ScreenGui this script is parented
	to.
--]]
Roact.mount(
	Roact.createElement(AppComponent),
	script.Parent,
	"basicstate.example.counter"
)
