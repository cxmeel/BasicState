# roact-wrapped-counter
This example can be synced-in using Rojo or directly inserted by downloading the attached `.rbxm` or `.rbxmx` model file.

Be sure to insert **`BasicState`** and **`Roact`** into a folder named "Modules" in `ReplicatedStorage`, unless you manually update the references through the components and project files.

# Usage with Roact
With `v0.1.0`, using BasicState with Roact is as simple as wrapping components with the experimental `:Roact()` method. This overrides the `:init()` and `:willUnmount()` methods of your component to create bindings to your BasicState store, handle state changes, and disconnecting events when unmounting.

```lua
local BasicState = require(path.to.BasicState)

local Store = BasicState.new({
    Hello = "World"
})

return Store
```

```lua
local Roact = require(path.to.Roact)
local MyComponent = Roact.Component:extend("MyComponent")

local Store = require(path.to.Store)

function MyComponent:render()
    return Roact.createElement("TextButton", {
        Text = string.format("Hello, %s!", self.state.Hello),
        --> Displays "Hello, World!"

        [Roact.Event.MouseButton1Click] = function()
            Store:Set("Hello", "Roblox")
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
