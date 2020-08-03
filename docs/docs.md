## `BasicState.new()`
-----
Creates a new state object. Accepts an optional `InitialState` parameter, for defining the state before it is returned.

### Syntax
`BasicState.new([ InitialState: Dictionary<any, any> = {} ]): State`

## `State:Set()`
-----
Sets the value of a given key in the state, and then fires off any `Changed` signals. You should always use this when you need to change the state. Never modify state directly, unless using `RawSet`!

### Syntax
`State:Set(Key: any, Value: any): void`

## `State:SetState()`
-----
Set multiple values in the state. `Changed` signals will be fired for each modified key.

!!! warning
    Setting sub-tables will fully overwrite their contents in the state. This method uses shallow-merging, which only merges the values at the root of the state. Use :Get() and append/overwrite keys where required, and set the modified table when storing tables.

### Syntax
`State:SetState(StateTable: Dictionary<any, any>): void`

### Example
```lua
local State = BasicState.new({
    Location = "Mountain",
    Greetings = {
        Place = "Welcome to the Mountain!",
        Roblox = "Hey Roblox!",
        Me = "Hi ClockworkSquirrel!"
    }
})

local function ChangeLocations(NewLocation)
    local NewGreetings = State:Get("Greetings")
    NewGreetings.Place = string.format("Hello %s!", NewLocation)

    State:SetState({
        Location = NewLocation,
        Greetings = NewGreetings
    })
end

ChangeLocations("City")
```

## `State:Toggle()`
-----
Toggles a stored Boolean value between `true` and `false`. Will throw an error if the stored value is not a Boolean.

### Syntax
`State:Toggle(Key: any): void`

### Example
```lua
local State = BasicState.new({
    MenuOpen = false
})

State:Toggle("MenuOpen") --> true
State:Toggle("MenuOpen") --> false
```

## `State:Increment()`
-----
Increases the value of a stored numeric value by 1 (or a specified amount), with an optional cap parameter, which will stop incrementing above a specified number. Will throw an error is the stored value is not a number.

### Syntax
`State:Increment(Key: any[, Amount: Number = 1][, Cap: Number = nil]): void`

## `State:Decrement()`
-----
Decreases the value of a stored numeric value by 1 (or a specified amount), with an optional cap parameter, which will stop decrementing below a specified number. Will throw an error if the stored value is not a number.

### Syntax
`State:Decrement(Key: any[, Amount: Number = 1][, Cap: Number = nil]): void`

### Example
```lua
local State = BasicState.new({
    Money = 100
})

local function BuyItem(ItemName, ItemPrice)
    -- A cap of 0 was specified to prevent Money from going below 0
    State:Decrement("Money", ItemPrice, 0)
    print(("Bought %s for %d"):format(ItemName, ItemPrice))
end

BuyItem("Noodles", 12)
```

## `State:RawSet()`
-----
Sets a value in the store without firing any `.Changed` (or `:GetChangedSignal`) events.

### Syntax
`State:RawSet(Key: any, Value: any): void`

## `State:Get()`
-----
Retrieves a value stored in the state. If `DefaultValue` is specified, it will return that if the entry does not exist (or is equal to `nil`).

### Syntax
`State:Get(Key: any[, DefaultValue: any = nil]): any`

## `State:GetState()`
-----
Returns the full state object. A new table is returned, rather than a reference to the internal state object. This prevents directly overwriting the state. You should always use the `:Set()` method if you wish to mutate state.

### Syntax
`State:GetState(): Dictionary<any, any>`

## `State:GetChangedSignal()`
-----
Returns an [RBXScriptSignal](https://developer.roblox.com/en-us/api-reference/datatype/RBXScriptSignal) which is only fired when the value of the specified key is updated. The Event fires with the following values (in order):

| Name          | Type                             | Description                                               |
|-----------------|--------------------------------|-------------------------------------------------------|
| `NewValue` | `any`                             | The new value of the requested entry.     |
| `OldValue`   | `any`                             | The value of the entry prior to mutation.  |
| `OldState`    | `Dictionary<any, any>` | The entire state object prior to mutation. |

### Syntax
`State:GetChangedSignal(Key: any): RBXScriptSignal`

### Example
```lua
local State = BasicState.new({
    Hello = "World"
})

State:GetChangedSignal("Hello"):Connect(function(NewValue, OldValue, OldState)
    print(OldValue) --> "World"
    print(NewValue) --> "Roblox"
end)

State:Set("Hello", "Roblox")
```

## `State:Destroy()`
-----
Clears the current state and disconnects all connections.

### Syntax
`State:Destroy(): void`

## `State.Changed`
-----
An [RBXScriptSignal](https://developer.roblox.com/en-us/api-reference/datatype/RBXScriptSignal) which is fired any time the state mutates. The Event fires with the following values (in order):

| Name          | Type                             | Description                                               |
|-----------------|--------------------------------|-------------------------------------------------------|
| `OldState`    | `Dictionary<any, any>` | The entire state object prior to mutation. |
| `Key`           | `any`                             | The key of the entry which has mutated. |

### Syntax
`State.Changed: RBXScriptSignal`

### Example
```lua
local State = BasicState.new({
    Hello = "World"
})

State.Changed:Connect(function(OldState, Key)
    print(Key) --> "Hello"
    print(OldState[Key]) --> "World"
    print(State:Get(Key)) --> "Roblox"
end)

State:Set("Hello", "Roblox")
```
