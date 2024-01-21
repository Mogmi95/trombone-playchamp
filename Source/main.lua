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

-- How many pixels 1 second represents (= scrolling speed)
local ONE_SECOND_IN_PIXELS = 150

-- Calculate the x position of a time (in milliseconds), using the
-- left bar x as origin. Value can be negative.
function getDistanceFromBarForTimeInMS(timeAtBar, timeToDisplay)
    local baseX = UI_LEFT_BAR_X_POSITION_CENTER
    return (timeToDisplay - timeAtBar) / 1000 * ONE_SECOND_IN_PIXELS
end

-- Estimates which seconds are currently displayed on screen (to avoid
-- calculating for non-rendered values).
-- Returns a pair min,max
function getDisplayedSecondsInterval(currentTime)
    local second = math.floor(currentTime)
    return second - 1, second + 6
end

function drawTime()
    -- The center of the left bar (UI_LEFT_BAR_X_POSITION_CENTER) represents the X
    -- position of the current time in the Song.
    -- Other elements are relative to this point/time considering the speed and scale
    local barX = UI_LEFT_BAR_X_POSITION_CENTER
    local time = currentSong:getCurrentSongTime()
    local second = math.floor(time)

    -- Getting the position of the seconds on screen
    local minSecond, maxSecond = getDisplayedSecondsInterval(second)
    for i = minSecond, maxSecond do
        local distanceFromBar = getDistanceFromBarForTimeInMS(time * 1000, i * 1000)
        gfx.drawText("" .. i, UI_LEFT_BAR_X_POSITION_CENTER + distanceFromBar, 220)
    end
end

function drawNotes()
    if currentSong == nil then return end

    local notes = currentSong:getNotes()
    local currentSongTime = currentSong:getCurrentSongTime()
    local minSecond, maxSecond = getDisplayedSecondsInterval(currentSong:getCurrentSongTime())
    for i,note in ipairs(notes) do
        local noteSecond = note["time"]
        local notePitch = note["pitch"]
        if (noteSecond >= minSecond) and (noteSecond <= maxSecond) then
            local noteX = UI_LEFT_BAR_X_POSITION_CENTER + getDistanceFromBarForTimeInMS(currentSongTime * 1000, noteSecond * 1000)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillCircleAtPoint(noteX, notePitch, 10)
            gfx.setColor(gfx.kColorWhite)
            gfx.fillCircleAtPoint(noteX, notePitch, 9)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillCircleAtPoint(noteX, notePitch, 3)
        end
    end
end

local tootButtonMask = playdate.kButtonB

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
    updateDisplay()
end

function playdate.AButtonDown()
    -- Closing current song
    if currentSong ~= nil then
        currentSong:destroy()
        currentSong = nil
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