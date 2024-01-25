-- Class containing everything concerning displaying notes from a file on the screen

local gfx <const> = playdate.graphics

class("Chart").extends()

-- How many pixels 1 second represents (= scrolling speed)
local ONE_SECOND_IN_PIXELS = 150
local UI_NOTE_WIDTH = 8

local listener = {
        onNotePlaying = function(note, isFirstFrame, isLastFrame)
        end
    }

function Chart:init(notes, playerPositionX)
    self.notes = notes
    self.playerPositionX = playerPositionX
    self.previousNote = nil
    self.currentNote = nil
    self.listeners = {}
end

function Chart:addListener(listener)
    table.insert(self.listeners, listener)
end

function Chart:removeListener(listener)
    -- I hate Lua
    for i, iterListener in ipairs(self.listeners) do
        if listener == iterListener then
            table.remove(self.listeners, i)
        end
        break
    end
end

function Chart:clearListeners()
    self.listeners = {}
end

function Chart:getCurrentNote()
    return self.currentNote
end

-- Calculate the x position of a time (in milliseconds), using the
-- left bar x as origin. Value can be negative.
local function getDistanceFromBarForTimeInMS(timeAtBar, timeToDisplay, playerPositionX)
    return (timeToDisplay - timeAtBar) / 1000 * ONE_SECOND_IN_PIXELS
end

-- Estimates which seconds are currently displayed on screen (to avoid
-- calculating for non-rendered values).
-- Returns a pair min,max
local function getDisplayedSecondsInterval(currentTime)
    local second = math.floor(currentTime)
    return second - 1, second + 3
end

local function drawTime(playerPositionX)
    -- The center of the left bar (playerPositionX) represents the X
    -- position of the current time in the Song.
    -- Other elements are relative to this point/time considering the speed and scale
    local time = playdate.sound.getCurrentTime()
    local second = math.floor(time)

    -- Getting the position of the seconds on screen
    local minSecond, maxSecond = getDisplayedSecondsInterval(second)
    for i = minSecond, maxSecond do
        local distanceFromBar = getDistanceFromBarForTimeInMS(time * 1000, i * 1000, playerPositionX)
        gfx.drawText("" .. i, playerPositionX + distanceFromBar, 220)
    end
end

local function drawSimpleNote(currentSongTime, note, playerPositionX)
    local startNoteX = playerPositionX
        + getDistanceFromBarForTimeInMS(currentSongTime * 1000, note.startSeconds * 1000, playerPositionX)
    local startNoteY = MIDINoteToY(note.pitchStartMIDI)

    local endNoteX = playerPositionX 
        + getDistanceFromBarForTimeInMS(currentSongTime * 1000, note.endSeconds * 1000, playerPositionX)
    local endNoteY = MIDINoteToY(note.pitchEndMIDI)
    
    local polygonMethod = gfx.fillPolygon

    if (hittingNote ~= nil) and (note == hittingNote) then
        polygonMethod = gfx.drawPolygon
    end
    polygonMethod(
        -- BOTTOM LEFT POINT
        startNoteX, startNoteY - UI_NOTE_WIDTH / 2,
        -- TOP LEFT POINT
        startNoteX , startNoteY + UI_NOTE_WIDTH / 2,
        -- TOP RIGHT POINT
        endNoteX, endNoteY + UI_NOTE_WIDTH / 2,
        -- BOTTOM RIGHT POINT
        endNoteX, endNoteY - UI_NOTE_WIDTH / 2
    )
end

local function drawNotes(notes, playerPositionX)
    gfx.pushContext() 
    gfx.setColor(gfx.kColorBlack)

    local currentSongTime = playdate.sound.getCurrentTime()
    local minSecond, maxSecond = getDisplayedSecondsInterval(currentSongTime)

    for i, note in ipairs(notes) do
        -- If either the start or the end of the note is on the interval displayed on screen, we draw the note
        if (((note.startSeconds >= minSecond) and (note.startSeconds <= maxSecond))
                or ((note.endSeconds >= minSecond) and (note.endSeconds <= maxSecond))) then
            -- TODO Check simple of modulated note
            drawSimpleNote(currentSongTime, note, playerPositionX)
        end

        -- Small optimization after finding the last possible displayed note
        if note.endSeconds > maxSecond then
            break
        end
    end

    gfx.popContext()
end

function Chart:draw()
    drawTime(self.playerPositionX)
    drawNotes(self.notes, self.playerPositionX)
end

function Chart:update()
    -- Looking if a note is being played
    local time = playdate.sound.getCurrentTime()
    local note = nil

    for i, travelNote in ipairs(self.notes) do
        if (travelNote.startSeconds <= time) and (travelNote.endSeconds >= time) then
            note = travelNote
            break
        end

        if travelNote.endSeconds > time then
            break
        end
    end

    if note then
        if self.previousNote == nil then
            -- First frame to play the note
            for i, listener in ipairs(self.listeners) do
                if listener.onNotePlaying then listener.onNotePlaying(note, true, false) end
            end
        else
            -- Somewhere during a note
            for i, listener in ipairs(self.listeners) do
                if listener.onNotePlaying then listener.onNotePlaying(note, false, false) end
            end
            
        end
    else
        -- No note right now
        if self.previousNote then
            -- Last frame to play the note
            for i, listener in ipairs(self.listeners) do
                if listener.onNotePlaying then listener.onNotePlaying(self.previousNote, false, true) end
            end
        end
    end
    self.currentNote = note
    self.previousNote = self.currentNote
end