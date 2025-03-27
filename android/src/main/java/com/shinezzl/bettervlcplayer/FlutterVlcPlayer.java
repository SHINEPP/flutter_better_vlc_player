package com.shinezzl.bettervlcplayer;

import android.content.Context;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.util.Log;
import android.view.Surface;

import com.shinezzl.bettervlcplayer.Enums.HwAcc;

import org.videolan.libvlc.LibVLC;
import org.videolan.libvlc.Media;
import org.videolan.libvlc.MediaPlayer;
import org.videolan.libvlc.RendererDiscoverer;
import org.videolan.libvlc.RendererItem;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry.SurfaceTextureEntry;

final class FlutterVlcPlayer {

    private final String TAG = this.getClass().getSimpleName();

    private static final String CHANNEL_VIDEO_EVENTS = "flutter_video_plugin/getVideoEvents_";
    private static final String CHANNEL_RENDERER_EVENTS = "flutter_video_plugin/getRendererEvents_";

    private final Context context;
    private final SurfaceTextureEntry textureEntry;

    private final QueuingEventSink mediaEventSink = new QueuingEventSink();
    private final EventChannel mediaEventChannel;

    private final QueuingEventSink rendererEventSink = new QueuingEventSink();
    private final EventChannel rendererEventChannel;

    private final List<String> options;
    private LibVLC libVLC;
    private MediaPlayer mediaPlayer;
    private List<RendererDiscoverer> rendererDiscoverers = new ArrayList<>();
    private List<RendererItem> rendererItems = new ArrayList<>();
    private boolean isDisposed = false;

    // VLC Player
    FlutterVlcPlayer(Context context, SurfaceTextureEntry texture, BinaryMessenger binaryMessenger, List<String> options) {
        this.context = context;
        this.options = options;

        // event for media
        mediaEventChannel = new EventChannel(binaryMessenger, CHANNEL_VIDEO_EVENTS + texture.id());
        mediaEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink sink) {
                mediaEventSink.setDelegate(sink);
            }

