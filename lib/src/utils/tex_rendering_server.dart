import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/src/models/rendering_engine.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class TeXRederingServer {
  static RenderingEngineCallback? onPageFinished,
      onTapCallback,
      onTeXViewRenderedCallback;
  static WebViewControllerPlus controller = WebViewControllerPlus();
  static TeXViewRenderingEngine renderingEngine =
      const TeXViewRenderingEngine.mathjax();

  static LocalhostServer localhostServer = LocalhostServer();

  static Future<void> run({int port = 0}) async {
    await localhostServer.start(port: port);
  }

  static Future<void> initController() async {
    var controllerCompleter = Completer<void>();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadFlutterAssetWithServer(
          "packages/flutter_tex/js/${renderingEngine.name}/index.html",
          localhostServer.port!)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            onPageFinished?.call(url);
            controllerCompleter.complete();
          },
        ),
      )
      ..setOnConsoleMessage(
        (message) {
          if (kDebugMode) {
            print(message.message);
          }
        },
      )
      ..addJavaScriptChannel(
        'OnTapCallback',
        onMessageReceived: (onTapCallbackMessage) {
          onTapCallback?.call(onTapCallbackMessage.message);
        },
      )
      ..addJavaScriptChannel(
        'TeXViewRenderedCallback',
        onMessageReceived: (teXViewRenderedCallbackMessage) {
          onTeXViewRenderedCallback
              ?.call(teXViewRenderedCallbackMessage.message);
        },
      );

    return controllerCompleter.future;
  }

  static Future<void> stop() async {
    await localhostServer.close();
  }
}

typedef RenderingEngineCallback = void Function(String message);
