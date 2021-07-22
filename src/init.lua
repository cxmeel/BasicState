--[[
	BasicState
	Version: 0.2.3

	Author: csqrl
	Contributors: boatbomber

	Other Contributors:
	https://github.com/csqrl/BasicState/graphs/contributors

	Documentation is at:
	https://csqrl.github.io/BasicState/

	Overview of Methods:
		BasicState.new([ InitialState: Dictionary<any, any> = {} ]): State

		State:Get(Key: any[, DefaultValue: any = nil]): any
		State:Set(Key: any, Value: any): void
		State:Delete(Key: any): void
		State:GetState(): Dictionary<any, any>
		State:SetState(StateTable: Dictionary<any, any> | Callback: function(CurrentState: Dictionary<any, any>): UpdatedState: Dictionary<any, any>): void
		State:Toggle(Key: any): void
		State:Increment(Key: any[, Amount: Number = 1][, Cap: Number = nil]): void
		State:Decrement(Key: any[, Amount: Number = 1][, Cap: Number = nil]): void
		State:RawSet(Key: any, Value: any): void
		State:GetChangedSignal(Key: any): RBXScriptSignal
		State:Roact(Component: Roact.Component[, Keys: any[] = nil]): Roact.Component
		State:Reset(): void
		State:Destroy(): void

		State.Changed: RBXScriptSignal

		State.ProtectType: boolean
		State.None: Instance
--]]

local State = {}

State.None = newproxy(true)
getmetatable(State.None).__tostring = function()
	return "BasicState.None"
end

--[[
	Create and return new BasicState instance
--]]
State.__index = State
function State.new(InitialState)
	--[[
		Copy "State" as it's defined in this module into an empty
		metatable
	--]]
	local self = setmetatable({}, State)

	--[[
		Set the state to the value of InitialState, if specified,
		or an empty table otherwise
	--]]
	self.__state = type(InitialState) == "table" and InitialState or {}


	--[[
		Store a copy of the initial state which can be retrieved later using State:Reset()
		Added by @Gaffal in v0.2.3
	]]
	self.__initialState = self:__joinDictionary(self.__state)

	--[[
		Create a new BindableEvent, which is triggered when state changes
	--]]
	self.__changeEvent = Instance.new("BindableEvent")

	--[[
		Assign an empty table which is used to hold an array of BindableEvent
		instances which are triggered when a specific value is changed, rather
		than the .Changed event, which is triggered every time state is mutated
	--]]
	self.__bindables = {}

	--[[
		Set BasicState.Changed as an alias for BasicState.__changeEvent.Event
	--]]
	self.Changed = self.__changeEvent.Event

	--[[
		Set BasicState.ProtectType to default to false to allow dynamically changing state types

		Type protection added by @boatbomber in v0.2.0
	--]]
	self.ProtectType = false

	--[[
		Handle firing bindables created from State:GetChangedSignal

		Added by @boatbomber in v0.2.0
	--]]
	self.Changed:Connect(function(OldState, ChangedKey)
		local Signal = self.__bindables[ChangedKey]

		if Signal then
			Signal:Fire(self:Get(ChangedKey), OldState[ChangedKey], OldState)
		end
	end)

	--[[
		Return the new completed BasicState instance
	--]]
	return self
end

--[[
	Helper function which creates a deep copy of passed tables.
	It's stored inside State so that it can access self for property checks.

	In v0.1.1, JoinDictionary now performs a deep copy of tables. This
	allows nested tables within state to be modified without losing
	original data.
--]]
function State:__joinDictionary(...)
	local NewDictionary = {}

	for _, Dictionary in next, { ... } do
		if type(Dictionary) ~= "table" then
			continue
		end

		for Key, Value in next, Dictionary do
			if Value == State.None then
				continue
			end

			if self.ProtectType and NewDictionary[Key] and typeof(NewDictionary[Key]) ~= typeof(Value) then
				error(
					string.format("attempt to set \"%s\" to new value type \"%s\". Disable State.ProtectType to allow this.", tostring(Key), typeof(Value)),
					2
				)
			end

			if type(Value) == "table" then
				NewDictionary[Key] = self:__joinDictionary(NewDictionary[Key], Value)
				continue
			end

			NewDictionary[Key] = Value
		end
	end

	return NewDictionary
