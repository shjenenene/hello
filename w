-- UI Library Module
local Library = {}
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

Library.Windows = {}
Library.Toggles = {}

local function createGradient(inst)
    local g = Instance.new("UIGradient", inst)
    g.Rotation = 90
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.6)
    })
    g.Color = ColorSequence.new(
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(220, 220, 220)
    )
    return g
end

function Library:CreateWindow(opts)
    local gui = Instance.new("ScreenGui")
    gui.Name = opts.Title or "Window"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame", gui)
    frame.Size = opts.Size or UDim2.new(0, 400, 0, 300)
    frame.Position = (opts.Center and UDim2.new(0.5, -(frame.Size.X.Offset/2), 0.5, -frame.Size.Y.Offset/2)) or (opts.Position or UDim2.new(0, 50, 0, 50))
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0

    local dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                   startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
            update(input)
        end
    end)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 1
    stroke.Transparency = 0.4

    createGradient(frame)

    local shine = Instance.new("Frame", frame)
    shine.Size = UDim2.new(1, 0, 0, 2)
    shine.Position = UDim2.new(0, 0, 0, 0)
    shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shine.BackgroundTransparency = 0.9
    shine.BorderSizePixel = 0

    local tabBar = Instance.new("Frame", frame)
    tabBar.Size = UDim2.new(1, 0, 0, 30)
    tabBar.Position = UDim2.new(0, 0, 0, 0)
    tabBar.BackgroundTransparency = 1

    local win = { Frame = frame, Tabs = {} }
    Library.Windows[gui] = win

    function win:AddTab(name)
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(0, 100, 1, 0)
        btn.Position = UDim2.new(#win.Tabs * 0.15, 0, 0, 0)
        btn.Text = name
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 16
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.BackgroundTransparency = 1
        btn.AutoButtonColor = false

        local page = Instance.new("Frame", frame)
        page.Size = UDim2.new(1, 0, 1, -30)
        page.Position = UDim2.new(0, 0, 0, 30)
        page.BackgroundTransparency = 1
        page.Visible = false

        btn.Activated:Connect(function()
            for _, t in ipairs(win.Tabs) do
                t.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
                t.Page.Visible = false
            end
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            page.Visible = true
        end)
        table.insert(win.Tabs, { Button = btn, Page = page })
        if #win.Tabs == 1 then btn:Activate() end

        return setmetatable({ Page = page }, { __index = function(_, k)
            if k == "AddGroupbox" then
                return function(_, title)
                    local gb = Instance.new("Frame", page)
                    gb.Size = UDim2.new(0, frame.Size.X.Offset/2 - 20, 0, 200)
                    gb.Position = UDim2.new(0, 10, 0, 40 + (#page:GetChildren() - 1) * 210)
                    gb.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    gb.BorderSizePixel = 0

                    local hdr = Instance.new("TextLabel", gb)
                    hdr.Size = UDim2.new(1, 0, 0, 24)
                    hdr.Position = UDim2.new(0, 0, 0, 0)
                    hdr.BackgroundTransparency = 1
                    hdr.Font = Enum.Font.GothamBold
                    hdr.TextSize = 16
                    hdr.TextColor3 = Color3.fromRGB(255, 255, 255)
                    hdr.Text = title

                    local container = Instance.new("Frame", gb)
                    container.Size = UDim2.new(1, -10, 1, -34)
                    container.Position = UDim2.new(0, 5, 0, 30)
                    container.BackgroundTransparency = 1

                    return setmetatable({ Frame = container }, { __index = function(_, m)
                        if m == "AddToggle" then
                            return function(_, id, opts)
                                local tbtn = Instance.new("TextButton", container)
                                tbtn.Size = UDim2.new(1, 0, 0, 24)
                                tbtn.Position = UDim2.new(0, 0, 0, #container:GetChildren() * 26)
                                tbtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                                tbtn.BorderSizePixel = 0
                                tbtn.Font = Enum.Font.GothamBold
                                tbtn.TextSize = 16
                                tbtn.TextXAlignment = Enum.TextXAlignment.Left
                                tbtn.Text = opts.Text or id
                                local state = opts.Default or false
                                local listeners = {}
                                function tbtn:Update(v)
                                    state = v
                                    tbtn.TextColor3 = v and Color3.fromRGB(120, 255, 120) or Color3.fromRGB(255, 100, 100)
                                    for _, f in ipairs(listeners) do f(state) end
                                end
                                function tbtn:OnChanged(f) table.insert(listeners, f) end
                                tbtn.Activated:Connect(function()
                                    tbtn:Update(not state)
                                    if opts.Callback then opts.Callback(state) end
                                end)
                                tbtn:Update(state)
                                Library.Toggles[id] = tbtn
                                return tbtn
                            end
                        elseif m == "AddButton" then
                            return function(_, opts)
                                local bbtn = Instance.new("TextButton", container)
                                bbtn.Size = UDim2.new(1, 0, 0, 24)
                                bbtn.Position = UDim2.new(0, 0, 0, #container:GetChildren() * 26)
                                bbtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                                bbtn.BorderSizePixel = 0
                                bbtn.Font = Enum.Font.GothamBold
                                bbtn.TextSize = 16
                                bbtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                                bbtn.Text = opts.Text or "Button"
                                bbtn.Activated:Connect(function() if opts.Func then opts.Func() end end)
                                return bbtn
                            end
                        end
                    end })
                end
            elseif k == "AddLabel" then
                return function(_, txt)
                    local lbl = Instance.new("TextLabel", page)
                    lbl.Size = UDim2.new(1, 0, 0, 24)
                    lbl.Position = UDim2.new(0, 10, 0, #page:GetChildren() * 26)
                    lbl.BackgroundTransparency = 1
                    lbl.Font = Enum.Font.Gotham
                    lbl.TextSize = 16
                    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
                    lbl.Text = txt
                    return lbl
                end
            end
        end })
    end

    return win
end

return Library
