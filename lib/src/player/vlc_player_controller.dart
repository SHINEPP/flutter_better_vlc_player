import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_better_vlc_player/flutter_better_vlc_player.dart';
import 'package:flutter_better_vlc_player/src/player/vlc_app_life_cycle_observer.dart';

/// Controls a platform vlc player, and provides updates when the state is
/// changing.
///
/// Instances must be initialized with initialize.
///
/// The video is displayed in a Flutter app by creating a [VlcPlayer] widget.
///
/// To reclaim the resources used by the player call [dispose].
///
/// After [dispose] all further calls are ignored.
class VlcPlayerController extends ValueNotifier<VlcPlayerValue> {
  static const _maxVolume = 100;

  /// The URI to the video file. This will be in different formats depending on
  /// the [DataSourceType] of the original video.
  final String dataSource;

  /// Set hardware acceleration for player. Default is Automatic.
  final HwAcc hwAcc;

  /// Adds options to vlc. For more [https://wiki.videolan.org/VLC_command-line_help] If nothing is provided,
  /// vlc will run without any options set.
  final VlcPlayerOptions? options;

  /// The video should be played automatically.
  final bool autoPlay;

  /// Set keep playing video in background, when app goes in background.
  /// The default value is false.
  final bool allowBackgroundPlayback;

  /// Only set for [asset] videos. The package that the asset was loaded from.
  String? package;

  DataSourceType _dataSourceType;

  /// The viewId for this controller
  int _viewId = -1;

  /// List of onInit listeners
  final List<VoidCallback> _onInitListeners = [];

  /// List of onRenderer listeners
  final List<RendererCallback> _onRendererEventListeners = [];

  bool _isDisposed = false;

  VlcAppLifeCycleObserver? _lifeCycleObserver;

  /// Describes the type of data source this [VlcPlayerController]
  /// is constructed with.
  DataSourceType get dataSourceType => _dataSourceType;

  /// This is just exposed for testing. It shouldn't be used by anyone depending
  /// on the plugin.
  int? get viewId => _viewId == -1 ? null : _viewId;

  final _initCompleter = Completer<void>();

  VlcPlayerController({
    required this.dataSource,
    required DataSourceType dataSourceType,
    this.allowBackgroundPlayback = false,
    this.package,
    this.hwAcc = HwAcc.auto,
    this.autoPlay = true,
    this.options,
    Duration duration = Duration.zero,
  }) : _dataSourceType = dataSourceType,
       super(VlcPlayerValue(duration: duration)) {
    _initialize(autoPlay);
  }

  factory VlcPlayerController.asset(
    String dataSource, {
    bool allowBackgroundPlayback = false,
    String? package,
    HwAcc hwAcc = HwAcc.auto,
    bool autoPlay = true,
    VlcPlayerOptions? options,
  }) {
    return VlcPlayerController(
      dataSource: dataSource,
      dataSourceType: DataSourceType.asset,
      allowBackgroundPlayback: allowBackgroundPlayback,
      package: package,
      hwAcc: hwAcc,
      autoPlay: autoPlay,
      options: options,
    );
  }

  factory VlcPlayerController.network(
    String dataSource, {
    bool allowBackgroundPlayback = false,
    String? package,
    HwAcc hwAcc = HwAcc.auto,
    bool autoPlay = true,
    VlcPlayerOptions? options,
  }) {
    return VlcPlayerController(
      dataSource: dataSource,
      dataSourceType: DataSourceType.network,
      allowBackgroundPlayback: allowBackgroundPlayback,
      package: package,
      hwAcc: hwAcc,
      autoPlay: autoPlay,
      options: options,
    );
  }

  factory VlcPlayerController.file(
    File file, {
    bool allowBackgroundPlayback = true,
    HwAcc hwAcc = HwAcc.auto,
    bool autoPlay = true,
    VlcPlayerOptions? options,
  }) {
    return VlcPlayerController(
      dataSource: 'file://${file.path}',
      dataSourceType: DataSourceType.file,
      allowBackgroundPlayback: allowBackgroundPlayback,
      package: null,
      hwAcc: hwAcc,
      autoPlay: autoPlay,
      options: options,
    );
  }

