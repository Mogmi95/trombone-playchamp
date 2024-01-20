import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/object"

import "Scripts/trombone"
import "Scripts/song"

local gfx <const> = playdate.graphics

local currentSong = nil
-- Dictionary of seconds currently displayed on screen, and their X position
-- Should be used to place notes on the track
local visibleSeconds = {}

function updateTimePositions()
    if currentSong == nil then
        visibleSeconds = {}
        return
    end

    -- Using the clock of the media player for future sync
    local time = currentSong:getCurrentSongTime()
    -- Using string as keys to have a dict instead of an array
    local currentSecond = "" .. math.floor(time)

    -- Updating positions of existing marks
    for second,xpos in pairs(visibleSeconds) do
        if xpos <= -5 then
            visibleSeconds[second] = nil
        else 
            visibleSeconds[second] -= 1
        end
    end

    if visibleSeconds[currentSecond] == nil then
        visibleSeconds[currentSecond] = 400
    end
end

function drawTime()
    -- Drawing seconds
    for second,xpos in pairs(visibleSeconds) do
        gfx.drawText("" .. second, xpos, 220)
    end
end


function drawNotes()
    if currentSong == nil then return end

    local notes = currentSong:getNotes()
    for i,note in ipairs(notes) do
        local noteSecond = "" .. math.floor(note["time"])
        local notePitch = note["pitch"]
        local visibleSecond = visibleSeconds[noteSecond]
        if visibleSecond then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillCircleAtPoint(visibleSecond, notePitch, 10)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillCircleAtPoint(visibleSecond, notePitch, 9)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillCircleAtPoint(visibleSecond, notePitch, 3)
        end
    end
end

function drawPlayer()
    -- Drawing the player (on the left bar)
    local playerPosition = getPlayerPosition()

    local playerCircleX = 27
    local playerCircleY = 20 + 2 * playerPosition
    local playerCircleRadius = 15

    local drawingPlayerFunction = gfx.drawCircleAtPoint
    if playdate.buttonIsPressed("up") or
        playdate.buttonIsPressed("down") or
        playdate.buttonIsPressed("left") or
        playdate.buttonIsPressed("right") or
        playdate.buttonIsPressed("b")
    then
        -- Pressed state
        gfx.setColor(gfx.kColorBlack)
        gfx.fillCircleAtPoint(playerCircleX, playerCircleY, playerCircleRadius)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(playerCircleX, playerCircleY, playerCircleRadius - 2)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillCircleAtPoint(playerCircleX, playerCircleY, playerCircleRadius - 5)
    else
        -- Normal state
        gfx.setColor(gfx.kColorBlack)
        gfx.fillCircleAtPoint(playerCircleX, playerCircleY, playerCircleRadius)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(playerCircleX, playerCircleY, playerCircleRadius - 2)
        
    end
end

function updateDisplay()
    -- Clearing the screen
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, 400, 240)

    if currentSong ~= nil then
        drawTime()
        drawNotes()
    end

    -- Drawing the vertical left bar
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(20, 0, 3, 240)
    gfx.fillRect(30, 0, 3, 240)

    drawPlayer()

    if playdate.buttonJustPressed("up") or
        playdate.buttonJustPressed("down") or
        playdate.buttonJustPressed("left") or
        playdate.buttonJustPressed("right") or
        playdate.buttonJustPressed("b")
    then
        startTooting(getMIDINote(playerPosition))
    end

    if playdate.buttonJustReleased("up") or
        playdate.buttonJustReleased("down") or
        playdate.buttonJustReleased("left") or
        playdate.buttonJustReleased("right") or
        playdate.buttonJustReleased("b")
    then
        stopTooting()
    end

    if currentSong == nil then
        gfx.drawText("Press A", 300, 100)
    end

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw()
    end
end

function initGame()
    playdate.setCrankSoundsDisabled()
end

-- Gameplay loop
initGame()
function playdate.update()
    updateTimePositions()
    updateDisplay()
end

function playdate.AButtonDown()
    -- Closing current song
    if currentSong ~= nil then
        currentSong:destroy()
        currentSong = nil
        visibleSeconds = {}
    end
    currentSong = loadSong()
    currentSong:start()

end

function playdate.cranked()
    if playdate.buttonIsPressed("up") or
        playdate.buttonIsPressed("down") or
        playdate.buttonIsPressed("left") or
        playdate.buttonIsPressed("right") or
        playdate.buttonIsPressed("b")
    then
        startTooting(getMIDINote(getPlayerPosition()))
    end
end