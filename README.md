# ReplayGain Test Vectors

This is a set of test files that can be used to verify that a player
implementing ReplayGain behaves correctly with a variety of audio codecs,
container formats, unusual (and sometimes broken!) metadata tags, etc.

## Downloading the Samples

The git repository does not contain a complete set of samples when cloned.
If you simply want to use the samples to test a music player, please download
the latest zip file from:
https://github.com/kepstin/replaygain-test-vectors/releases
to get a complete set of samples.

## Building the Samples

The git repository contains a master audio file that the samples are generated
from, and a set of scripts to set ReplayGain tags in various formats.

In order to generate the samples, please make sure you have recent versions of
the following software available:

- ffmpeg (>=3.2 or a recent git snapshot), with support for libmp3lame, libopus,
  libvorbis and the full set of built-in GPL codecs enabled.
- mutagen (>=1.34, for python 3)

If the tools are available, you can simply run `make` at the top level, and
the sample files will be generated.

## About the Audio

The audio used as the reference track is by Broke For Free, from the album
Petal (2014). This is a short segment of track 2, "Summer Spliffs".
The track is licensed under CC-BY 3.0, and can be downloaded or purchased
at https://brokeforfree.bandcamp.com/track/summer-spliffs

## About the Reference Track and Levels

The file named `reference` is the reference audio track. It has been normalized
to have a ReplayGain value of 0.0 dB (when using Replay Gain 2.0, with the
EBU-R128 algorithm).

## Using the Audio Samples

The audio samples are split into subdirectories by file format. In each
subdirectory, you'll find a README.md specific to the file format that lists
all of the samples, and the expected behaviour for each. There is also a copy
of the `reference` file in that format, alongside the 12dB louder and 12dB
quieter versions, `reference+12` and `reference-12`.

The individual test files are generally encoded either 12 dB louder or 12 dB
quieter than the reference file, and use ReplayGain tags such that they play
at the same level as the reference file (but see individual sample notes).

Since the test files may be up to 12 dB louder than the reference file and
are intended to exercise bugs, be careful when listening using headphones!
The file `reference+12` should play at a comfortable level.

Samples are classified as follows:

- **Recommended**
  
  These samples represent common "in the wild" ReplayGain tagging formats.
  Most users would expect these files to have their loudness interpreted
  correctly in a modern player.

- **Optional**

  These samples represent older or uncommon tagging formats that you should
  probably support if doing so would not require an excess of effort or cause
  other issues.

- **Obscure**

  These samples represent strange legacy formats that most modern players don't
  support. If you don't plan to support these formats, you should at least
  make sure the tags are being ignored correctly.

Tests are present to verify the following features for most tagging formats:

- Ensure track gain and album gain are applied correctly, depending on player
  configuration.
- Ensure that newer, standard tags are preferred over older formats when
  conflicting tags are present.
- Ensure that errors in tag formatting are handled correctly.
- Ensure that the peak limiting feature in the player works correctly in both
  on and off states.
