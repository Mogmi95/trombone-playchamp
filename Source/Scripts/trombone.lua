local tromboneSynth = playdate.sound.synth.new(playdate.sound.kWavePOVosim)

-- Vertical position of the dot, from 0 (top) to 100 (bottom)
function getPlayerPosition()
    return 100 - math.abs((playdate.getCrankPosition() - 180) / 1.8)
end

local pitchHighBound = 698.46 -- F5
local pitchLowBound = 82.41 -- E2

function getPitch(position)
    return 	pitchHighBound - (pitchHighBound - pitchLowBound) * position / 100
end

function startTooting(pitch)
    tromboneSynth:noteOff()
    tromboneSynth:playNote(pitch)
end


function stopTooting()
    tromboneSynth:noteOff()
end