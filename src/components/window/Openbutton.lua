local OpenButton = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local cloneref = (cloneref or clonereference or function(instance) return instance end)

local UserInputService = cloneref(game:GetService("UserInputService"))

function OpenButton.New(Window)
    local OpenButtonMain = {
        Button = nil
    }
    
    local Icon
    
    -- Icon = New("ImageLabel", {
    --     Image = "",
    --     Size = UDim2.new(0,22,0,22),
    --     Position = UDim2.new(0.5,0,0.5,0),
    --     LayoutOrder = -1,
    --     AnchorPoint = Vector2.new(0.5,0.5),
    --     BackgroundTransparency = 1,
    --     Name = "Icon"
    -- })

    local Title = New("TextLabel", {
        Text = Window.Title,
        TextSize = 17,
        FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
        BackgroundTransparency = 1,
        AutomaticSize = "XY",
        TextColor3 = Color3.new(1,1,1), -- เพิ่มสีข้อความขาว
    })

    local Drag = New("Frame", {
        Size = UDim2.new(0,44-8,0,44-8),
        BackgroundTransparency = 1, 
        Name = "Drag",
    }, {
        New("ImageLabel", {
            Image = Creator.Icon("move")[1],
            ImageRectOffset = Creator.Icon("move")[2].ImageRectPosition,
            ImageRectSize = Creator.Icon("move")[2].ImageRectSize,
            Size = UDim2.new(0,18,0,18),
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            ThemeTag = {
                ImageColor3 = "Icon",
            },
            ImageTransparency = .3,
        })
    })
    local Divider = New("Frame", {
        Size = UDim2.new(0,1,1,0),
        Position = UDim2.new(0,20+16,0.5,0),
        AnchorPoint = Vector2.new(0,0.5),
        BackgroundColor3 = Color3.new(1,1,1),
        BackgroundTransparency = .9,
    })

    local Container = New("Frame", {
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0,6+44/2),
        AnchorPoint = Vector2.new(0.5,0.5),
        Parent = Window.Parent,
        BackgroundTransparency = 1,
        Active = true,
        Visible = false,
    })

    local UIScale = New("UIScale", {
        Scale = 1,
    })

    -- ปรับแต่งเป็น Square สีดำ ขอบมน Outline สีขาว
    local Button = New("Frame", {
        Size = UDim2.new(0,0,0,44),
        AutomaticSize = "X",
        Parent = Container,
        Active = false,
        BackgroundTransparency = 0, -- ทำให้ทึบ
        ZIndex = 99,
        BackgroundColor3 = Color3.new(0,0,0), -- สีดำ
    }, {
        UIScale,
        New("UICorner", {
            CornerRadius = UDim.new(0, 12) -- ขอบมน
        }),
        New("UIStroke", {
            Thickness = 2,
            ApplyStrokeMode = "Border",
            Color = Color3.new(1,1,1), -- สีขาว
            Transparency = 0,
        }),
        Drag,
        Divider,
        
        New("UIListLayout", {
            Padding = UDim.new(0, 4),
            FillDirection = "Horizontal",
            VerticalAlignment = "Center",
        }),
        
        New("TextButton",{
            AutomaticSize = "XY",
            Active = true,
            BackgroundTransparency = 1, -- .93
            Size = UDim2.new(0,0,0,44-(4*2)),
            --Position = UDim2.new(0,20+16+16+1,0,0),
            BackgroundColor3 = Color3.new(1,1,1),
        }, {
            New("UICorner", {
                CornerRadius = UDim.new(0, 8)
            }),
            Icon,
            New("UIListLayout", {
                Padding = UDim.new(0, Window.UIPadding),
                FillDirection = "Horizontal",
                VerticalAlignment = "Center",
            }),
            Title,
            New("UIPadding", {
                PaddingLeft = UDim.new(0,7+4),
                PaddingRight = UDim.new(0,7+4),
            }),
        }),
        New("UIPadding", {
            PaddingLeft = UDim.new(0,4),
            PaddingRight = UDim.new(0,4),
        })
    })
    
    OpenButtonMain.Button = Button
    
    function OpenButtonMain:SetIcon(newIcon)
        if Icon then
            Icon:Destroy()
        end
        if newIcon then
            Icon = Creator.Image(
                newIcon,
                Window.Title,
                0,
                Window.Folder,
                "OpenButton",
                true,
                Window.IconThemed
            )
            Icon.Size = UDim2.new(0,22,0,22)
            Icon.LayoutOrder = -1
            Icon.Parent = OpenButtonMain.Button.TextButton
        end
    end
    
    if Window.Icon then
        OpenButtonMain:SetIcon(Window.Icon)
    end
    
    Creator.AddSignal(Button:GetPropertyChangedSignal("AbsoluteSize"), function()
        Container.Size = UDim2.new(
            0, Button.AbsoluteSize.X,
            0, Button.AbsoluteSize.Y
        )
    end)
    
    Creator.AddSignal(Button.TextButton.MouseEnter, function()
        Tween(Button.TextButton, .1, {BackgroundTransparency = .93}):Play()
    end)
    Creator.AddSignal(Button.TextButton.MouseLeave, function()
        Tween(Button.TextButton, .1, {BackgroundTransparency = 1}):Play()
    end)
    
    local DragModule = Creator.Drag(Container)
    
    -- เพิ่มระบบลากสำหรับมือถือ โดยไม่กระทบระบบเดิม
    local touchData = {
        isDragging = false,
        dragStart = nil,
        startPos = nil,
        connection = nil
    }
    
    -- สร้างฟังก์ชันสำหรับจัดการการลากบนมือถือ
    local function setupMobileDrag()
        -- เช็คว่ามี Container และใช้งานได้
        if not Container then return end
        
        -- Event สำหรับเริ่มลาก
        local beganConnection = Container.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                touchData.isDragging = true
                touchData.dragStart = input.Position
                touchData.startPos = Container.Position
            end
        end)
        
        -- Event สำหรับเปลี่ยนแปลงตำแหน่ง
        local changedConnection = UserInputService.InputChanged:Connect(function(input)
            if touchData.isDragging and input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - touchData.dragStart
                local newPos = UDim2.new(
                    touchData.startPos.X.Scale,
                    touchData.startPos.X.Offset + delta.X,
                    touchData.startPos.Y.Scale,
                    touchData.startPos.Y.Offset + delta.Y
                )
                Container.Position = newPos
            end
        end)
        
        -- Event สำหรับสิ้นสุดการลาก
        local endedConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                touchData.isDragging = false
                touchData.dragStart = nil
                touchData.startPos = nil
            end
        end)
        
        -- เก็บ connections เพื่อใช้ในการ cleanup
        touchData.connection = {
            began = beganConnection,
            changed = changedConnection,
            ended = endedConnection
        }
    end
    
    -- เรียกใช้ระบบลากสำหรับมือถือ
    setupMobileDrag()
    
    function OpenButtonMain:Visible(v)
        Container.Visible = v
    end
    
    function OpenButtonMain:SetScale(scale)
        UIScale.Scale = scale
    end
    
    function OpenButtonMain:Edit(OpenButtonConfig)
        local OpenButtonModule = {
            Title = OpenButtonConfig.Title,
            Icon = OpenButtonConfig.Icon,
            Enabled = OpenButtonConfig.Enabled,
            Position = OpenButtonConfig.Position,
            OnlyIcon = OpenButtonConfig.OnlyIcon or false,
            Draggable = OpenButtonConfig.Draggable or nil,
            OnlyMobile = OpenButtonConfig.OnlyMobile,
            CornerRadius = OpenButtonConfig.CornerRadius or UDim.new(0, 12),
            StrokeThickness = OpenButtonConfig.StrokeThickness or 2,
            Scale = OpenButtonConfig.Scale or 1,
            Color = OpenButtonConfig.Color 
                or ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
        }
        
        if OpenButtonModule.Enabled == false then
            Window.IsOpenButtonEnabled = false
        end
        
        if OpenButtonModule.OnlyMobile ~= false then
            OpenButtonModule.OnlyMobile = true
        else
            Window.IsPC = false
        end
        
        if OpenButtonModule.Draggable == false and Drag and Divider then
            Drag.Visible = OpenButtonModule.Draggable
            Divider.Visible = OpenButtonModule.Draggable
            
            if DragModule then
                DragModule:Set(OpenButtonModule.Draggable)
            end
        end
        
        if OpenButtonModule.Position and Container then
            Container.Position = OpenButtonModule.Position
        end
        
        if OpenButtonModule.OnlyIcon == true and Title then
            Title.Visible = false
            Button.TextButton.UIPadding.PaddingLeft = UDim.new(0,7)
            Button.TextButton.UIPadding.PaddingRight = UDim.new(0,7)
        elseif OpenButtonModule.OnlyIcon == false then
            Title.Visible = true
            Button.TextButton.UIPadding.PaddingLeft = UDim.new(0,7+4)
            Button.TextButton.UIPadding.PaddingRight = UDim.new(0,7+4)
        end
        
        if Title then
            if OpenButtonModule.Title then
                Title.Text = OpenButtonModule.Title
                Creator:ChangeTranslationKey(Title, OpenButtonModule.Title)
            elseif OpenButtonModule.Title == nil then
                --Title.Visible = false
            end
        end
        
        if OpenButtonModule.Icon then
            OpenButtonMain:SetIcon(OpenButtonModule.Icon)
        end

        -- ใช้สี Gradient จาก config (แต่ไม่ใช้กับพื้นหลังสีดำ)
        if Glow then
            Glow.UIGradient.Color = OpenButtonModule.Color
        end

        -- ตั้งค่า Corner Radius แบบ Square
        Button.UICorner.CornerRadius = OpenButtonModule.CornerRadius
        Button.TextButton.UICorner.CornerRadius = UDim.new(
            OpenButtonModule.CornerRadius.Scale, 
            math.max(0, OpenButtonModule.CornerRadius.Offset - 4)
        )
        Button.UIStroke.Thickness = OpenButtonModule.StrokeThickness
        
        OpenButtonMain:SetScale(OpenButtonModule.Scale)
    end

    return OpenButtonMain
end

return OpenButton
