import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tex/src/models/rendering_engine.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class TeXRederingServer {
  static HttpServer? server;
  static RenderingEngineCallback? onPageFinished,
      onTapCallback,
      onTeXViewRenderedCallback;
  static WebViewControllerPlus controller = WebViewControllerPlus();
  static TeXViewRenderingEngine renderingEngine =
      const TeXViewRenderingEngine.katex();

  static Future<void> run({int port = 0}) async {
    await LocalHostServer.start(port: port);
    server = LocalHostServer.server;
  }

  static Future<void> initController() async {
    var completer = Completer<void>();

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadFlutterAssetWithServer(
          "packages/flutter_tex/js/${renderingEngine.name}/index.html",
          server!.port)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            onPageFinished?.call(url);
            completer.complete();
          },
        ),
      )
      ..setOnConsoleMessage(
        (message) {
          if (kDebugMode) {
            print(message);
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
        onMessageReceived: (teXViewRenderedCallbackMessage) async {
          onTeXViewRenderedCallback
              ?.call(teXViewRenderedCallbackMessage.message);
        },
      );

    return completer.future;
  }

  static Future<void> stop() async {
    await LocalHostServer.close();
  }
}

typedef RenderingEngineCallback = void Function(String message);
