import "CoreLibs/math"
import "Scripts/devsettings"

local function MIDIToFreq(MIDINote)
    return 440 * 2 ^ ((MIDINote - 69) / 12)
end

-- Samples from https://freesound.org/
local refSample = playdate.sound.sampleplayer.new(
    "Assets/Samples/374039__samulis__tenor-trombone-vibrato-sustain-d4-tenortbn_vib_d3_v1_1.pda")

local tromboneMaxVolume = 1
local refMIDINote <const> = 62
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

SynthPhase = {
    ["ATTACK"] = 1,
    ["DECAY"] = 2,
    ["SUSTAIN"] = 3,
    ["RELEASE"] = 4,
};

function Trombone:init()
    refSample:play(0)
    refSample:setVolume(0)
    self.attack_ms = 0.03 * 1000
    self.decay_ms = 0.2 * 1000
    self.sustainVolume = 0.7 * tromboneMaxVolume
    self.release_ms = 0.05 * 1000

    self.attackSpeed = tromboneMaxVolume / self.attack_ms
    self.decaySpeed = (tromboneMaxVolume - self.sustainVolume) / self.decay_ms
    self.releaseSpeed = self.sustainVolume / self.release_ms
    self.currentPhase = nil
    self.lastUpdate_ms = nil
end

function Trombone:startTooting()
    self.currentPhase = SynthPhase.ATTACK
end

function Trombone:stopTooting()
    self.currentPhase = SynthPhase.RELEASE
end

function Trombone:update()
    now = playdate.getCurrentTimeMilliseconds()
    currentVolume = refSample:getVolume()
    if self.lastUpdate_ms ~= nil and self.currentPhase ~= nil then
        if self.currentPhase == SynthPhase.ATTACK then
            if currentVolume < tromboneMaxVolume then
                currentVolume += self.attackSpeed * (now - self.lastUpdate_ms)
            else
                self.currentPhase = SynthPhase.DECAY
            end
        elseif self.currentPhase == SynthPhase.DECAY then
            if currentVolume > self.sustainVolume then
                currentVolume -= self.decaySpeed * (now - self.lastUpdate_ms)
            else
                self.currentPhase = SynthPhase.SUSTAIN
            end
        elseif self.currentPhase == SynthPhase.SUSTAIN then
            currentVolume = self.sustainVolume
        elseif self.currentPhase == SynthPhase.RELEASE then
            if currentVolume > 0 then
                currentVolume -= self.releaseSpeed * (now - self.lastUpdate_ms)
            else
                self.currentPhase = nil
            end
        end
    end
    self.lastUpdate_ms = now
    print(currentVolume)
    refSample:setVolume(currentVolume)
end

function Trombone:setNote(MIDINote)
    noteFreq = MIDIToFreq(MIDINote)
    local rate = noteFreq / refFreq
    refSample:setRate(rate)
end
