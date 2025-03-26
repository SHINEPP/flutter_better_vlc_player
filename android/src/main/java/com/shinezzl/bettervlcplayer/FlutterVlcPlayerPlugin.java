package com.shinezzl.bettervlcplayer;


import androidx.annotation.NonNull;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

public class FlutterVlcPlayerPlugin implements FlutterPlugin, ActivityAware {

    private static final String VIEW_TYPE = "flutter_video_plugin/getVideoView";

    private static FlutterVlcPlayerFactory playerFactory;
    private FlutterPluginBinding pluginBinding;

    public FlutterVlcPlayerPlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        pluginBinding = binding;

        if (playerFactory == null) {
            final FlutterInjector injector = FlutterInjector.instance();
            playerFactory = new FlutterVlcPlayerFactory(
                    pluginBinding.getBinaryMessenger(),
                    pluginBinding.getTextureRegistry(),
                    injector.flutterLoader()::getLookupKeyForAsset,
                    injector.flutterLoader()::getLookupKeyForAsset);
            pluginBinding.getPlatformViewRegistry()
                    .registerViewFactory(VIEW_TYPE, playerFactory);
        }
        startListening();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        stopListening();
        pluginBinding = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivity() {
    }

    private static void startListening() {
        if (playerFactory != null) {
            playerFactory.startListening();
        }
    }

    private static void stopListening() {
        if (playerFactory != null) {
            playerFactory.stopListening();
            playerFactory = null;
        }
    }
}
