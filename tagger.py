#!/usr/bin/env python3

# Copyright 2017 Calvin Walton <calvin.walton@kepstin.ca>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import argparse
import logging
import mutagen
import mutagen.apev2
import mutagen.mp3
import mutagen.oggvorbis

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Some constants that'll get reused a bunch...

# ALL-CAPS as used in most tag formats (ID3v2 TXXX, VorbisComment, etc.)
TG_UPPER='REPLAYGAIN_TRACK_GAIN'
TP_UPPER='REPLAYGAIN_TRACK_PEAK'
AG_UPPER='REPLAYGAIN_ALBUM_GAIN'
AP_UPPER='REPLAYGAIN_ALBUM_PEAK'
R128_TG_UPPER='R128_TRACK_GAIN'
R128_AG_UPPER='R128_ALBUM_GAIN'

# 100% guaranteed random case variations
TG_MIXED='rEpLaYGaIn_TrAcK_gAiN'
TP_MIXED='RePLaYgAIn_tRAcK_pEAk'
AG_MIXED='RePlAYgAIn_aLbUM_GAin'
AP_MIXED='rEPlayGaiN_AlBum_PeaK'
R128_TG_MIXED='r128_trAcK_gAiN'
R128_AG_MIXED='R128_aLbUM_GAin'

# The default tag formats (can be overridden by options)
TG=TG_UPPER
TP=TP_UPPER
AG=AG_UPPER
AP=AP_UPPER
R128_TG=R128_TG_UPPER
R128_AG=R128_AG_UPPER

# Format ReplayGain gain adjustment values, either in the standard way
# or with some non-standard distortions
def format_rg_gain(gain, args):
    # Standard format
    return "{:.2f} dB".format(gain)

# Format ReplayGain peak values, again either in the standard way or with
# distortions applied
def format_rg_peak(peak, args):
    # Standard format
    # "Six numeric digits in the decimal field (dddddd) is adequate to
    # accurately represent peak values for 16-bit audio data."
    return "{:.6f}".format(10.0 ** (peak / 20.0))

# Format Ogg Opus R128 gain adjustment values
def format_oggopus_gain(gain, args):
    # The R128 gain tags use a -23LUFS reference rather than -18LUFS
    gain = gain + 5
    # And is a fixed-point value represented as an integer
    gain = int(gain * 256.0)

    if gain < -32768 or gain > 32767:
        logger.warning("Opus gain value %d is out of range", gain)

    # Standard format
    return "{:d}".format(value)


def write_id3(id3, args):
    if args.id3_txxx:
        if args.tg is not None:
            id3.add(mutagen.id3.TXXX(desc=TG, encoding=args.id3v2_encoding,
                text=[format_rg_gain(args.tg, args)]))
        if args.tp is not None:
            id3.add(mutagen.id3.TXXX(desc=TP, encoding=args.id3v2_encoding,
                text=[format_rg_peak(args.tp, args)]))
        if args.ag is not None:
            id3.add(mutagen.id3.TXXX(desc=AG, encoding=args.id3v2_encoding,
                text=[format_rg_gain(args.ag, args)]))
        if args.ap is not None:
            id3.add(mutagen.id3.TXXX(desc=AP, encoding=args.id3v2_encoding,
                text=[format_rg_peak(args.ap, args)]))

    if args.id3_rva2:
        if args.id3v2_version < 4:
            logger.warning("Writing ID3v2.4 RVA2 to an ID3v2.3 file")
        if args.tg is not None:
            if args.tp is not None:
                tp = args.tp
            else:
                logger.warning("Track peak unset, writing 1.0 to RVA2 tag")
                tp = 1.0
            id3.add(mutagen.id3.RVA2(desc='track', channel=1,
                gain=args.tg, peak=tp))
        if args.ag is not None:
            if args.ap is not None:
                ap = args.ap
            else:
                logger.warning("Album peak unset, writing 1.0 to RVA2 tag")
                ap = 1.0
            id3.add(mutagen.id3.RVA2(desc='album', channel=1,
                gain=args.ag, peak=ap))

