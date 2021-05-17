<!-- Link References -->
[repo]: https://github.com/csqrl/BasicState
[contribs]: https://github.com/csqrl/BasicState/graphs/contributors
[actions]: https://github.com/csqrl/BasicState/actions
[latest-release]: https://github.com/csqrl/BasicState/releases/latest

[docs]: https://csqrl.github.io/BasicState
[docs-example]: https://csqrl.github.io/BasicState/example

[forum]: https://devforum.roblox.com/t/571355
[forum-dm]: https://devforum.roblox.com/new-message?username=csqrl

<!-- Image References -->
[img-cover]: resources/basicstate-cover.png
[img-ci-status]: https://github.com/csqrl/BasicState/actions/workflows/ci.yml/badge.svg
[img-latest-release]: https://img.shields.io/github/v/release/csqrl/BasicState?label=version

<!-- Content -->
[![# BasicState][img-cover]][docs]
[![CI Status][img-ci-status]][actions] [![Latest Release][img-latest-release]][latest-release]

BasicState is a really, really simple key-value based state management solution. It makes use of [BindableEvents](https://developer.roblox.com/en-us/api-reference/class/BindableEvent) to allow your projects to watch for changes in state, and provides a simple API for communication with your state objects. Think [Rodux](https://roblox.github.io/rodux/), but much more simple.

## Getting Started
[Visit the documentation site][docs] to get started with BasicState, see examples, and view the full documentation.

## Contributors
A huge thanks to [the contributors][contribs] of this project. You've added some awesome new features and helps work out a few kinks.

## Documentation
Documentation is available on the [documentation site][docs].

## Examples
For examples, please see the [documentation site][docs-example].

**Basic example:**
```lua
local BasicState = require(path.to.BasicState)

local State = BasicState.new({
    Hello = "World"
})

State:GetChangedSignal("Hello"):Connect(function(NewValue, OldValue)
    print(string.format("Hello, %s; goodbye %s!", NewValue, OldValue))
end)

State:SetState({
    Hello = "Roblox"
})

--[[
    Triggers the RBXScriptConnection above and prints
    "Hello, Roblox; goodbye World!"
--]]
```

**Usage with Roact**

`MyProject.Store.lua`:

```lua
local BasicState = require(path.to.BasicState)

local Store = BasicState.new({
    Hello = "World"
})

return Store
```

`MyProject.Components.MyComponent.lua`:
```lua
local Roact = require(path.to.Roact)
local MyComponent = Roact.Component:extend("MyComponent")

local Store = require(script.Parent.Parent.Store)

function MyComponent:render()
    return Roact.createElement("TextButton", {
        Text = string.format("Hello, %s!", self.state.Hello),
        --> Displays "Hello, World!"

        [Roact.Event.MouseButton1Click] = function()
            Store:SetState({ Hello = "Roblox" })
            --> Will re-render and display "Hello, Roblox!"
        end
    })
end

--[[
    Wrap the component with the BasicState store and inject
    the value of Hello into the component state.
--]]
return Store:Roact(MyComponent, { "Hello" })
```

## Get in Touch
Please refer to the [thread on the Roblox Developer Forums][forum] if you wish to discuss BasicState.
You can also contact me via direct message [on the DevForums][forum-dm].
