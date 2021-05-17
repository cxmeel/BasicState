local Replicated = game:GetService("ReplicatedStorage")
local TestEZ = require(Replicated.Packages.TestEZ)

TestEZ.TestBootstrap:run({
    Replicated.BasicState,
})
