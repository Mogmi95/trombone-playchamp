class("Song").extends()

function loadSong(songName)
    -- TODO load a specific song
    return Song(songName)
end

function Song:init(songName)
    -- TODO Load JSON from external file
    local tmpNotes = json.decode([[
        {
            "notes": [
                {
                    "time": 1.2,
                    "pitch": 50
                }, 
                {
                    "time": 2.2,
                    "pitch": 75
                },
                {
                    "time": 3,
                    "pitch": 25
                }
            ]
        }
    ]])
    self.songName = songName
    self.notes = tmpNotes["notes"]
end

function Song:start()
    playdate.sound.resetTime()
    -- TODO load and play the sound file
end

function Song:destroy()
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
    -- TODO
end