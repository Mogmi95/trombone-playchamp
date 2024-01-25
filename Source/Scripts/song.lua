-- SONG CLASS

class("Song").extends()

function loadSong(songName)
    return Song(songName)
end

-- There can only be one note
local function convertAndAggregateNotes(tempo, rawNoteData)
    local result = {}

    for i, note in ipairs(rawNoteData) do
        result[i] = SimpleNote(tempo, note)
    end

    return result
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
    self.name = jsonData["name"]
    self.tempo = jsonData["tempo"]
    self.notes = convertAndAggregateNotes(self.tempo, jsonData["notes"])
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

class("Note").extends()

function Note:toString()
end

-- NOTE CLASS

function tmbNoteToMIDI(tmbNote)
    return (tmbNote / 13.75) + 60
end

-- A Note that has at most one pitch change
class("SimpleNote").extends("Note")

function SimpleNote:init(tempo, rawNoteData)
    self.startBar = rawNoteData[1]
    self.durationBar = rawNoteData[2]
    self.endBar = self.startBar + self.durationBar
    self.pitchStartTmb = rawNoteData[3]
    self.NotSureMaybeStrengthOfPitchCurve = rawNoteData[4]
    self.pitchEndTmb = rawNoteData[5]

    self.startSeconds = self.startBar / tempo * 60
    self.durationSeconds = self.durationBar / tempo * 60
    self.endSeconds = self.endBar / tempo * 60

    self.pitchStartMIDI = tmbNoteToMIDI(self.pitchStartTmb)
    self.pitchEndMIDI = tmbNoteToMIDI(self.pitchEndTmb)
end

function SimpleNote:toString()
    return "Note("
        --.. "startBar=" .. self.startBar .. ", "
        .. "startSeconds=" .. self.startSeconds .. ", "
        .. "pitchStartMIDI=" .. self.pitchStartMIDI .. ", "
        .. ")"
end

-- A Note that can contain multiple pitch changes
class("ModulatedNote").extends("Note")

function ModulatedNote:init(tempo, listOfRawNoteData)
    -- TODO
end

function ModulatedNote:toString()
    -- TODO
end