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

local GameData = {
    Zones = {
        ['Early Game'] = ReplicatedStorage["__DIRECTORY"].Zones['Early Game'],
        ['Mid Game'] = ReplicatedStorage["__DIRECTORY"].Zones['Mid Game'],
        ['End Game'] = ReplicatedStorage["__DIRECTORY"].Zones['End Game']
    },

}

local Utils = {} do
    function Utils.onCharAdded(char)
        localChar = char
        localHumanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
    end

    function Utils.getZones()
        local zones = {}
        for _, zone in pairs(GameData.Zones) do
            for _, child in ipairs(zone:GetChildren()) do
                local name = child.Name

                local number = tonumber(name:match("%d+"))
                if not number then continue end

                table.insert(zones, {name = name, number = number})
            end
        end

        table.sort(zones, function(a, b)
            return a.number < b.number
        end)

        local zoneNames = {}
        for _, zone in ipairs(zones) do
            table.insert(zoneNames, zone.name)
        end

        return zoneNames
    end
end

for _, connection in next, getconnections(localPlayer.Idled) do
    connection:Disable()
end

localPlayer.CharacterAdded:Connect(function(newC)
    Utils.onCharAdded(newC)
end)

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

local Settings = {}

local Tabs = {}
Tabs.Main = Window:AddTab("Main", {default = true}) 
do
    local AutoFarm = Tabs.Main:AddSection("Auto Farm", {default = true})
    do
        AutoFarm:AddDropdown("Zones", Utils.getZones(), {default = "1 | Spawn"}, function(value)
            Settings.SelectedZone = value
        end)


    end
end