import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:flutter_tex/src/utils/core_utils.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class TeXViewState extends State<TeXView> {
  final WebViewControllerPlus _controller = TeXRederingServer.controller;

  double _height = defaultHeight;
  String _lastData = "";

  @override
  void initState() {
    TeXRederingServer.onTeXViewRenderedCallback =
        (teXViewRenderedCallbackMessage) async {
      double newHeight = double.parse(teXViewRenderedCallbackMessage);
      if (_height != newHeight) {
        setState(() {
          _height = newHeight;
        });
      }
      widget.onRenderFinished?.call(_height);
    };

    TeXRederingServer.onTapCallback = (tapCallbackMessage) {
      widget.child.onTapCallback(tapCallbackMessage);
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _renderTeXView();
    return IndexedStack(
      index: widget.loadingWidgetBuilder?.call(context) != null
          ? _height == defaultHeight
              ? 1
              : 0
          : 0,
      children: <Widget>[
        SizedBox(
          height: _height,
          child: WebViewWidget(
            controller: _controller,
          ),
        ),
        widget.loadingWidgetBuilder?.call(context) ?? const SizedBox.shrink()
      ],
    );
  }

  void _renderTeXView() {
    var rawData = getRawData(widget);
    if (rawData != _lastData) {
      if (widget.loadingWidgetBuilder != null) _height = defaultHeight;
      _controller.runJavaScriptReturningResult("initView($rawData)");
      _lastData = rawData;
    }
  }
}
