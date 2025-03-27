package com.shinezzl.bettervlcplayer;


import androidx.annotation.NonNull;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

public class BetterVlcPlayerPlugin implements FlutterPlugin, ActivityAware {

    private VlcPlayerCreator playerCreator;

    public BetterVlcPlayerPlugin() {
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        if (playerCreator == null) {
            final FlutterInjector injector = FlutterInjector.instance();
            playerCreator = new VlcPlayerCreator(binding.getApplicationContext(),
                    binding.getBinaryMessenger(),
                    binding.getTextureRegistry(),
                    injector.flutterLoader()::getLookupKeyForAsset,
                    injector.flutterLoader()::getLookupKeyForAsset);
        }
        playerCreator.startListening();
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
        if (playerCreator != null) {
            playerCreator.stopListening();
            playerCreator = null;
        }
    }
}
