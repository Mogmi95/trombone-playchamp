class("Song").extends()

function loadSong(songName)
    return Song(songName)
end

function Song:init(songName)
    self.filePlayer = playdate.sound.fileplayer.new()
    local pdaPath = "/Songs/" .. songName .."/song.pda"
    local mp3Path = "/Songs/" .. songName .."/song.mp3"
    if playdate.file.exists(pdaPath) then
        self.filePlayer:load(pdaPath)
    elseif playdate.file.exists(mp3Path) then
        self.filePlayer:load(mp3Path)
    end
    local jsonData = json.decodeFile("/Songs/" .. songName .."/song.tmb")
    printTable(jsonData)
    self.name = jsonData["name"]
    self.tempo = jsonData["tempo"]
    self.notes = jsonData["notes"]
end

function Song:start()
    playdate.sound.resetTime()
    self.filePlayer:play()
    -- TODO load and play the sound file
end

function Song:destroy()
    self.filePlayer:stop()
    -- TODO clear the player
    self.song = nil
end

function Song:getCurrentSongTime()
    return playdate.sound.getCurrentTime()
end

function Song:getNotes()
    return self.notes
end

-- Checks if hiting a certain pitch at this moment is correct
function Song:isCurrentNoteCorrect(pitch)
    -- MIDINote = (note[4]/13.75)+60
    -- TODO
end