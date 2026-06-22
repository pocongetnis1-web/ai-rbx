-- ============================================================
-- main.lua - NUCLEAR EDITION (Guaranteed to Run)
-- ============================================================

print("🚀 Starting PNG Gallery (Nuclear Edition)...")

-- ===== STEP 1: Check if we're in a game =====
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

if not Player then
    error("❌ You're not in a game! Join a game first.")
end

print("✅ Player found: " .. Player.Name)

-- ===== STEP 2: Create GUI safely =====
local PlayerGui = Player:FindFirstChild("PlayerGui")
if not PlayerGui then
    PlayerGui = Instance.new("ScreenGui")
    PlayerGui.Name = "PlayerGui"
    PlayerGui.Parent = Player
    print("✅ Created PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PNGGallery"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui
print("✅ Created ScreenGui")

-- ===== STEP 3: Create a simple red test frame =====
local TestFrame = Instance.new("Frame")
TestFrame.Size = UDim2.new(0, 200, 0, 100)
TestFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
TestFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TestFrame.Parent = ScreenGui
print("✅ Created red test frame - you should see it!")

local TestLabel = Instance.new("TextLabel")
TestLabel.Size = UDim2.new(1, 0, 1, 0)
TestLabel.BackgroundTransparency = 1
TestLabel.Text = "PNG Gallery Loaded!\nSearching for 'kucing lucu'..."
TestLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TestLabel.Font = Enum.Font.SourceSansBold
TestLabel.TextSize = 16
TestLabel.TextWrapped = true
TestLabel.Parent = TestFrame

-- ===== STEP 4: Simple HTTP test =====
print("⏳ Testing HTTP request...")
local httpSuccess, httpResult = pcall(function()
    return game:HttpGet("https://www.google.com", true)
end)

if httpSuccess then
    print("✅ HTTP works! Length: " .. #httpResult)
else
    warn("❌ HTTP failed: " .. tostring(httpResult))
    TestLabel.Text = "HTTP FAILED!\nYour executor blocks web requests."
    return
end

-- ===== STEP 5: Search for PNGs =====
local function searchPNG(query)
    print("🔍 Searching for: " .. query)
    local encoded = string.gsub(query, " ", "+")
    local url = "https://www.google.com/search?q=" .. encoded .. "&tbm=isch&as_filetype=png"
    
    local success, html = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success then
        warn("❌ Search failed: " .. tostring(html))
        TestLabel.Text = "Search failed!\n" .. tostring(html)
        return {}
    end
    
    local urls = {}
    for src in string.gmatch(html, 'src="([^"]+)"') do
        if string.find(src, "gstatic%.com") and string.find(src, "%.png") then
            table.insert(urls, src)
        end
    end
    
    -- Show results
    print("✅ Found " .. #urls .. " PNGs")
    for i, url in ipairs(urls) do
        print(i .. ". " .. url)
    end
    
    if #urls > 0 then
        TestLabel.Text = "✅ Found " .. #urls .. " PNGs!\nFirst URL copied to clipboard (if supported)"
        -- Try to copy first URL to clipboard
        pcall(function()
            game:GetService("ClipboardService"):SetClipboard(urls[1])
            print("📋 Copied first URL to clipboard!")
        end)
    else
        TestLabel.Text = "❌ No PNGs found.\nTry another keyword."
    end
    
    return urls
end

-- ===== STEP 6: Run search =====
task.wait(1)
searchPNG("kucing lucu")

print("✅ Script finished. If you see a red box, it worked!")
