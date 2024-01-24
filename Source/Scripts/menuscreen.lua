import "Scripts/screen"
import "Scripts/state"

local gfx <const> = playdate.graphics

local function getSongName(songFileName)
    -- TODO: read from json
    return string.sub(songFileName, 1, -2)
end

class("MenuScreen").extends(Screen)

function MenuScreen:init()
    self.songfiles = playdate.file.listFiles("Songs")
    self.selectedIndex = 1
end

function MenuScreen:transitionIn()
    self:draw()
end

function MenuScreen:draw()
    gfx.clear()
    if #self.songfiles == 0 then
        gfx.drawText("No songs :(", 20, 30)
    else
        local selectorPosition <const> = 4
        gfx.drawText(">", 10, selectorPosition * 20)
        for i, song_filename in pairs(self.songfiles) do
            lineDiff = i - self.selectedIndex + selectorPosition
            gfx.drawText(getSongName(song_filename), 20, lineDiff * 20)
        end
    end
end

function MenuScreen:getSelectedSongFilename()
    return self.songfiles[self.selectedIndex]
end

function MenuScreen:upButtonDown()
    self.selectedIndex = math.max(self.selectedIndex - 1, 1)
    self:draw()
end

function MenuScreen:downButtonDown()
    self.selectedIndex = math.min(self.selectedIndex + 1, #self.songfiles)
    self:draw()
end

function MenuScreen:AButtonDown()
    return {["screen"] = Screens.PLAYING, ["params"] = self:getSelectedSongFilename()}
end