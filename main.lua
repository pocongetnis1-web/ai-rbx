
-- ============================================================
-- main.lua - Google PNG Gallery v2.0 (Mobile-Optimized)
-- Features:
--   ✅ Resizable (drag bottom-right corner)
--   ✅ Minimizable (tap header to collapse)
--   ✅ Draggable (move anywhere on screen)
--   ✅ Mobile-friendly touch controls
--   ✅ Gstatic PNG scraper
--   ✅ Click URL to copy to clipboard (mobile-compatible)
-- ============================================================

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local ClipboardService = game:GetService("ClipboardService") -- Roblox has this now

-- ===== CONFIG =====
local DEFAULT_QUERY = "kucing lucu"
local MAX_IMAGES = 20
local GRID_COLUMNS = 3 -- mobile-friendly: 3 columns

-- ===== CREATE MAIN GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PNGGallery"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- ===== MAIN FRAME (resizable) =====
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 480) -- mobile-friendly default
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(60, 60, 80)
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- ===== MAKE DRAGGABLE =====
local function makeDraggable(frame)
    local dragging = false
    local dragStartPos, dragStartMouse
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if input.UserInputType == Enum.UserInputType.Touch then
                -- Only drag if not touching a button or textbox
                local target = input.Position
                local hit = game:GetService("GuiService"):GetGuiObjectAtPosition(target)
                if hit and (hit:IsA("TextButton") or hit:IsA("TextBox") or hit:IsA("ImageButton")) then
                    return
                end
            end
            dragging = true
            dragStartPos = frame.Position
            dragStartMouse = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStartMouse
            local newPos = UDim2.new(
                dragStartPos.X.Scale,
                dragStartPos.X.Offset + delta.X,
                dragStartPos.Y.Scale,
                dragStartPos.Y.Offset + delta.Y
            )
            frame.Position = newPos
        end
    end)
end

makeDraggable(MainFrame)

-- ===== HEADER (minimize toggle) =====
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(1, -60, 1, 0)
HeaderLabel.Position = UDim2.new(0, 10, 0, 0)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "🔍 PNG Gallery"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.Font = Enum.Font.SourceSansBold
HeaderLabel.TextSize = 18
HeaderLabel.Parent = Header

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Position = UDim2.new(1, -45, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "➖"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.SourceSans
MinBtn.TextSize = 24
MinBtn.Parent = Header

local isMinimized = false
local fullHeight = 480
local minHeight = 40

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 350, 0, minHeight)
        MinBtn.Text = "➕"
        SearchBox.Visible = false
        SearchBtn.Visible = false
        ScrollFrame.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 350, 0, fullHeight)
        MinBtn.Text = "➖"
        SearchBox.Visible = true
        SearchBtn.Visible = true
        ScrollFrame.Visible = true
    end
end)

-- ===== SEARCH BAR =====
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 240, 0, 35)
SearchBox.Position = UDim2.new(0, 10, 0, 50)
SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Text = DEFAULT_QUERY
SearchBox.PlaceholderText = "Search PNGs..."
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 16
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = MainFrame

-- ===== SEARCH BUTTON =====
local SearchBtn = Instance.new("TextButton")
SearchBtn.Size = UDim2.new(0, 80, 0, 35)
SearchBtn.Position = UDim2.new(0, 260, 0, 50)
SearchBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBtn.Text = "🔍"
SearchBtn.Font = Enum.Font.SourceSansBold
SearchBtn.TextSize = 18
SearchBtn.Parent = MainFrame

-- ===== SCROLLING FRAME (images grid) =====
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0, 330, 0, 380)
ScrollFrame.Position = UDim2.new(0, 10, 0, 95)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ScrollFrame.BackgroundTransparency = 0.3
ScrollFrame.BorderSizePixel = 1
ScrollFrame.BorderColor3 = Color3.fromRGB(40, 40, 60)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 8
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
ScrollFrame.Parent = MainFrame

-- Grid Layout
local GridLayout = Instance.new("UIGridLayout")
GridLayout.CellSize = UDim2.new(0, 100, 0, 100)
GridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
GridLayout.FillDirection = Enum.FillDirection.Vertical
GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
GridLayout.Parent = ScrollFrame

-- ===== RESIZE HANDLE (bottom-right corner) =====
local ResizeHandle = Instance.new("Frame")
ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
ResizeHandle.Position = UDim2.new(1, -22, 1, -22)
ResizeHandle.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
ResizeHandle.BackgroundTransparency = 0.5
ResizeHandle.BorderSizePixel = 0
ResizeHandle.Parent = MainFrame

local ResizeIcon = Instance.new("TextLabel")
ResizeIcon.Size = UDim2.new(1, 0, 1, 0)
ResizeIcon.BackgroundTransparency = 1
ResizeIcon.Text = "↘"
ResizeIcon.TextColor3 = Color3.fromRGB(200, 200, 255)
ResizeIcon.Font = Enum.Font.SourceSans
ResizeIcon.TextSize = 14
ResizeIcon.Parent = ResizeHandle

-- ===== RESIZE LOGIC (mobile-friendly) =====
local resizing = false
local resizeStartPos, resizeStartSize

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        resizeStartPos = input.Position
        resizeStartSize = MainFrame.Size
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
            end
        end)
    end
end)

