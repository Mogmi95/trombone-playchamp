local tromboneSynth = playdate.sound.synth.new(playdate.sound.kWavePOVosim)

-- Vertical position of the dot, from 0 (top) to 100 (bottom)
function getPlayerPosition()
    return 100 - math.abs((playdate.getCrankPosition() - 180) / 1.8)
end

-- https://trombone.wiki/#/creating-charts
-- "Midi notes should be in the range 47 to 73 to match the game."
local pitchHighBound = 587.33 -- MIDI note 74
local pitchLowBound = 116.54 -- MIDI note 46

function getPitch(position)
    return 	pitchHighBound - (pitchHighBound - pitchLowBound) * position / 100
end

function startTooting(pitch)
    tromboneSynth:playNote(pitch)
end


function stopTooting()
    tromboneSynth:noteOff()
end