            @Override
            public void onCancel(Object o) {
                mediaEventSink.setDelegate(null);
            }
        });

        // event for renderer
        rendererEventChannel = new EventChannel(binaryMessenger, CHANNEL_RENDERER_EVENTS + texture.id());
        rendererEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink sink) {
                rendererEventSink.setDelegate(sink);
            }

            @Override
            public void onCancel(Object o) {
                rendererEventSink.setDelegate(null);
            }
        });

        // textureView
        textureEntry = texture;

        libVLC = new LibVLC(context, options);
        mediaPlayer = new MediaPlayer(libVLC);
        //mediaPlayer.getVLCVout().setWindowSize(textureView.getWidth(), textureView.getHeight());
        mediaPlayer.getVLCVout().setVideoSurface(textureEntry.surfaceTexture());
        mediaPlayer.getVLCVout().attachViews();
        //mediaPlayer.setVideoTrackEnabled(true);
        mediaPlayer.setEventListener(this::handleMediaPlayerEvent);
    }

    public long getTextureId() {
        return textureEntry.id();
    }

    private void handleMediaPlayerEvent(MediaPlayer.Event event) {
        HashMap<String, Object> eventObject = new HashMap<>();

        // Current video track is only available when the media is playing
        int height = 0;
        int width = 0;
        Media.VideoTrack currentVideoTrack = mediaPlayer.getCurrentVideoTrack();
        if (currentVideoTrack != null) {
            height = currentVideoTrack.height;
            width = currentVideoTrack.width;
        }

        switch (event.type) {
            case MediaPlayer.Event.Opening:
                eventObject.put("event", "opening");
                mediaEventSink.success(eventObject);
                break;

            case MediaPlayer.Event.Paused:
                eventObject.put("event", "paused");
                mediaEventSink.success(eventObject);
                break;

            case MediaPlayer.Event.Stopped:
                eventObject.put("event", "stopped");
                mediaEventSink.success(eventObject);
                break;

            case MediaPlayer.Event.Playing:
                eventObject.put("event", "playing");
                eventObject.put("height", height);
                eventObject.put("width", width);
                eventObject.put("speed", mediaPlayer.getRate());
                eventObject.put("duration", mediaPlayer.getLength());
                eventObject.put("audioTracksCount", mediaPlayer.getAudioTracksCount());
                eventObject.put("activeAudioTrack", mediaPlayer.getAudioTrack());
                eventObject.put("spuTracksCount", mediaPlayer.getSpuTracksCount());
                eventObject.put("activeSpuTrack", mediaPlayer.getSpuTrack());
                mediaEventSink.success(eventObject.clone());
                break;

            case MediaPlayer.Event.Vout:
                // mediaPlayer.getVLCVout().setWindowSize(textureView.getWidth(), textureView.getHeight());
                break;

            case MediaPlayer.Event.EndReached:
                eventObject.put("event", "ended");
                eventObject.put("position", mediaPlayer.getTime());
                mediaEventSink.success(eventObject);
                break;

            case MediaPlayer.Event.Buffering:
            case MediaPlayer.Event.TimeChanged:
                eventObject.put("event", "timeChanged");
                eventObject.put("height", height);
                eventObject.put("width", width);
                eventObject.put("speed", mediaPlayer.getRate());
                eventObject.put("position", mediaPlayer.getTime());
                eventObject.put("duration", mediaPlayer.getLength());
                eventObject.put("buffer", event.getBuffering());
                eventObject.put("audioTracksCount", mediaPlayer.getAudioTracksCount());
                eventObject.put("activeAudioTrack", mediaPlayer.getAudioTrack());
                eventObject.put("spuTracksCount", mediaPlayer.getSpuTracksCount());
                eventObject.put("activeSpuTrack", mediaPlayer.getSpuTrack());
                eventObject.put("isPlaying", mediaPlayer.isPlaying());
                mediaEventSink.success(eventObject);
                break;

            case MediaPlayer.Event.EncounteredError:
                eventObject.put("event", "error");
                mediaEventSink.success(eventObject);
                break;

            case MediaPlayer.Event.RecordChanged:
                eventObject.put("event", "recording");
                eventObject.put("isRecording", event.getRecording());
                eventObject.put("recordPath", event.getRecordPath());
                mediaEventSink.success(eventObject);
                break;

            case MediaPlayer.Event.LengthChanged:
            case MediaPlayer.Event.MediaChanged:
            case MediaPlayer.Event.ESAdded:
            case MediaPlayer.Event.ESDeleted:
            case MediaPlayer.Event.ESSelected:
            case MediaPlayer.Event.PausableChanged:
            case MediaPlayer.Event.SeekableChanged:
            case MediaPlayer.Event.PositionChanged:
            default:
                break;
        }
    }

    void play() {
        if (mediaPlayer != null && !mediaPlayer.isPlaying()) {
            mediaPlayer.play();
        }
    }

    void pause() {
        if (mediaPlayer != null && mediaPlayer.isPlaying()) {
            mediaPlayer.pause();
        }
    }

    void stop() {
        if (mediaPlayer != null) {
            mediaPlayer.stop();
        }
    }

    boolean isPlaying() {
        return mediaPlayer != null && mediaPlayer.isPlaying();
    }

    boolean isSeekable() {
        if (mediaPlayer == null) return false;
        return mediaPlayer.isSeekable();
    }

    void setStreamUrl(String url, boolean isAssetUrl, boolean autoPlay, long hwAcc) {
        if (mediaPlayer == null) {
            return;
        }
        Log.d(TAG, "setStreamUrl(), url = " + url);

        try {
            if (mediaPlayer.isPlaying()) {
                mediaPlayer.stop();
            }
            Media media = null;
            if (isAssetUrl) {
                media = new Media(libVLC, context.getAssets().openFd(url));
            } else if (url.startsWith("content://")) {
                try (ParcelFileDescriptor p = context.getContentResolver().openFileDescriptor(Uri.parse(url), "r")) {
                    if (p != null) {
                        media = new Media(libVLC, p.getFileDescriptor());
                    }
                } catch (Exception e) {
                    Log.e(TAG, "setStreamUrl(), e = " + e);
                }
            } else {
                media = new Media(libVLC, Uri.parse(url));
            }
            if (media == null) {
                return;
            }

            final HwAcc hwAccValue = HwAcc.values()[(int) hwAcc];
            switch (hwAccValue) {
                case DISABLED:
                    media.setHWDecoderEnabled(false, false);
                    break;
                case DECODING:
                case FULL:
                    media.setHWDecoderEnabled(true, true);
                    break;
            }
            if (hwAccValue == HwAcc.DECODING) {
                media.addOption(":no-mediacodec-dr");
                media.addOption(":no-omxil-dr");
            }
            if (options != null) {
                for (String option : options) {
                    media.addOption(option);
                }
            }
            mediaPlayer.setMedia(media);
            media.release();

            if (autoPlay) {
                mediaPlayer.play();
            }
        } catch (Throwable e) {
            Log.e(TAG, "setStreamUrl(), e = " + e);
        }
    }

    void setLooping(boolean value) {
        if (mediaPlayer != null && mediaPlayer.getMedia() != null) {
            mediaPlayer.getMedia().addOption(value ? "--loop" : "--no-loop");
        }
    }

    void setVolume(long value) {
        if (mediaPlayer == null) {
            return;
        }
        long bracketedValue = Math.max(0, Math.min(100, value));
        mediaPlayer.setVolume((int) bracketedValue);
    }

    int getVolume() {
        if (mediaPlayer == null) {
            return -1;
        }
        return mediaPlayer.getVolume();
    }

    void setPlaybackSpeed(double value) {
        if (mediaPlayer == null) {
            return;
        }
        mediaPlayer.setRate((float) value);
    }

    float getPlaybackSpeed() {
        if (mediaPlayer == null) {
            return -1.0f;
        }
        return mediaPlayer.getRate();
    }

    void seekTo(int location) {
        if (mediaPlayer == null) {
            return;
        }
        mediaPlayer.setTime(location);
    }

    long getPosition() {
        if (mediaPlayer == null) {
            return -1;
        }
        return mediaPlayer.getTime();
    }

    long getDuration() {
        if (mediaPlayer == null) {
            return -1;
        }
        return mediaPlayer.getLength();
    }

    int getSpuTracksCount() {
        if (mediaPlayer == null) {
            return -1;
        }
        return mediaPlayer.getSpuTracksCount();
    }

    HashMap<Integer, String> getSpuTracks() {
        if (mediaPlayer == null) {
            return new HashMap<>();
        }
        MediaPlayer.TrackDescription[] spuTracks = mediaPlayer.getSpuTracks();
        HashMap<Integer, String> subtitles = new HashMap<>();
        if (spuTracks != null) {
            for (MediaPlayer.TrackDescription trackDescription : spuTracks) {
                if (trackDescription.id >= 0)
                    subtitles.put(trackDescription.id, trackDescription.name);
            }
        }
        return subtitles;
    }

    void setSpuTrack(int index) {
        if (mediaPlayer == null) {
            return;
        }
        mediaPlayer.setSpuTrack(index);
    }

    int getSpuTrack() {
        if (mediaPlayer == null) {
            return -1;
        }
        return mediaPlayer.getSpuTrack();
    }

    void setSpuDelay(long delay) {
        if (mediaPlayer == null) {
            return;
        }
        mediaPlayer.setSpuDelay(delay);
    }

    long getSpuDelay() {
        if (mediaPlayer == null) {
            return -1;
        }
        return mediaPlayer.getSpuDelay();
    }

    void addSubtitleTrack(String url, boolean isSelected) {
        if (mediaPlayer == null) {
            return;
        }
        mediaPlayer.addSlave(Media.Slave.Type.Subtitle, Uri.parse(url), isSelected);
    }

    int getAudioTracksCount() {
        if (mediaPlayer == null) {
            return -1;
        }
        return mediaPlayer.getAudioTracksCount();
    }

    HashMap<Integer, String> getAudioTracks() {
        if (mediaPlayer == null) {
            return new HashMap<>();
        }
        MediaPlayer.TrackDescription[] audioTracks = mediaPlayer.getAudioTracks();
        HashMap<Integer, String> audios = new HashMap<>();
        if (audioTracks != null) {
            for (MediaPlayer.TrackDescription trackDescription : audioTracks) {
                if (trackDescription.id >= 0)
                    audios.put(trackDescription.id, trackDescription.name);
            }
        }
        return audios;
    }

    void setAudioTrack(int index) {
        if (mediaPlayer == null) {
            return;
        }
        mediaPlayer.setAudioTrack(index);
    }

    int getAudioTrack() {
        if (mediaPlayer == null) {
            return -1;
        }
        return mediaPlayer.getAudioTrack();
    }

    void setAudioDelay(long delay) {
        if (mediaPlayer == null) {
            return;
        }
        mediaPlayer.setAudioDelay(delay);
    }

    long getAudioDelay() {
        if (mediaPlayer == null) {
            return -1;
        }
        return mediaPlayer.getAudioDelay();
    }

    void addAudioTrack(String url, boolean isSelected) {
        if (mediaPlayer == null) {
            return;
        }
        mediaPlayer.addSlave(Media.Slave.Type.Audio, Uri.parse(url), isSelected);
    }

    int getVideoTracksCount() {
        if (mediaPlayer == null) {
            return -1;
        }
        return mediaPlayer.getVideoTracksCount();
    }

    HashMap<Integer, String> getVideoTracks() {
        if (mediaPlayer == null) {
            return new HashMap<>();
        }
        MediaPlayer.TrackDescription[] videoTracks = mediaPlayer.getVideoTracks();
        HashMap<Integer, String> videos = new HashMap<>();
        if (videoTracks != null) {
            for (MediaPlayer.TrackDescription trackDescription : videoTracks) {
                if (trackDescription.id >= 0)
                    videos.put(trackDescription.id, trackDescription.name);
            }
        }
        return videos;
    }

    void setVideoTrack(int index) {
        if (mediaPlayer == null) {
            return;
        }
        mediaPlayer.setVideoTrack(index);
    }

    int getVideoTrack() {
        if (mediaPlayer == null) {
            return -1;
        }
        return mediaPlayer.getVideoTrack();
    }

    void setVideoScale(float scale) {
        if (mediaPlayer == null) {
            return;
        }
        mediaPlayer.setScale(scale);
    }

    float getVideoScale() {
        if (mediaPlayer == null) {
            return -1.0f;
        }
        return mediaPlayer.getScale();
    }

    void setVideoAspectRatio(String aspectRatio) {
        if (mediaPlayer == null) {
            return;
        }
        mediaPlayer.setAspectRatio(aspectRatio);
    }

    String getVideoAspectRatio() {
        if (mediaPlayer == null) {
            return "";
        }
        return mediaPlayer.getAspectRatio();
    }

    void startRendererScanning(String rendererService) {
        if (libVLC == null) {
            return;
        }

        //  android -> chromecast -> "microdns"
        //  ios -> chromecast -> "Bonjour_renderer"
        rendererDiscoverers = new ArrayList<>();
        rendererItems = new ArrayList<>();
        //
        //todo: check for duplicates
        RendererDiscoverer.Description[] renderers = RendererDiscoverer.list(libVLC);
        for (RendererDiscoverer.Description renderer : renderers) {
            RendererDiscoverer rendererDiscoverer = new RendererDiscoverer(libVLC, renderer.name);
            try {
                rendererDiscoverer.setEventListener(event -> {
                    HashMap<String, Object> eventObject = new HashMap<>();
                    RendererItem item = event.getItem();
                    switch (event.type) {
                        case RendererDiscoverer.Event.ItemAdded:
                            rendererItems.add(item);
                            eventObject.put("event", "attached");
                            eventObject.put("id", item.name);
                            eventObject.put("name", item.displayName);
                            rendererEventSink.success(eventObject);
                            break;

                        case RendererDiscoverer.Event.ItemDeleted:
                            rendererItems.remove(item);
                            eventObject.put("event", "detached");
                            eventObject.put("id", item.name);
                            eventObject.put("name", item.displayName);
                            rendererEventSink.success(eventObject);
                            break;

                        default:
                            break;
                    }
                });
                rendererDiscoverer.start();
                rendererDiscoverers.add(rendererDiscoverer);
            } catch (Exception ex) {
                rendererDiscoverer.setEventListener(null);
            }
        }
    }

    void stopRendererScanning() {
        if (mediaPlayer == null) {
            return;
        }

        if (isDisposed) {
            return;
        }

        for (RendererDiscoverer rendererDiscoverer : rendererDiscoverers) {
            rendererDiscoverer.stop();
            rendererDiscoverer.setEventListener(null);
        }
        rendererDiscoverers.clear();
        rendererItems.clear();

        // return back to default output
        if (mediaPlayer != null) {
            mediaPlayer.pause();
            mediaPlayer.setRenderer(null);
            mediaPlayer.play();
        }
    }

    ArrayList<String> getAvailableRendererServices() {
        if (libVLC == null) {
            return new ArrayList<>();
        }
        RendererDiscoverer.Description[] renderers = RendererDiscoverer.list(libVLC);
        ArrayList<String> availableRendererServices = new ArrayList<>();
        for (RendererDiscoverer.Description renderer : renderers) {
            availableRendererServices.add(renderer.name);
        }
        return availableRendererServices;
    }

    HashMap<String, String> getRendererDevices() {
        HashMap<String, String> renderers = new HashMap<>();
        if (rendererItems != null) {
            for (RendererItem rendererItem : rendererItems) {
                renderers.put(rendererItem.name, rendererItem.displayName);
            }
        }
        return renderers;
    }

    void castToRenderer(String rendererDevice) {
        if (mediaPlayer == null) {
            return;
        }
        if (isDisposed) {
            return;
        }

        if (mediaPlayer.isPlaying()) {
            mediaPlayer.pause();
        }

        // if you set it to null, it will start to render normally (i.e. locally) again
        RendererItem rendererItem = null;
        for (RendererItem item : rendererItems) {
            if (item.name.equals(rendererDevice)) {
                rendererItem = item;
                break;
            }
        }
        mediaPlayer.setRenderer(rendererItem);

        // start the playback
        mediaPlayer.play();
    }

    String getSnapshot() {
        return "";
    }

    Boolean startRecording(String directory) {
        return mediaPlayer.record(directory);
    }

    Boolean stopRecording() {
        if (mediaPlayer == null) {
            return true;
        }
        return mediaPlayer.record(null);
    }

    public void dispose() {
        if (isDisposed) {
            return;
        }
        isDisposed = true;

        textureEntry.release();

        mediaEventChannel.setStreamHandler(null);
        rendererEventChannel.setStreamHandler(null);
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.setEventListener(null);
            mediaPlayer.getVLCVout().detachViews();
            mediaPlayer.release();
            mediaPlayer = null;
        }
        if (libVLC != null) {
            libVLC.release();
            libVLC = null;
        }
    }
}
