import "CoreLibs/math"
import "Scripts/devsettings"

local function MIDIToFreq(MIDINote)
    return 440 * 2 ^ ((MIDINote - 69) / 12)
end

-- Samples from https://freesound.org/
local refSample = playdate.sound.sampleplayer.new("Assets/Samples/60.pda")

local tromboneMaxVolume = 1
local refMIDINote <const> = 60
local refFreq <const> = MIDIToFreq(refMIDINote)

-- https://trombone.wiki/#/creating-charts
-- "Midi notes should be in the range 47 to 73 to match the game."
local MIDINoteHighBound = 73
local MIDINoteLowBound = 47

class("Trombone").extends()

function getMIDINote(position)
    return MIDINoteHighBound - (MIDINoteHighBound - MIDINoteLowBound) * position / 100
end

function getPosition(MIDINote)
    return 100 * (MIDINoteHighBound - MIDINote) / (MIDINoteHighBound - MIDINoteLowBound)
end

function Trombone:init()
    refSample:setVolume(0)
    refSample:play(0)
    self.attack_ms = 0.2 * 1000
    self.decay_ms = 0.3 * 1000
    self.sustainVolume = 0.6 * tromboneMaxVolume
    self.release_ms = 0.1 * 1000
    self.noteStartTime_ms = nil
    self.noteReleaseTime_ms = nil
end

function Trombone:getVolume(now)
    if self.noteStartTime_ms == nil then
        return 0
    end
    if self.noteReleaseTime_ms == nil then
        if now < self.noteStartTime_ms + self.attack_ms then
            -- attack_ms phase
            return playdate.math.lerp(0, tromboneMaxVolume, (now - self.noteStartTime_ms) / self.attack_ms)
        elseif now < self.noteStartTime_ms + self.attack_ms + self.decay_ms then
            -- decay phase
            return playdate.math.lerp(tromboneMaxVolume, self.sustainVolume,
                (now - self.attack_ms - self.noteStartTime_ms) / self.decay_ms)
        else
            -- sustain phase
            return self.sustainVolume
        end
    else
        if now < self.noteReleaseTime_ms + self.release_ms then
            -- release phase
            return playdate.math.lerp(self.sustainVolume, 0,
                (now - self.attack_ms - self.noteStartTime_ms) / self.release_ms)
        else
            -- After full release
            return 0
        end
    end
end

function Trombone:startTooting()
    self.noteStartTime_ms = playdate.getCurrentTimeMilliseconds()
    self.noteReleaseTime_ms = nil
end

function Trombone:stopTooting()
    print("STOP")
    self.noteReleaseTime_ms = playdate.getCurrentTimeMilliseconds()
end

function Trombone:update()
    volume = self:getVolume(playdate.getCurrentTimeMilliseconds())
    print(volume)
    refSample:setVolume(volume)
end

function Trombone:setNote(MIDINote)
    noteFreq = MIDIToFreq(MIDINote)
    local rate = noteFreq / refFreq
    print(noteFreq)
    refSample:setRate(rate)
end
