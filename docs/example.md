## Tab Highlighting
This is a direct extract from the avatar editor UI controller in Bloxikins World. BasicState is being used to control which tab is currently in focus and which asset category to display to players.

```lua
-- Reference the tab buttons UI container
local Tabs = script.Parent.TabButtons

-- Create a new BasicState object with the category preset to "HAT"
local State = BasicState.new({
	Category = "HAT"
})

-- Update the tabs when the "Category" property changes
State:GetChangedSignal("Category"):Connect(function(NewCategory)
    -- Iterate through each tab button in the container
    for _, TabButton in next, Tabs:GetChildren() do
        -- Ignore any UI elements which are not ImageButtons
        if not TabButton:IsA("ImageButton") then continue end

        -- If the TabButton's Name matches the new value of Category, then it should
        -- be selected
		local Selected = TabButton.Name == NewCategory

        -- If Selected == true, set the button to yellow; otherwise make it white
		TabButton.ImageColor3 = Selected and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(235, 235, 235)
    end

    --[[
        This function has been truncated for the sake of this example.
        The full source code for this method also updates the displayed
        assets in the avatar editor UI.
    --]]
end)

-- Iterate through the children of the TabButton container
for _, TabButton in next, Tabs:GetChildren() do
    -- Ignore Instances which are not ImageButtons
    if not TabButton:IsA("ImageButton") then continue end

    -- If the TabButton's Name is not uppercase, then ignore it
	if TabButton.Name ~= TabButton.Name:upper() then continue end

    -- Listen for taps and clicks on the TabButton
    TabButton.MouseButton1Click:Connect(function()
        -- Set Category to the name of TabButton on click
		State:Set("Category", TabButton.Name)
	end)
end
```