ResizeHandle.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - resizeStartPos
        local newWidth = math.max(250, resizeStartSize.X.Offset + delta.X)
        local newHeight = math.max(300, resizeStartSize.Y.Offset + delta.Y)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        
        -- Update Grid columns based on width
        local cols = math.floor((newWidth - 30) / 108)
        cols = math.max(2, math.min(4, cols))
        GridLayout.CellSize = UDim2.new(0, (newWidth - 30 - (cols-1)*8) / cols, 0, 100)
        
        -- Update ScrollFrame size
        ScrollFrame.Size = UDim2.new(0, newWidth - 20, 0, newHeight - 100)
        
        -- Update positions
        SearchBox.Size = UDim2.new(0, newWidth - 100, 0, 35)
        SearchBtn.Position = UDim2.new(0, newWidth - 85, 0, 50)
        ResizeHandle.Position = UDim2.new(1, -22, 1, -22)
        
        fullHeight = newHeight
    end
end)

-- ===== SCRAPER FUNCTION (gstatic only) =====
local function googlePngSearchGstatic(query, maxResults)
    maxResults = maxResults or 20
    local encoded = string.gsub(query, " ", "+")
    local url = "https://www.google.com/search?q=" .. encoded .. "&tbm=isch&as_filetype=png"
    
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success then
        warn("Fetch failed: " .. tostring(result))
        return {}
    end
    
    local html = result
    local gstaticUrls = {}
    
    -- Extract ALL gstatic URLs
    for src in string.gmatch(html, 'src="([^"]+)"') do
        if string.find(src, "gstatic%.com") and string.find(src, "%.png") then
            table.insert(gstaticUrls, src)
        end
    end
    for src in string.gmatch(html, 'data%-src="([^"]+)"') do
        if string.find(src, "gstatic%.com") and string.find(src, "%.png") then
            table.insert(gstaticUrls, src)
        end
    end
    -- Also check imgurl param (sometimes has gstatic)
    for src in string.gmatch(html, 'imgurl=([^&]+)') do
        local decoded = src:gsub("%%(%x%x)", function(h)
            return string.char(tonumber(h, 16))
        end)
        if string.find(decoded, "gstatic%.com") and string.find(decoded, "%.png") then
            table.insert(gstaticUrls, decoded)
        end
    end
    
    -- Deduplicate
    local seen = {}
    local unique = {}
    for _, v in ipairs(gstaticUrls) do
        if not seen[v] then
            seen[v] = true
            table.insert(unique, v)
        end
    end
    
    local result = {}
    for i = 1, math.min(maxResults, #unique) do
        table.insert(result, unique[i])
    end
    return result
end

-- ===== RENDER GALLERY =====
local function renderGallery(query)
    -- Clear old images
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("ImageLabel") or child:IsA("ImageButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local urls = googlePngSearchGstatic(query, MAX_IMAGES)
    
    if #urls == 0 then
        local noResult = Instance.new("TextLabel")
        noResult.Size = UDim2.new(1, 0, 1, 0)
        noResult.BackgroundTransparency = 1
        noResult.Text = "❌ No PNGs found\nTry another keyword"
        noResult.TextColor3 = Color3.fromRGB(255, 200, 200)
        noResult.Font = Enum.Font.SourceSans
        noResult.TextSize = 18
        noResult.TextWrapped = true
        noResult.Parent = ScrollFrame
        return
    end
    
    -- Calculate grid columns dynamically
    local width = MainFrame.Size.X.Offset
    local cols = math.floor((width - 30) / 108)
    cols = math.max(2, math.min(4, cols))
    GridLayout.CellSize = UDim2.new(0, (width - 30 - (cols-1)*8) / cols, 0, 100)
    
    for i, imgUrl in ipairs(urls) do
        -- Image container
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 100)
        container.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        container.BorderSizePixel = 1
        container.BorderColor3 = Color3.fromRGB(60, 60, 80)
        container.Parent = ScrollFrame
        
        -- Image
        local image = Instance.new("ImageLabel")
        image.Size = UDim2.new(1, 0, 1, -25)
        image.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        image.Image = imgUrl
        image.ScaleType = Enum.ScaleType.Fit
        image.Parent = container
        
        -- URL Button (bottom of container)
        local urlBtn = Instance.new("TextButton")
        urlBtn.Size = UDim2.new(1, 0, 0, 22)
        urlBtn.Position = UDim2.new(0, 0, 1, -22)
        urlBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        urlBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        urlBtn.Text = "📋 Copy URL"
        urlBtn.Font = Enum.Font.SourceSans
        urlBtn.TextSize = 11
        urlBtn.Parent = container
        
        urlBtn.MouseButton1Click:Connect(function()
            -- Copy to clipboard
            local success, err = pcall(function()
                ClipboardService:SetClipboard(imgUrl)
            end)
            if success then
                urlBtn.Text = "✅ Copied!"
                task.wait(1)
                urlBtn.Text = "📋 Copy URL"
            else
                -- Fallback: print to console
                print("PNG URL: " .. imgUrl)
                urlBtn.Text = "📋 Printed!"
                task.wait(0.8)
                urlBtn.Text = "📋 Copy URL"
            end
        end)
    end
    
    -- Update canvas height
    local rowCount = math.ceil(#urls / cols)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, rowCount * 108 + 20)
end

-- ===== SEARCH ACTION =====
local function doSearch()
    local query = SearchBox.Text
    if query and query ~= "" then
        renderGallery(query)
    end
end

SearchBtn.MouseButton1Click:Connect(doSearch)

SearchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        doSearch()
    end
end)

-- ===== KEYBOARD SHORTCUT (Enter key) =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
        if SearchBox:IsFocused() then
            doSearch()
        end
    end
end)

-- ===== LOAD DEFAULT =====
task.wait(0.5)
renderGallery(DEFAULT_QUERY)

-- ===== CLOSE BUTTON (X) =====
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.SourceSans
CloseBtn.TextSize = 18
CloseBtn.Parent = Header

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ===== SUCCESS MESSAGE =====
print("🔥 PNG Gallery loaded! Search any keyword.")
print("📱 Drag to move | ↘ to resize | ➖ to minimize")
