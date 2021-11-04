local Replicated = game:GetService("ReplicatedStorage")

return function()
    local Roact: Roact = require(Replicated.Roact)
    local BasicState = require(script.Parent)

    local DEMO_STATE = {
        Hello = "World",
        Number = 10,
        Boolean = true,
        Colour = Color3.new(),
    }

    local state = nil

    describe(".new()", function()
        it("constructs a new state instance", function()
            state = BasicState.new(DEMO_STATE)
            expect(state).to.be.ok()
        end)
    end)

    describe(":Get()", function()
        it("gets the value of a stored key", function()
            expect(state:Get("Hello")).to.equal("World")
        end)

        it("returns a default value if key is `nil`", function()
            expect(state:Get("Game", "Experience")).to.equal("Experience")
        end)
    end)

    describe(":Set()", function()
        it("sets the value of any given key", function()
            state:Set("Players", "People")
            expect(state:Get("Players")).to.equal("People")
        end)
    end)

    describe(":Delete()", function()
        it("removes a key from the state", function()
            state:Delete("Players")
            expect(state:Get("Players")).to.equal(nil)
        end)
    end)

    describe(":GetState()", function()
        it("returns the current state table", function()
            local getState = state:GetState()

            expect(getState.Hello).to.equal(DEMO_STATE.Hello)
            expect(getState.Number).to.equal(DEMO_STATE.Number)
            expect(getState.Boolean).to.equal(DEMO_STATE.Boolean)
            expect(getState.Colour).to.equal(DEMO_STATE.Colour)
        end)
    end)

    describe(":SetState()", function()
        it("updates mutliple keys at once", function()
            state:SetState({
                Hello = "Metaverse",
                Banana = false,
            })

            expect(state:Get("Hello")).to.equal("Metaverse")
            expect(state:Get("Banana")).to.equal(false)
        end)

        it("accepts a callback for setting state", function()
            local state = BasicState.new(DEMO_STATE)

            state:SetState(function(state)
                if state.Hello == "World" then
                    state.Hello = "Metaverse"
                end

                state.Banana = false

                return state
            end)

            expect(state:Get("Hello")).to.equal("Metaverse")
            expect(state:Get("Banana")).to.equal(false)
        end)
    end)

    describe(":Toggle()", function()
        it("toggles the value of a stored boolean", function()
            state:Toggle("Boolean")

            expect(state:Get("Boolean")).to.equal(false)
        end)
    end)

    describe(":Increment()", function()
        it("increments a numeric key by 1", function()
            state:Increment("Number")

            expect(state:Get("Number")).to.equal(11)
        end)

        it("increments a numeric key by 2", function()
            state:Increment("Number", 2)

            expect(state:Get("Number")).to.equal(13)
        end)
    end)

    describe(":Decrement()", function()
        it("decrements a numeric key by 1", function()
            state:Decrement("Number")

            expect(state:Get("Number")).to.equal(12)
        end)

        it("decrements a numeric key by 2", function()
            state:Decrement("Number", 2)

            expect(state:Get("Number")).to.equal(10)
        end)
    end)

    describe(":RawSet()", function()
        it("sets the value of a key without firing events", function()
            local changedFired = false
            local changedSignal = state.Changed:Connect(function()
                changedFired = true
            end)

            state:RawSet("Roblox", "Metaverse")

            expect(state:Get("Roblox")).to.equal("Metaverse")
            expect(changedFired).to.equal(false)

            changedSignal:Disconnect()
        end)
    end)

    describe(":GetChangedSignal()", function()
        local testKey = "Roblox"

        local signal = nil
        local connection = nil

        local fired = 0

        it("returns an RBXScriptSignal for any key", function()
            signal = state:GetChangedSignal(testKey)
            connection = signal:Connect(function()
                fired += 1
            end)

            expect(typeof(signal)).to.equal("RBXScriptSignal")
            expect(typeof(connection)).to.equal("RBXScriptConnection")
        end)

        it("fires when the key is updated via :Set()", function()
            state:Set(testKey, "Experience")

            expect(state:Get(testKey)).to.equal("Experience")
            expect(fired).to.equal(1)
        end)

        it("fires when the key is updated via :SetState()", function()
            state:SetState({
                [testKey] = "Bobux",
            })

            expect(state:Get(testKey)).to.equal("Bobux")
            expect(fired).to.equal(2)
        end)

        afterAll(function()
            if connection then
                connection:Disconnect()
            end
        end)
    end)

    describe(":Roact()", function()
        it("wraps Roact components with state", function()
            local responseEvent = Instance.new("BindableEvent")
            local component = Roact.Component:extend("test-component")

            function component:didMount()
                expect(self.state.Hello).to.equal("Metaverse")
            end

            function component:render()
                return nil
            end

            local testTree = Roact.mount(
                Roact.createElement(
                    state:Roact(component, { "Hello" })
                ),
                nil,
                "test-tree"
            )

            responseEvent.Event:Connect(function()
                Roact.unmount(testTree)
                responseEvent:Destroy()
            end)
        end)
    end)

    describe(".Changed", function()
        it("responds to state changes", function()
            state.Changed:Connect(function(_, key)
                expect(key).to.equal("Roblox")
            end)

            state:Set("Roblox", "Oof")
        end)
    end)

    describe(".ProtectType", function()
        it("prevents incorrect types from being specified", function()
            state.ProtectType = true

            expect(pcall(state.Set, state, "Number", true)).to.equal(false)
            expect(pcall(state.SetState, state, { Number = true })).to.equal(false)
            expect(pcall(state.Set, state, "Number", 1)).to.equal(true)
        end)
    end)

    describe(":Reset()", function()
        it("resets state back to its initial value(s)", function()
            local state = BasicState.new(DEMO_STATE)

            state:Set("Hello", "David")

            expect(state:Get("Hello")).to.equal("David")

            state:Reset()

            expect(state:Get("Hello")).to.equal(DEMO_STATE.Hello)
        end)
    end)

    describe(":Destroy()", function()
        it("obiliterates the state instance", function()
            state:Destroy()

            local count = 0

            for _, _ in pairs(state.__state) do
                count += 1
            end

            expect(count).to.equal(0)
        end)
    end)
end
