import "Scripts/devsettings"

local tromboneSynth = playdate.sound.synth.new(waveform)

local noteStartTime = nil

-- Vertical position of the dot, from 0 (top) to 100 (bottom)
function getPlayerPosition()
    return 100 - math.abs((playdate.getCrankPosition() - 180) / 1.8)
end

-- https://trombone.wiki/#/creating-charts
-- "Midi notes should be in the range 47 to 73 to match the game."
local MIDINoteHighBound = 74
local MIDINoteLowBound = 46

function getMIDINote(position)
    return 	MIDINoteHighBound - (MIDINoteHighBound - MIDINoteLowBound) * position / 100
end

function startTooting(MIDINote)
    local now = playdate.getCurrentTimeMilliseconds()
    if noteStartTime == nil or now - noteStartTime > minNoteDurationMs then
        print(MIDINote)
        tromboneSynth:playMIDINote(MIDINote)
        noteStartTime = now
    end
end


function stopTooting()
    tromboneSynth:noteOff()
    noteStartTime = nil
end