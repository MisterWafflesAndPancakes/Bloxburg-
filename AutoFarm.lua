-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create Window + Tab
local Window = Rayfield:CreateWindow({
    Name = "RO-BOXING Stat checker",
    LoadingTitle = "RO-BOXING Stat checker",
    LoadingSubtitle = "Made by Mister Waffles",
    ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("Stats", 4483362458)

-- Input for player name
local inputText = nil
Tab:CreateInput({
    Name = "Player Username / Display Name",
    PlaceholderText = "Enter part of a name...",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        inputText = text:lower()
    end
})

-- Labels for each stat
local statLabels = {}
local categories = {"Endurance","Speed","Accuracy","Fitness","Strength"}

for _,cat in ipairs(categories) do
    statLabels[cat] = Tab:CreateLabel(cat..": (no data)")
end

-- Helper: find player by username, display name, or partial
local function findMatchingPlayer(query)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr.Name:lower():find(query, 1, true) or plr.DisplayName:lower():find(query, 1, true) then
            return plr
        end
    end
    return nil
end

-- Button to fetch and bind stats
Tab:CreateButton({
    Name = "Check Stats",
    Callback = function()
        if not inputText or inputText == "" then
            return
        end

        local target = findMatchingPlayer(inputText)
        if not target then
            for _,cat in ipairs(categories) do
                statLabels[cat]:Set(cat..": player not found")
            end
            return
        end

        local playerInfo = workspace:WaitForChild("Player_Information"):FindFirstChild(target.Name)
        if not playerInfo then
            for _,cat in ipairs(categories) do
                statLabels[cat]:Set(cat..": no stats found")
            end
            return
        end

        local statsFolder = playerInfo:WaitForChild("Stats")

        for _,cat in ipairs(categories) do
            local folder = statsFolder:FindFirstChild(cat)
            if folder then
                local level = folder:WaitForChild("Level")
                local xp = folder:WaitForChild("XP")

                -- Set initial label text
                statLabels[cat]:Set(cat.." → Level: "..level.Value.." | XP: "..xp.Value)

                -- Update on changes
                level.Changed:Connect(function()
                    statLabels[cat]:Set(cat.." → Level: "..level.Value.." | XP: "..xp.Value)
                end)
                xp.Changed:Connect(function()
                    statLabels[cat]:Set(cat.." → Level: "..level.Value.." | XP: "..xp.Value)
                end)
            else
                statLabels[cat]:Set(cat..": missing")
            end
        end
    end
})
