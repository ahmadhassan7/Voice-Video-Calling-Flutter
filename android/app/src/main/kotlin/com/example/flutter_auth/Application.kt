package com.bimeta.chat

import io.flutter.app.FlutterApplication

import io.flutter.app.FlutterActivity

import io.flutter.plugin.common.PluginRegistry

import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback

import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService



import com.github.cloudwebrtc.flutter_callkeep.FlutterCallkeepPlugin


class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
                FlutterFirebaseMessagingService.setPluginRegistrant(this);
    }

    override fun registerWith(pluginRegistry: PluginRegistry) {
        FirebaseMessagingPlugin.registerWith(pluginRegistry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
        FlutterCallkeepPlugin.registerWith(pluginRegistry.registrarFor("com.github.cloudwebrtc.flutter_callkeep.FlutterCallkeepPlugin"))
    }
}