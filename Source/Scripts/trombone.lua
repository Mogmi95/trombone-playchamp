
-- Vertical position of the dot, from 0 (top) to 100 (bottom)
function getPlayerPosition()
    return 100 - math.abs((playdate.getCrankPosition() - 180) / 1.8)
end
