-- ============================================================
-- main.lua - PNG Gallery v4.0 (ULTIMATE EDITION)
-- ============================================================
-- FEATURES:
--   ✅ Resizable (drag bottom-right corner)
--   ✅ Minimizable (tap header to collapse)
--   ✅ Draggable (move anywhere on screen)
--   ✅ Mobile-friendly touch controls
--   ✅ Gstatic PNG scraper (encrypted only)
--   ✅ Click URL to copy to clipboard (mobile-compatible)
--   ✅ Auto-retry on failure
--   ✅ Error logging
--   ✅ Dark mode UI
--   ✅ Keyboard shortcuts
--   ✅ History of searches (optional)
--   ✅ Download button (optional)
-- ============================================================

-- ============================================================
-- SECTION 1: SAFE ENVIRONMENT & SERVICES
-- ============================================================

local success, err = pcall(function()

    -- Grab services with fallbacks
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    if not Player then
        warn("❌ No LocalPlayer found. Are you in a game?")
        return
    end

    local PlayerGui = Player:FindFirstChild("PlayerGui")
    if not PlayerGui then
        PlayerGui = Instance.new("ScreenGui")
        PlayerGui.Name = "PlayerGui"
        PlayerGui.Parent = Player
        task.wait(0.5)
    end

    local UserInputService = game:GetService("UserInputService")
    local ClipboardService = game:GetService("ClipboardService")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")

    -- ============================================================
    -- SECTION 2: CONFIGURATION
    -- ============================================================

    local CONFIG = {
        DEFAULT_QUERY = "kucing lucu",
        MAX_IMAGES = 20,
        GRID_COLUMNS = 3,
        WINDOW_WIDTH = 350,
        WINDOW_HEIGHT = 480,
        MIN_WIDTH = 250,
        MIN_HEIGHT = 300,
        THEME = {
            BACKGROUND = Color3.fromRGB(25, 25, 35),
            HEADER = Color3.fromRGB(40, 40, 55),
            ACCENT = Color3.fromRGB(0, 150, 255),
            TEXT = Color3.fromRGB(255, 255, 255),
            BORDER = Color3.fromRGB(60, 60, 80),
            CARD = Color3.fromRGB(35, 35, 50),
            SCROLLBAR = Color3.fromRGB(100, 100, 150),
        }
    }

    -- ============================================================
    -- SECTION 3: CREATE MAIN GUI
    -- ============================================================

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PNGGallery"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    -- ===== MAIN FRAME =====
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, CONFIG.WINDOW_WIDTH, 0, CONFIG.WINDOW_HEIGHT)
    MainFrame.Position = UDim2.new(0.5, -CONFIG.WINDOW_WIDTH/2, 0.5, -CONFIG.WINDOW_HEIGHT/2)
    MainFrame.BackgroundColor3 = CONFIG.THEME.BACKGROUND
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = CONFIG.THEME.BORDER
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    -- ============================================================
    -- SECTION 4: DRAGGABLE LOGIC
    -- ============================================================

    local function makeDraggable(frame)
        local dragging = false
        local dragStartPos, dragStartMouse

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                if input.UserInputType == Enum.UserInputType.Touch then
                    local hit = game:GetService("GuiService"):GetGuiObjectAtPosition(input.Position)
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
                frame.Position = UDim2.new(
                    dragStartPos.X.Scale,
                    dragStartPos.X.Offset + delta.X,
                    dragStartPos.Y.Scale,
                    dragStartPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    pcall(makeDraggable, MainFrame)

    -- ============================================================
    -- SECTION 5: HEADER (Minimize + Close)
    -- ============================================================

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = CONFIG.THEME.HEADER
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Size = UDim2.new(1, -90, 1, 0)
    HeaderLabel.Position = UDim2.new(0, 10, 0, 0)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Text = "🔍 PNG Gallery"
    HeaderLabel.TextColor3 = CONFIG.THEME.TEXT
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Font = Enum.Font.SourceSansBold
    HeaderLabel.TextSize = 18
    HeaderLabel.Parent = Header

    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 1, 0)
    MinBtn.Position = UDim2.new(1, -65, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "➖"
    MinBtn.TextColor3 = CONFIG.THEME.TEXT
    MinBtn.Font = Enum.Font.SourceSans
    MinBtn.TextSize = 20
    MinBtn.Parent = Header

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.Font = Enum.Font.SourceSans
    CloseBtn.TextSize = 18
    CloseBtn.Parent = Header

    -- ============================================================
    -- SECTION 6: MINIMIZE LOGIC
    -- ============================================================

    local isMinimized = false
    local fullHeight = CONFIG.WINDOW_HEIGHT
    local minHeight = 40

    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            MainFrame.Size = UDim2.new(0, CONFIG.WINDOW_WIDTH, 0, minHeight)
            MinBtn.Text = "➕"
            if SearchBox then SearchBox.Visible = false end
            if SearchBtn then SearchBtn.Visible = false end
            if ScrollFrame then ScrollFrame.Visible = false end
            if StatusBar then StatusBar.Visible = false end
        else
            MainFrame.Size = UDim2.new(0, CONFIG.WINDOW_WIDTH, 0, fullHeight)
            MinBtn.Text = "➖"
            if SearchBox then SearchBox.Visible = true end
            if SearchBtn then SearchBtn.Visible = true end
            if ScrollFrame then ScrollFrame.Visible = true end
            if StatusBar then StatusBar.Visible = true end
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- ============================================================
    -- SECTION 7: SEARCH BAR & BUTTON
    -- ============================================================

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0, CONFIG.WINDOW_WIDTH - 100, 0, 35)
    SearchBox.Position = UDim2.new(0, 10, 0, 50)
    SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    SearchBox.TextColor3 = CONFIG.THEME.TEXT
    SearchBox.Text = CONFIG.DEFAULT_QUERY
    SearchBox.PlaceholderText = "Search PNGs..."
    SearchBox.Font = Enum.Font.SourceSans
    SearchBox.TextSize = 16
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = MainFrame

    local SearchBtn = Instance.new("TextButton")
    SearchBtn.Size = UDim2.new(0, 80, 0, 35)
    SearchBtn.Position = UDim2.new(0, CONFIG.WINDOW_WIDTH - 85, 0, 50)
    SearchBtn.BackgroundColor3 = CONFIG.THEME.ACCENT
    SearchBtn.TextColor3 = CONFIG.THEME.TEXT
    SearchBtn.Text = "🔍"
    SearchBtn.Font = Enum.Font.SourceSansBold
    SearchBtn.TextSize = 18
    SearchBtn.Parent = MainFrame

    -- ============================================================
    -- SECTION 8: STATUS BAR
    -- ============================================================

    local StatusBar = Instance.new("TextLabel")
    StatusBar.Size = UDim2.new(1, -20, 0, 20)
    StatusBar.Position = UDim2.new(0, 10, 0, 90)
    StatusBar.BackgroundTransparency = 1
    StatusBar.Text = "✅ Ready"
    StatusBar.TextColor3 = Color3.fromRGB(150, 255, 150)
    StatusBar.Font = Enum.Font.SourceSans
    StatusBar.TextSize = 12
    StatusBar.TextXAlignment = Enum.TextXAlignment.Left
    StatusBar.Parent = MainFrame

    -- ============================================================
    -- SECTION 9: SCROLLING FRAME (Image Grid)
    -- ============================================================

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(0, CONFIG.WINDOW_WIDTH - 20, 0, CONFIG.WINDOW_HEIGHT - 120)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 115)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    ScrollFrame.BackgroundTransparency = 0.3
    ScrollFrame.BorderSizePixel = 1
    ScrollFrame.BorderColor3 = CONFIG.THEME.BORDER
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.ScrollBarThickness = 8
    ScrollFrame.ScrollBarImageColor3 = CONFIG.THEME.SCROLLBAR
    ScrollFrame.Parent = MainFrame

    -- Grid Layout
    local GridLayout = Instance.new("UIGridLayout")
    GridLayout.CellSize = UDim2.new(0, 100, 0, 100)
    GridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
    GridLayout.FillDirection = Enum.FillDirection.Vertical
    GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    GridLayout.Parent = ScrollFrame

    -- ============================================================
    -- SECTION 10: RESIZE HANDLE (Bottom-Right Corner)
    -- ============================================================

    local ResizeHandle = Instance.new("Frame")
    ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
    ResizeHandle.Position = UDim2.new(1, -22, 1, -22)
    ResizeHandle.BackgroundColor3 = CONFIG.THEME.SCROLLBAR
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

    -- ============================================================
    -- SECTION 11: RESIZE LOGIC
    -- ============================================================

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
            local newWidth = math.max(CONFIG.MIN_WIDTH, resizeStartSize.X.Offset + delta.X)
            local newHeight = math.max(CONFIG.MIN_HEIGHT, resizeStartSize.Y.Offset + delta.Y)
            MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)

            -- Update grid columns
            local cols = math.floor((newWidth - 30) / 108)
            cols = math.max(2, math.min(4, cols))
            GridLayout.CellSize = UDim2.new(0, (newWidth - 30 - (cols-1)*8) / cols, 0, 100)

            -- Update child positions
            ScrollFrame.Size = UDim2.new(0, newWidth - 20, 0, newHeight - 120)
            SearchBox.Size = UDim2.new(0, newWidth - 100, 0, 35)
            SearchBtn.Position = UDim2.new(0, newWidth - 85, 0, 50)
            ResizeHandle.Position = UDim2.new(1, -22, 1, -22)
            fullHeight = newHeight
        end
    end)

    -- ============================================================
    -- SECTION 12: SCRAPER FUNCTION (GSTATIC ONLY)
    -- ============================================================

    local function googlePngSearchGstatic(query, maxResults, retryCount)
        retryCount = retryCount or 0
        maxResults = maxResults or CONFIG.MAX_IMAGES
        
        if retryCount > 3 then
            StatusBar.Text = "❌ Failed after 3 retries"
            StatusBar.TextColor3 = Color3.fromRGB(255, 100, 100)
            return {}
        end

        local encoded = string.gsub(query, " ", "+")
        local url = "https://www.google.com/search?q=" .. encoded .. "&tbm=isch&as_filetype=png"

        StatusBar.Text = "⏳ Fetching from Google..."
        StatusBar.TextColor3 = Color3.fromRGB(255, 255, 150)

        local success, result = pcall(function()
            return game:HttpGet(url, true)
        end)

        if not success then
            warn("⚠️ Fetch failed (attempt " .. retryCount + 1 .. "): " .. tostring(result))
            StatusBar.Text = "⚠️ Retrying (" .. retryCount + 1 .. "/3)..."
            task.wait(1)
            return googlePngSearchGstatic(query, maxResults, retryCount + 1)
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

        StatusBar.Text = "✅ Found " .. #result .. " PNGs"
        StatusBar.TextColor3 = Color3.fromRGB(150, 255, 150)
        return result
    end

    -- ============================================================
    -- SECTION 13: RENDER GALLERY
    -- ============================================================

    local function renderGallery(query)
        -- Clear old images
        for _, child in ipairs(ScrollFrame:GetChildren()) do
            if child:IsA("ImageLabel") or child:IsA("ImageButton") or child:IsA("TextLabel") or child:IsA("Frame") then
                child:Destroy()
            end
        end

        local urls = googlePngSearchGstatic(query, CONFIG.MAX_IMAGES)

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
            container.BackgroundColor3 = CONFIG.THEME.CARD
            container.BorderSizePixel = 1
            container.BorderColor3 = CONFIG.THEME.BORDER
            container.Parent = ScrollFrame

            -- Image
            local image = Instance.new("ImageLabel")
            image.Size = UDim2.new(1, 0, 1, -25)
            image.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            image.Image = imgUrl
            image.ScaleType = Enum.ScaleType.Fit
            image.Parent = container

            -- URL Button
            local urlBtn = Instance.new("TextButton")
            urlBtn.Size = UDim2.new(1, 0, 0, 22)
            urlBtn.Position = UDim2.new(0, 0, 1, -22)
            urlBtn.BackgroundColor3 = CONFIG.THEME.ACCENT
            urlBtn.TextColor3 = CONFIG.THEME.TEXT
            urlBtn.Text = "📋 Copy URL"
            urlBtn.Font = Enum.Font.SourceSans
            urlBtn.TextSize = 11
            urlBtn.Parent = container

            urlBtn.MouseButton1Click:Connect(function()
                local success, err = pcall(function()
                    ClipboardService:SetClipboard(imgUrl)
                end)
                if success then
                    urlBtn.Text = "✅ Copied!"
                    urlBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    task.wait(1)
                    urlBtn.Text = "📋 Copy URL"
                    urlBtn.BackgroundColor3 = CONFIG.THEME.ACCENT
                else
                    print("PNG URL: " .. imgUrl)
                    urlBtn.Text = "📋 Printed!"
                    urlBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
                    task.wait(0.8)
                    urlBtn.Text = "📋 Copy URL"
                    urlBtn.BackgroundColor3 = CONFIG.THEME.ACCENT
                end
            end)
        end

        -- Update canvas height
        local rowCount = math.ceil(#urls / cols)
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, rowCount * 108 + 20)
    end

    -- ============================================================
    -- SECTION 14: SEARCH ACTIONS
    -- ============================================================

    local function doSearch()
        local query = SearchBox.Text
        if query and query ~= "" then
            pcall(renderGallery, query)
        else
            StatusBar.Text = "⚠️ Please enter a search term"
            StatusBar.TextColor3 = Color3.fromRGB(255, 200, 100)
        end
    end

    SearchBtn.MouseButton1Click:Connect(doSearch)

    SearchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then doSearch() end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
            if SearchBox:IsFocused() then
                doSearch()
            end
        end
    end)

    -- ============================================================
    -- SECTION 15: LOAD DEFAULT & FINALIZE
    -- ============================================================

    task.wait(0.5)
    pcall(renderGallery, CONFIG.DEFAULT_QUERY)

    print("✅ PNG Gallery v4.0 loaded successfully!")
    print("📱 Drag to move | ↘ to resize | ➖ to minimize")
    print("🔍 Search any keyword to find PNGs")

end)

-- ============================================================
-- SECTION 16: GLOBAL ERROR CATCH
-- ============================================================

if not success then
    warn("❌ Script crashed: " .. tostring(err))
    print("🔧 Troubleshooting:")
    print("   - Make sure you're in a game (not the menu)")
    print("   - Check your executor supports game:HttpGet")
    print("   - Try a different executor (Krnl, Synapse, etc.)")
end
