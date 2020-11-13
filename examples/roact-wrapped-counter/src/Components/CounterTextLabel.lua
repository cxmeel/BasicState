local Replicated = game:GetService("ReplicatedStorage")
local Roact = require(Replicated.Modules.Roact)

local CounterTextLabel = Roact.Component:extend("CounterTextLabel")
local Store = require(script.Parent.Parent.State.Store)

function CounterTextLabel:init(props)
	self.decorator = props.Decorator or ""
end

function CounterTextLabel:render()
	local Count = self.state.Count

	return Roact.createElement("TextLabel", {
		TextScaled = true,
		Size = UDim2.fromScale(.5, 1),
		--[[
			Display the value of Count by referencing from the component's
			state. This is updated when Count changes in the BasicState store,
			as we wrapped the component using Store:Roact().
		--]]
		Text = Count and string.format("%s%d", self.decorator, Count) or tostring(Count),
		LayoutOrder = 1
	})
end

--[[
	Wrap the component in the BasicState store. This component will re-render
	whenever any value of the BasicState store changes, as we didn't specify
	which key(s) to listen to. This is not recommended.
--]]
return Store:Roact(CounterTextLabel)
