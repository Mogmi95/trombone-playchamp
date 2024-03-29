import "CoreLibs/graphics"

import "Scripts/screen"
import "Scripts/song"
import "Scripts/score"
import "Scripts/chart"
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

local FLAG_ENABLE_COMMENTS = true
local DIFFICULTY_X = 4
local DIFFICULTY_Y = 10

local CONFIG_MESSAGE_TTL = 10
local CONFIG_MESSAGE_SPEED = 2

local CONFIG_BUTTON_TOOT = playdate.kButtonB
local tootButtonMask = CONFIG_BUTTON_TOOT

local UI_LEFT_BAR_X_POSITION_CENTER = 25
local UI_LEFT_BAR_WIDTH = 8
local UI_LEFT_BAR_BORDER_WIDTH = 3

local UI_NOTE_WIDTH = 8

-- How many pixels 1 second represents (= scrolling speed)
local ONE_SECOND_IN_PIXELS = 150

local function drawPlayer(trombone, position)
    -- Drawing the player (on the left bar)
    local playerPosition = position

    local playerCircleX = UI_LEFT_BAR_X_POSITION_CENTER
    local playerCircleY = positionToY(playerPosition)
    local playerCircleRadius = 15

    if trombone.isTooting then
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

function isPitchCorrect(playerPosition, note)
    if (note:isa(SimpleNote)) then
        local currentPlayerPitch = getMIDINote(playerPosition)
        return math.abs(note.pitchStartMIDI - currentPlayerPitch) < DIFFICULTY_Y
    else
        -- TODO: support ModulatedNotes
    end
end

-- Checks if the player is hitting a note, and update the score accordingly
local function checkScore(buttonCurrent, score, chart)
    local currentNote = chart:getCurrentNote()

    if playdate.buttonJustPressed(CONFIG_BUTTON_TOOT) then
        if currentNote == nil then
            -- Wrong timing
        else
            -- Correct timing, checking the pitch
            if (isPitchCorrect(getPlayerPosition(), currentNote)) then
                hittingNote = currentNote
                hittingScore += 300
            else
                -- Wrong pitch
            end
        end
    elseif hittingNote and ((buttonCurrent & tootButtonMask) > 0) then
        -- Maintaining a note after hitting it
        -- TODO Better check if the note is valid
        if currentNote == hittingNote then
            -- Still hitting the note
            hittingScore += 100
        else
            score:addPoints(hittingScore)
            hittingNote = nil
            hittingScore = 0
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

-- list of
-- {
--      "y": 40
--      "text": "Yay!"
--      "ttl": 3     -- (Time To Live, in frames)
-- }
local successMessages = {}

local function drawSuccessMessages()
    gfx.pushContext() 
    gfx.setColor(gfx.kColorBlack)
    playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
    local horizontalMargin = 4

    for i, msg in ipairs(successMessages) do
        local textWidth, textHeight = playdate.graphics.getTextSize(msg.text)
        local textX = UI_LEFT_BAR_X_POSITION_CENTER + 10
        local textY = msg.y - 30 + msg.ttl * 2
        gfx.fillRect(textX, textY, textWidth + horizontalMargin * 2, textHeight)
        gfx.drawText(msg.text, textX + horizontalMargin, textY)
        msg.ttl -= CONFIG_MESSAGE_SPEED
        if msg.ttl == 0 then
            table.remove(successMessages, i)
        end
    end
    gfx.popContext()
end

class("PlayingScreen").extends(Screen)

function PlayingScreen:init(songFilename)
    self.showFPS = false
    self.score = Score(400 - getScoreWidth(), 5)
    self.song = loadSong(songFilename)

    self.chart = Chart(self.song.notes, UI_LEFT_BAR_X_POSITION_CENTER)
    local chartListener = {
        onNotePlaying = function(note, isFirstFrame, isLastFrame)
            -- Maybe we want the Chart to return the currentPitch approximated as well
            print(note:toString())

            -- Time to display a message with the note success!
            if FLAG_ENABLE_COMMENTS and isLastFrame then
                local text = "Missed."
                if hittingScore > 0 then
                    text = "Nice!"
                end
                table.insert(successMessages, {
                    -- y = positionToY(getPlayerPosition()),
                    y = MIDINoteToY(note.pitchEndMIDI),
                    text = text,
                    ttl = CONFIG_MESSAGE_TTL
                })
            end
        end
    }
    self.chart:addListener(chartListener)

    self.trombone = Trombone()
    self.trombone:setNote(getMIDINote(getPlayerPosition()))
    self.song:start()
    self.autoplay = false
end

function PlayingScreen:draw()
    gfx.clear()

    self.chart:draw()

    -- Drawing the vertical left bar
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(UI_LEFT_BAR_X_POSITION_CENTER - UI_LEFT_BAR_WIDTH / 2 - UI_LEFT_BAR_BORDER_WIDTH, 0,
        UI_LEFT_BAR_BORDER_WIDTH, 240)
    gfx.fillRect(UI_LEFT_BAR_X_POSITION_CENTER + UI_LEFT_BAR_WIDTH / 2, 0, UI_LEFT_BAR_BORDER_WIDTH, 240)

    playerPosition = getPlayerPosition()
    if self.autoplay then
        playerPosition = getPosition(self.trombone.currentMIDINote)
    end

    drawPlayer(self.trombone, playerPosition)

    checkScore(buttonCurrent, self.score, self.chart)
    self.score:draw()

    if FLAG_ENABLE_COMMENTS then
        drawSuccessMessages()
    end

    if self.showFPS then
        playdate.drawFPS()
    end
end

local function getCurrentPitch(note, currentTime)
    return playdate.math.lerp(note.pitchStartMIDI, note.pitchEndMIDI,
        (currentTime - note.startSeconds) / (note.durationSeconds))
end

function PlayingScreen:update()
    local buttonCurrent, buttonPressed, buttonReleased = playdate.getButtonState()
    self:draw(buttonCurrent, buttonPressed, buttonReleased)

    self.chart:update()

    if self.autoplay then
        currentNote = self.chart:getCurrentNote()
        if currentNote == nil then
            if self.trombone.isTooting then
                self.trombone:stopTooting()
            end
        else
            self.trombone:setNote(getCurrentPitch(currentNote, self.song:getCurrentSongTime()))
            if not self.trombone.isTooting then
                self.trombone:startTooting()
            end
        end
    elseif playdate.isCrankDocked() then
        playdate.ui.crankIndicator:draw()
    end
end

function PlayingScreen:AButtonDown()
    -- Closing current song
    self.song:destroy()
    self.song = nil
    return { ["screen"] = Screens.MENU, ["params"] = nil }
end

function PlayingScreen:BButtonDown()
    self.trombone:startTooting()
end

function PlayingScreen:BButtonUp()
    self.trombone:stopTooting()
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

function PlayingScreen:leftButtonDown()
    self.autoplay = not self.autoplay
end

function PlayingScreen:cranked()
    buttonCurrent, buttonPressed, buttonReleased = playdate.getButtonState()
    if (buttonCurrent & tootButtonMask) > 0 then
        self.trombone:setNote(getMIDINote(getPlayerPosition()))
    end
end
