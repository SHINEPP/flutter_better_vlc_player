import 'package:flutter_better_vlc_player/src/utils/options/vlc_advanced_options.dart';
import 'package:flutter_better_vlc_player/src/utils/options/vlc_audio_options.dart';
import 'package:flutter_better_vlc_player/src/utils/options/vlc_http_options.dart';
import 'package:flutter_better_vlc_player/src/utils/options/vlc_rtp_options.dart';
import 'package:flutter_better_vlc_player/src/utils/options/vlc_stream_output_options.dart';
import 'package:flutter_better_vlc_player/src/utils/options/vlc_subtitle_options.dart';
import 'package:flutter_better_vlc_player/src/utils/options/vlc_video_options.dart';

class VlcPlayerOptions {
  final VlcAdvancedOptions? advanced;
  final VlcAudioOptions? audio;
  final VlcHttpOptions? http;
  final VlcVideoOptions? video;
  final VlcSubtitleOptions? subtitle;
  final VlcRtpOptions? rtp;
  final VlcStreamOutputOptions? sout;
  final List<String>? extras;

  VlcPlayerOptions({
    this.advanced,
    this.audio,
    this.http,
    this.video,
    this.subtitle,
    this.rtp,
    this.sout,
    this.extras,
  });

  List<String> get() {
    final options = <String>[];
    if (advanced != null) options.addAll(advanced?.options ?? []);
    if (audio != null) options.addAll(audio?.options ?? []);
    if (http != null) options.addAll(http?.options ?? []);
    if (video != null) options.addAll(video?.options ?? []);
    if (subtitle != null) options.addAll(subtitle?.options ?? []);
    if (rtp != null) options.addAll(rtp?.options ?? []);
    if (sout != null) options.addAll(sout?.options ?? []);
    if (extras != null) options.addAll(extras ?? []);

    return options;
  }
}
