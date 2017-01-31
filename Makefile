# This Makefile is used to generate some of the samples automatically based
# on the file reference.flac. It requires a very recent version of ffmpeg
# for correct operation.

CP = cp --reflink=auto
FFMPEG = ffmpeg
MKDIR_P = mkdir -p
RM_F = rm -f

VOL_PLUS_12 = -af volume=+12dB
VOL_MINUS_12 = -af volume=-12dB
FFMPEG_OPTS = -v error -nostats -nostdin -hide_banner -map_metadata -1 -y
FFMPEG_FLAC = -c flac -sample_fmt s16 -f flac
FFMPEG_MP3_VBR = -c libmp3lame -q 4 -f mp3
FFMPEG_MP3_CBR = -c libmp3lame -b:a 160K -f mp3
FFMPEG_MP4_ALAC = -c alac -f ipod
FFMPEG_MP4_AAC = -c aac -b 192K -f ipod
FFMPEG_OGG_VORBIS = -c libvorbis -q 4 -f ogg
FFMPEG_WAV = -c pcm_s16le -f wav

FFMPEG_CMD = $(FFMPEG) -i $< $(FFMPEG_OPTS) $(FFMPEG_FORMAT) $@

.PHONY: default
default:

FLAC_SAMPLES = flac/reference.flac \
	       flac/reference+12.flac \
	       flac/reference-12.flac
ALL_SAMPLES += $(FLAC_SAMPLES)

flac:
	$(MKDIR_P) flac

flac/reference.flac: FFMPEG_FORMAT = $(FFMPEG_FLAC)
flac/reference.flac: reference.flac | flac
	$(FFMPEG_CMD)

flac/reference+12.flac: FFMPEG_FORMAT = $(VOL_PLUS_12) $(FFMPEG_FLAC)
flac/reference+12.flac: reference.flac | flac
	$(FFMPEG_CMD)

flac/reference-12.flac: FFMPEG_FORMAT = $(VOL_MINUS_12) $(FFMPEG_FLAC)
flac/reference-12.flac: reference.flac | flac
	$(FFMPEG_CMD)

MP3_SAMPLES = mp3/reference.mp3 \
	      mp3/reference+12.mp3 \
	      mp3/reference-12.mp3 \
	      mp3/id3v24-txxx-track-only.mp3 \
	      mp3/id3v23-txxx-track-only.mp3 \
	      mp3/id3v24-txxx-track.mp3 \
	      mp3/id3v23-txxx-track.mp3 \
	      mp3/id3v24-txxx-album.mp3 \
	      mp3/id3v23-txxx-album.mp3 \
	      mp3/id3v23-txxx-track-nopeak.mp3 \
	      mp3/id3v23-txxx-album-nopeak.mp3 \
	      mp3/id3v23-txxx-peak.mp3 \
	      mp3/id3v23-txxx-latin1.mp3 \
	      mp3/id3v24-txxx-utf8.mp3 \
	      mp3/id3v23-txxx-case.mp3 \
	      mp3/apev2-track-only.mp3 \
	      mp3/apev2-track-prefer-id3-txxx.mp3

ALL_SAMPLES += $(MP3_SAMPLES)

