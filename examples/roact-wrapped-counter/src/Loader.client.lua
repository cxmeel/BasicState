local Replicated = game:GetService("ReplicatedStorage")
local Roact = require(Replicated.Modules.Roact)

local AppComponent = require(script.Parent.Components.App)

Roact.mount(
	Roact.createElement(AppComponent),
	script.Parent,
	"basicstate.example.counter"
)
