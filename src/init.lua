--[[
	BasicState by ClockworkSquirrel
	Version: 0.0.4

	Documentation is at:
	https://clockworksquirrel.github.io/BasicState/
 ]]

local State = {}

--[[
	Helper function which creates a shallow copy of passed tables.
	Child tables will not be copied, and passed ByRef, meaning
	modifying them will affect the original copy
 ]]
local function JoinDictionary(...)
	local NewDictionary = {}

	for _, Dictionary in next, { ... } do
		for Key, Value in next, Dictionary do
			NewDictionary[Key] = Value
		end
	end

	return NewDictionary
end

--[[
	Create and return new BasicState instance
 ]]
State.__index = State
function State.new(InitialState)
	--[[
		Copy "State" as it's defined in this module into an empty
		metatable
	 ]]
	local self = setmetatable({}, State)

	--[[
		Set the state to the value of InitialState, if specified,
		or an empty table otherwise
	 ]]
	self.__state = type(InitialState) == "table" and InitialState or {}

	--[[
		Create a new BindableEvent, which is triggered when state changes
	 ]]
	self.__changeEvent = Instance.new("BindableEvent")

	--[[
		Assign an empty table which is used to hold an array of BindableEvent
		instances which are triggered when a specific value is changed, rather
		than the .Changed event, which is triggered every time state is mutated
	 ]]
	self.__bindables = {}

	--[[
		Set BasicState.Changed as an alias for BasicState.__changeEvent.Event
	 ]]
	self.Changed = self.__changeEvent.Event

	--[[
		Previously used to prevent setting of values on the root BasicState
		object. Currently unused
	 ]]
	--[[
		self.__newindex = function(self, key, value)

		end
	 ]]

	--[[
		Return the new completed BasicState instance
	 ]]
	return self
end

--[[
	Return a shallow copy of the current stored state
 ]]
function State:GetState()
	return JoinDictionary(self.__state, {})
end

--[[
	Set a value without triggering Changed events
 ]]
function State:RawSet(Key, Value)
	self.__state[Key] = Value
end

--[[
	Sets a value in the state and triggers Changed events. Will not fire
	events when the passed value is the same as the already stored value
 ]]
function State:Set(Key, Value)
	local OldState = self:GetState()

	if (OldState[Key] ~= Value) then
		self:RawSet(Key, Value)
		self.__changeEvent:Fire(OldState, Key)
	end
end

--[[
	Like React's setState method, SetState accepts a table of key-value pairs,
	which will be added to or mutated in the store. This is a shallow-merge,
	and therefore sub-tables will be fully overwritten by whatever value
	is specified using this method.

	Be sure to Get() a copy of the currently stored table, overwrite or append
	relevant keys, and pass the modified table into this method, when setting
	table values.
 ]]
function State:SetState(StateTable)
	assert(type(StateTable) == "table")

	for Key, Value in next, StateTable do
		self:Set(Key, Value)
	end
end

--[[
	Retrieve and return a value from the store. Optionally takes a DefaultValue
	parameter, which will be returned if the stored value is nil
 ]]
function State:Get(Key, DefaultValue)
	local StateValue = self:GetState()[Key]
	return type(StateValue) == "nil" and DefaultValue or StateValue
end

--[[
	Allows a stored boolean value to be toggled between true and false. Will throw
	and error if the stored value is not boolean
 ]]
function State:Toggle(Key)
	local Value = self:Get(Key)

	assert(type(Value) == "boolean")
	return self:Set(Key, not Value)
end

--[[
	Increment a stored number by 1. Optionally takes an Amount parameter, which allows
	the user to specify how much to increment by, and a Cap parameter, which will
	prevent the value from exceeding the specified number
 ]]
function State:Increment(Key, Amount, Cap)
	local Value = self:Get(Key)

	Amount = type(Amount) == "number" and Amount or 1
	assert(type(Value) == "number")

	local NewValue = Value + Amount
	if (Cap) then NewValue = math.min(NewValue, Cap) end

	return self:Set(Key, NewValue)
end

--[[
	Decrement a stored number by 1. As with the Increment method, optional Amount
	and Cap parameters may be passed to specify how much to decrement the value by.
	Setting a Cap prevents the value from falling below the specified number.
 ]]
function State:Decrement(Key, Amount, Cap)
	local Value = self:Get(Key)

	Amount = type(Amount) == "number" and Amount or 1
	assert(type(Value) == "number")

	local NewValue = Value - Amount
	if (Cap) then NewValue = math.max(NewValue, Cap) end

	return self:Set(Key, NewValue)
end

--[[
	Creates a new BindableEvent, which is fired when the passed key's value changes.
	The returned value is the new BindableEvent's .Event event, to keep consistency
	with Roblox's :GetPropertyChangedSignal() method, which returns a single
	RBXScriptConnection
 ]]
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

--[[
	Destroys all BindableEvents created using GetChangedSignal, the .Changed event's
	BindableEvent, clears the state, and finally the BasicState instance itself
 ]]
function State:Destroy()
	for _, bindable in next, self.__bindables do
		bindable:Destroy()
	end

	self.__changeEvent:Destroy()
	self.__state = nil
	self = nil
end

--[[
	Return the State table from the module to allow users to construct new
	BasicState instances
 ]]
return State
