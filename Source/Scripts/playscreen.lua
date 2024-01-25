import "CoreLibs/graphics"

import "Scripts/screen"
import "Scripts/song"
import "Scripts/score"
import "Scripts/trombone"
import "Scripts/devsettings"

local gfx <const> = playdate.graphics

-- Vertical position of the dot, from 0 (top) to 100 (bottom)
function getPlayerPosition()
    local s <const> = 100 / (100 - 2 * deadzone)
    local position = 100 - math.abs((playdate.getCrankPosition() - 180) / 1.8)
    return math.max(0, math.min((position - deadzone) * s, 100))
end

function positionToY(position)
    return 20 + 2 * position
end

function MIDINoteToY(MIDINote)
    return positionToY(getPosition(MIDINote))
end

function YToMIDINote(y)
    return getMIDINote((y - 20) / 2)
end

function tmbNoteToMIDI(tmbNote)
    return (tmbNote / 13.75) + 60
end

local CONFIG_BUTTON_TOOT = playdate.kButtonB
local tootButtonMask = CONFIG_BUTTON_TOOT

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

-- TODO Make not global
local DIFFICULTY_X = 2 -- pixels allowed to miss the note
local currentNote = nil

local function drawNotes(song)
    -- TODO SHOULD NOT BE DONE DURING DRAWING
    currentNote = nil

    local notes = song.notes
    local currentSongTime = song:getCurrentSongTime()
    local minSecond, maxSecond = getDisplayedSecondsInterval(song:getCurrentSongTime())
    local ratioTempoToSeconds = song.tempo / 60
    for i, note in ipairs(notes) do
        local startNoteSecond = note[1] / ratioTempoToSeconds
        local endNoteSecond = (note[1] + note[2]) / ratioTempoToSeconds
        if (endNoteSecond >= minSecond) and (startNoteSecond <= maxSecond) then
            local startNoteX = UI_LEFT_BAR_X_POSITION_CENTER
                + getDistanceFromBarForTimeInMS(currentSongTime * 1000, startNoteSecond * 1000)
            local startNoteY = MIDINoteToY(tmbNoteToMIDI(note[3]))
            local endNoteX = UI_LEFT_BAR_X_POSITION_CENTER 
                + getDistanceFromBarForTimeInMS(currentSongTime * 1000, endNoteSecond * 1000)
            local endNoteY = MIDINoteToY(tmbNoteToMIDI(note[5]))
            
            gfx.pushContext() 
            gfx.setColor(gfx.kColorBlack)
            gfx.setLineCapStyle(playdate.graphics.kLineCapStyleRound)
            gfx.setLineWidth(8) 
            gfx.drawLine(startNoteX, startNoteY, endNoteX, endNoteY)
            gfx.popContext() 

            -- TODO SHOULD NOT BE DONE DURING DRAWING
            if (startNoteX - UI_LEFT_BAR_X_POSITION_CENTER <= DIFFICULTY_X) and (endNoteX - UI_LEFT_BAR_X_POSITION_CENTER >= DIFFICULTY_X) then
                print("CURRENT NOTE " .. note[1])
                currentNote = note
            end
            -- END TODO SHOULD NOT BE DONE DURING DRAWING

        end
    end
end

local function drawPlayer(buttonCurrent)
    -- Drawing the player (on the left bar)
    local playerPosition = getPlayerPosition()

    local playerCircleX = UI_LEFT_BAR_X_POSITION_CENTER
    local playerCircleY = positionToY(playerPosition)
    local playerCircleRadius = 15

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

local hittingNote = nil
local hittingScore = 0

local function checkScore(buttonCurrent, score)
    if playdate.buttonJustPressed(CONFIG_BUTTON_TOOT) then
        if currentNote == nil then
            -- MISS
        else
            -- HIT
            hittingNote = currentNote
            hittingScore += 300
        end
    elseif hittingNote and ((buttonCurrent & tootButtonMask) > 0) then
        -- Maintaining a note after hitting it
        -- TODO Better check if the note is valid
        if currentNote == hittingNote then
            -- Still hitting the note
            hittingScore += 100
        end
    elseif playdate.buttonJustReleased(CONFIG_BUTTON_TOOT) then
        -- Actually scoring pending points
        if hittingScore > 0 then
            score:addPoints(hittingScore)
            hittingNote = nil
            hittingScore = 0
        end
    end
end


class("PlayingScreen").extends(Screen)

function PlayingScreen:init(songFilename)
    self.showFPS = false
    self.score = Score(400 - getScoreWidth(), 200)
    self.song = loadSong(songFilename)
    self.trombone = Trombone()
    self.song:start()
end

function PlayingScreen:draw(buttonCurrent, buttonPressed, buttonReleased)
    gfx.clear()

    drawTime(self.song)
    drawNotes(self.song)

    -- Drawing the vertical left bar
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(UI_LEFT_BAR_X_POSITION_CENTER - UI_LEFT_BAR_WIDTH / 2 - UI_LEFT_BAR_BORDER_WIDTH, 0,
        UI_LEFT_BAR_BORDER_WIDTH, 240)
    gfx.fillRect(UI_LEFT_BAR_X_POSITION_CENTER + UI_LEFT_BAR_WIDTH / 2, 0, UI_LEFT_BAR_BORDER_WIDTH, 240)

    drawPlayer(buttonCurrent)

    checkScore(buttonCurrent, self.score)
    self.score:draw()

    if self.showFPS then
        playdate.drawFPS()
    end
end

function PlayingScreen:update()
    
    local buttonCurrent, buttonPressed, buttonReleased = playdate.getButtonState()
    self:draw(buttonCurrent, buttonPressed, buttonReleased)
    if (buttonPressed & tootButtonMask) > 0 then
        self.trombone:startTooting(getMIDINote(getPlayerPosition()))
    end

    if (buttonReleased & tootButtonMask) > 0 then
        self.trombone:stopTooting()
    end

    if playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw()
    end
end

function PlayingScreen:AButtonDown()
    -- Closing current song
    self.song:destroy()
    self.song = nil
    return { ["screen"] = Screens.MENU, ["params"] = nil }
end

function PlayingScreen:downButtonDown()
    self.showFPS = not self.showFPS
end

function PlayingScreen:upButtonDown()
    if self.song.filePlayer:getVolume() > 0 then
        self.song.filePlayer:setVolume(0)
    else
        self.song.filePlayer:setVolume(1)
    end
end

function PlayingScreen:cranked()
    buttonCurrent, buttonPressed, buttonReleased = playdate.getButtonState()
    if (buttonCurrent & tootButtonMask) > 0 then
        self.trombone:startTooting(getMIDINote(getPlayerPosition()))
    end
end
