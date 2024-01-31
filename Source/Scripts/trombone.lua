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

function Trombone:init()
    refSample:play(0)
    refSample:setVolume(0)
    self.isTooting = false
    self.currentMIDINote = nil
end

function Trombone:startTooting()
    self.isTooting = true
    refSample:setVolume(tromboneMaxVolume)
end

function Trombone:stopTooting()
    refSample:setVolume(0)
    self.isTooting = false
end

function Trombone:setNote(MIDINote)
    self.currentMIDINote = MIDINote
    noteFreq = MIDIToFreq(MIDINote)
    local rate = noteFreq / refFreq
    refSample:setRate(rate)
end
