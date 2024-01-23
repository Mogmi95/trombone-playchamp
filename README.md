# trombone-playchamp

A playdate game very heavily inspired by [Trombone Champ](https://www.trombonechamp.com/).


## Adding songs
Songs must be added manually to the playdate to play the game. This is done by following these steps:
- Start the game once 
- Restart the playdate as a USB device (settings>System>Reboot to Data Disk)
- Plug the playdate into a computer. The playdate filesystem should be visible as a USB drive.
- In the `Data` directory, find the directory with a name ending with `fr.mogmi.playdate.trombone`. It should contain a `Songs` folder, to which you can now copy any song data.

Each song is a directory `Data/<...>fr.mogmi.playdate.trombone/Songs/my_song_name/` containing:
  * `song.mp3` The audio file to play (.ogg files are not supported)
  * `song.tmb` The track data containing notes (no official documentation about the format, sadly)


## Compilation

1. Install the SDK from [https://play.date/dev/](https://play.date/dev/)
2. Run `$ pdc Source TrombonePlaychamp.pdx`
3. Launch `TrombonePlaychamp.pdx` in the simulator
