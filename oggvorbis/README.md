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
