if not game:IsLoaded() then game.Loaded:Wait() end

local services = setmetatable({}, {__index = function(t, k)
    local service = game:GetService(k)
    t[k] = service
    return service
end})

local Players = services.Players
local RunService = services.RunService
local ReplicatedStorage = services.ReplicatedStorage
local VirtualUser = services.VirtualUser
local CoreGui = services.CoreGui

local localPlayer = Players.LocalPlayer
local localChar = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local localHumanoid = localChar:FindFirstChildOfClass("Humanoid")

local Connections = {} do
    function Connections:Add(obj, event, func)
        local conn = obj[event]:Connect(func)
        self[conn] = conn
    end

    function Connections:Remove(conn)
        conn:Disconnect()
        self[conn] = nil
    end

    function Connections:Destroy()
        for conn in pairs(self) do
            conn:Disconnect()
            self[conn] = nil
        end
    end

    function Connections:Connect(obj, events, forcecall)
        for event, callback in pairs(events) do
            self:Add(obj, event, callback)
        end

        if not forcecall then
            return
        end

        forcecall()
    end
end

local Utils = {} do
    function Utils.onCharAdded(char)
        localChar = char
        localHumanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
    end
end

for _, connection in next, getconnections(localPlayer.Idled) do
    connection:Disable()
end

localPlayer.CharacterAdded:Connect(function(newC)
    Utils.onCharAdded(newC)
end)

local GameData = {

}

-- cleanup of before UIs created
for _, v in next, CoreGui:GetChildren() do
    if not v.Name:find('Vynixius') then continue end
    v:Destroy()
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RegularVynixu/UI-Libraries/main/Vynixius/Source.lua"))()

local Window = Library:AddWindow({
	title = {"Zyra", "Pet Simulator 99"},
	theme = {
		Accent = Color3.fromRGB(114, 189, 207)
	},
	key = Enum.KeyCode.RightControl,
	default = true
})
