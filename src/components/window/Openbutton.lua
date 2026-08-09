local Openbutton = {}
-- ============================================================
-- Open Button (ลากได้ทุกที่)
-- ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

-- ลบของเก่าถ้ามี
if Player.PlayerGui:FindFirstChild("PumpkitzOpenButton") then
    Player.PlayerGui.PumpkitzOpenButton:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PumpkitzOpenButton"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.fromOffset(40, 40)
OpenButton.Position = UDim2.fromOffset(15, 120)
OpenButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
OpenButton.BorderSizePixel = 0
OpenButton.AutoButtonColor = true
OpenButton.Image = "rbxassetid://75519083960535"
OpenButton.ZIndex = 999999
OpenButton.Visible = true
OpenButton.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = OpenButton

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(255, 140, 0)
Stroke.Thickness = 2
Stroke.Parent = OpenButton

-- ============================================================
-- Drag System (ลากได้ทุกที่ ไม่มีขีดจำกัด)
-- ============================================================

local dragging = false
local dragInput = nil
local dragStart
local startPos
local moved = false

OpenButton.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.Touch
    and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    dragging = true
    dragInput = input
    dragStart = input.Position
    startPos = OpenButton.Position
    moved = false
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input ~= dragInput then
        return
    end

    local delta = input.Position - dragStart

    if delta.Magnitude > 8 then
        moved = true
    end

    -- ลบ math.clamp ออก เพื่อให้ลากไปได้ทุกที่
    local newX = startPos.X.Offset + delta.X
    local newY = startPos.Y.Offset + delta.Y

    OpenButton.Position = UDim2.fromOffset(newX, newY)
end)

UserInputService.InputEnded:Connect(function(input)
    if input ~= dragInput then
        return
    end

    dragging = false
    dragInput = nil

    if not moved then
        pcall(function()
            Window:Open()
        end)

        OpenButton.Visible = false
    end
end)

-- ============================================================
-- แสดงปุ่มอีกครั้งเมื่อ GUI ถูกปิด
-- ============================================================

task.spawn(function()
    while task.wait(0.2) do
        local visible = false

        pcall(function()
            visible = Window.Visible
        end)

        if not visible then
            OpenButton.Visible = true
        end
    end
end)


-- ============================================================
-- Emergency Fix
-- ============================================================
_G.FixButton = function()
    if OpenButton then
        OpenButton.Visible = true
        print("✅ OpenButton ถูกกู้คืนแล้ว!")
    end
end
