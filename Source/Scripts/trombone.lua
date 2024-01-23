import "Scripts/devsettings"

local tromboneSynth = playdate.sound.synth.new(waveform)

local noteStartTime = nil

-- https://trombone.wiki/#/creating-charts
-- "Midi notes should be in the range 47 to 73 to match the game."
local MIDINoteHighBound = 73
local MIDINoteLowBound = 47

function getMIDINote(position)
    return 	MIDINoteHighBound - (MIDINoteHighBound - MIDINoteLowBound) * position / 100
end

function getPosition(MIDINote)
    return 100 * (MIDINoteHighBound - MIDINote) / (MIDINoteHighBound - MIDINoteLowBound)
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