end

--[[
	Return a deep copy of the current stored state
--]]
function State:GetState()
	return self:__joinDictionary(self.__state)
end

--[[
	Set a value without triggering Changed events and bypasses ProtectType
--]]
function State:RawSet(Key, Value)
	self.__state[Key] = Value
end

--[[
	Sets a value in the state and triggers Changed events. Will not fire
	events when the passed value is the same as the already stored value
--]]
function State:Set(Key, Value)
	local OldState = self:GetState()

	if self.ProtectType then
		if OldState[Key] and typeof(Value) ~= typeof(OldState[Key]) then
			error(
				string.format("attempt to set \"%s\" to new value type \"%s\". Disable State.ProtectType to allow this.", tostring(Key), typeof(Value)),
				2
			)
		end
	end

	if type(Value) == "table" then
		Value = self:__joinDictionary(OldState[Key], Value)
	end

	if OldState[Key] ~= Value then
		self:RawSet(Key, Value)
		self.__changeEvent:Fire(OldState, Key)
	end
end

--[[
	Like React's setState method, SetState accepts a table of key-value pairs,
	which will be added to or mutated in the store. This is a deep copy, so
	original data will not be overwritten unless specified.

	- Added by @Gaffal in v0.2.3
	SetState also accepts a function which receives a copy of the current
	state and returns the new state.
--]]
function State:SetState(State)
	local StateType = type(State)
	assert(StateType == "table" or StateType == "function")

	if StateType == 'table' then
		for Key, Value in next, State do
			self:Set(Key, Value)
		end

	elseif StateType == "function" then
		local UpdatedState = State(self:GetState())

		if type(UpdatedState) == 'table' then
			self:SetState(UpdatedState)
		end
	end
end

--[[
	Retrieve and return a value from the store. Optionally takes a DefaultValue
	parameter, which will be returned if the stored value is nil
--]]
function State:Get(Key, DefaultValue)
	local StateValue = self:GetState()[Key]

	if StateValue == State.None then
		StateValue = nil
	end

	return type(StateValue) == "nil" and DefaultValue or StateValue
end

--[[
	Delete a key from the store by setting its value to BasicState.None.
--]]
function State:Delete(Key)
	return self:Set(Key, State.None)
end

--[[
	Allows a stored boolean value to be toggled between true and false. Will throw
	and error if the stored value is not boolean
--]]
function State:Toggle(Key)
	local Value = self:Get(Key)

	assert(type(Value) == "boolean")
	return self:Set(Key, not Value)
end

--[[
	Increment a stored number by 1. Optionally takes an Amount parameter, which allows
	the user to specify how much to increment by, and a Cap parameter, which will
	prevent the value from exceeding the specified number
--]]
function State:Increment(Key, Amount, Cap)
	local Value = self:Get(Key)

	Amount = type(Amount) == "number" and Amount or 1
	assert(type(Value) == "number")

	local NewValue = Value + Amount

	if Cap then
		NewValue = math.min(NewValue, Cap)
	end

	return self:Set(Key, NewValue)
end

--[[
	Decrement a stored number by 1. As with the Increment method, optional Amount
	and Cap parameters may be passed to specify how much to decrement the value by.
	Setting a Cap prevents the value from falling below the specified number.
--]]
function State:Decrement(Key, Amount, Cap)
	local Value = self:Get(Key)

	Amount = type(Amount) == "number" and Amount or 1
	assert(type(Value) == "number")

	local NewValue = Value - Amount

	if Cap then
		NewValue = math.max(NewValue, Cap)
	end

	return self:Set(Key, NewValue)
