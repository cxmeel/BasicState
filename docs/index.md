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
[devhub/replicatedstorage]: https://developer.roblox.com/en-us/api-reference/class/ReplicatedStorage
[roblox-ts]: https://roblox-ts.com/
[@tech0tron]: https://github.com/tech0tron

# BasicState

BasicState is a really, really simple key-value based state management solution. It makes use of [BindableEvents][devhub/bindableevents] to allow your projects to watch for changes in state, and provides a simple API for communication with your state objects. Think [Rodux][roblox/rodux], but much more simple.

## Getting Started

It's easy to get started using BasicState. There are a few methods to add BasicState to your project:

!!! info

    It's recommended that you place the BasicState module in a place like [ReplicatedStorage][devhub/replicatedstorage], as it can be used on both the client and server; however, this is not mandatory.

### Method 1: [Wally][wally]

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
BasicState = "csqrl/BasicState@^0.2.5"
```

```sh
$ wally install
```

### Method 2: [Rojo][rojo]

You can use git submodules to clone this repo into your project's packages directory:

```sh
$ git submodule add https://github.com/csqrl/BasicState packages/BasicState
```

Once added, simply sync into Studio using the [Rojo][rojo] plugin.

#### 0.5.x

Download/clone this repo on to your device, and copy the `/src` directory into your packages directory.

### Method 3: [Roblox-TS][roblox-ts] (unofficial)

While this package doesn't officially support TypeScript, bindings are available under the [`@rbxts/basicstate`][npm package] package, which can be installed using npm or yarn.

```sh
$ npm i @rbxts/basicstate
$ yarn add @rbxts/basicstate
$ pnpm add @rbxts/basicstate
```

TypeScript bindings are provided by [@tech0tron][@tech0tron]. Please file any issues for the npm package over on [their repo][ts bindings repo].

### Method 4: Manual Installation

Grab a copy [from the Roblox Library (Toolbox)][library url], or download the latest `.rbxm/.rbxmx` file from [the releases page][latest release] and drop it into Studio.

### Method 5: Git Submodules

Follow the instructions in the following Gist to import a GitHub repo as a submodule. This allows you to link modules into your project, and sync updates when they become available:

https://gist.github.com/gitaarik/8735255#adding-a-submodule
