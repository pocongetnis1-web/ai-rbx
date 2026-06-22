============================================================
PNG GALLERY v2.0 - Google Image Scraper (Gstatic Only)
============================================================

A mobile-friendly, resizable, minimizable GUI for browsing
Google Images PNG results. Built for Roblox executors.

------------------------------------------------------------
FEATURES
------------------------------------------------------------
- Search any keyword → returns gstatic-encrypted PNG URLs
- Mobile-optimized touch controls
- Drag to move anywhere on screen
- Resize by dragging bottom-right corner
- Minimize to a tiny bar (tap ➖ / ➕)
- Copy image URL to clipboard with one tap
- Auto-adjusting grid (2–4 columns)
- Dark UI with smooth scrolling

------------------------------------------------------------
HOW TO USE
------------------------------------------------------------
1. Paste main.lua into your executor (Synapse, Krnl, etc.)
2. Run the script
3. Type a search term (default: "kucing lucu")
4. Tap 🔍 or press Enter
5. Browse images in the scrollable grid
6. Tap "Copy URL" under any image to grab the gstatic link
7. Drag the header to reposition
8. Drag ↘ to resize the window
9. Tap ➖ to minimize, ➕ to expand
10. Tap ✕ to close the GUI

------------------------------------------------------------
REQUIREMENTS
------------------------------------------------------------
- Roblox executor with game:HttpGet support
- Roblox ClipboardService (falls back to console print)
- Touch or mouse input

------------------------------------------------------------
CUSTOMIZATION
------------------------------------------------------------
Edit these variables at the top of main.lua:
- DEFAULT_QUERY  = "kucing lucu"   -- default search term
- MAX_IMAGES     = 20              -- max results per search
- GRID_COLUMNS   = 3               -- mobile default

------------------------------------------------------------
TROUBLESHOOTING
------------------------------------------------------------
- "No PNGs found" → try a different keyword
- Clipboard not working → URL prints to console/output
- GUI not showing → check executor permissions
- Resize not working → ensure you're dragging the ↘ corner

------------------------------------------------------------
NOTES
------------------------------------------------------------
- Uses Google's gstatic proxy URLs (fast, cached, bypass CORS)
- No login required
- No API keys needed
- Pure scraping + parsing

------------------------------------------------------------
CREDITS
------------------------------------------------------------
Evil Captain Underpants (ECU) Edition
For George, Harold, and everyone who wants PNGs without the BS.

------------------------------------------------------------
