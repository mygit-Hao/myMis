package com.waiminggroup.mis_app;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
//import io.flutter.plugins.localauth.LocalAuthPlugin;

import androidx.annotation.NonNull;

public class MainActivity extends FlutterFragmentActivity {
    // TODO(bparrishMines): Remove this once v2 of GeneratedPluginRegistrant rolls to stable. https://github.com/flutter/flutter/issues/42694
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        //GeneratedPluginRegistrant.registerWith(flutterEngine);
        //flutterEngine.getPlugins().add(new LocalAuthPlugin());
    }
}