  /// Register a [VoidCallback] closure to be called when the controller gets initialized
  void addOnInitListener(VoidCallback listener) {
    _onInitListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of onInit closures
  void removeOnInitListener(VoidCallback listener) {
    _onInitListeners.remove(listener);
  }

  /// Register a [RendererCallback] closure to be called when a cast renderer device gets attached/detached
  void addOnRendererEventListener(RendererCallback listener) {
    _onRendererEventListeners.add(listener);
  }

  /// Remove a previously registered closure from the list of OnRendererEvent closures
  void removeOnRendererEventListener(RendererCallback listener) {
    _onRendererEventListeners.remove(listener);
  }

  /// init
  _initialize(bool autoPlay) async {
    _viewId = await VlcPlayerPlatform.instance.create(
      uri: dataSource,
      type: dataSourceType,
      package: package,
      hwAcc: hwAcc,
      autoPlay: autoPlay,
      options: options,
    );

    VlcPlayerPlatform.instance
        .mediaEventsFor(_viewId)
        .listen(_onMediaEventListener, onError: _onMediaErrorListener);

    VlcPlayerPlatform.instance
        .rendererEventsFor(_viewId)
        .listen(_onRendererEventListener);

    if (!allowBackgroundPlayback) {
      _lifeCycleObserver = VlcAppLifeCycleObserver(this)..initialize();
    }

    if (!_initCompleter.isCompleted) {
      _initCompleter.complete(null);
    }

    value = value.copyWith(
      isInitialized: true,
      playingState: PlayingState.initialized,
    );

    _notifyOnInitListeners();

    if (autoPlay) {
      play();
    }

    return _initCompleter.future;
  }

  void _onMediaEventListener(VlcMediaEvent event) {
    if (_isDisposed) {
      return;
    }

    switch (event.mediaEventType) {
      case VlcMediaEventType.opening:
        value = value.copyWith(
          isPlaying: false,
          isBuffering: true,
          isEnded: false,
          playingState: PlayingState.buffering,
          errorDescription: VlcPlayerValue.noError,
        );
      case VlcMediaEventType.paused:
        value = value.copyWith(
          isPlaying: false,
          isBuffering: false,
          playingState: PlayingState.paused,
        );
      case VlcMediaEventType.stopped:
        value = value.copyWith(
          isPlaying: false,
          isBuffering: false,
          isRecording: false,
          playingState: PlayingState.stopped,
          position: Duration.zero,
        );
      case VlcMediaEventType.playing:
        value = value.copyWith(
          isEnded: false,
          isPlaying: true,
          isBuffering: false,
          playingState: PlayingState.playing,
          duration: event.duration,
          size: event.size,
          playbackSpeed: event.playbackSpeed,
          audioTracksCount: event.audioTracksCount,
          activeAudioTrack: event.activeAudioTrack,
          spuTracksCount: event.spuTracksCount,
          activeSpuTrack: event.activeSpuTrack,
          errorDescription: VlcPlayerValue.noError,
        );
      case VlcMediaEventType.ended:
        value = value.copyWith(
          isPlaying: false,
          isBuffering: false,
          isEnded: true,
          isRecording: false,
          playingState: PlayingState.ended,
          position: event.position,
        );
      case VlcMediaEventType.buffering:
      case VlcMediaEventType.timeChanged:
        value = value.copyWith(
          isEnded: false,
          isBuffering: event.mediaEventType == VlcMediaEventType.buffering,
          position: event.position,
          duration: event.duration,
          playbackSpeed: event.playbackSpeed,
          bufferPercent: event.bufferPercent,
          size: event.size,
          audioTracksCount: event.audioTracksCount,
          activeAudioTrack: event.activeAudioTrack,
          spuTracksCount: event.spuTracksCount,
          activeSpuTrack: event.activeSpuTrack,
          isPlaying: event.isPlaying,
          playingState:
              (event.isPlaying ?? false)
                  ? PlayingState.playing
                  : value.playingState,
          errorDescription: VlcPlayerValue.noError,
        );
      case VlcMediaEventType.mediaChanged:
        break;

      case VlcMediaEventType.recording:
        value = value.copyWith(
          playingState: PlayingState.recording,
          isRecording: event.isRecording,
          recordPath: event.recordPath,
        );
      case VlcMediaEventType.error:
        value = value.copyWith(
          isPlaying: false,
          isBuffering: false,
          isEnded: false,
          playingState: PlayingState.error,
          errorDescription: VlcPlayerValue.unknownError,
        );
      case VlcMediaEventType.unknown:
        break;
    }
  }

  void _onMediaErrorListener(Object obj) {
    if (_isDisposed) {
      return;
    }
    value = VlcPlayerValue.erroneous(obj.toString());
    if (!_initCompleter.isCompleted) {
      _initCompleter.completeError(obj);
    }
  }

  void _onRendererEventListener(VlcRendererEvent event) {
    if (_isDisposed) {
      return;
    }
    switch (event.eventType) {
      case VlcRendererEventType.attached:
      case VlcRendererEventType.detached:
        _notifyOnRendererListeners(
          event.eventType,
          event.rendererId,
          event.rendererName,
        );
      case VlcRendererEventType.unknown:
        break;
    }
  }

  /// Notify onInit callback & all registered listeners
  void _notifyOnInitListeners() {
    for (final listener in _onInitListeners) {
      listener();
    }
  }

  /// Notify onRendererHandler callback & all registered listeners
  void _notifyOnRendererListeners(
    VlcRendererEventType type,
    String? id,
    String? name,
  ) {
    if (id != null && name != null) {
      for (final listener in _onRendererEventListeners) {
        listener(type, id, name);
      }
    }
  }

  /// This stops playback and changes the data source. Once the new data source has been loaded, the playback state will revert to
  /// its state before the method was called. (i.e. if this method is called whilst media is playing, once the new
  /// data source has been loaded, the new stream will begin playing.)
  /// [dataSource] - the path of the asset file.
  Future<void> setMediaFromAsset(
    String dataSource, {
    String? package,
    bool? autoPlay,
    HwAcc? hwAcc,
  }) async {
    _dataSourceType = DataSourceType.asset;
    this.package = package;
    await _setStreamUrl(
      dataSource,
      dataSourceType: DataSourceType.asset,
      package: package,
      autoPlay: autoPlay,
      hwAcc: hwAcc,
    );
  }

  /// This stops playback and changes the data source. Once the new data source has been loaded, the playback state will revert to
  /// its state before the method was called. (i.e. if this method is called whilst media is playing, once the new
  /// data source has been loaded, the new stream will begin playing.)
  /// [dataSource] - the URL of the stream to start playing.
  Future<void> setMediaFromNetwork(
    String dataSource, {
    bool? autoPlay,
    HwAcc? hwAcc,
  }) async {
    _dataSourceType = DataSourceType.network;
    package = null;
    await _setStreamUrl(
      dataSource,
      dataSourceType: DataSourceType.network,
      autoPlay: autoPlay,
      hwAcc: hwAcc,
    );
  }

  /// This stops playback and changes the data source. Once the new data source has been loaded, the playback state will revert to
  /// its state before the method was called. (i.e. if this method is called whilst media is playing, once the new
  /// data source has been loaded, the new stream will begin playing.)
  /// [file] - the File stream to start playing.
  Future<void> setMediaFromFile(
    File file, {
    bool? autoPlay,
    HwAcc? hwAcc,
  }) async {
    _dataSourceType = DataSourceType.file;
    package = null;
    final dataSource = 'file://${file.path}';
    await _setStreamUrl(
      dataSource,
      dataSourceType: DataSourceType.file,
      autoPlay: autoPlay,
      hwAcc: hwAcc,
    );
  }

  /// This stops playback and changes the data source. Once the new data source has been loaded, the playback state will revert to
  /// its state before the method was called. (i.e. if this method is called whilst media is playing, once the new
  /// data source has been loaded, the new stream will begin playing.)
  /// [dataSource] - the URL of the stream to start playing.
  /// [dataSourceType] - the source type of media.
  Future<void> _setStreamUrl(
    String dataSource, {
    required DataSourceType dataSourceType,
    String? package,
    bool? autoPlay,
    HwAcc? hwAcc,
  }) async {
    await _initCompleter.future;
    _throwIfNotInitialized('setStreamUrl');
    await VlcPlayerPlatform.instance.stop(_viewId);
    await VlcPlayerPlatform.instance.setStreamUrl(
      _viewId,
      uri: dataSource,
      type: dataSourceType,
      package: package,
      hwAcc: hwAcc ?? HwAcc.auto,
      autoPlay: autoPlay ?? true,
    );
    return;
  }

  /// Starts playing the video.
  ///
  /// This method returns a future that completes as soon as the "play" command
  /// has been sent to the platform, not when playback itself is totally
  /// finished.
  Future<void> play() async {
    await _initCompleter.future;
    _throwIfNotInitialized('play');

    await VlcPlayerPlatform.instance.play(_viewId);
    // This ensures that the correct playback speed is always applied when
    // playing back. This is necessary because we do not set playback speed
    // when paused.
    await setPlaybackSpeed(value.playbackSpeed);
  }

  /// Pauses the video.
  Future<void> pause() async {
    await _initCompleter.future;
    _throwIfNotInitialized('pause');
    await VlcPlayerPlatform.instance.pause(_viewId);
  }

  /// stops the video.
  Future<void> stop() async {
    await _initCompleter.future;
    _throwIfNotInitialized('stop');
    await VlcPlayerPlatform.instance.stop(_viewId);
  }

  /// Sets whether or not the video should loop after playing once.
  Future<void> setLooping(bool looping) async {
    await _initCompleter.future;
    _throwIfNotInitialized('setLooping');
    value = value.copyWith(isLooping: looping);
    await VlcPlayerPlatform.instance.setLooping(_viewId, looping);
  }

  /// Returns true if media is playing.
  Future<bool?> isPlaying() async {
    await _initCompleter.future;
    _throwIfNotInitialized('isPlaying');
    return VlcPlayerPlatform.instance.isPlaying(_viewId);
  }

  /// Returns true if media is seekable.
  Future<bool?> isSeekable() async {
    await _initCompleter.future;
    _throwIfNotInitialized('isSeekable');
    return VlcPlayerPlatform.instance.isSeekable(_viewId);
  }

  /// Set video timestamp in millisecond
  Future<void> setTime(int time) async {
    return seekTo(Duration(milliseconds: time));
  }

  /// Sets the video's current timestamp to be at [moment]. The next
  /// time the video is played it will resume from the given [moment].
  ///
  /// If [moment] is outside of the video's full range it will be automatically
  /// and silently clamped.
  Future<void> seekTo(Duration position) async {
    await _initCompleter.future;
    _throwIfNotInitialized('seekTo');
    final Duration newPosition;
    if (position > value.duration) {
      newPosition = value.duration;
    } else if (position < Duration.zero) {
      newPosition = Duration.zero;
    } else {
      newPosition = position;
    }
    await VlcPlayerPlatform.instance.seekTo(_viewId, newPosition);
  }

  /// Get the video timestamp in millisecond
  Future<int> getTime() async {
    final position = await getPosition();
    return position.inMilliseconds;
  }

  /// Returns the position in the current video.
  Future<Duration> getPosition() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getPosition');
    final position = await VlcPlayerPlatform.instance.getPosition(_viewId);
    value = value.copyWith(position: position);
    return position;
  }

