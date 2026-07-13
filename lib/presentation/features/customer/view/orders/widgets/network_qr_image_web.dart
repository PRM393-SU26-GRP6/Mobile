import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

class NetworkQrImage extends StatefulWidget {
  const NetworkQrImage({super.key, required this.url});

  final String url;

  @override
  State<NetworkQrImage> createState() => _NetworkQrImageState();
}

class _NetworkQrImageState extends State<NetworkQrImage> {
  static final Set<String> _registeredViewTypes = <String>{};
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'sepay-qr-${widget.url.hashCode}';
    if (_registeredViewTypes.add(_viewType)) {
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
        return web.HTMLImageElement()
          ..src = widget.url
          ..alt = 'SePay payment QR'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'contain';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(
      key: const Key('sepay-network-qr'),
      viewType: _viewType,
    );
  }
}