def write_generic(tags, args):
    if args.tg is not None:
        tags[TG] = [format_rg_gain(args.tg, args)]
    if args.tp is not None:
        tags[TP] = [format_rg_peak(args.tp, args)]
    if args.ag is not None:
        tags[AG] = [format_rg_gain(args.ag, args)]
    if args.ap is not None:
        tags[AP] = [format_rg_peak(args.ap, args)]

def write_vorbiscomment(tags, args):
    if args.vc_standard:
        write_generic(tags, args)

    if args.vc_oggopus:
        if args.tp is not None or args.ap is not None:
            logger.warning("Ogg Opus R128 gain tags do not support peak info")
        
        if args.tg is not None:
            tags[R128_TG] = [format_oggopus_gain(args.tg, args)]
        if args.ag is not None:
            tags[R128_AG] = [format_oggopus_gain(args.ag, args)]

def write_mp3(args):
    mp3 = mutagen.mp3.MP3(args.file)
    write_id3(mp3.tags, args)
    mp3.save(v2_version=args.id3v2_version)

    if args.mp3_apev2:
        apev2 = mutagen.apev2.APEv2File(args.file)
        write_generic(apev2, args)
        apev2.save()

def write_oggvorbis(args):
    oggvorbis = mutagen.oggvorbis.OggVorbis(args.file)
    write_vorbiscomment(oggvorbis.tags, args)
    oggvorbis.save()

parser = argparse.ArgumentParser(description='ReplayGain tag testing tool')

parser.add_argument('file', help='file to update')

# Gain/peak values to write
parser.add_argument('--tg', type=float, help='track gain adjustment (dB)')
parser.add_argument('--tp', type=float, help='track peak level (dBFS)')
parser.add_argument('--ag', type=float, help='album gain adjustment (dB)')
parser.add_argument('--ap', type=float, help='album peak level (dBFS)')

# File format handlers to use
parser.add_argument('--mp3', dest='formats', action='append_const',
        const=write_mp3, help='write MP3 (usually ID3) format tags')
parser.add_argument('--oggvorbis', dest='formats', action='append_const',
        const=write_oggvorbis, help='write Ogg Vorbis native tags')

# Options common to multiple tag formats
parser.add_argument('--mixed-case', action='store_true',
        help='for tag formats that preserve case, use a random mix of case')

# Options for specific tag formats

# MP3/ID3
parser.add_argument('--id3v23', dest='id3v2_version',
        action='store_const', const=3, default=4,
        help='write ID3 tags using version 2.3 instead of 2.4')
parser.add_argument('--id3-txxx', action='store_true',
        help='write ID3 tags using the modern TXXX format')
parser.add_argument('--id3-rva2', action='store_true',
        help='write ID3 tags using RVA2 (ID3v2.4) frames')
parser.add_argument('--id3-latin1', dest='id3v2_encoding',
        action='store_const', const=0, default=1,
        help='write ID3 tags using Latin1 encoding rather than UTF-16')
parser.add_argument('--id3-utf8', dest='id3v2_encoding',
        action='store_const', const=3, default=1,
        help='write ID3v2.4 tags using UTF-8 encoding rather than UTF-16')
parser.add_argument('--mp3-info', action='store_true',
        help='write gain values to the LAME information tag')
parser.add_argument('--mp3-apev2', action='store_true',
        help='write gain values to an APEv2 tag on MP3 (like mp3gain)')

# Multiple formats - VorbisComment
parser.add_argument('--vc', dest='vc_standard', action='store_true',
        help='write VorbisComment tags in standard ReplayGain format')
parser.add_argument('--vc-oggopus', action='store_true',
        help='write VorbisComment tags in Ogg Opus R128 format')

args = parser.parse_args()

if args.mixed_case:
    TG=TG_MIXED
    TP=TP_MIXED
    AG=AG_MIXED
    AP=AP_MIXED
    R128_TG=R128_TG_MIXED
    R128_AG=R128_AG_MIXED

for format in args.formats:
    format(args)