end

--[[
	Creates a new BindableEvent, which is fired when the passed key's value changes.
	The returned value is the new BindableEvent's .Event event, to keep consistency
	with Roblox's :GetPropertyChangedSignal() method, which returns a single
	RBXScriptConnection
--]]
function State:GetChangedSignal(Key)
	local Signal = self.__bindables[Key]

	if Signal then
		return Signal.Event
	end

	Signal = Instance.new("BindableEvent")
	self.__bindables[Key] = Signal

	return Signal.Event
end

--[[
	Set the current state to the initial state passed when creating the state object
	Added by @Gaffal in v0.2.3
]]
function State:Reset()
	-- Set the keys which are in __initialState
	for key, value in next, self.__initialState do
		self:Set(key, value)
	end

	-- Remove the keys which are not in __initialState
	for key in next, self:GetState() do
		if self.__initialState[key] == nil then
			self:Delete(key)
		end
	end
end

--[[
	Destroys all BindableEvents created using GetChangedSignal, the .Changed event's
	BindableEvent, clears the state, and finally the BasicState instance itself
--]]
function State:Destroy()
	for _, bindable in next, self.__bindables do
		bindable:Destroy()
	end

	self.__changeEvent:Destroy()
	self.__state = {}
end

--[[
	Wraps a Roact component and injects the given keys into the component's state.
	The component will be re-rendered when State changes.
--]]
function State:Roact(Component, Keys)
	local ComponentLifecycle = {
		init = Component.init,
		willUnmount = Component.willUnmount
	}

	Component.__bsIsUnmounting = false

	Component.init = function(this, ...)
		if ComponentLifecycle.init then
			ComponentLifecycle.init(this, ...)
		end

		this.__basicStateBindings = {}

		local InitialState = {}

		if type(Keys) == "table" then
			for _, Key in next, Keys do
				InitialState[Key] = self:Get(Key)

				this.__basicStateBindings[Key] = self:GetChangedSignal(Key):Connect(function(NewValue)
					this:setState({ [Key] = NewValue })
				end)
			end
		else
			InitialState = self:GetState()

			this.__basicStateBindings[1] = self.Changed:Connect(function()
				if this.__bsIsUnmounting then
					return
				end

				this:setState(self:GetState())
			end)
		end

		this:setState(InitialState)
	end

	Component.willUnmount = function(this, ...)
		this.__bsIsUnmounting = true

		if ComponentLifecycle.willUnmount then
			ComponentLifecycle.willUnmount(this, ...)
		end

		if this.__basicStateBindings then
			for _, Connection in next, this.__basicStateBindings do
				Connection:Disconnect()
			end

			this.__basicStateBindings = {}
		end
	end

	return Component
end

--[[
	Returns a string format of the current state instead of the class.
	Added by @Kevinwkz in v0.2.2
]]
function State:__tostring()
	local str = "\n"
	local spaces = 2

	local function parseString(s)
		return type(s) == "string" and "\"" .. s .. "\"" or tostring(s)
	end

	local function stringify(tbl, stack)
		stack = stack or 1
		local s = ""
		local space = ((" "):rep(spaces)):rep(stack)

		local length = 0
		for _, _ in next , tbl do
			length += 1
		end

		local i = 1
		for k, v in next, tbl do
			local key = ("%s[%s]:"):format(space, parseString(k))
			local comma = i < length and "," or ""
			if type(v) ~= "table" then
				s ..= ("%s %s%s\n"):format(key, parseString(v), comma)
			else
				s ..= ("%s {\n%s%s}%s\n"):format(key, stringify(v, stack + 1), space, comma)
			end
			i += 1
		end
		if stack == 1 then
			str ..= s
		end
		return s
	end
	stringify(self.__state)

	return ("\n(State): {%s}"):format(str)
end

--[[
	Return the State table from the module to allow users to construct new
	BasicState instances
--]]
return State
