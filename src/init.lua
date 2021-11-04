local State = {}

State.None = newproxy(true)
getmetatable(State.None).__tostring = function()
	return "BasicState.None"
end

State.__index = State
function State.new(InitialState)
	local self = setmetatable({}, State)

	self.__initialState = self:__joinDictionary(type(InitialState) == "table" and InitialState or {})
	self.__state = self:__joinDictionary(self.__initialState)
	self.__changeEvent = Instance.new("BindableEvent")
	self.__bindables = {}

	self.Changed = self.__changeEvent.Event
	self.ProtectType = false

	self.Changed:Connect(function(OldState, ChangedKey)
		local Signal = self.__bindables[ChangedKey]

		if Signal then
			Signal:Fire(self:Get(ChangedKey), OldState[ChangedKey], OldState)
		end
	end)

	return self
end

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

function State:GetState()
	return self:__joinDictionary(self.__state)
end

function State:RawSet(Key, Value)
	self.__state[Key] = Value
end

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

function State:Get(Key, DefaultValue)
	local StateValue = self:GetState()[Key]

	if StateValue == State.None then
		StateValue = nil
	end

	return type(StateValue) == "nil" and DefaultValue or StateValue
end

function State:Delete(Key)
	return self:Set(Key, State.None)
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

	if Cap then
		NewValue = math.min(NewValue, Cap)
	end

	return self:Set(Key, NewValue)
end

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

function State:GetChangedSignal(Key)
	local Signal = self.__bindables[Key]

	if Signal then
		return Signal.Event
	end

	Signal = Instance.new("BindableEvent")
	self.__bindables[Key] = Signal

	return Signal.Event
end

function State:Reset()
	for key, value in next, self.__initialState do
		self:Set(key, value)
	end

	for key in next, self:GetState() do
		if self.__initialState[key] == nil then
			self:Set(key, nil)
		end
	end
end

function State:Destroy()
	for _, bindable in next, self.__bindables do
		bindable:Destroy()
	end

	self.__changeEvent:Destroy()
	self.__state = nil
end

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

return State
