# Ogg Vorbis Test Vectors

Ogg Vorbis is perhaps the most straightforwards format for handling ReplayGain
tags. There's only one tagging format supported, and only one common method for
encoding the ReplayGain tags in it.

## Recommended

### VorbisComment

The native Ogg Vorbis tagging format. It uses simple key-value pairs to encode the
ReplayGain tags, as specified in the
[Hydrogenaudio ReplayGain specification](http://wiki.hydrogenaud.io/index.php?title=ReplayGain_specification#ID3v2) 
and the
[Hydrogenaudio Replaygain 2.0 specification](http://wiki.hydrogenaud.io/index.php?title=ReplayGain_2.0_specification#ID3v2).

#### Basic functionality

- `track-only.ogg`

  File that has only track gain and peak present. This should play at the
  reference level regardless of whether the player is in track or album mode.
  If no gain is applied, it will play back too quietly.

  track gain: 12 dB, track peak: 0.251189, album gain & peak not set.

- `track.ogg`

  File for testing the application's track mode setting. It should play at the
  reference level if the player is in track mode. It will play too quietly if
  the album gain is used, and too loud if no gain is applied.

  track gain: -12 dB, track peak: 1.0, album gain: -24 dB, album peak: 1.0

- `album.ogg`

  File for testing the application's album mode setting. It should play at the
  reference level if the player is in album mode. It will play too quietly if
  the track gain is used, and too loud if no gain is applied.

  track gain: -24 dB, track peak: 1.0, album gain: -12 dB, album peak: 1.0

#### Clipping prevention

These files are designed to verify the behaviour of the players clipping
prevention support, which should be a configurable option that allows selecting
between lowering the gain based on stored peak value ReplayGain tags, or
keeping the desired level and applying an audio limiter or compression filter
to reduce audible artifacts.

- `track-nopeak.ogg` and `album-nopeak.ogg`

  These test files are designed to verify that the player allows raising the
  gain past the maximum headroom indicated when the player is configured not
  to reduce gain on tracks which might clip.

  The first file tests track mode; the second covers album mode. In both cases,
  the files will play too quietly if peak limiting is applied, and at the
  reference level if the peak values are correctly ignored.

  `track-nopeak`: track gain: 12 dB, track peak: 1.0,
                  album gain: 0 dB, album peak: 3.981072

  `album-nopeak`: track gain: 24 dB, track peak: 0.063096, 
                  album gain: 12 dB, album peak: 1.0

- `peak.ogg`

  This test file verifies that the player will reduce the playgain gain based
  on the stored peak value when the gain reduction feature is enabled.

  The same test file is used for both album and track mode. In track mode, the
  file should play back at the reference level. In album mode, the file should
  play back quieter than the reference level (match the `reference-12` file).

  If the gains are switched (track mode is quiet, album mode is reference),
  then the wrong peak values are being used. If the playback is loud, then
  the peak values are not being applied.

  track gain: 24 dB, track peak: 0.251189,
  album gain: 24 dB, album peak: 0.063096

#### ReplayGain tag formatting

The modern ReplayGain tag spec gives a specific format to use for the tags,
but tag-writing applications have significant variations in the formats
they actually use. These tests verify the robustness of the tag parser.

- `case.ogg`

  Verify that the `REPLAYGAIN_*_GAIN` tags are matched case-insensitively.

  In track mode this file will play back at the reference level. In album
  mode it will play back at 12 dB quieter than the reference level. If the
  tags aren't read correctly it will play back 12 dB louder than the
  reference level.

  track gain: -12 dB, track peak: 1.0, album gain: -24 dB, album peak: 1.0
