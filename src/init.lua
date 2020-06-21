--[[
	BasicState by ClockworkSquirrel
	Version: 0.0.3

	Documentation is at:
	https://clockworksquirrel.github.io/BasicState/
--]]

local State = {}

local function JoinDictionary(...)
	local NewDictionary = {}

	for _, Dictionary in next, { ... } do
		for Key, Value in next, Dictionary do
			NewDictionary[Key] = Value
		end
	end

	return NewDictionary
end

State.__index = State
function State.new(InitialState)
	local self = setmetatable({}, State)

	self.__state = type(InitialState) == "table" and InitialState or {}
	self.__changeEvent = Instance.new("BindableEvent")
	self.__bindables = {}

	self.Changed = self.__changeEvent.Event

	self.__newindex = function()
		warn("Do not modify state directly!")
	end

	return self
end

function State:GetState()
	return JoinDictionary(self.__state, {})
end

function State:RawSet(Key, Value)
	self.__state[Key] = Value
end

function State:Set(Key, Value)
	local OldState = self:GetState()

	if (OldState[Key] ~= Value) then
		self.__state[Key] = Value
		self.__changeEvent:Fire(OldState, Key)
	end
end

function State:Get(Key, DefaultValue)
	local StateValue = self:GetState()[Key]
	return type(StateValue) == "nil" and DefaultValue or StateValue
end

function State:Toggle(Key)
	local Value = self:Get(Key)

	assert(type(Value) == "boolean")
	return self:Set(Key, not Value)
end

function State:Increment(Key, Amount, Cap)
	local Value = self:Get(Key)

	Amount = type(Amount) == "number" and Amount or 1
	assert(type(Value) == "number")

	local NewValue = Value + Amount
	if (Cap) then NewValue = math.min(NewValue, Cap) end

	return self:Set(Key, NewValue)
end

function State:Decrement(Key, Amount, Cap)
	local Value = self:Get(Key)

	Amount = type(Amount) == "number" and Amount or 1
	assert(type(Value) == "number")

	local NewValue = Value - Amount
	if (Cap) then NewValue = math.max(NewValue, Cap) end

	return self:Set(Key, NewValue)
end

function State:GetChangedSignal(Key)
	local Signal = Instance.new("BindableEvent")

	self.Changed:Connect(function(OldState, ChangedKey)
		if (Key == ChangedKey) then
			Signal:Fire(self:Get(Key), OldState[Key], OldState)
		end
	end)

	self.__bindables[#self.__bindables + 1] = Signal
	return Signal.Event
end

function State:Destroy()
	for _, bindable in next, self.__bindables do
		bindable:Destroy()
	end

	self.__changeEvent:Destroy()
	self.__state = nil
	self = nil
end

return State
