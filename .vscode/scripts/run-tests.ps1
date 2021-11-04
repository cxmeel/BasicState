foreman install
rojo build .\test.project.json -o .\test-place.rbxlx
run-in-roblox --place .\test-place.rbxlx --script .\test-runner.server.lua
Remove-Item -Force .\test-place.rbxlx
