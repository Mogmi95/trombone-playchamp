import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/object"

import "Scripts/trombone"
import "Scripts/song"

local gfx <const> = playdate.graphics

local UI_LEFT_BAR_X_POSITION_CENTER = 25
local UI_LEFT_BAR_WIDTH = 8
local UI_LEFT_BAR_BORDER_WIDTH = 3

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
local tootButtonMask = playdate.kButtonB

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

    local playerCircleX = UI_LEFT_BAR_X_POSITION_CENTER
    local playerCircleY = 20 + 2 * playerPosition
    local playerCircleRadius = 15

    buttonCurrent,buttonPressed,buttonReleased = playdate.getButtonState()
    if (buttonCurrent & tootButtonMask) > 0 then
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
    gfx.fillRect(UI_LEFT_BAR_X_POSITION_CENTER - UI_LEFT_BAR_WIDTH / 2 - UI_LEFT_BAR_BORDER_WIDTH, 0, UI_LEFT_BAR_BORDER_WIDTH, 240)
    gfx.fillRect(UI_LEFT_BAR_X_POSITION_CENTER + UI_LEFT_BAR_WIDTH / 2 , 0, UI_LEFT_BAR_BORDER_WIDTH, 240)

    drawPlayer()

    if (buttonPressed & tootButtonMask) > 0 then
        startTooting(getMIDINote(getPlayerPosition()))
    end

    if (buttonReleased & tootButtonMask) > 0 then
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
    buttonCurrent,buttonPressed,buttonReleased = playdate.getButtonState()
    if (buttonCurrent & tootButtonMask) > 0 then
        startTooting(getMIDINote(getPlayerPosition()))
    end
end