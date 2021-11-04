<!-- Project Link References -->

[ci status]: https://github.com/csqrl/BasicState/actions
[latest release]: https://github.com/csqrl/BasicState/releases/latest
[library url]: https://www.roblox.com/library/5023525481
[docs]: https://csqrl.github.io/BasicState
[npm package]: https://www.npmjs.com/package/@rbxts/basicstate
[ts bindings repo]: https://github.com/tech0tron/BasicState

<!-- Articles -->

[rojo]: https://rojo.space
[wally]: https://github.com/upliftgames/wally
[roblox/rodux]: https://roblox.github.io/rodux/
[devhub/bindableevents]: https://developer.roblox.com/en-us/api-reference/class/BindableEvent
[roblox-ts]: https://roblox-ts.com/
[@tech0tron]: https://github.com/tech0tron

<!-- Images -->

[shield ci]: https://github.com/csqrl/BasicState/actions/workflows/unit-tests.yml/badge.svg
[shield gh release]: https://img.shields.io/github/v/release/csqrl/BasicState?label=latest+release&style=flat
[shield wally release]: https://img.shields.io/endpoint?url=https://runkit.io/clockworksquirrel/wally-version-shield/branches/master/csqrl/BasicState&color=blue&label=wally&style=flat
[hero]: .github/assets/basicstate-cover.png

[![BasicState][hero]][docs]

[![CI][shield ci]][ci status]
[![GitHub release (latest by date)][shield gh release]][latest release]
[![Wally release (latest)][shield wally release]][latest release]

BasicState is a really simple key-value based state management solution. It makes use of [BindableEvents][devhub/bindableevents] to allow your project to watch for changes in state, and provides a simple but comprehensive API for communication with your state objects. Think [Rodux][roblox/rodux], but easier!

## Installation

### [Rojo][rojo]

You can use git submodules to clone this repo into your project's packages directory:

```sh
$ git submodule add https://github.com/csqrl/BasicState packages/BasicState
```

Once added, simply sync into Studio using the [Rojo][rojo] plugin.

#### 0.5.x

Download/clone this repo on to your device, and copy the `/src` directory into your packages directory.

### [Wally][wally]

Add `BasicState` to your `wally.toml` and run `wally install`

```toml
[package]
name = "user/repo"
description = "My awesome Roblox project"
version = "1.0.0"
license = "MIT"
authors = ["You (https://github.com/you)"]
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
BasicState = "csqrl/BasicState@^0.2.3"
```

```sh
$ wally install
```

### [Roblox-TS][roblox-ts] (unofficial)

While this package doesn't officially support TypeScript, bindings are available under the [`@rbxts/basicstate`][npm package] package, which can be installed using npm or yarn.

```sh
$ npm i @rbxts/basicstate
$ yarn add @rbxts/basicstate
$ pnpm add @rbxts/basicstate
```

TypeScript bindings are provided by [@tech0tron][@tech0tron]. Please file any issues for the npm package over on [their repo][ts bindings repo].

### Manual Installation

Grab a copy [from the Roblox Library (Toolbox)][library url], or download the latest `.rbxm/.rbxmx` file from [the releases page][latest release] and drop it into Studio.

## Usage

Here's a quick example of how BasicState can be used:

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

Usage with Roact:

```lua
-- Store.lua
local BasicState = require(path.to.BasicState)

local Store = BasicState.new({
    Hello = "World"
})

return Store
```

```lua
-- MyComponent.lua
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

-- Wrap the component with the BasicState store
return Store:Roact(MyComponent)
```

# Documentation

Please [refer to the documentation site][docs] for a full overview of the exported API and further examples on how to use this module.
