import "CoreLibs/ui"
import "CoreLibs/object"

import "Scripts/state"

import "Scripts/menuscreen"
import "Scripts/playscreen"


local menuScreen = MenuScreen()
local currentScreen = nil

local function changeScreen(transitionData)
    if transitionData.screen == Screens.MENU then
        currentScreen = menuScreen
    elseif transitionData.screen == Screens.PLAYING then
        currentScreen = PlayingScreen(transitionData.params)
    end
    currentScreen:transitionIn()
end

local function processCallback(transition)
    if transition ~= nil then
        changeScreen(transition)
    end
end

local function initGame()
    -- Create songs directory in the filesystem
    playdate.file.mkdir("Songs")

    -- Start from the menu screen
    changeScreen({ ["screen"] = Screens.MENU, ["params"] = nil })
end

-- Gameplay loop
initGame()
function playdate.update()
    processCallback(currentScreen:update())
end

-- Button callbacks
function playdate.AButtonDown()
    processCallback(currentScreen:AButtonDown())
end

function playdate.BButtonDown()
    processCallback(currentScreen:BButtonDown())
end

function playdate.BButtonUp()
    processCallback(currentScreen:BButtonUp())
end

function playdate.upButtonDown()
    processCallback(currentScreen:upButtonDown())
end

function playdate.downButtonDown()
    processCallback(currentScreen:downButtonDown())
end

function playdate.leftButtonDown()
    processCallback(currentScreen:leftButtonDown())
end

function playdate.rightButtonDown()
    processCallback(currentScreen:leftButtonDown())
end


function playdate.cranked()
    processCallback(currentScreen:cranked())
end