.PHONY: clean_mp3
clean_mp3:
	$(RM_F) mp3/*.mp3

mp3/reference.mp3: FFMPEG_FORMAT = $(FFMPEG_MP3_VBR)
mp3/reference.mp3: flac/reference.flac
	$(FFMPEG_CMD)

mp3/reference+12.mp3: FFMPEG_FORMAT = $(FFMPEG_MP3_VBR)
mp3/reference+12.mp3: flac/reference+12.flac
	$(FFMPEG_CMD)

mp3/reference-12.mp3: FFMPEG_FORMAT = $(FFMPEG_MP3_VBR)
mp3/reference-12.mp3: flac/reference-12.flac
	$(FFMPEG_CMD)

mp3/id3v24-txxx-track-only.mp3: mp3/reference-12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3-txxx --tg 12 --tp -12 $@

mp3/id3v23-txxx-track-only.mp3: mp3/reference-12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3v23 --id3-txxx --tg 12 --tp -12 $@

mp3/id3v24-txxx-track.mp3: mp3/reference+12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3-txxx --tg -12 --tp 0 --ag -24 --ap 0 $@

mp3/id3v23-txxx-track.mp3: mp3/reference+12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3v23 --id3-txxx --tg -12 --tp 0 --ag -24 --ap 0 $@

mp3/id3v24-txxx-album.mp3: mp3/reference+12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3-txxx --tg -24 --tp 0 --ag -12 --ap 0 $@

mp3/id3v23-txxx-album.mp3: mp3/reference+12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3v23 --id3-txxx --tg -24 --tp 0 --ag -12 --ap 0 $@

mp3/id3v23-txxx-track-nopeak.mp3: mp3/reference-12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3v23 --id3-txxx --tg 12 --tp 0 --ag 0 --ap 12 $@

mp3/id3v23-txxx-album-nopeak.mp3: mp3/reference-12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3v23 --id3-txxx --tg 24 --tp -24 --ag 12 --ap 0 $@

mp3/id3v23-txxx-peak.mp3: mp3/reference+12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3v23 --id3-txxx --tg 0 --tp 12 --ag 0 --ap 24 $@

mp3/id3v23-txxx-latin1.mp3: mp3/reference-12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3v23 --id3-latin1 --id3-txxx --tg 12 --tp -12 $@

mp3/id3v24-txxx-utf8.mp3: mp3/reference-12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3-utf8 --id3-txxx --tg 12 --tp -12 $@

mp3/id3v23-txxx-case.mp3: mp3/reference+12.mp3
	$(CP) $< $@ && \
	./tagger.py --mixed-case --mp3 --id3v23 --id3-txxx --tg -12 --tp 0 --ag -24 --ap 0 $@

mp3/apev2-track-only.mp3: mp3/reference-12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --mp3-apev2 --tg 12 --tp -12 $@

mp3/apev2-track-prefer-id3-txxx.mp3: mp3/reference+12.mp3
	$(CP) $< $@ && \
	./tagger.py --mp3 --id3-txxx --tg -12 --tp 0 --ag 0 --ap 0 $@ && \
	./tagger.py --mp3 --mp3-apev2 --tg -24 --tp 0 --ag 0 --ap 0 $@

OGG_VORBIS_SAMPLES = oggvorbis/reference.ogg \
		     oggvorbis/reference+12.ogg \
		     oggvorbis/reference-12.ogg \
		     oggvorbis/track-only.ogg \
		     oggvorbis/track.ogg \
		     oggvorbis/album.ogg \
		     oggvorbis/track-nopeak.ogg \
		     oggvorbis/album-nopeak.ogg \
		     oggvorbis/peak.ogg

ALL_SAMPLES += $(OGG_VORBIS_SAMPLES)

.PHONY: clean_oggvorbis
clean_oggvorbis:
	$(RM_F) oggvorbis/*.ogg

oggvorbis/reference.ogg: FFMPEG_FORMAT = $(FFMPEG_OGG_VORBIS)
oggvorbis/reference.ogg: flac/reference.flac
	$(FFMPEG_CMD)

oggvorbis/reference+12.ogg: FFMPEG_FORMAT = $(FFMPEG_OGG_VORBIS)
oggvorbis/reference+12.ogg: flac/reference+12.flac
	$(FFMPEG_CMD)

oggvorbis/reference-12.ogg: FFMPEG_FORMAT = $(FFMPEG_OGG_VORBIS)
oggvorbis/reference-12.ogg: flac/reference-12.flac
	$(FFMPEG_CMD)

oggvorbis/track-only.ogg: oggvorbis/reference-12.ogg
	$(CP) $< $@ && \
	./tagger.py --oggvorbis --vc --tg 12 --tp -12 $@

oggvorbis/track.ogg: oggvorbis/reference+12.ogg
	$(CP) $< $@ && \
	./tagger.py --oggvorbis --vc --tg -12 --tp 0 --ag -24 --ap 0 $@

oggvorbis/album.ogg: oggvorbis/reference+12.ogg
	$(CP) $< $@ && \
	./tagger.py --oggvorbis --vc --tg -24 --tp 0 --ag -12 --ap 0 $@

oggvorbis/track-nopeak.ogg: oggvorbis/reference-12.ogg
	$(CP) $< $@ && \
	./tagger.py --oggvorbis --vc --tg 12 --tp 0 --ag 0 --ap 12 $@

oggvorbis/album-nopeak.ogg: oggvorbis/reference-12.ogg
	$(CP) $< $@ && \
	./tagger.py --oggvorbis --vc --tg 24 --tp -24 --ag 12 --ap 0 $@

oggvorbis/peak.ogg: oggvorbis/reference+12.ogg
	$(CP) $< $@ && \
	./tagger.py --oggvorbis --vc --tg 0 --tp 12 --ag 0 --ap 24 $@

default: $(ALL_SAMPLES)

$(ALL_SAMPLES): tagger.py Makefile

.PHONY: clean
clean: clean_mp3 clean_oggvorbis
