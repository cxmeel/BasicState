local TestService = game:GetService("TestService")

local Roact = require(TestService.Packages.Roact)
local BasicState = require(script.Parent)

local DEMO_STATE = {
  Hello = "World",
  Number = 42,
  Boolean = true,
  Colour = Color3.fromHex("#00a2ff"),
  Table = {
    Dave = "Roblox",
  },
}

local function NewState()
  return BasicState.new(DEMO_STATE)
end

return function()
  describe("Constructor (.new())", function()
    it("should create a new BasicState", function()
      expect(NewState()).to.be.ok()
    end)
  end)

  describe(":Get()", function()
    it("should return the value of a given key", function()
      local state = NewState()
      expect(state:Get("Hello")).to.equal(DEMO_STATE.Hello)
    end)

    it("returns a default value for a missing key", function()
      local state = NewState()
      expect(state:Get("Missing", "Default")).to.equal("Default")
    end)
  end)

  describe(":Set()", function()
    it("should set the value of a given key", function()
      local state = NewState()

      state:Set("Hello", "Dave")

      expect(state:Get("Hello")).to.equal("Dave")
    end)
  end)

  describe(":Delete()", function()
    it("should delete the value of a given key", function()
      local state = NewState()

      state:Delete("Hello")

      expect(state:Get("Hello")).to.equal(nil)
    end)
  end)

  describe(":GetState()", function()
    it("should return all values", function()
      local state = NewState()

      for key, value in pairs(DEMO_STATE) do
        if key == "Table" then
          expect(state:GetState()[key]).to.be.a("table")
          expect(state:GetState()[key].Dave).to.equal(DEMO_STATE.Table.Dave)

          continue
        end

        expect(state:GetState()[key]).to.equal(value)
      end
    end)
  end)

  describe(":SetState()", function()
    it("should merge all given values", function()
      local state = NewState()

      state:SetState({
        Colour = Color3.fromHex("#ffa200"),
        Table = {
          Banana = "Yellow",
        },
      })

      expect(state:Get("Hello")).to.equal(DEMO_STATE.Hello)
      expect(state:Get("Colour")).to.equal(Color3.fromHex("#ffa200"))
      expect(state:Get("Table").Banana).to.equal("Yellow")
    end)

    it("accepts a callback for setting state", function()
      local state = NewState()

      local function setter(isCute: boolean)
        return function(state)
          if isCute then
            state.Cat = "Meow"
          end

          return state
        end
      end

      state:SetState(setter(false))
      expect(state:Get("Cat")).to.equal(nil)

      state:SetState(setter(true))
      expect(state:Get("Cat")).to.equal("Meow")
    end)
  end)

  describe(":Toggle()", function()
    it("should toggle the value of a given key", function()
      local state = NewState()

      state:Toggle("Boolean")

      expect(state:Get("Boolean")).to.equal(false)
    end)
  end)

  describe(":Increment()", function()
    it("should increment the value of a given key", function()
      local state = NewState()

      state:Increment("Number")

      expect(state:Get("Number")).to.equal(43)
    end)

    it("should increment the value of a given key by a given amount", function()
      local state = NewState()

      state:Increment("Number", 2)

      expect(state:Get("Number")).to.equal(44)
    end)
  end)

  describe(":Decrement()", function()
    it("should decrement the value of a given key", function()
      local state = NewState()

      state:Decrement("Number")

      expect(state:Get("Number")).to.equal(41)
    end)

    it("should decrement the value of a given key by a given amount", function()
      local state = NewState()

      state:Decrement("Number", 2)

      expect(state:Get("Number")).to.equal(40)
    end)
  end)

  describe(":RawSet()", function()
    it("sets the value of a given key without firing events", function()
      local state = NewState()

      local changedFired = false
      local changedSignal = state.Changed:Connect(function()
        changedFired = true
      end)

      state:RawSet("Hello", "Dave")

      expect(state:Get("Hello")).to.equal("Dave")
      expect(changedFired).to.equal(false)

      changedSignal:Disconnect()
    end)
  end)

  describe(":GetChangedSignal()", function()
    it("returns a signal for any key", function()
      local state = NewState()

      local signal = state:GetChangedSignal("Shrek")
      local fired = false

      local connection = signal:Connect(function()
        fired = true
      end)

      state:Set("Shrek", "Fiona")
      connection:Disconnect()

      expect(fired).to.equal(true)
    end)
  end)

  describe(":Roact()", function()
    it("wraps a Roact component with the state", function()
      local state = NewState()

      local component = Roact.Component:extend("Component")

      function component:render()
        return nil
      end

      function component:didMount()
        expect(self.state.Hello).to.equal(DEMO_STATE.Hello)
      end

      local element = Roact.createElement(state:Roact(component))
      local instance = Roact.mount(element, nil)

      state:Set("Hello", "Dave")

      afterAll(function()
        Roact.unmount(instance)
      end)
    end)

    it("updates Roact components when state changes", function()
      local state = NewState()

      local component = Roact.Component:extend("Component")

      function component:render()
        return nil
      end

      function component:didUpdate()
        expect(self.state.Hello).to.equal("Dave")
      end

      local element = Roact.createElement(state:Roact(component))
      local instance = Roact.mount(element, nil)

      state:Set("Hello", "Dave")

      afterAll(function()
        Roact.unmount(instance)
      end)
    end)
  end)

  describe(".Changed", function()
    it("fires when state changes", function()
      local state = NewState()

      local signal = state.Changed:Connect(function()
        expect(state:Get("Hello")).to.equal("Dave")
      end)

      state:Set("Hello", "Dave")

      signal:Disconnect()
    end)
  end)

  describe(".ProtectType", function()
    it("prevents setting a key to an incorrect type", function()
      local state = NewState()

      state.ProtectType = true

      expect(function()
        state:Set("Hello", true)
      end).to.throw()

      expect(function()
        state:Set("Hello", "Dave")
      end).to.be.ok()
    end)
  end)

  describe(":Reset()", function()
    it("resets the state to the default values", function()
      local state = NewState()

      state:Set("Hello", "Dave")
      state:Reset()

      for key, value in pairs(DEMO_STATE) do
        if key == "Table" then
          expect(state:GetState()[key]).to.be.a("table")
          expect(state:GetState()[key].Dave).to.equal(DEMO_STATE.Table.Dave)

          continue
        end

        expect(state:GetState()[key]).to.equal(value)
      end
    end)
  end)
end
