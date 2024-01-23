local gfx <const> = playdate.graphics

local function getSongName(songFileName)
    -- TODO: read from json
    return string.sub(songFileName, 1, -2)
end

class("MenuScreen").extends()

function MenuScreen:init()
    self.songfiles = playdate.file.listFiles("Songs")
    self.selectedIndex = 1
end

function MenuScreen:display()
    gfx.clear()
    for i, song_filename in pairs(self.songfiles) do
        if i == self.selectedIndex then
            gfx.drawText(">", 10, 10 + i * 20)
        end
        gfx.drawText(getSongName(song_filename), 20, 10 + i * 20)
    end
end

function MenuScreen:getSelectedSongFilename()
    return self.songfiles[self.selectedIndex]
end

function MenuScreen:upButtonDown()
    self.selectedIndex = math.max(self.selectedIndex - 1, 1)
    print(self:getSelectedSongFilename())
    self:display()
end

function MenuScreen:downButtonDown()
    self.selectedIndex = math.min(self.selectedIndex + 1, #self.songfiles)
    print(self:getSelectedSongFilename())
    self:display()
end
