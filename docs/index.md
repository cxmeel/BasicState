# BasicState
BasicState is a really, really simple key-value based state management solution. It makes use of [BindableEvents](https://developer.roblox.com/en-us/api-reference/class/BindableEvent) to allow your projects to watch for changes in state, and provides a simple API for communication with your state objects. Think [Rodux](https://roblox.github.io/rodux/), but much more simple.

## Community
Special thanks to the contributors of this project! You've made some great improvements and added some awesome features. 😁

## Getting Started
It's easy to get started using BasicState. There are a few methods to add BasicState to your project:

!!! info
    It's recommended that you place the BasicState module in a place like [ReplicatedStorage](https://developer.roblox.com/en-us/api-reference/class/ReplicatedStorage), as it can be used on both the client and server; however, this is not mandatory.

### Method 1: Library
The easiest method to add BasicState to your project is via the Toolbox.

* Grab a copy of the model from [the Library page](https://www.roblox.com/library/5023525481/BasicState).
* Insert it into your game via the [Toolbox](https://developer.roblox.com/en-us/resources/studio/Toolbox) in Roblox Studio.

### Method 2: Model File
* Download the latest `rbxm` or `rbxmx` file from the [Releases page](https://github.com/csqrl/BasicState/releases/latest).
* Insert it into your game via Roblox Studio.

### Method 3: Rojo
* Clone the `/src` directory into your project.
* Rename the folder to `BasicState`.
* Sync it into your game using [Rojo](https://github.com/rojo-rbx/rojo).

### Method 4: Git Submodules
Follow the instructions in the following Gist to import a GitHub repo as a submodule. This allows you to link modules into your project, and sync updates when they become available:

https://gist.github.com/gitaarik/8735255#adding-a-submodule