  /// Sets the audio volume of
  ///
  /// [volume] indicates a value between 0 (silent) and 100 (full volume) on a
  /// linear scale.
  Future<void> setVolume(int volume) async {
    await _initCompleter.future;
    _throwIfNotInitialized('setVolume');
    value = value.copyWith(volume: volume.clamp(0, _maxVolume));
    await VlcPlayerPlatform.instance.setVolume(_viewId, value.volume);
  }

  /// Returns current vlc volume level.
  Future<int?> getVolume() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getVolume');
    final volume = await VlcPlayerPlatform.instance.getVolume(_viewId);
    value = value.copyWith(volume: volume?.clamp(0, _maxVolume));
    return volume;
  }

  /// Returns duration/length of loaded video
  Future<Duration> getDuration() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getDuration');
    final duration = await VlcPlayerPlatform.instance.getDuration(_viewId);
    value = value.copyWith(duration: duration);
    return duration;
  }

  /// Sets the playback speed.
  ///
  /// [speed] - the rate at which VLC should play media.
  /// For reference:
  /// 2.0 is double speed.
  /// 1.0 is normal speed.
  /// 0.5 is half speed.
  Future<void> setPlaybackSpeed(double speed) async {
    if (speed < 0) {
      throw ArgumentError.value(
        speed,
        'Negative playback speeds are not supported.',
      );
    } else if (speed == 0) {
      throw ArgumentError.value(
        speed,
        'Zero playback speed is not supported. Consider using [pause].',
      );
    }
    await _initCompleter.future;
    _throwIfNotInitialized('setPlaybackSpeed');
    // Setting the playback speed on iOS will trigger the video to play. We
    // prevent this from happening by not applying the playback speed until
    // the video is manually played from Flutter.
    if (value.isPlaying) {
      value = value.copyWith(playbackSpeed: speed);
      await VlcPlayerPlatform.instance.setPlaybackSpeed(
        _viewId,
        value.playbackSpeed,
      );
    }
  }

  /// Returns the vlc playback speed.
  Future<double?> getPlaybackSpeed() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getPlaybackSpeed');
    final speed = await VlcPlayerPlatform.instance.getPlaybackSpeed(_viewId);
    value = value.copyWith(playbackSpeed: speed);
    return speed;
  }

  /// Return the number of subtitle tracks (both embedded and inserted)
  Future<int?> getSpuTracksCount() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getSpuTracksCount');
    final spuTracksCount = await VlcPlayerPlatform.instance.getSpuTracksCount(
      _viewId,
    );
    value = value.copyWith(spuTracksCount: spuTracksCount);
    return spuTracksCount;
  }

  /// Return all subtitle tracks as array of <Int, String>
  /// The key parameter is the index of subtitle which is used for changing subtitle
  /// and the value is the display name of subtitle
  Future<Map<int, String>> getSpuTracks() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getSpuTracks');
    return VlcPlayerPlatform.instance.getSpuTracks(_viewId);
  }

  /// Change active subtitle index (set -1 to disable subtitle).
  /// [spuTrackNumber] - the subtitle index obtained from getSpuTracks()
  Future<void> setSpuTrack(int spuTrackNumber) async {
    await _initCompleter.future;
    _throwIfNotInitialized('setSpuTrack');
    return VlcPlayerPlatform.instance.setSpuTrack(_viewId, spuTrackNumber);
  }

  /// Returns active spu track index
  Future<int?> getSpuTrack() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getSpuTrack');
    final activeSpuTrack = await VlcPlayerPlatform.instance.getSpuTrack(
      _viewId,
    );
    value = value.copyWith(activeSpuTrack: activeSpuTrack);
    return activeSpuTrack;
  }

  /// [spuDelay] - the amount of time in milliseconds which vlc subtitle should be delayed.
  /// (both positive & negative value applicable)
  Future<void> setSpuDelay(int spuDelay) async {
    await _initCompleter.future;
    _throwIfNotInitialized('setSpuDelay');
    value = value.copyWith(spuDelay: spuDelay);
    return VlcPlayerPlatform.instance.setSpuDelay(_viewId, spuDelay);
  }

  /// Returns the amount of subtitle time delay.
  Future<int?> getSpuDelay() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getSpuDelay');
    final spuDelay = await VlcPlayerPlatform.instance.getSpuDelay(_viewId);
    value = value.copyWith(spuDelay: spuDelay);
    return spuDelay;
  }

  /// Add extra network subtitle to media.
  /// [dataSource] - Url of subtitle
  /// [isSelected] - Set true if you wanna force the added subtitle to start display on media.
  Future<void> addSubtitleFromNetwork(
    String dataSource, {
    bool? isSelected,
  }) async {
    return _addSubtitleTrack(
      dataSource,
      dataSourceType: DataSourceType.network,
      isSelected: isSelected ?? true,
    );
  }

  /// Add extra subtitle file to media.
  /// [file] - Subtitle file
  /// [isSelected] - Set true if you wanna force the added subtitle to start display on media.
  Future<void> addSubtitleFromFile(File file, {bool? isSelected}) async {
    return _addSubtitleTrack(
      'file://${file.path}',
      dataSourceType: DataSourceType.file,
      isSelected: isSelected ?? true,
    );
  }

  /// Add extra subtitle to media.
  /// [uri] - URI of subtitle
  /// [isSelected] - Set true if you wanna force the added subtitle to start display on media.
  Future<void> _addSubtitleTrack(
    String uri, {
    required DataSourceType dataSourceType,
    bool? isSelected,
  }) async {
    await _initCompleter.future;
    _throwIfNotInitialized('addSubtitleTrack');
    return VlcPlayerPlatform.instance.addSubtitleTrack(
      _viewId,
      uri: uri,
      type: dataSourceType,
      isSelected: isSelected ?? true,
    );
  }

  /// Returns the number of audio tracks
  Future<int?> getAudioTracksCount() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getAudioTracksCount');
    final audioTracksCount = await VlcPlayerPlatform.instance
        .getAudioTracksCount(_viewId);
    value = value.copyWith(audioTracksCount: audioTracksCount);
    return audioTracksCount;
  }

  /// Returns all audio tracks as array of <Int, String>
  /// The key parameter is the index of audio track which is used for changing audio
  /// and the value is the display name of audio
  Future<Map<int, String>> getAudioTracks() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getAudioTracks');
    return VlcPlayerPlatform.instance.getAudioTracks(_viewId);
  }

  /// Returns active audio track index
  Future<int?> getAudioTrack() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getAudioTrack');
    final activeAudioTrack = await VlcPlayerPlatform.instance.getAudioTrack(
      _viewId,
    );
    value = value.copyWith(activeAudioTrack: activeAudioTrack);
    return activeAudioTrack;
  }

  /// Change active audio track index (set -1 to mute).
  /// [audioTrackNumber] - the audio track index obtained from getAudioTracks()
  Future<void> setAudioTrack(int audioTrackNumber) async {
    await _initCompleter.future;
    _throwIfNotInitialized('setAudioTrack');
    return VlcPlayerPlatform.instance.setAudioTrack(_viewId, audioTrackNumber);
  }

  /// [audioDelay] - the amount of time in milliseconds which vlc audio should be delayed.
  /// (both positive & negative value appliable)
  Future<void> setAudioDelay(int audioDelay) async {
    await _initCompleter.future;
    _throwIfNotInitialized('setAudioDelay');
    value = value.copyWith(audioDelay: audioDelay);
    return VlcPlayerPlatform.instance.setAudioDelay(_viewId, audioDelay);
  }

  /// Returns the amount of audio track time delay in millisecond.
  Future<int?> getAudioDelay() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getAudioDelay');
    final audioDelay = await VlcPlayerPlatform.instance.getAudioDelay(_viewId);
    value = value.copyWith(audioDelay: audioDelay);
    return audioDelay;
  }

  /// Add extra network audio to media.
  /// [dataSource] - Url of audio
  /// [isSelected] - Set true if you wanna force the added audio to start playing on media.
  Future<void> addAudioFromNetwork(
    String dataSource, {
    bool? isSelected,
  }) async {
    return _addAudioTrack(
      dataSource,
      dataSourceType: DataSourceType.network,
      isSelected: isSelected ?? true,
    );
  }

  /// Add extra audio file to media.
  /// [file] - Audio file
  /// [isSelected] - Set true if you wanna force the added audio to start playing on media.
  Future<void> addAudioFromFile(File file, {bool? isSelected}) async {
    return _addAudioTrack(
      'file://${file.path}',
      dataSourceType: DataSourceType.file,
      isSelected: isSelected ?? true,
    );
  }

  /// Add extra audio to media.
  /// [uri] - URI of audio
  /// [isSelected] - Set true if you wanna force the added audio to start playing on media.
  Future<void> _addAudioTrack(
    String uri, {
    required DataSourceType dataSourceType,
    bool? isSelected,
  }) async {
    await _initCompleter.future;
    _throwIfNotInitialized('addAudioTrack');
    return VlcPlayerPlatform.instance.addAudioTrack(
      _viewId,
      uri: uri,
      type: dataSourceType,
      isSelected: isSelected ?? true,
    );
  }

  /// Returns the number of video tracks
  Future<int?> getVideoTracksCount() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getVideoTracksCount');
    final videoTracksCount = await VlcPlayerPlatform.instance
        .getVideoTracksCount(_viewId);
    value = value.copyWith(videoTracksCount: videoTracksCount);
    return videoTracksCount;
  }

  /// Returns all video tracks as array of <Int, String>
  /// The key parameter is the index of video track and the value is the display name of video track
  Future<Map<int, String>> getVideoTracks() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getVideoTracks');
    return VlcPlayerPlatform.instance.getVideoTracks(_viewId);
  }

  /// Change active video track index.
  /// [videoTrackNumber] - the video track index obtained from getVideoTracks()
  Future<void> setVideoTrack(int videoTrackNumber) async {
    await _initCompleter.future;
    _throwIfNotInitialized('setVideoTrack');
    return VlcPlayerPlatform.instance.setVideoTrack(_viewId, videoTrackNumber);
  }

  /// Returns active video track index
  Future<int?> getVideoTrack() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getVideoTrack');
    final activeVideoTrack = await VlcPlayerPlatform.instance.getVideoTrack(
      _viewId,
    );
    value = value.copyWith(activeVideoTrack: activeVideoTrack);
    return activeVideoTrack;
  }

  /// [scale] - the video scale value
  /// Set video scale
  Future<void> setVideoScale(double videoScale) async {
    await _initCompleter.future;
    _throwIfNotInitialized('setVideoScale');
    value = value.copyWith(videoScale: videoScale);
    return VlcPlayerPlatform.instance.setVideoScale(_viewId, videoScale);
  }

  /// Returns video scale
  Future<double?> getVideoScale() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getVideoScale');
    final videoScale = await VlcPlayerPlatform.instance.getVideoScale(_viewId);
    value = value.copyWith(videoScale: videoScale);
    return videoScale;
  }

  /// [aspectRatio] - the video aspect ratio like "16:9"
  ///
  /// Set video aspect ratio
  Future<void> setVideoAspectRatio(String aspectRatio) async {
    await _initCompleter.future;
    _throwIfNotInitialized('setVideoAspectRatio');
    return VlcPlayerPlatform.instance.setVideoAspectRatio(_viewId, aspectRatio);
  }

  /// Returns video aspect ratio in string format
  ///
  /// This is different from the aspectRatio property in video value "16:9"
  Future<String?> getVideoAspectRatio() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getVideoAspectRatio');
    return VlcPlayerPlatform.instance.getVideoAspectRatio(_viewId);
  }

  /// Returns binary data for a snapshot of the media at the current frame.
  ///
  Future<Uint8List> takeSnapshot() async {
    await _initCompleter.future;
    _throwIfNotInitialized('takeSnapshot');
    return VlcPlayerPlatform.instance.takeSnapshot(_viewId);
  }

  /// Get list of available renderer services which is supported by vlc library
  Future<List<String>> getAvailableRendererServices() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getAvailableRendererServices');
    return VlcPlayerPlatform.instance.getAvailableRendererServices(_viewId);
  }

  /// Start vlc cast discovery to find external display devices (chromecast)
  /// By setting serviceName, the vlc discovers renderer with that service
  Future<void> startRendererScanning({String? rendererService}) async {
    await _initCompleter.future;
    _throwIfNotInitialized('startRendererScanning');
    return VlcPlayerPlatform.instance.startRendererScanning(
      _viewId,
      rendererService: rendererService ?? '',
    );
  }

  /// Stop vlc cast and scan
  Future<void> stopRendererScanning() async {
    await _initCompleter.future;
    _throwIfNotInitialized('stopRendererScanning');
    return VlcPlayerPlatform.instance.stopRendererScanning(_viewId);
  }

  /// Returns all detected renderer devices as array of <String, String>
  /// The key parameter is the name of cast device and the value is the display name of cast device
  Future<Map<String, String>> getRendererDevices() async {
    await _initCompleter.future;
    _throwIfNotInitialized('getRendererDevices');
    return VlcPlayerPlatform.instance.getRendererDevices(_viewId);
  }

  /// [castDevice] - name of renderer device
  /// Start vlc video casting to the selected device.
  /// Set null if you wanna stop video casting.
  Future<void> castToRenderer(String castDevice) async {
    await _initCompleter.future;
    _throwIfNotInitialized('castToRenderer');
    return VlcPlayerPlatform.instance.castToRenderer(_viewId, castDevice);
  }

  /// [saveDirectory] - directory path of the recorded file
  /// Returns true if media is start recording.
  Future<bool?> startRecording(String saveDirectory) async {
    await _initCompleter.future;
    _throwIfNotInitialized('startRecording');
    return VlcPlayerPlatform.instance.startRecording(_viewId, saveDirectory);
  }

  /// Returns true if media is stop recording.
  Future<bool?> stopRecording() async {
    await _initCompleter.future;
    _throwIfNotInitialized('stopRecording');
    return VlcPlayerPlatform.instance.stopRecording(_viewId);
  }

  /// [functionName] - name of function
  /// throw exception if vlc player controller is not initialized
  void _throwIfNotInitialized(String functionName) {
    if (!value.isInitialized) {
      throw Exception(
        '$functionName() was called on an uninitialized VlcPlayerController.',
      );
    }
    if (_isDisposed) {
      throw Exception(
        '$functionName() was called on a disposed VlcPlayerController.',
      );
    }
  }

  /// Dispose controller
  @override
  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    _onInitListeners.clear();
    _onRendererEventListeners.clear();
    _lifeCycleObserver?.dispose();

    await VlcPlayerPlatform.instance.dispose(_viewId);
    super.dispose();
  }
}

/// RendererCallback
typedef RendererCallback = void Function(VlcRendererEventType, String, String);
