import "Scripts/devsettings"

local function MIDIToFreq(MIDINote)
    return 440 * 2 ^ ((MIDINote - 69) / 12)
end

-- Samples from https://freesound.org/
local refSample = playdate.sound.sampleplayer.new("Assets/Samples/60.pda")

local tromboneOnVolume = 1
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
end

function Trombone:startTooting(MIDINote)
    noteFreq = MIDIToFreq(MIDINote)
    refSample:setVolume(tromboneOnVolume)
    local rate = noteFreq / refFreq
    print(noteFreq)
    refSample:setRate(rate)
end

function Trombone:stopTooting()
    refSample:setVolume(0)
end
