# trombone-playchamp

A playdate game very heavily inspired by [Trombone Champ](https://www.trombonechamp.com/).

## How to use

Put your files inside `/Sources/Songs` before compiling and running.

The program expects:
* `/Songs/my_song_name/`
  * `song.mp3` The audio file to play (.ogg files are not supported)
  * `song.tmb` The track data containing notes (no official documentation about the format, sadly)

## Compilation

1. Install the SDK from [https://play.date/dev/](https://play.date/dev/)
2. Run `$ pdc src TrombonePlaychamp.pdx`
3. Launch `TrombonePlaychamp.pdx` in the simulator
