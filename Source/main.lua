import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/object"

import "Scripts/state"
import "Scripts/song"

import "Scripts/menuscreen"
import "Scripts/playscreen"


local menuScreen = MenuScreen()
local playingScreen = nil
local currentScreen = nil

function toMenuScreen()
    currentScreen = Screens.MENU
    menuScreen:display()
end

function toPlayingScreen(songFilename)
    currentScreen = Screens.PLAYING
    song = loadSong(songFilename)
    playingScreen = PlayingScreen(song)
    song:start()
end


function initGame()
    playdate.setCrankSoundsDisabled()
    toMenuScreen()
end

-- Gameplay loop
initGame()
function playdate.update()
    if currentScreen == Screens.PLAYING then
        playingScreen:draw()    
    end
end

function playdate.AButtonDown()
    if currentScreen == Screens.PLAYING then
        -- Closing current song
        currentSong:destroy()
        currentSong = nil
        toMenuScreen()
    elseif  currentScreen == Screens.MENU then
        toPlayingScreen(menuScreen:getSelectedSongFilename())
    end
end

function playdate.upButtonDown()
    if currentScreen == Screens.PLAYING then
    elseif  currentScreen == Screens.MENU then
        menuScreen:upButtonDown()
    end
end

function playdate.downButtonDown()
    if currentScreen == Screens.PLAYING then
    elseif  currentScreen == Screens.MENU then
        menuScreen:downButtonDown()
    end
end

function playdate.cranked()
    if currentScreen == Screens.PLAYING then
        playingScreen:cranked()
    elseif  currentScreen == Screens.MENU then
    end
end