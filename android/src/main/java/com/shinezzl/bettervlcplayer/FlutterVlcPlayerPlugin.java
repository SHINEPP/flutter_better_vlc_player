package com.shinezzl.bettervlcplayer;


import androidx.annotation.NonNull;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

public class FlutterVlcPlayerPlugin implements FlutterPlugin, ActivityAware {

    private FlutterVlcPlayerBuilder playerBuilder;

    public FlutterVlcPlayerPlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        if (playerBuilder == null) {
            final FlutterInjector injector = FlutterInjector.instance();
            playerBuilder = new FlutterVlcPlayerBuilder(binding.getApplicationContext(),
                    binding.getBinaryMessenger(),
                    binding.getTextureRegistry(),
                    injector.flutterLoader()::getLookupKeyForAsset,
                    injector.flutterLoader()::getLookupKeyForAsset);
        }
        playerBuilder.startListening();
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onDetachedFromActivity() {
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (playerBuilder != null) {
            playerBuilder.stopListening();
            playerBuilder = null;
        }
    }
}
