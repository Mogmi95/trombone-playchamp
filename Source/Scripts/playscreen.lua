import "Scripts/trombone"

local gfx <const> = playdate.graphics


local tootButtonMask = playdate.kButtonB

local UI_LEFT_BAR_X_POSITION_CENTER = 25
local UI_LEFT_BAR_WIDTH = 8
local UI_LEFT_BAR_BORDER_WIDTH = 3

-- How many pixels 1 second represents (= scrolling speed)
local ONE_SECOND_IN_PIXELS = 150

-- Calculate the x position of a time (in milliseconds), using the
-- left bar x as origin. Value can be negative.
local function getDistanceFromBarForTimeInMS(timeAtBar, timeToDisplay)
    local baseX = UI_LEFT_BAR_X_POSITION_CENTER
    return (timeToDisplay - timeAtBar) / 1000 * ONE_SECOND_IN_PIXELS
end

-- Estimates which seconds are currently displayed on screen (to avoid
-- calculating for non-rendered values).
-- Returns a pair min,max
local function getDisplayedSecondsInterval(currentTime)
    local second = math.floor(currentTime)
    return second - 1, second + 6
end

local function drawTime(song)
    -- The center of the left bar (UI_LEFT_BAR_X_POSITION_CENTER) represents the X
    -- position of the current time in the Song.
    -- Other elements are relative to this point/time considering the speed and scale
    local barX = UI_LEFT_BAR_X_POSITION_CENTER
    local time = song:getCurrentSongTime()
    local second = math.floor(time)

    -- Getting the position of the seconds on screen
    local minSecond, maxSecond = getDisplayedSecondsInterval(second)
    for i = minSecond, maxSecond do
        local distanceFromBar = getDistanceFromBarForTimeInMS(time * 1000, i * 1000)
        gfx.drawText("" .. i, UI_LEFT_BAR_X_POSITION_CENTER + distanceFromBar, 220)
    end
end

local function drawNotes(song)
    local notes = song.notes
    local currentSongTime = song:getCurrentSongTime()
    local minSecond, maxSecond = getDisplayedSecondsInterval(song:getCurrentSongTime())
    local ratioTempoToSeconds = song.tempo / 60
    for i,note in ipairs(notes) do
        local noteSecond = note[1] / ratioTempoToSeconds
        if (noteSecond >= minSecond) and (noteSecond <= maxSecond) then
            local startNoteX = UI_LEFT_BAR_X_POSITION_CENTER + getDistanceFromBarForTimeInMS(currentSongTime * 1000, noteSecond * 1000)
            local startNoteY = 100 - note[3] / 2
            local endNoteSecond = (note[1] + note[2]) / ratioTempoToSeconds
            local endNoteX = UI_LEFT_BAR_X_POSITION_CENTER + getDistanceFromBarForTimeInMS(currentSongTime * 1000, endNoteSecond * 1000)
            local endNoteY = 100 - note[5] / 2
            gfx.setColor(gfx.kColorBlack)
            gfx.drawLine(startNoteX, startNoteY, endNoteX, endNoteY)

            gfx.fillCircleAtPoint(startNoteX, startNoteY, 6)
            gfx.fillCircleAtPoint(endNoteX, endNoteY, 3)
            -- gfx.fillCircleAtPoint(startNoteX, startNoteY, 10)
            -- gfx.setColor(gfx.kColorWhite)
            -- gfx.fillCircleAtPoint(startNoteX, startNoteY, 9)
            -- gfx.setColor(gfx.kColorBlack)
            -- gfx.fillCircleAtPoint(startNoteX, startNoteY, 3)
        end
    end
end

local function drawPlayer()
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

class("PlayingScreen").extends()

function PlayingScreen:init(song)
    self.song = song
end

function PlayingScreen:draw()
    gfx.clear()

    drawTime(self.song)
    drawNotes(self.song)

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

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw()
    end
end

function PlayingScreen:cranked()
    buttonCurrent,buttonPressed,buttonReleased = playdate.getButtonState()
    if (buttonCurrent & tootButtonMask) > 0 then
        startTooting(getMIDINote(getPlayerPosition()))
    end
end